# CompassEats — Option B Blurb Pipeline Runbook

**Purpose:** Standing instructions so any fresh chat (inside the CompassEats Project)
can produce the next batch of Option B blurbs without re-deriving the method.
Keep this in the Project files. Update it only when the method itself changes.

Last updated: July 11, 2026 · 48 venues live · 968 remaining in the qualifying set.
**Revised: July 18, 2026 — the `/humanizer` + `/delete-ai-words` skills are now mandatory
on every blurb. See the new "HUMANIZER LAYER" section. Em dashes are out of all new blurbs.**
**Bars now have their own method — see the "BARS ADDENDUM" at the end before writing any bar blurb.**

> **STEP ZERO (do this every time):** Before writing a single blurb, read this whole
> runbook — the base method, the HUMANIZER LAYER, and (for bars) the BARS ADDENDUM.
> Never start writing from memory. This applies to every batch, in every chat.

---

## What Option B is

Hand-quality "rich" blurbs for the marquee tier — they name the real chef, signature
dishes, history, and setting. This is allowed ONLY because every fact is extracted from
**real fetched source text**, never the model's memory. That honesty firewall is the
whole point; breaking it (writing rich facts from memory) is the one unacceptable failure.

The bulk blurbs already cover all 968 of these venues live, so Option B is a **premium
upgrade layer, not a fix**. Stopping at any tier line still leaves a coherent site.

## The qualifying set (defined, do not re-derive)

997 venues qualify, 968 still need Option B. Criteria:
- All 2 & 3-star Michelin
- World's 50 Best Restaurants & Bars, top 50 — in the last 5 years OR "considerable
  history" of 3+ total years in the top 50
- La Liste 99.5+/100
- James Beard Best Chef / Restaurant
- **Regional 50 Best lists and 51–100 lists are EXCLUDED**

The full priority-sorted list is `optionb_qualifying_venues.csv` (and `.txt`) in the
Project files. Column `needs_option_b` = NEED vs have. Work top-down by priority
(3-star → top-10 W50 → 2-star → rest).

## The pipeline (4 steps per venue)

1. **Fetch** real source text — web-search the venue's Michelin Guide entry and its
   World's 50 Best entry (plus Wikipedia / reputable press as needed).
2. **Write** from sources only — short + long blurb, in the locked voice (below).
3. **Verify** — list every concrete claim (chef, dish, year, setting, ranking) and
   confirm each traces to fetched source text. Flag anything that doesn't.
4. If anything is unverifiable, **soften or cut it** — never ship an unsourced fact.
5. **Humanize** — run the HUMANIZER LAYER pass on every short and long before shipping.

Throughput is ~8–12 venues per chat turn before quality degrades. Do batches of ~10.

## The locked voice spec (must match the existing 48)

- Warm "well-traveled friend" register, 2nd person, opinionated about the PLACE.
- "Chef" title precedes EVERY chef reference in prose (e.g. "Chef René Redzepi").
- Short and long open on DIFFERENT beats; short still works alone on a card.
- No implied firsthand visits. No invented dishes/settings/numbers. Durable facts only.
- Dishes framed experientially ("known for years for…"), never "signature dish."
- Field-definers (Noma, El Celler, etc.) get ONE extra sentence of verifiable influence
  stated as fact.
- 3 stars MUST be mentioned; 1/2 optional (mention if also on W50).
- Fond humor sparingly (~1 in 3–4), never at the venue's or guest's expense.
- Scarcity framed as "beloved, worth the effort," never exclusion.
- Vary closers (don't cluster "worth the detour"). Michelin spelled in words.
- Banned vocab: curated, top 10, hidden gem, nestled, boasts, eatery, foodie
  (plus the full HUMANIZER LAYER banned list below).
- `chef` column = clean name(s), no title, semicolon-separated for partnerships
  (e.g. "Joan Roca; Josep Roca; Jordi Roca"). Woven into prose only — no UI use yet.

---

## HUMANIZER LAYER (mandatory — every blurb, restaurant and bar)

Every blurb must pass the `/humanizer` and `/delete-ai-words` skills before it ships.
This is part of the house voice now, not an optional polish. It is the last step of the
pipeline for each blurb. Where a rule here conflicts with an older instruction above,
this layer wins — with the single documented exception of the three approved bar
exemplars (see note at the end of the BARS ADDENDUM).

**No em dashes.** This is the loudest AI tell and it is out of every new blurb.
Restructure instead: use a period, a comma, a colon, or parentheses for a true aside.
Do not swap in a spaced hyphen. If a sentence needed a dash, it needed rewriting.

**No negation-pivot / reframe.** Ban "not X, but Y", "isn't about X, it's about Y",
"less X, more Y", "forget X, focus on Y", and the soft versions ("while X may seem…",
"at first glance X…"). State the positive claim directly. Allowed contrast only for a
real factual correction, never for drama or fake depth.

**Banned vocab (merge with the list above).** delve, tapestry, testament, a testament to,
realm, vibrant, bustling, elevate, unlock, unleash, seamless, robust, leverage, harness,
crucial, pivotal, must-visit, rich history, hidden gem, nestled, boasts, journey and
landscape (metaphorical), cutting-edge, curated, top 10, eatery, foodie, mixologist (as
cliché). Keep a banned word only when it carries literal meaning — an actual hidden
entrance is fine to describe factually; "bartender" is fine, "mixologist" is not.

**Vary rhythm hard.** Follow a long sentence with a short one. No metronome of
same-length sentences or same-shaped paragraphs.

**Other tells to kill.** No throat-clearing openers ("In the heart of…", "Nestled in…",
"Tucked away…"). No closer that only restates the point — the varied action-closer
("Order the martini.", "Book months out.") is fine and encouraged. Digits for numbers
where natural (3 stars, 32 seats, 2 days). Contractions on. Specifics over abstractions.
No rule-of-three padding; use the number of items that's actually true.

**Do not over-correct.** No forced casualness, no slang for its own sake, no fake typos.
Accuracy and the warm "well-traveled friend" register still win over any single rule.

**System-wide:** these two skills also apply to all other CompassEats prose (site copy,
journal posts, emails). They do NOT apply to code, structured specs, or reference docs
(this runbook itself is a reference doc and is intentionally not "humanized").

## Output format

A CSV with columns: `slug, chef, blurb_short, blurb_long`. Slugs MUST match the current
`venues` tab exactly (verify against the latest venues export uploaded to the chat).
Then Claude produces an **updated full `importOptionB.gs`** with the new rows merged into
the embedded `OPTION_B` array (existing rows + new, deduped by slug).

## How Ben loads a batch (the workflow)

1. Claude hands back the updated full `importOptionB.gs`.
2. In Apps Script: open the `importOptionB` file, select all, delete, paste the new file.
3. Save. Run `importOptionB`. Alert must say "rows written: N / N, all slugs matched."
   - If any slug is NOT FOUND, paste the list back to Claude to reconcile.
4. **Publish** in Lovable.
5. Hard-refresh a new venue page in an incognito window to confirm (beats cache).

## Critical guardrails (hard-won)

- **Run order is reshape → importBlurbsFromDrive → importOptionB → cities → publish.**
  Never run reshape AFTER the imports without re-importing — reshape blanks all blurbs
  + chef every run.
- **If blurbs don't appear live:** check the publish build log for
  `Wrote: data/venues.json 11032 venues` (synced, good — any staleness is browser cache)
  vs `⚠️ SYNC SKIPPED — using committed JSON` (publish-env missing `SHEETS_API_KEY` or
  `COMPASSEATS_SHEET_ID` → refresh those Build Secrets, real AIza key in SHEETS_API_KEY,
  never the locked GOOGLE_SHEETS_API_KEY → publish again).
- **Duplicate-slug / wrong-row trap:** some venues have multiple rows sharing one slug
  across cities (Narisawa tokyo/shanghai, Pierre Gagnaire paris/osaka, Etxebarri
  axpe/atxondo). `importOptionB` matches by slug only, so it can land on the wrong row.
  When a target venue has twins, verify which row is the live flagship and target that
  one (or write to both). This is the unresolved name/twin-row dedup item.

## To start a fresh batch in a new chat, say:

"Next 10 Option B blurbs." Upload the latest `venues` export (CSV) and the current
`importOptionB.gs` if it's changed. Claude reads this runbook first (base method +
HUMANIZER LAYER), reads the qualifying list, picks the next ~10 by priority, runs the
pipeline (including the humanize step), and hands back the updated `.gs`.

---

# BARS ADDENDUM

Bars break two assumptions of the restaurant method above: there is **no Michelin spine**
(bars have no Michelin stars), and the **accolades and the people work differently**.
Everything in the base runbook still applies — the honesty firewall, the 4-step
pipeline shape, the HUMANIZER LAYER, the output format, the load workflow, the twin-row
trap, all of it — **except** where this addendum overrides it. Read this whole section
before writing any bar.

## The bar qualifying set (defined, do not re-derive)

164 of the 997 qualifying venues are cocktail bars. They all sit at **priority 4**, and
every one qualified on **World's 50 Best Bars top 50** (regional lists and 51–100 are
excluded, same as restaurants). Their `credentials` field carries the rank inline, e.g.
`World's 50 Best Bars (best #7, 7 yrs, historic)`.

**Ordering (overrides base priority):** within the bars, work **top-down by that
`best #` number** — lowest number first (best #1 before best #20) — so the marquee names
people actually search for lead. Use the `yrs` count and the `historic` flag as
tiebreakers toward the more established name. Do NOT go alphabetically; alphabetical
starts you on "1930 Cocktail Bar" and "28 Hongkong St," which is exactly wrong for a wedge.

Before including a bar, confirm it is still open — several high-`best#` "historic" names
have closed or rebranded (e.g. Dandelyan became Lyaness; Milk & Honey London is closed).
Skip closed venues and flag them for the worklist; do not write a live blurb for them.

## Bar sourcing (replaces step 1 of the pipeline)

Steps 2–5 (write → verify → soften/cut → humanize) are unchanged. Replace the *fetch*
step with this source order. Facts only from fetched text, never memory:

1. The bar's **World's 50 Best Bars profile page** (`theworlds50best.com/bars/…`) — the
   anchor source and the qualifying credential.
2. The bar's **own website / about page** — founder, opening year, concept, signature serves.
3. **The Pinnacle Guide site + reputable drinks press** — The Spirits Business, The Drinks
   Business, Difford's Guide, PUNCH, Imbibe, Forbes drinks, InsideHook — for pins, Spirited
   titles, and corroborating detail.
4. The **Spirited Awards archive** (`talesofthecocktail.org`) — for any Tales/Spirited titles.
5. **Top 500 Bars** (`top500bars.com`) — corroboration and long-tail only, never the lead.
6. The venue's own **`awards_json`** on its `venues` row — bar awards already ingested
   (Top 500 Bars, Spirited, Pinnacle, etc.) are safe to cite.

## The bar accolade hierarchy

No single award plays Michelin's role for bars, so the **spine is World's 50 Best Bars**
(most complete, most recognized, and what qualified these 164). Pinnacle 3-pin and the
Spirited "World's Best Bar" title are **apex boosters** layered on top; Top 500 Bars is
**corroboration only**. Mapped to the restaurant tiers:

- **Tier A — Apex (the "3-star equivalent"):** World's 50 Best Bars top ~10 (especially a
  "World's Best Bar" #1 holder) · Pinnacle **3 pins** · Spirited **World's Best Bar** winner.
- **Tier B — Elite ("2-star / strong-W50"):** W50 Bars #11–50 · Pinnacle **2 pins** ·
  Spirited **Best International / U.S. Cocktail Bar** and top category wins · **#1 on a
  regional 50 Best** (Asia's, North America's, MENA's).
- **Tier C — Distinguished ("regional-list / 1-star"):** the rest of a regional 50 Best ·
  Pinnacle **1 pin** · Spirited nominations & Timeless honors · W50 Bars 51–100.
- **Tier D — Corroborating ("La Liste / aggregator" layer):** Top 500 Bars rank — a high
  placement (top ~20) corroborates; the long tail just means "on the international radar."

Two facts to respect when using these:
- **Pinnacle is self-nomination only** — a bar must apply, so *absence* of a pin means
  nothing (the bar may simply never have entered). Only treat a pin it *holds* as a signal.
- **All these lists reshuffle annually.** Frame rank **structurally** ("a fixture near the
  top of the World's 50 Best Bars," "one of only a handful ever to hold three pins"), never
  hardcode "#4 in 2024" — same rule as award-holder counts for restaurants. A one-time
  **#1 / "World's Best Bar" title** is a discrete historical event and may be stated
  ("topped the World's 50 Best Bars"), but keep it structural and skip the year unless the
  year itself is the point.

## Two honesty rules specific to bars (non-negotiable)

1. **Always name the source of any "world's best / #1" claim.** There are two different
   "World's Best Bar" titles: the **World's 50 Best Bars #1 ranking** (what people assume by
   default) and the **Spirited Awards** category winner. A bar can hold one and not the
   other (e.g. Kumiko won the Spirited title and has never topped W50). Unqualified "named
   the World's Best Bar" is misleading — always attribute ("…at the Spirited Awards,"
   "…topped the World's 50 Best Bars").
2. **Never frame a secondary guide as the field's authority.** World's 50 Best Bars is the
   leading voice. The Pinnacle Guide is *Michelin-style* (a pins tier) — describe its
   structure, never imply it is "the bar world's Michelin" or the definitive ranking.

## Bar voice deltas (from the locked restaurant voice)

Everything in the base voice spec and the HUMANIZER LAYER carries over. The bar-specific
changes:

- **Accolade placement:** woven **mid-blurb**, never the opener and never a headline. Mix
  by bar (some land it earlier, some later), but it should read as part of the story, not
  a banner.
- **People — center the bar, not a name.** These are team efforts, not a single chef's
  vision. Name an individual ONLY if they clear the icon threshold: they hold **other
  awards**, **own other notable/award-winning bars**, or are a **genuine industry icon**.
  Examples that clear it: Julia Momosé (multiple James Beard wins), Lorenzo Antinori
  (International Bartender of the Year), Giacomo Giannotti (industry icon, multiple bars),
  Alex Day & David Kaplan (Death & Co), Ryan "Mr Lyan" Chetiyawardana (Lyaness), Julie
  Reiner, Dale DeGroff, Dave Arnold. If the person doesn't clear it, **make it about the
  team.** Never attach a floating/employed star bartender to one venue (they move between
  bars — the "Phil Ward problem"). Founders and historic figures tied to the venue's origin
  are safe to name as history even if they've since moved on.
- **No "Chef" honorific for bar people** — bars don't use it. Just the name and role
  ("founder Lorenzo Antinori," "led by Julia Momosé").
- **Drinks over dishes, with mandatory technical accuracy.** Reference a signature serve
  when sourced, framed experientially — never mis-describe a build (don't call a stirred
  drink shaken; get it right or stay general).
- **Theatrical / speakeasy venues: the drinks are the star, the room and the entrance are
  the supporting frame.** Never imply the best thing about a bar is how you get into it.
- **Lean harder into sense of place** — the room, the entrance, the hour. It's more of a
  bar's identity than a restaurant's.
- **Humor up a notch** vs. restaurants (it's a night out), still aimed at the situation,
  never the reader, one line max in supporting text.
- **Banned vocab** carries over; "hidden gem" stays banned, but describing an actual hidden
  entrance factually is fine. "bartender" is fine; "mixologist" as cliché is not.

## `chef` column for bars

Reuse the same `chef` column. Populate it **only** with a person who clears the icon
threshold above (e.g. "Julia Momosé", "Lorenzo Antinori", "Giacomo Giannotti"); otherwise
**leave it blank** and keep the blurb team-centric. Same clean-name, semicolon-separated
format. No UI use yet — woven into prose only. For an institutional bar with no current
owner-icon (e.g. the American Bar), leave `chef` blank and carry any legend in the prose.

## Mechanics unchanged

Same `importOptionB.gs`, matched by `slug` and disambiguated by `city_display`, same load
+ publish workflow, same output CSV (`slug, chef, blurb_short, blurb_long`). The twin-row
trap applies to bars too — same names recur across cities (Artesian, Atlas, etc.), so
verify the right row when a slug has twins.

## Voice exemplars (approved — match these)

Three top bars, written and signed off as the reference for register, humor level, and
name calibration. They show the spectrum: **no name (team)**, **light owner-icon**, and
**synonymous figure**.

> **Punctuation note (2026-07-18):** these three exemplars predate the HUMANIZER LAYER and
> still contain em dashes. They are approved as-is and locked — do NOT edit them. Match
> them for **register, humor, and name calibration only**; match **punctuation to the
> HUMANIZER LAYER** (no em dashes) for every new blurb. A later cleanup pass may align the
> exemplars' punctuation once Ben signs off.

**Bar Leone — Hong Kong** (`bar-leone`, chef: `Lorenzo Antinori`) — *owner-icon, cleared on IBOTY*
- *Short:* Bar Leone runs on a stubborn idea: that a great bar is a *neighborhood* bar —
  somewhere you drop in for an aperitivo and a warm hello, not a spectacle. Roman bartender
  Lorenzo Antinori transplanted that idea to Hong Kong's Central district, and it worked so
  well the place topped the World's 50 Best Bars. Turns out unpretentious is a competitive
  advantage.
- *Long:* The cocktail world spends enormous energy on spectacle, which is what makes Bar
  Leone quietly radical: its entire thesis is *come in, have an aperitivo, feel at home*.
  Founder Lorenzo Antinori — later named International Bartender of the Year — recreated the
  corner bars of Rome in the middle of Hong Kong, all easy conviviality and classics poured
  properly rather than reinvented into oblivion. That warmth, backed by genuinely excellent
  drinks, carried it to the top of the World's 50 Best Bars, a first for a bar in Asia.
  Regulars and first-timers get the same welcome, which is rarer than it should be.

**Paradiso — Barcelona** (`paradiso`, chef: `Giacomo Giannotti`) — *drinks as star, room as frame*
- *Short:* Paradiso's cocktails are full-blown productions — recipes engineered over months,
  presented with a magician's timing, rebuilt around a new theme every single year. The
  famous fridge-door entrance and the swooping wooden room are just the frame; the drinks
  are the show, and a good enough one to top the World's 50 Best Bars. Yes, you get in
  through a pastrami shop. No, that's not the most interesting thing about it.
- *Long:* At Paradiso, a cocktail is closer to a small theatrical act — an ever-changing
  menu built each year around a single theme, drinks developed in a dedicated lab, serves
  designed to *do something* in front of you. The Supercool Martini is poured tableside and
  freezes into an iceberg in the glass as you watch. Founder Giacomo Giannotti — a Tuscan
  who named the place after his family's gelateria — wraps all this in a warm, whale-ribbed
  room hidden behind a refrigerator door in a pastrami shop in El Born, so the setting
  amplifies the drinks instead of upstaging them. It topped the World's 50 Best Bars and has
  stayed near the summit for years; once you've watched a drink assembled like a magic
  trick, you understand why.

**Kumiko — Chicago** (`kumiko`, chef: `Julia Momosé`) — *synonymous figure; source attributed*
- *Short:* There's no sign outside Kumiko — just a hushed, light-wood room in Chicago's West
  Loop that feels like it was airlifted from Japan. It's named for a Japanese woodworking
  style that fits tiny pieces together without a single nail, which tells you plenty about
  the drinks: restrained, precise, and quietly an explosion of flavor. Julia Momosé's dining
  bar was named World's Best Bar at the Spirited Awards — and it earns the quiet.
- *Long:* Kumiko takes its name from the Japanese craft of assembling intricate wooden
  latticework without nails, and the whole place runs on that same principle: precision you
  feel more than notice. The room is deliberately calm — light wood, exposed brick, no sign
  out front, a short corridor that gives you a second to settle before you sit — and the
  drinks match it, leaning on sake, shochu, and Japanese ingredients to land big, complex
  flavors without ever raising their voice. Even the alcohol-free "spiritfrees" get the same
  serious treatment. Julia Momosé — a multiple James Beard Award winner for both the bar and
  her cocktail book — treats food and drinks as equals here, which is part of how Kumiko was
  named World's Best Bar at the Spirited Awards and became one of the rare few to earn three
  pins from the Pinnacle Guide, a Michelin-style rating system for bars. Come for a drink,
  stay for dinner, leave calmer than you arrived.

## To start a bar batch in a fresh chat, say:

"Next 10 bar blurbs." Upload the latest `venues` export (CSV) and the current
`importOptionB.gs`. Claude reads the base runbook + the HUMANIZER LAYER + this addendum,
picks the next ~10 bars **top-down by World's 50 Best Bars `best #`** (skipping any closed
venue), runs the bar pipeline (bar sourcing order + bar voice + humanize), verifies every
claim against fetched text, and hands back the updated `.gs`. The three exemplars above are
already approved; include them in the first bar batch (drop-in as-is) alongside the next
new bars.
