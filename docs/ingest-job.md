# The ingest job

Written for Ben. Phase 2's first deliverable: how a published award list becomes
rows in the database, with you approving it in the middle.

There are two buttons. The first one looks at a list and tells you what it would
do. The second one does it. Nothing between the two buttons changes anything you
can see on the site.

---

## Before the first run — three one-time setup steps

### 1. Add the database connection string as a repo secret

The job needs to talk to Supabase directly, because it has to do everything in
one transaction — all of it lands or none of it does. A Supabase *service key*
can't do that (it goes through an API that has no transactions), so the job uses
the database's own connection string instead.

1. Go to **supabase.com → the `compass-canonical` project → Project Settings →
   Database**.
2. Find **Connection string**, pick the **URI** tab, and copy it. It starts with
   `postgresql://postgres...`.
3. Where it says `[YOUR-PASSWORD]`, put your database password in.
4. Go to **github.com/benjamineades/compasseats → Settings → Secrets and
   variables → Actions → New repository secret**.
5. Name it exactly `SUPABASE_DB_URL`. Paste the string in. Save.

That secret is the only credential the job uses. Nothing else needs setting up.

### 2. Run the two migrations

In **supabase.com → the project → SQL Editor**, open a new query, paste in the
whole of each file and run it. In this order:

1. `supabase/migrations/20260911000100_ingest_batch_key.sql`
2. `supabase/migrations/20260911000200_award_categories.sql`

Each file runs as one transaction, so it either lands completely or changes
nothing. Read the comments at the top of the second one before you run it —
there's a finding in there about your category data that's worth knowing.

Afterwards, run this to see what the vocabulary was seeded with:

```sql
SELECT source_id, count(*) AS categories
  FROM award_categories GROUP BY 1 ORDER BY 2 DESC, 1;
```

### 3. Nothing else

No packages to install. The scripts have no dependencies.

---

## Button one: **Ingest — stage**

**Actions tab → "Ingest — stage" → Run workflow.**

| Field | What to put in it |
|---|---|
| `csv_path` | Where the CSV is in the repo, e.g. `fixtures/ingest/first-batch-2026-09.csv` |
| `batch_key` | A name for this batch, e.g. `w50b-restaurants-2024-51-100`. If the CSV has a `batch_key` column, every row has to carry this same value. If it doesn't have that column — the older Award Radar shape doesn't — this value is used for every row and the report says so. |
| `decisions_path` | Leave blank the first time. |
| `note` | Optional. Anything you want stored against the batch. |

The batch key is the thing that makes re-running safe. If a run times out and
you click it again, the second run sees the key, tells you the batch is already
there, and stops. It will not do the work twice. That's the whole point of it.

When the run finishes, the report is in three places: the **run summary** (scroll
down on the run page — easiest on a phone), an artifact you can download, and
committed into the repo at `reports/<batch key>-stage.md`.

### What the CSV needs in it

One row per (venue, award). These columns:

```
batch_key, source_id, year, rank, category, distinction, source_url,
venue_name, city_label, country_label, venue_category, venue_status,
price_symbol_raw, note
```

- `source_url` is **required on every row**. A blank one fails the row. This is
  Ruling 5 — every new award row carries its source.
- `rank`, `category` and `distinction` may be blank.
- `venue_category` may be blank; the job works it out from the source (a bars
  list makes bars) and says so in the report.
- `venue_status` blank means open. `closed` is allowed.
- `venue_name` is used **exactly as the publisher prints it**. The job never
  tidies a name. That's the name rule.

The job also reads the older Award Radar shape from the Apps Script templates
(`source_slug`, `name`, `city`, `country`, `category_override`…) and maps it
across. It prints exactly what it mapped, so you can check. One thing that shape
is missing is an award `source_url` column — you'll need to add one, and the job
says so plainly rather than staging anything.

Geo, address and cuisine columns are read and **ignored**. This job writes
awards, venues, listings, slugs, city labels, price and the exposure ledger.
Nothing else. Geo is Phase 3.

---

## Reading the stage report

### Verdicts

Every row gets one verdict. Population: all the data rows in the CSV.

| Verdict | What it means |
|---|---|
| `new_venue` | The venue isn't in the database. Promote will create it, plus its listing, its URL, its city labels, and the award. |
| `match` | The venue is already there. Promote adds the award to it. |
| `duplicate` | That exact award already exists. Promote skips it. Not a problem. |
| `subsumed` | The venue already holds a higher distinction from the same guide and year, and this row is a bare "Listed". Promote skips the lower one. |
| `reject` | The row failed a check. Nothing will be written for it. |
| `review_city` | The city couldn't be pinned down to exactly one, or the country label disagrees with the city that matched. **Needs you.** |
| `review_venue` | More than one venue with that name in the city, or the name only exists in a different city. **Needs you.** |
| `skipped` | You marked it `skip` in the review CSV. |

### Why a row gets rejected

| Reason | What happened |
|---|---|
| `source_not_registered` | That `source_id` isn't in `award_sources`. Check the spelling. |
| `source_suspended` | That publisher is switched off. A D10 decision, not a data problem. |
| `missing_source_url` | Blank `source_url`. |
| `competitor_source_url` | The URL is joinpearl, thebestrestaurantsguide or beliapp. Competitor sites are never a source. Find the publisher's own page. |
| `malformed_source_url` | Not a URL. |
| `year_out_of_range` | Outside 1900–2100, or blank. |
| `rank_not_positive` | Rank is zero or negative. |
| `unknown_category` | That category isn't in the vocabulary for that source. Add it (see below) and re-stage under a **new** batch key. The job never adds one for you. |
| `bad_venue_category` | Not `restaurant` or `bar`. |
| `bad_venue_status` | Not `active` or `closed`. |
| `missing_venue_name` | Blank `venue_name`. The database won't take a nameless venue, so the row stops here rather than taking the whole batch down at promote. |

To add a category to a source's vocabulary, run this in the Supabase SQL editor
and then re-stage under a new key:

```sql
INSERT INTO award_categories (source_id, category) VALUES ('michelin', 'Two Stars');
```

### The counts table

```
| table | before | expected after | delta |
```

Before is read live at the moment you staged. Expected is what promote will make
it. Population is the whole table every time.

One thing to watch: **the venue delta is not the number of `new_venue` rows.**
Three award rows for Guy Savoy are three awards on one venue. The report says
the venue number, and promote enforces it.

### The sample

Five `new_venue` rows and five `match` rows, with the exact venue id and URL each
one would get. If those ten look right, the rest usually are.

### Two things the report flags but doesn't act on

**"Ranks another venue already holds."** A published rank belongs to one venue.
If a row claims a rank that's already sitting on somebody else, one of the two is
wrong. Both stay — the job never moves or deletes an award — and you decide.
This is exactly the La Cúpula / Bodega El Capricho shape.

**"Existing 'Listed' rows this batch outranks."** A real distinction arrived for
a venue that already has a bare "Listed" row for the same guide and year. The new
one lands; the old one stays. Named for your cleanup list.

---

## When rows land in review

The report tells you how many, and where the file is:
`reports/<batch key>-review.csv`.

1. Open it in Google Sheets.
2. The `candidates` column already holds the answers in the shape the job wants.
3. Fill the **`decision`** column:

| Type | Meaning |
|---|---|
| `use:ve_xxxxxxxxxx` | This row is that existing venue. |
| `new` | Make a new venue for it. |
| `city:ci_xxxxxxxx` | The city is that one. |
| `skip` | Leave this row out of the promote. |
| `city:ci_x;use:ve_y` | Both, separated by a semicolon. |

4. Download it as CSV, put it in the repo (anywhere — `reports/` is fine), and
   run **Ingest — stage** again with:
   - the **same** `csv_path`
   - the **same** `batch_key`
   - `decisions_path` pointing at the filled file

Your decisions apply to the rows you filled in. Every other row is checked again
from scratch against the database **as it is now** — so if something changed
since the first run, a row can come back with a different verdict (a `new_venue`
that somebody else has since created comes back as `match`, for instance). The
report you get is always the current truth, not the old one.

The CSV has to be the same file. If a row has changed, the job stops and says
so, rather than letting a decision you made about one row land on another.

If a decision leaves a row still unresolved, it just comes back in the next
review CSV. You can go round as many times as you like.

### Why a row comes to you

| Reason | What happened |
|---|---|
| `city_not_found` | Nothing in `cities` matches that label. The job never creates a city. |
| `city_ambiguous` | Two or more cities match. Give it the right one with `city:`. |
| `country_label_disagrees` | The label says one country, every matching city is in another — "London, France". Worth a look before it becomes a wrong city label. |
| `venue_ambiguous_in_city` | Two venues with that name already in that city. |
| `same_key_other_city` | Nothing with that name in this city, but there is one elsewhere. Usually a genuinely different venue; occasionally the city label is wrong. |
| `norm_key_too_short` | The name reduces to fewer than three letters or digits — every all-CJK name does. The database's own rule says these never group automatically. |

**Under-merge beats over-merge.** The job matches automatically only on an exact
name key **in the resolved city** — that's what including the city in the
signature is for. The same name in another city does not stop that match and
does not merge anything; two venues of that name in one city always come to you.
It will never quietly merge two venues, and it will never create a city.

---

## Button two: **Ingest — promote**

**Actions tab → "Ingest — promote" → Run workflow.**

| Field | What to put in it |
|---|---|
| `batch_key` | The same key. |
| `confirmation` | `PROMOTE <batch key>` — exactly, including the key. |
| `dry_run` | Tick it to do everything and then roll it all back. |

If the confirmation isn't exact, nothing happens and the log tells you what it
expected. If any review row is still open, nothing happens and the log lists
them.

A dry run is free and worth doing on a big batch: it does every insert, checks
every invariant, prints the real numbers, then rolls back so the database is
untouched.

### What promote does, in order, inside one transaction

1. Marks the batch approved.
2. Creates the new venues — id, name, category, city, status. Mints the URL
   slug; if that slug is taken in that city, the venue that already has it keeps
   it and the new one gets `-2`.
3. Creates each new venue's listing (published for open venues, unpublished for
   closed ones), its canonical URL row, and its publisher city and country
   labels.
4. Inserts the awards, each with its source URL. Skips duplicates and subsumed
   rows.
5. Inserts price, but only where the publisher is marked `price_capable` and the
   venue has no price yet. It never overwrites a price. **Today no source is
   marked `price_capable`, so this writes nothing for any batch** — turning that
   on for a publisher is a D10 decision.
6. Writes the exposure ledger: one row per publisher and field type, tagged
   `ingest-promote:<batch key>`.
7. Marks the batch promoted.
8. Checks every invariant. If a single one fails, the whole thing rolls back and
   nothing changed.

### The invariants

- awards went up by exactly the number of award rows promoted
- venues, listings and slugs each went up by exactly the number of new venues
- city labels, price rows and ledger rows each went up by exactly the number planned
- the count of open venues did not go down
- every award inserted carries a source URL and names a registered publisher
- no Google value anywhere in what was written

Before any of that, and still inside the transaction, it checks that the world
hasn't moved since you staged: that no venue it means to create has appeared in
the meantime, that no URL it means to mint has been taken, that no award it means
to insert is already there, that no publisher has been suspended, and that no
category has left the vocabulary. If any of that has changed it stops and tells
you to re-stage under a new key, because the report you approved would no longer
describe what it was about to do.

Then it reads the counts back **after** the commit and prints before → expected →
actual. If those three columns agree, it did what it said.

### Running promote twice

Safe. The second run sees the batch is already promoted and stops.

### Undoing a promote

There is no undo button, and building one is separate work. What exists is the
trail: `city_label_source.note` and `source_capture_ledger.job` both carry the
batch key, and `audit_log` holds every row that changed with its timestamp. A
reversal job keyed on the batch key can be written when it's needed.

---

## Things this job will never do

- Touch a live table outside the promote transaction
- Create a city
- Merge two venues
- Rename a venue
- Delete anything
- Fetch a web page — it reads a CSV you hand it, and that's all
- Store anything Google-derived
- Promote without the exact typed confirmation

---

## When something goes wrong

**"SUPABASE_DB_URL is not set."** The repo secret is missing or misspelled. Step
1 above.

**"batch_key mismatch."** Rows in the CSV carry a different key from the one you
typed. Usually two lists pasted into one file. Nothing was staged — fix the file
and run it again.

**"Batch X is already promoted."** It worked. Nothing to do.

**"N rows are still in review."** Fill the decision column and re-stage with the
decisions file.

**"The database has moved on since this batch was staged."** Something changed
between staging and promoting — usually another batch landed first. Nothing was
changed. Stage it again under a **new** batch key; the same rules run against the
database as it is now and you'll see a fresh report before anything happens.

**"Line N of the CSV does not match what was staged."** You re-staged decisions
against a different file. Use the same CSV the batch was built from.

**"Invariant failure."** The whole batch rolled back and nothing changed. The log
names which invariant and by how much. If the counts are off by exactly the size
of something else that landed at the same moment, staging again under a new key
is the right move. If they're off in a way that doesn't have an obvious cause,
don't keep clicking — send the numbers on, because that means something is wrong
a retry won't fix.

---

## Running it on your own machine

Rarely needed, but:

```bash
export SUPABASE_DB_URL='postgresql://postgres...'
bun run ingest:stage -- --csv fixtures/ingest/first-batch-2026-09.csv --batch-key first-batch-2026-09
bun run ingest:promote -- --batch-key first-batch-2026-09 --confirm "PROMOTE first-batch-2026-09" --dry-run
```

The tests need a throwaway Postgres, never the live one:

```bash
export INGEST_TEST_DB_URL='postgres://postgres@localhost:5432/compass_test'
bun run test:ingest
```
