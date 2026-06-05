# Contest list page generator

Generates [`public_html/tr4w_contests.html`](../../public_html/tr4w_contests.html) — the themed,
searchable table of every contest TR4W supports — directly from the TR4W program's `ContestsArray`.

## Regenerate

```bash
python3 tools/contests/build_contests.py
```

Reads the TR4W source from `~/projects/TR4W/tr4w/src/VC.pas` by default (override with
`--vc <path>`), writes `public_html/tr4w_contests.html`, and prints a count to stdout.

## Source of truth — the TR4W program

The contest data lives in the program, in the `ContestsArray` in **`tr4w/src/VC.pas`**. Each
record looks roughly like:

```pascal
(Name: 'CQ-WW-CW';  ...  WA7BNM: 192;  ...  FriendlyName: 'CQ Worldwide DX Contest, CW'),
```

The generator parses each record for three fields:

| Field | Used as |
|-------|---------|
| `Name` (the `{commented}` form is read too) | **Column 1 — TR4W Name** |
| `WA7BNM` | ref id; when `> 0`, the Contest name links to `contestdetails.php?ref=<id>` |
| `FriendlyName` | **Column 2 — Contest**; falls back to `Name` when empty |

The `DUMMY CONTEST` placeholder record is skipped.

**To change anything on the page** — a name, a description, a WA7BNM id — edit the `ContestsArray`
in the program, rebuild/commit it there, then regenerate this page. There is **no** website-side
data file to maintain (the old `wa7bnm_contest_ids.csv` / `wa7bnm_cabnames.txt` /
`friendly_overrides.txt` are gone — VC.pas replaced all three).

## Output

- Every row shows the TR4W **Name** in column 1.
- The **Contest** column shows the `FriendlyName` (or the `Name` when there's none), linked to the
  WA7BNM schedule page when a `WA7BNM` id is present.
- The generated HTML carries an `AUTO-GENERATED — DO NOT EDIT` notice. Don't hand-edit the page;
  edit the program and regenerate.
