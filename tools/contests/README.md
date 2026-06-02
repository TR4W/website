# Contest list page generator

Generates [`public_html/tr4w_contests.html`](../../public_html/tr4w_contests.html) — the themed,
searchable table of every contest TR4W supports — by joining two vendored data files on the
WA7BNM contest id.

## Regenerate

```bash
python3 tools/contests/build_contests.py
```

Run from the repo root (paths are resolved relative to the script, so cwd doesn't matter).
Data-quality warnings print to **stderr**; the page is written to `public_html/tr4w_contests.html`.

## Inputs

| File | What | Source of truth |
|------|------|-----------------|
| `wa7bnm_contest_ids.csv` | `ContestName,WA7BNM_ID` — maps each TR4W contest name to a WA7BNM ref id (`0` = not assigned). | **The TR4W program repo** (`ny4i/TR4W`). This is a *snapshot*. |
| `wa7bnm_cabnames.txt` | `<ref-id>\|<Friendly Name>` — the WA7BNM ref id → friendly contest name. | Captured from <https://www.contestcalendar.com/cabnames.php> (each row's Contest link is `contestdetails.php?ref=<id>`). |

### Updating the data

- **Contest ids change** (new contest, fixed id): update the canonical CSV in the TR4W program
  repo, copy it here, and regenerate:
  ```bash
  cp /path/to/TR4W/wa7bnm_contest_ids.csv tools/contests/wa7bnm_contest_ids.csv
  python3 tools/contests/build_contests.py
  ```
- **Friendly-name table changes** (WA7BNM adds/renames contests): re-capture `cabnames.php` into
  `wa7bnm_cabnames.txt` (keep the `id|Name` format; `#` lines are comments). The page only adds
  friendly names — it never invents them.

> ⚠️ The CSV here is a **snapshot**, so it can drift from the program repo's canonical copy.
> Always re-copy before regenerating. You can also point the generator straight at the canonical
> file without vendoring: `build_contests.py --csv /path/to/TR4W/wa7bnm_contest_ids.csv`.

## Output behavior

- Every row always shows the **TR4W name**.
- The **Contest** column shows the friendly name (linked to the WA7BNM detail page) when the id
  resolves; otherwise it is **blank** — a deliberate sentinel meaning "not matched yet".
- On each run the generator warns about:
  - **collisions** — one WA7BNM id assigned to more than one contest (at least one is wrong);
  - **unmatched** — a non-zero id not present in `wa7bnm_cabnames.txt`.
