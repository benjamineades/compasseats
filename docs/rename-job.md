# The rename job

Written for Ben. The fourth button, and the one that undoes it.

The database refuses to let anything change a venue's name. That has been true
since Phase 1 — a trigger called `trg_venue_rename` sits on the `venues` table
and raises an error on any change to `name`, whoever is asking. It was put there
after a script quietly renamed venues and orphaned the blurbs hanging off them.

Until now the guard has been a stop sign with nothing behind it: no job, no
route, nothing. This is the something behind it. It is the **only** thing that
can rename a venue, and it can only do it for the length of its own transaction,
with a batch key you typed and a confirmation you typed.

Two buttons. The first changes a batch of names. The second puts one batch back.

---

## Before the first run

### 1. The connection string is already set up

The rename job uses the same repo secret as the ingest job, `SUPABASE_DB_URL`.
If you have run an ingest, there is nothing to do here. If you have not, do step
1 of `docs/ingest-job.md` first — it matters which of the three Supabase
connection strings you copy, and that page spells out which.

### 2. Run migration 4

In **supabase.com → the project → SQL Editor**, open a new query, paste in the
whole of this file and run it:

```
supabase/migrations/20260914000100_rename_batches.sql
```

It runs as one transaction, so it either lands completely or changes nothing. It
creates two tables and touches nothing that exists.

Afterwards, run these three to see that it landed:

```sql
SELECT count(*) FROM rename_batches;               -- expect 0
SELECT count(*) FROM rename_rows;                  -- expect 0
SELECT unnest(enum_range(NULL::rename_status_t));  -- staged / applied / undone
```

### 3. Nothing else

No packages to install. The scripts have no dependencies.

---

## Button four: **Rename — apply**

**Actions tab → "Rename — apply" → Run workflow.**

| Field          | What to put in it                                                                                                 |
| -------------- | ----------------------------------------------------------------------------------------------------------------- |
| `csv_path`     | Where the CSV is in the repo, e.g. `fixtures/rename/michelin-2026-france-names.csv`                               |
| `batch_key`    | A name for this batch, e.g. `rename-michelin-2026-france`. Every row of the CSV has to carry this same value.     |
| `confirmation` | `RENAME <batch key>` — exactly, including the key.                                                                |
| `dry_run`      | **Starts ticked. Leave it ticked the first time.**                                                                |
| `note`         | Optional. Anything you want stored against the batch.                                                             |

One run does the whole thing: it reads the file, checks every row, shows you
what the renames would touch, and then renames — or refuses and changes nothing.
There is no separate staging step, because there is nothing to stage: a rename
is one column on one row, and the decision that matters was made when the file
was built.

**The batch key is used once, for ever.** If a run times out and you click it
again, the second run finds the key and stops. Any key that exists is refused,
whatever state it is in. To rename more venues — including putting right
something this batch got wrong — build a new file and use a new key.

### Always dry-run it first

`dry_run` starts ticked, like the undo buttons. A dry run does the entire job:
every check, every rename, every invariant, the full report with real numbers —
and then rolls it all back, so every name in the database is exactly as it was.
Read that report, then run it again with the box unticked.

---

## What the CSV needs in it

One row per venue. Exactly these columns, and no others:

```
batch_key, venue_id, expected_name, new_name, source_id, source_url, note
```

- **`venue_id`** is the venue's id, `ve_` and ten characters. Not its name, not
  its slug.
- **`expected_name`** is the name the file believes the venue has **right now**.
  If the live name is something else, the row is refused and the whole batch
  stops. This is the rule from the plan, and it is the one that makes a file
  built last week safe to run today: if somebody changed a name in between, you
  find out rather than overwriting them.
- **`new_name`** is used **exactly as written**. The job never tidies a name,
  never trims a suffix, never changes case. The only thing it removes is
  whitespace at the two ends, which spreadsheets add and nobody means. Deciding
  what a name should be is the preparation step's job, not this one's.
- **`source_id`** is the publisher whose spelling `new_name` follows, and it has
  to be a registered source in `award_sources`. There is one other value it can
  take: `venue`, which means the venue's own website settled the spelling — and
  then `source_url` is that website.
- **`source_url`** is **required on every row**. A blank one fails the row. Same
  rule as the ingest job, same three banned hosts: joinpearl,
  thebestrestaurantsguide and beliapp are never a source.
- **`note`** is free text, stored with the row. Use it — a year from now it is
  the only thing that will say why.

---

## Reading the report

The report lands in three places: the **run summary** (scroll down on the run
page — easiest on a phone), an artifact you can download, and committed into the
repo at `reports/<batch key>-rename.md`.

### Verdicts

Every row gets exactly one. Population: all the data rows in the CSV.

| Verdict     | What it means                                                                                     |
| ----------- | --------------------------------------------------------------------------------------------------- |
| `rename`    | The venue exists, its live name is the one the file expected, and the new name is different. It changes. |
| `no_change` | The venue already carries the new name. Skipped, and that is not an error.                        |
| `reject`    | The row failed a check. **The whole batch stops.**                                                |
| `review`    | The row needs a human. **The whole batch stops.**                                                 |

**One bad row stops everything.** Not the row — the batch. Nothing partial ever
lands, no batch row is written, and the key you used is still free. Fix the file
and run it again.

### Why a row is refused

| Reason                    | What happened                                                                                             |
| ------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `venue_not_found`         | No venue with that id. Check the id, not the name.                                                        |
| `name_moved`              | The live name is neither what the file expected nor what it wanted. The report prints both. Somebody has changed it since the file was built. |
| `empty_new_name`          | Blank `new_name`. The database will not take a nameless venue.                                            |
| `batch_key_mismatch`      | That row carries a different batch key. Usually two files pasted into one.                                |
| `duplicate_venue_in_file` | Two rows name the same venue. They cannot both be right, and choosing is not this job's call — both go.   |
| `missing_source_url`      | Blank `source_url`.                                                                                       |
| `malformed_source_url`    | Not a URL.                                                                                                |
| `competitor_source_url`   | joinpearl, thebestrestaurantsguide or beliapp. Find the publisher's own page.                             |
| `source_not_registered`   | That `source_id` is not in `award_sources`, and is not the literal word `venue`. Check the spelling.      |

### Why a row comes to you

There is one reason, and it is the same situation the ingest job sends you:

| Reason               | What happened                                                                                                                    |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `norm_key_collision` | After the rename, this venue and another venue **in the same city** would reduce to the same key — the database's own dedupe signal. The report names the other venue and its id. |

The key ignores case, accents and punctuation, so "Hôllow" and "Hollow" are the
same key and would collide; "The Hollow" is a different key and would not. The
job works this out against the state the **whole batch** would leave behind, so
a file that renames two venues past each other is not flagged for a collision
that would never exist.

A collision is not always wrong — two restaurants in one hotel can genuinely end
up with near-identical names — but it is never the job's call. Decide, then
either change the name in the file or leave that venue out, and run again under
a new key.

### The downstream impact table

Printed **before anything changes**, for every row that would be renamed.
Population: the rename rows in this file. For each venue:

- **awards by publisher** — who prints this venue, and how many award rows each
  one holds. None of them are touched. An award row keeps the publisher's own
  full string, including any suffix the venue name drops.
- **blurb** — whether a `blurbs` row exists. This is the thing the original
  incident orphaned. It cannot be orphaned now: blurbs key on venue id.
- **slug** — the venue's URL, printed to say that it does not change.

Then one more section, **"Where else the name is stored"**: every text column of
every table in the database is counted against the names about to change, and
the report says what it found. Measured, not assumed. It also names the columns
it did **not** search — the jsonb history documents — because a scan that does
not say what it skipped is not a scan.

**The slug does not change.** URLs key on the venue id, the slug is minted once,
and changing one means a redirect and a decision about an address people may
already have. That is a separate decision and a separate job.

### The counts

```
| table | before | expected | actual |
```

Population: whole table, read inside the transaction before and after the
writes. `venues`, `awards`, `slugs` and `blurbs` are in the table precisely
because a rename must not change any of them — so "it changed nothing else" is a
number you can check rather than a promise.

### The invariants

All checked inside the transaction, before the commit. One failure rolls the
whole batch back and nothing changed:

- renamed venues equals the `rename` rows in the file
- every renamed venue's live name is now its `new_name`
- the venue count, the award count, the slug count and the blurb count are
  unchanged
- ledger rows added equals the publishers in the batch
- `audit_log` shows exactly this batch's renames for this transaction, and no
  other venue update at all

That last one is worth knowing. `audit_log` records every change with the old
and the new value, and its timestamp is the *transaction's* timestamp — so the
job can read back a row-by-row receipt of what it just did and check that
nothing else slipped through while the guard was open.

### The exposure ledger

One row per publisher whose spelling the batch followed, tagged
`rename-apply:<batch key>`, with the number of venues renamed to that
publisher's spelling. Rows whose source is `venue` write nothing here: the venue
is not a publisher, and the ledger is a record of publisher exposure. The report
says how many rows that was, so the arithmetic is never a surprise.

---

## Button five: **Rename — undo**

**Actions tab → "Rename — undo" → Run workflow.**

One applied batch, put back.

| Field          | What to put in it                                       |
| -------------- | --------------------------------------------------------- |
| `batch_key`    | The same key you applied.                               |
| `confirmation` | `UNDO-RENAME <batch key>` — exactly, including the key. |
| `dry_run`      | **Starts ticked. Leave it ticked the first time.**      |

Inside one transaction it puts every name in the batch back to its
`expected_name`, removes the ledger rows tagged `rename-apply:<batch key>`, and
marks the batch `undone`. Then it reads the counts back and prints before →
expected → actual, like everything else.

### When it refuses

If a venue this batch renamed **has been renamed again since**, the undo stops
and names it. It does not adapt and it does not pick a winner: putting the old
name back would throw away whatever the later change decided, and only you know
which name is right. Settle it — usually by running a new rename batch — and
then run the undo again.

It also refuses if a venue is not there any more.

A refusal takes the whole batch with it. Nothing goes back partly.

### An undo runs once

A second run is an error, not a no-op. The names are already back, so a second
run would have nothing to do but guess. The batch row stays for ever with status
`undone` and an `undone_at` timestamp, and every one of its `rename_rows` stays
exactly as the apply wrote it. **History is never deleted.**

The same key can never be applied again either. To change these names again,
build a new file and use a new key.

### One thing the undo reports but does not refuse

If putting an old name back would create a same-city name collision — because a
venue with that name has arrived since — the report says so and the undo
continues. That state is one the database was already in before the batch ran,
and refusing to restore it would leave a batch with no way back. Worth your eyes
afterwards.

---

## Things this job will never do

- Create a venue
- Delete a venue
- Merge two venues
- Change a slug, a URL or a redirect
- Touch an award, in any way — the award row keeps the publisher's own string
- Touch a blurb, a listing, a city or a price
- Set `app.allow_rename` anywhere but inside its own transaction, with
  `SET LOCAL`, for the width of one UPDATE — and it turns it off again before
  that transaction ends
- Tidy, trim, case-correct or otherwise improve a name you gave it
- Fetch a web page — it reads a CSV you hand it, and that is all
- Run without the exact typed confirmation

There is no hand-SQL route around the guard, and this page deliberately does not
give you one. If a name needs changing, it goes through this button, with a file
and a report — that is the whole point of the trigger.

---

## When something goes wrong

**"SUPABASE_DB_URL is not set."** The repo secret is missing or misspelled. See
step 1 of `docs/ingest-job.md`.

**A network error at connect time.** The connection string is the direct one,
which is IPv6-only and unreachable from a GitHub runner. Copy the **Session
pooler** string instead.

**"Batch X already exists."** That key has been used. Nothing was changed. Use a
new key.

**"N rejected row(s) and M row(s) needing your eyes."** Nothing was renamed, and
no batch row was written. The report lists every one with its reason. Fix the
file, use a new key.

**"name_moved."** Somebody changed that venue's name after the file was built.
Look at what it is called now and decide: either the file is out of date and
needs rebuilding, or the change was wrong and this batch should put it right —
in which case update `expected_name` to the live name and run under a new key.

**"norm_key_collision."** Two venues in one city would end up with the same
name key. The report names the other one. Your call.

**"relation 'rename_batches' does not exist."** Migration 4 has not been run.
See step 2 above.

**"Invariant failure."** The whole batch rolled back and nothing changed. The log
names which invariant and by how much. Do not keep clicking — send the numbers
on.

**"This batch cannot be undone as it stands."** Something was renamed again after
the batch applied, and the log names each one. Settle those and run the undo
again.

**"Batch X is already undone."** The undo already ran. It runs once.

---

## Running it on your own machine

Rarely needed, but:

```bash
export SUPABASE_DB_URL='postgresql://postgres.<ref>:...@aws-0-<region>.pooler.supabase.com:5432/postgres'
bun run rename:apply -- --csv fixtures/rename/michelin-2026-france-names.csv \
  --batch-key rename-michelin-2026-france \
  --confirm "RENAME rename-michelin-2026-france" --dry-run
bun run rename:undo -- --batch-key rename-michelin-2026-france \
  --confirm "UNDO-RENAME rename-michelin-2026-france" --dry-run
```

The tests need a throwaway Postgres, never the live one:

```bash
export INGEST_TEST_DB_URL='postgres://postgres@localhost:5432/compass_test'
bun run test:rename
```

There is no environment variable, anywhere, that sets `app.allow_rename`. The
only thing that sets it is the apply job and the undo job, inside their own
transaction.
