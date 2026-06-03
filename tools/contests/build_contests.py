#!/usr/bin/env python3
"""
build_contests.py — generate public_html/tr4w_contests.html

Joins two vendored data files on the WA7BNM contest id and renders a themed,
filterable HTML table of every contest TR4W supports.

Inputs (defaults are the vendored snapshots next to this script):
  wa7bnm_contest_ids.csv   TR4W contest name -> WA7BNM ref id   (ContestName,WA7BNM_ID)
                           Canonical copy lives in the TR4W program repo; this is a
                           snapshot. When it changes upstream, copy it here and re-run.
  wa7bnm_cabnames.txt      WA7BNM ref id -> friendly name        ("id|Friendly Name")
                           Captured from https://www.contestcalendar.com/cabnames.php
                           (each row's Contest link is contestdetails.php?ref=<id>).

Output:
  public_html/tr4w_contests.html

A row whose id is 0 or doesn't resolve gets a BLANK friendly cell (a sentinel for
"not matched yet" — never invent a name). On every run, data problems (duplicate
ids = collisions, non-zero ids missing from the WA7BNM table) are reported to stderr.

Usage:
  python3 tools/contests/build_contests.py
  python3 tools/contests/build_contests.py --csv /path/to/wa7bnm_contest_ids.csv
"""
import argparse
import collections
import html
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parents[1]
DETAIL = "https://www.contestcalendar.com/contestdetails.php?ref="


def load_cabnames(path):
    fid = {}
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        ref, name = line.split("|", 1)
        fid[ref.strip()] = name.strip()
    return fid


def load_csv(path):
    rows = []
    for i, line in enumerate(path.read_text().splitlines()):
        if not line.strip():
            continue
        if i == 0 and line.lower().startswith("contestname"):
            continue  # header
        name, wid = line.rsplit(",", 1)
        rows.append((name.strip(), wid.strip()))
    return rows


def report_quality(rows, fid):
    """Warn (stderr) about collisions and unresolved non-zero ids. Returns issue count."""
    byid = collections.defaultdict(list)
    for name, wid in rows:
        if wid not in ("0", ""):
            byid[wid].append(name)
    collisions = {w: ns for w, ns in byid.items() if len(ns) > 1}
    unmatched = [(n, w) for n, w in rows if w not in ("0", "") and w not in fid]

    if collisions:
        print("WARNING: %d WA7BNM id(s) assigned to multiple contests (collisions):"
              % len(collisions), file=sys.stderr)
        for w, ns in sorted(collisions.items()):
            print("  id %s -> %s  : %s"
                  % (w, fid.get(w, "(not in table)"), ", ".join(ns)), file=sys.stderr)
    if unmatched:
        print("WARNING: %d non-zero id(s) not found in the WA7BNM table:"
              % len(unmatched), file=sys.stderr)
        for n, w in unmatched:
            print("  %s (id=%s)" % (n, w), file=sys.stderr)
    return len(collisions) + len(unmatched)


def render(rows, fid):
    out_rows = []
    resolved = 0
    for name, wid in rows:
        friendly = fid.get(wid, "") if wid not in ("0", "") else ""
        search = html.escape((name + " " + friendly).lower(), quote=True)
        if friendly:
            resolved += 1
            cell = ('<a href="%s%s" target="_blank" rel="noopener">%s</a>'
                    % (DETAIL, html.escape(wid, quote=True), html.escape(friendly)))
        else:
            cell = ""  # blank sentinel
        out_rows.append(
            '      <tr data-search="%s"><td class="name">%s</td>'
            '<td class="friendly">%s</td></tr>'
            % (search, html.escape(name), cell)
        )
    page = (TEMPLATE
            .replace("__ROWS__", "\n".join(out_rows))
            .replace("__TOTAL__", str(len(rows)))
            .replace("__RESOLVED__", str(resolved)))
    return page, resolved


def main():
    ap = argparse.ArgumentParser(description="Build tr4w_contests.html")
    ap.add_argument("--csv", type=Path, default=SCRIPT_DIR / "wa7bnm_contest_ids.csv")
    ap.add_argument("--cabnames", type=Path, default=SCRIPT_DIR / "wa7bnm_cabnames.txt")
    ap.add_argument("--out", type=Path, default=REPO_ROOT / "public_html" / "tr4w_contests.html")
    args = ap.parse_args()

    fid = load_cabnames(args.cabnames)
    rows = load_csv(args.csv)
    report_quality(rows, fid)

    page, resolved = render(rows, fid)
    args.out.write_text(page)
    print("wrote %s  (%d contests, %d resolved, %d blank)"
          % (args.out, len(rows), resolved, len(rows) - resolved))


TEMPLATE = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>TR4W — Supported Contests</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Barlow:wght@300;400;600;700&family=Barlow+Condensed:wght@700;800&display=swap" rel="stylesheet">
<style>
  :root {
    --green: #39ff6a; --green-dim: #1a7a35; --amber: #f5a623;
    --bg: #080c09; --surface: #0e1510; --surface2: #141d16;
    --border: rgba(57,255,106,0.15); --border-bright: rgba(57,255,106,0.35);
    --text: #c8e8cd; --muted: #5c8066;
    --mono: 'Share Tech Mono', monospace; --body: 'Barlow', sans-serif;
    --display: 'Barlow Condensed', sans-serif;
  }
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  html { scroll-behavior: smooth; }
  body { background: var(--bg); color: var(--text); font-family: var(--body);
    font-size: 16px; line-height: 1.6; -webkit-font-smoothing: antialiased; }
  body::before { content: ''; position: fixed; inset: 0; z-index: 9999;
    pointer-events: none;
    background: repeating-linear-gradient(0deg, transparent, transparent 2px,
      rgba(0,0,0,0.08) 2px, rgba(0,0,0,0.08) 4px); }
  a { color: var(--green); }

  nav { position: sticky; top: 0; z-index: 100; background: rgba(8,12,9,0.92);
    backdrop-filter: blur(8px); border-bottom: 1px solid var(--border);
    padding: 0 2rem; display: flex; align-items: center;
    justify-content: space-between; height: 56px; }
  .nav-logo { font-family: var(--mono); font-size: 1.1rem; color: var(--green);
    letter-spacing: 0.1em; text-decoration: none; }
  .nav-logo span { color: var(--muted); }
  nav ul { list-style: none; display: flex; gap: 2rem; }
  nav a { color: var(--muted); text-decoration: none; font-size: 0.85rem;
    letter-spacing: 0.08em; text-transform: uppercase; transition: color 0.2s; }
  nav a:hover { color: var(--green); }

  main { max-width: 940px; margin: 0 auto; padding: 4rem 1.5rem 5rem; }
  .page-label { font-family: var(--mono); font-size: 0.8rem; color: var(--green-dim);
    letter-spacing: 0.15em; text-transform: uppercase; margin-bottom: 0.75rem; }
  h1 { font-family: var(--display); font-weight: 800; font-size: clamp(2.2rem, 6vw, 3.4rem);
    line-height: 1; text-transform: uppercase; color: var(--text); margin-bottom: 1rem; }
  h1 .blink { color: var(--green); }
  .lead { color: var(--muted); max-width: 60ch; margin-bottom: 2rem; }
  .lead strong { color: var(--text); }

  .toolbar { display: flex; align-items: center; gap: 1rem; flex-wrap: wrap;
    margin-bottom: 1rem; }
  #filter { flex: 1 1 260px; background: var(--surface); color: var(--text);
    border: 1px solid var(--border); border-radius: 4px; padding: 0.65rem 0.9rem;
    font-family: var(--mono); font-size: 0.95rem; }
  #filter:focus { outline: none; border-color: var(--border-bright); }
  #filter::placeholder { color: var(--muted); }
  .count { font-family: var(--mono); font-size: 0.85rem; color: var(--muted);
    white-space: nowrap; }

  table { width: 100%; border-collapse: collapse; }
  thead th { position: sticky; top: 56px; background: var(--bg);
    text-align: left; font-family: var(--mono); font-size: 0.75rem;
    text-transform: uppercase; letter-spacing: 0.1em; color: var(--green-dim);
    padding: 0.6rem 0.8rem; border-bottom: 1px solid var(--border-bright); }
  tbody td { padding: 0.55rem 0.8rem; border-bottom: 1px solid rgba(57,255,106,0.07);
    vertical-align: top; }
  tbody tr:hover { background: var(--surface2); }
  td.name { font-family: var(--mono); font-size: 0.9rem; color: var(--text);
    white-space: nowrap; }
  td.friendly a { color: var(--green); text-decoration: none; }
  td.friendly a:hover { text-decoration: underline; }
  td.friendly:empty::after { content: '—'; color: var(--muted); opacity: 0.45; }
  #noresults { display: none; color: var(--muted); font-family: var(--mono);
    padding: 1.5rem 0.8rem; }
  .note { margin-top: 1.75rem; font-size: 0.85rem; color: var(--muted); }
  .note a { color: var(--green); }

  footer { border-top: 1px solid var(--border); padding: 2rem; display: flex;
    align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 1rem;
    color: var(--muted); font-size: 0.8rem; }
  footer .f-logo { font-family: var(--mono); color: var(--green); letter-spacing: 0.1em; }
  @media (max-width: 560px) { td.name { white-space: normal; } nav ul { gap: 1.1rem; } }
</style>
</head>
<body>

<nav>
  <a class="nav-logo" href="index.html">TR4W<span>_</span></a>
  <ul>
    <li><a href="index.html">Home</a></li>
    <li><a href="index.html#download">Download</a></li>
    <li><a href="https://github.com/TR4W/TR4W" target="_blank">GitHub &#8599;</a></li>
  </ul>
</nav>

<main>
  <div class="page-label">// reference</div>
  <h1>Supported Contests<span class="blink">_</span></h1>
  <p class="lead">TR4W has built-in support for these <strong>__TOTAL__</strong> contests.
     Use the <em>TR4W name</em> when selecting a contest in the logger; resolved names link to
     the full schedule and rules at WA7BNM's Contest Calendar. A blank in the Contest column just
     means it isn't matched to the calendar yet.</p>

  <div class="toolbar">
    <input id="filter" type="search" placeholder="Filter contests&hellip;" autocomplete="off" spellcheck="false">
    <span class="count" id="count"></span>
  </div>

  <table>
    <thead><tr><th>TR4W Name</th><th>Contest</th></tr></thead>
    <tbody id="rows">
__ROWS__
    </tbody>
  </table>
  <div id="noresults">No contests match that filter.</div>

  <p class="note">Friendly names and schedule links courtesy of the
    <a href="https://www.contestcalendar.com/" target="_blank" rel="noopener">WA7BNM Contest Calendar</a>
    (<span id="resolved">__RESOLVED__</span> of __TOTAL__ matched).</p>
</main>

<footer>
  <p class="f-logo">TR4W_</p>
  <p>&copy; TR4W Project &middot; Free &amp; Open Source</p>
</footer>

<script>
  var inp = document.getElementById('filter');
  var rows = Array.prototype.slice.call(document.querySelectorAll('#rows tr'));
  var countEl = document.getElementById('count');
  var noRes = document.getElementById('noresults');
  function update() {
    var q = inp.value.trim().toLowerCase();
    var visible = 0;
    for (var i = 0; i < rows.length; i++) {
      var show = !q || rows[i].getAttribute('data-search').indexOf(q) !== -1;
      rows[i].style.display = show ? '' : 'none';
      if (show) visible++;
    }
    countEl.textContent = visible + ' / ' + rows.length + ' shown';
    noRes.style.display = visible ? 'none' : 'block';
  }
  inp.addEventListener('input', update);
  update();
</script>
</body>
</html>
"""


if __name__ == "__main__":
    main()
