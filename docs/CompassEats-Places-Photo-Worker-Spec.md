# CompassEats — Owner-Filtered Places Live-Photo Worker

**What this is:** a build + decision spec for a small Cloudflare Worker that serves a real, owner-uploaded Google Places photo for venues that don't have a curated photo of their own — live, at request time. Hand this to a developer or to Lovable.

**Status:** spec only. Not built. Read the **Cost** and **Recommendation** sections before deciding to build it — the economics changed from earlier framing and matter to the decision.

---

## TL;DR

- The venue page's photo points at a CompassEats URL (`/api/venue-photo/{placeId}`). When a browser loads it, the Worker asks Google for that venue's photos, picks the **owner/business-uploaded** one (the good ones), and redirects the browser to it.
- Owner photos are identified by an **empty `authorAttributions`** field — that's the signal you spotted that separates the good owner shots from random diner phone pics. A size/shape guard skips logos.
- **It can't be cached** (Google's terms), so every photo view costs **~$0.025–0.027** after the free tier: one Place Details call + one Place Photo call. Free to ~1,000 photo-views/month; ~$240/month at 10k; ~$1,300/month at 50k. The cost grows with traffic and can't be brought down by caching.
- **Recommendation:** build it but deploy it *selectively*, put hard spend caps on the Google project, and keep using free curated/Commons photos + the compass on your highest-traffic pages. At today's traffic it's basically free; the concern is purely at scale.

---

## Where the Worker fits — the cascade

Every venue page resolves its photo in this order:

1. **Curated photo** (Wikimedia CC / Unsplash / venue-provided), hosted on your Cloudflare R2 — free, best quality, fully yours. Use this for the marquee tier.
2. **Owner-filtered Places live photo** — *this Worker*. A real photo of the venue, served live from Google. Per-view cost. Can't be hosted.
3. **Compass fallback** — the on-brand placeholder, reserved for genuinely obscure venues with neither of the above.

The Worker is **step 2 only**. It's the engine that puts a real photo on the ~10,000 venues you'll never curate by hand.

---

## How it works (plain language)

```
Browser loads venue page
        │
        ▼
 <img src="https://compasseats.com/api/venue-photo/PLACE_ID">
        │
        ▼
 Cloudflare Worker
   1. Calls Google Place Details for PLACE_ID, asking only for "photos"
   2. Looks through the returned photo list
   3. Picks the first OWNER photo (empty authorAttributions) that is
      landscape and reasonably large (skips logos / portraits)
   4. Calls Google Place Photo to turn that into a real image URL
   5. Returns a 302 redirect to that image URL
        │
        ▼
 Browser loads the actual photo straight from Google's image servers
```

If there's no owner photo, the Worker returns a "no photo" signal and the page shows the compass instead (it does **not** fall back to a random diner photo).

---

## The owner-photo filter (the core logic)

Google's photo objects include an `authorAttributions` array. Based on our review of real venues:

- **Owner/business-uploaded photos** generally come back with an **empty** `authorAttributions` — these are the polished, on-brand shots.
- **User-uploaded photos** carry a named credit (a person's display name + profile link) — these are the hit-or-miss phone pics.

So the selection rule is:

1. From the photo list, keep only photos where `authorAttributions` is **empty or missing**.
2. Among those, prefer ones that are **landscape** (`widthPx > heightPx`) and **at least ~1200px wide** — this skips square logos and tall portrait shots.
3. Pick the first that qualifies. If none qualify the size/shape guard, fall back to the first empty-attribution photo regardless.
4. If there is **no** empty-attribution photo at all → return "no photo" (page shows compass).

This empty-attribution filter does double duty: it gets the good photos **and** keeps attribution simple (see Compliance).

> Note: empty attribution is a *strong* proxy for "owner-uploaded," not a guarantee — Google exposes no explicit owner flag. In practice it reliably surfaces the better photos. You can tune the size thresholds after seeing results.

---

## Technical detail (for the developer)

### Call 1 — Place Details (New), to get the photo list

```
GET https://places.googleapis.com/v1/places/{PLACE_ID}
Headers:
  X-Goog-Api-Key: {RESTRICTED_KEY}
  X-Goog-FieldMask: id,photos
```

Use the **minimal field mask `id,photos`** — anything extra raises the bill to a higher tier. The response includes:

```jsonc
{
  "id": "...",
  "photos": [
    {
      "name": "places/PLACE_ID/photos/PHOTO_RESOURCE",
      "widthPx": 4032,
      "heightPx": 3024,
      "authorAttributions": []          // empty → owner photo
    },
    {
      "name": "places/PLACE_ID/photos/OTHER_RESOURCE",
      "widthPx": 3000,
      "heightPx": 4000,
      "authorAttributions": [
        { "displayName": "Jane D.", "uri": "...", "photoUri": "..." }  // named → user photo
      ]
    }
  ]
}
```

### Call 2 — Place Photo (New), to turn the chosen photo into an image

```
GET https://places.googleapis.com/v1/{PHOTO_RESOURCE_NAME}/media?maxWidthPx=1600&key={RESTRICTED_KEY}
```

- Default behavior: returns a **302 redirect** to the actual image (on `googleusercontent.com`).
- Add `skipHttpRedirect=true` to get JSON `{ "photoUri": "https://..." }` instead, if you prefer to read the URL explicitly.

**Recommended serving method:** the Worker reads the redirect target (or `photoUri`) and **302-redirects the browser to it**. The browser then loads the image directly from Google's image servers. This is the cheapest and the cleanest from a terms standpoint — Google serves its own image; you never host it.

### Reference Worker (Cloudflare, JavaScript — illustrative)

```js
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const placeId = url.pathname.split("/").pop();
    if (!placeId) return new Response("Bad request", { status: 400 });

    try {
      // 1. Get the photo list (minimal field mask).
      const detailsRes = await fetch(
        `https://places.googleapis.com/v1/places/${placeId}`,
        { headers: {
            "X-Goog-Api-Key": env.PLACES_KEY,
            "X-Goog-FieldMask": "id,photos",
        }}
      );
      if (!detailsRes.ok) return redirectToCompass();
      const data = await detailsRes.json();
      const photos = data.photos || [];

      // 2. Owner photos = empty authorAttributions.
      const owner = photos.filter(
        p => !p.authorAttributions || p.authorAttributions.length === 0
      );
      if (owner.length === 0) return redirectToCompass();

      // 3. Prefer landscape + reasonably large; else first owner photo.
      const good =
        owner.find(p => p.widthPx >= 1200 && p.widthPx > p.heightPx) || owner[0];

      // 4. Resolve to an image URL.
      const mediaRes = await fetch(
        `https://places.googleapis.com/v1/${good.name}/media` +
        `?maxWidthPx=1600&skipHttpRedirect=true&key=${env.PLACES_KEY}`
      );
      if (!mediaRes.ok) return redirectToCompass();
      const media = await mediaRes.json();
      if (!media.photoUri) return redirectToCompass();

      // 5. Redirect the browser to Google's image. Do NOT cache the URL.
      return Response.redirect(media.photoUri, 302);
    } catch (e) {
      return redirectToCompass();
    }

    function redirectToCompass() {
      // Point at your static compass image, or return 404 and let the
      // VenuePhoto component show its built-in fallback.
      return Response.redirect("https://compasseats.com/img/compass-fallback.png", 302);
    }
  }
};
```

Bind the API key as a **Worker secret** (`env.PLACES_KEY`), never in client code.

---

## Fallback & error behavior

- **No owner photo found** → redirect to compass (don't serve a user phone pic).
- **Any Google error / timeout / unexpected shape** → redirect to compass.
- Venues with **no `placeId`** never hit the Worker — the build step leaves `photo_url` empty and the page shows the compass directly.

The site should *never* show a broken image; every failure path lands on the compass.

---

## Caching & terms-of-service compliance

This is the part that drives the cost, so it's worth stating plainly.

- **No caching of photo names or images.** Google's Maps Platform terms let you cache **only the `place_id`** indefinitely. Photo names can expire and **must not be stored**; photo bytes **must not be cached or rehosted**. This is the same rule that killed the "cache Places photos to R2" plan.
- **Consequence:** you cannot pre-pick a photo and store a pointer to it. Every page view must re-fetch the photo list (Call 1) and re-resolve the image (Call 2). That's two billed calls per view, every view.
- **Do not edge-cache the Worker response.** Set the route to bypass Cloudflare cache for these images. (Normal per-page browser caching during a single page load is fine — that's display, not storage.)
- **Attribution.** When you serve a Places photo you must show Google attribution (a small "Photo via Google" credit + the Google logo per Google's branding guidelines). Because we filter to **owner photos (empty attribution)**, there's usually no per-photographer credit to display — a single small "via Google" credit on Worker-served images covers it. If you ever broaden the filter to include user photos, you'd need to display each photo's `authorAttributions` text/link.
- **API key.** Create a **new, restricted key** used only by this Worker, limited to the Places API. Keep it in a Worker secret. **Do not** reuse the leaked key currently sitting in the public repo (`apps-script/Compasseats Photos.gs`) — that one should be deleted regardless.

There is a non-compliant shortcut some sites use — briefly caching the resolved photo for ~24h–30d to cut calls. It dramatically lowers cost but it **violates the terms** and risks key suspension, and it's inconsistent with the trust positioning behind CompassEats. **Not recommended**, flagged only so the cost trade-off is fully understood.

---

## Cost (read this before building)

Because nothing can be cached, **every photo view = 1 Place Details + 1 Place Photo.**

| SKU | Rate | Free per month |
|---|---|---|
| Place Details (New) — `photos` field | ~$17–20 / 1,000 | 1,000–5,000 (tier-dependent, see note) |
| Place Photo (New) — media | $7 / 1,000 | 1,000 |

The universal $200/month Google Maps credit **no longer exists** in 2026.

**Per photo-view after free tiers:** roughly **$0.025–$0.027**.

**Monthly cost by traffic** (conservative — assumes the `photos` field bills at the Enterprise tier, $20/1K + 1K free):

| Venue photo-views / month | Approx. cost / month |
|---|---|
| ≤ 1,000 | ~$0 (inside free tiers) |
| 5,000 | ~$110 |
| 10,000 | ~$240 |
| 50,000 | ~$1,300 |

> **Tier to confirm before launch:** sources conflict on which Place Details tier the `photos` field triggers — one analysis says **Enterprise** ($20/1K, 1,000 free), and Google's own field-trigger list does not place `photos` in Pro or Enterprise (likely a truncated doc). If it bills at **Pro** ($17/1K, 5,000 free) instead, costs are a bit lower and the free tier is larger. Verify in the Google Cloud console with a few live calls before relying on the numbers above. Either way, the **shape** holds: cheap at low traffic, expensive and uncacheable at scale.

**Protect yourself:** set **hard daily and monthly budget caps** on the Google Cloud project (Cloud Console → Billing → Budgets & alerts, plus per-API quota limits on the Places API). A quota cap makes the API stop responding when hit — the Worker then falls back to the compass — so a traffic spike can't produce a surprise bill.

---

## What changes on the CompassEats site

1. **Add the Worker + route.** Deploy the Worker on Cloudflare and bind a route like `compasseats.com/api/venue-photo/*` (same-domain, no CORS, looks native).

2. **Derive `photo_url` in the build, and stop the reshape from wiping curated fills.** Right now reshape blanks `photo_url` every run, so curated photos have to be re-applied by hand. Fix it with a dedicated column:
   - Add a Sheet column **`curated_photo_url`** that reshape **preserves** (never blanks).
   - In `scripts/sync-sheet.ts`, set `photo_url` per venue using this rule:
     1. if `curated_photo_url` is set → use it;
     2. else if the venue has a `placeId` → set `photo_url = https://compasseats.com/api/venue-photo/{placeId}`;
     3. else → leave empty.
   - Result: curated photos persist across reshapes, the Worker route is applied automatically to everything with a placeId, and the compass covers the rest. The Worker route is a stable URL, so it bakes safely into the prerendered pages.

3. **Attribution UI (small Lovable change).** On any Worker-served image, show a small, unobtrusive **"Photo via Google"** credit + Google logo. Detect Worker-served images by the `/api/venue-photo/` path in `photo_url`. Curated R2 photos show their own credit (from the Wikimedia/Unsplash file page); the compass shows nothing.

4. **No SSR needed.** The page stays static/prerendered. The `<img>` points at the stable Worker URL; the live resolution happens when the browser loads it.

---

## Build brief (checklist for a developer / Lovable)

1. Create a **restricted Google Maps Platform API key**, limited to the Places API; store it as a Cloudflare Worker secret (`PLACES_KEY`). Delete the old leaked key in the repo.
2. Write the Worker per the reference above: route `compasseats.com/api/venue-photo/:placeId` → Place Details (`X-Goog-FieldMask: id,photos`) → owner-photo filter (empty `authorAttributions`, prefer landscape ≥1200px) → Place Photo media (`maxWidthPx=1600`) → 302 redirect to the image; compass on any miss/error.
3. Configure the route to **bypass Cloudflare cache**; do not store photo names or images anywhere.
4. Add the **`curated_photo_url`** Sheet column (reshape-preserved) and the `photo_url` derivation rule in `sync-sheet.ts` (curated → Worker route → empty).
5. Add the **"Photo via Google"** credit on Worker-served images in the venue template.
6. In Google Cloud, set **budget alerts + hard Places API quota caps**.
7. Verify on a few venues with and without owner photos that: owner photo shows; no-owner-photo falls to compass; no-placeId falls to compass; errors fall to compass.

---

## Open decisions / things to confirm

- **Confirm the `photos` Place Details billing tier** (Pro vs Enterprise) with live calls before relying on the cost table.
- **Where to deploy it:** everywhere with a placeId, or only on a subset (e.g., venues that actually get traffic, or only below the curated marquee tier)? Selective deployment is the main cost lever.
- **`maxWidthPx`:** 1600 is a good hero size; drop to ~1200 if you want smaller payloads (doesn't change API cost).
- **Per-photographer attribution:** only needed if you ever serve user photos; the empty-attribution filter avoids it for now.

---

## Honest recommendation

The Worker is technically sound and it's the only way to get real photos onto the long tail of ~10,000 venues without hand-curating each one. The catch is the economics: because Google forbids caching, the cost is real and grows with success — and you can't engineer it down without breaking the terms.

So: **build it, but treat it as a metered tap, not a default.**

- At today's traffic it's effectively free — fine to turn on.
- Put **hard spend/quota caps** on the Google project from day one so a spike can't surprise you.
- Keep using **free curated/Commons photos for the marquee** (your highest-traffic pages) and the **compass for the genuinely obscure** — that keeps the paid surface small.
- Revisit the deploy breadth as traffic and monetization grow. If photo views climb into the tens of thousands per month before revenue does, narrow where the Worker runs, or look at a licensed photo source.

The cheapest win remains the **venue-permission emails** (now on the punch list): a venue's own press photo is free, on-brand, hostable, and terms-clean — strictly better than a paid Places view for any venue you can get one from.
