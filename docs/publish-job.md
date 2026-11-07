# The publish job

Written for Ben. Phase 2, last deliverable: the database becomes files, in a
preview only, with a way back.

There are three buttons and one test run:

| Button | What it does | What it changes |
|---|---|---|
| **Publish — build** | Reads the database once and writes one new version folder, plus a report. | Adds a folder to the `publish-preview` branch. It does not move the preview. |
| **Publish — promote** | Points the preview at one version. | One file: `channels/preview.json`. |
| **Publish — rollback** | Points the preview back at the version before. | One file: `channels/preview.json`. |
| **Publish — tests** | Runs by itself on every pull request that changes the job. | Nothing. It uses a throwaway database. |

None of the three buttons writes to the database. None of them changes the
live site. The live site builds from `data/venues.json` on `main` until the
Phase 5 move.

---

## Before the first run

### 1. The database secret: nothing to do

The build uses the repo secret `SUPABASE_DB_URL`, the same secret as the
ingest and rename buttons (the Session pooler string, see `docs/ingest-job.md`
step 1). It reads in one transaction that Postgres itself marks **read only**,
so a write cannot happen even by mistake. Each report shows
`read only = on`.

A separate read-only database user for this job is a later item. It needs one
database change with your "go".

### 2. Merge the pull request

1. Open the pull request link.
2. Read the description. Make sure that the checks at the bottom are green.
3. Click **Merge pull request**, then **Confirm merge**.

The buttons show in the Actions tab only after the merge, because GitHub reads
button files from `main`.

### 3. After the first build: make sure that no deploy started

The `publish-preview` branch holds no site code, so a site build on it cannot
succeed. Check it once anyway:

1. After the first **Publish — build** run, open the Cloudflare dashboard.
2. Go to **Workers & Pages → compasseats → Deployments**.
3. Make sure that no deployment names the branch `publish-preview`.
4. In Lovable, open the project and make sure that no new deploy started at the
   same time.

If you see a deploy from `publish-preview`, stop and tell Claude. Do not run
promote until that is settled.

---

## Button one: **Publish — build**

**Actions tab → "Publish — build" → Run workflow.**

| Field | What to put in it |
|---|---|
| Use workflow from | `main` (the default). |
| `allow_decrease` | Leave blank. Fill it only when a report asks you to (see the gates). |
| `note` | Optional. Any text. It goes in the version's `manifest.json`. |

Click **Run workflow**. In the Nov 7 rehearsal against a local copy of the
database, the build step took about 1 second for 11,510 venues. On GitHub the
read goes over the network, so it takes longer. That time is not measured yet.

When it finishes:

- **Green tick:** the version is on the `publish-preview` branch. The report is
  in the **run summary** (scroll down on the run page), in the artifact
  `publish-build-report`, and in the version folder at `report/report.md`.
  The last line of the summary names the version, for example
  `20261107T021949Z`. You need it for promote.
- **Red cross:** a gate failed, or the build stopped. No version was written
  and nothing was pushed. The run summary says which gate and why.

### What a version holds

`versions/<version>/` on the `publish-preview` branch:

| File | Rows | What it is |
|---|---|---|
| `index.json` | 1 per venue | A light row per venue: id, name, native name, category, city, address, award count, sources, newest award year, price tier, blurb yes/no. |
| `venues/<city>.json` | 1 file per city | The city, and every venue in it in full: `ve_` id, name, native name, category, city, cuisine, every award row (all years), price, blurb. |
| `cities.json` | 1 per city with a venue | Name, country, region, and venue counts that the job made itself. |
| `regions.json` | 1 per region with a venue | Name, cities, counts. |
| `redirects.json` | 1 per old address | The `redirects` table, plus every old (non-canonical) slug of a published venue, to its current address. |
| `attribution.json` | 1 per source | Each source in the files: display name, attribution text, row counts. |
| `report/` | | The report and its CSV files. |
| `manifest.json` | | The version id, the time, the code version, the database ids, and the sha256 of every file. |

The address of a venue is `/<city_slug>/<slug>`, the same form as the
`redirects` table.

What is never in the files: a Google value (place ids, Google coordinates,
Google addresses), anything from a source that is switched off, a closed venue,
and a blurb whose status is `needs_rewrite`. Geo, address, hours and photo rows
are counted in the report only. Their published shape is a Phase 3 decision.

The same database state always gives the same files, byte for byte. The
report's **content hash** shows this: two builds with no database change in
between show the same content hash.

### The gates

Every gate runs before a single file is written. If one fails, no version is
written.

| Gate | It checks | If it fails |
|---|---|---|
| `venue_count_matches_database` | The venue count in the files equals the count of open venues with a published listing. | A bug. Do not rerun. Send the report to Claude. |
| `one_canonical_slug` | Every venue has exactly 1 current address. | The report names the venues. Fix the slugs, then build again. |
| `city_exists` | Every venue's city exists. | The report names the venues. |
| `no_closed_venue` | No closed venue has a published listing. | The report names them. Unpublish or reopen each one, then build again. |
| `no_suspended_source` | Nothing in the files comes from a source that is switched off. | A bug: those rows are left out before this check. Send the report to Claude. |
| `no_google_value` | No Google id, Google link or Google source in any file. | The report names the file and the value. Remove the value from the database, then build again. |
| `no_duplicate_michelin` | No venue holds 2 Michelin rows of the same year and category. | The report names the venues. |
| `no_large_decrease` | The venue count did not fall by more than 0.5% since the last version. | See below. |
| `redirect_from_unique` | No old address has 2 different answers. | The report names the addresses. |

**A large decrease.** If you closed or removed many venues on purpose, the
report gives the exact words to type, for example `ALLOW DECREASE 11402`.
Run the build again and type those words in `allow_decrease`. The words
contain the new count, so words typed for one build do not work for another.

### Reading the report

| Section | What it tells you |
|---|---|
| Gates | Pass or fail for each gate, with the numbers. |
| Files | Row counts and the content hash. |
| Counts | Venues, awards, prices, blurbs, each with its population. |
| Left out on purpose | Rows that the rules keep out, and why. |
| Checks | Things to look at that do not stop the build. |
| Exposure (D10) | Per publisher: rows in the database and rows in this version. No limit is applied (choice 8). |
| Blurb coverage | Which blurbs went in (rule Q4). |
| Change from the last version | Venues added, removed and changed. `report/diff.csv` lists each one and the fields that changed. |
| Compare with the live site file | Each live page in one group, the same groups as the Nov 5 table. `report/compare-live.csv` lists each one. |

---

## Button two: **Publish — promote**

**Actions tab → "Publish — promote" → Run workflow.**

| Field | What to put in it |
|---|---|
| `version` | The version id from the build report, for example `20261107T021949Z`. |
| `confirmation` | `PUBLISH <version>`, exactly, for example `PUBLISH 20261107T021949Z`. |
| `dry_run` | Tick it to do every check and change nothing. |

Before it moves the preview, promote checks the version folder against its own
`manifest.json`: every file is there, every sha256 is the same, no extra file
is there, and every gate passed at build. If one thing differs, it stops and
names the file.

If the confirmation is not exact, nothing happens and the log says what it
expected. Promoting the version that is already the preview is safe: it says so
and changes nothing.

---

## Button three: **Publish — rollback**

**Actions tab → "Publish — rollback" → Run workflow.**

| Field | What to put in it |
|---|---|
| `confirmation` | `ROLLBACK <the version the preview points at now>`. Find it in `channels/preview.json` on the `publish-preview` branch, line `"current"`. |
| `dry_run` | Tick it to do every check and change nothing. |

Rollback points the preview back at the version that was the preview before the
current one. Before it moves the pointer, it checks that earlier version
against its own `manifest.json`, file by file.

The confirmation names the version you take out of the preview. So a
confirmation typed for one state cannot roll back another.

You can roll back again: each rollback goes back one more promote. To undo a
rollback, run **Publish — promote** with the version you rolled back from.

`channels/preview.json` keeps a `history` list of every promote and rollback,
with the time and the run number. It is never trimmed.

---

## Keeping versions

The build keeps the newest 10 version folders in the branch. It also keeps the
version that the preview points at and the version a rollback would go to, at
any age. It removes older folders from the branch. Every removed folder stays
in git history.

### A version that is no longer in the tree

Promote and rollback refuse a version whose folder was removed. To bring one
back, ask Claude to restore `versions/<version>/` on the `publish-preview`
branch from git history. Promote checks the restored folder against its
manifest like any other.

---

## The two supervised runs

Do these once, after the merge.

**Run 1.**
1. Run **Publish — build**. Read the report. Write down the version id and the
   content hash.
2. Do the deploy check in "Before the first run", step 3.
3. Run **Publish — promote** with `dry_run` ticked. Read the output.
4. Run **Publish — promote** again with `dry_run` not ticked.

**Run 2.**
1. Run **Publish — build** again. If no batch landed in between, the content
   hash is the same as run 1, and "Change from the last version" says
   added 0, removed 0, changed 0.
2. Promote the new version.
3. Run **Publish — rollback** with `ROLLBACK <the new version>`. The preview
   goes back to the run 1 version.

Send the two run summaries to Claude.

---

## When something goes wrong

**"SUPABASE_DB_URL is not set."** The repo secret is missing. See
`docs/ingest-job.md` step 1.

**A network error at connect time.** The secret holds the direct connection
string. Use the Session pooler string (`docs/ingest-job.md` step 1).

**"The publish-preview branch does not exist yet."** Promote or rollback ran
before the first build. Run **Publish — build** first.

**"is not newer than the newest version in the tree".** The clock of the run
gave an id older than one already there. Run the build again.

**"did not pass its hash check".** A file in that version folder changed after
the build. The log names each file. Do not edit version folders by hand.
Ask Claude to restore the folder from git history.

**"channels/preview.json is inconsistent ... edited by hand".** Someone edited
the pointer file. Nothing was changed. Ask Claude to restore it from git
history.

**"The confirmation must read exactly ...".** Copy the words from the log and
run again.

---

## Things this job will never do

- Write to the database
- Change the live site, or `main`
- Store or publish a Google value
- Publish a closed venue, or a blurb whose status is `needs_rewrite`
- Move the preview without the exact typed confirmation
- Run on a schedule (choice 7: only when you press the button)

---

## Running it on your own machine

Rarely needed:

```bash
export SUPABASE_DB_URL='postgresql://postgres.<ref>:...@aws-0-<region>.pooler.supabase.com:5432/postgres'
bun run publish:build -- --tree ../preview --live-file data/venues.json
bun run publish:promote -- --tree ../preview --version <id> --confirm "PUBLISH <id>" --dry-run
bun run publish:rollback -- --tree ../preview --confirm "ROLLBACK <current>" --dry-run
```

The tests need a throwaway Postgres, never the live one:

```bash
export INGEST_TEST_DB_URL='postgres://postgres@localhost:5432/compass_test'
bun run test:publish
```
