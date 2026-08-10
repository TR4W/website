# CLAUDE.md

Guidance for working in the `tr4w.net` website repository (**GitHub: `TR4W/website`**, public).

## What this is

The **website and download portal for TR4W**, a free Windows contest-logging program for amateur
radio. It is a web-hosting tree, **not** an application codebase — no build system for the site
itself, no test suite, no package manager. The TR4W *application* lives elsewhere:
<https://github.com/TR4W/TR4W>. This repo serves the landing page, the installer downloads, and a
PHP network-diagnostics tool.

**Source-only repo.** The repo tracks the site *source*; the bulky/managed artifacts are
gitignored and live only on the production web host (synced via rsync from
`ssh TR4W:/var/www/tr4w.net/public_html/`). See `.gitignore` for the full exclusion list:
- Installer binaries — `*.exe`, `*.exe.gpg`, `*.7z` (served statically; never committed).
- `TRMASTER.DTA` / `.ASC` callsign DB — uploaded separately via the TR4W/TR4W release process.
- Abandoned NSIS build toolchain — `NSIS/`, `build/`, `*.nsi`, `make_setup_file.bat`.
- Secrets/cruft — `info.php`, `serial+key.txt`, `*.bak`, `*~`, etc.

## Layout

| Path | Purpose |
|------|---------|
| `public_html/` | **The canonical deployed web root.** Everything served at `https://tr4w.net/` is here. |
| `public_html/index.html` | The landing page (single file, inline CSS, terminal/green theme). This is the **source of truth** — there is no longer a separate root-level `index.html`. |
| `public_html/site.css` | Shared theme — design tokens + base chrome (nav/footer/scan-line). Linked by every page **and** the contests generator template; edit colors/fonts here, once. **Bump `?v=N` in each `<link href="site.css?v=N">` whenever you change this file**, or browsers serve stale CSS. |
| `public_html/.htaccess` | Apache config: `Options +Indexes` **plus the download redirect** (see below). |
| `public_html/4.NN/` | One directory per TR4W release. Holds the Windows installer plus 8 localized builds. **In the repo these stop at 4.148** (~116 dirs, 4.31 →) because newer releases ship *only* gitignored `.exe` files, so their dirs exist on the server but not here. Don't read the newest dir in the working tree as "the current release". |
| `public_html/*/tr4wmaintlist.html` | Per-version maintenance/changelog pages. |
| `bin/publish-release.sh` | **Start here for a release.** End-to-end publisher: fetch → upload → TRMASTER.DTA → repoint → push → verify (see Releases). |
| `bin/release.sh` | Lower-level helper called by the above — repoints `.htaccess`/`index.html` only. |
| `public_html/tr4w_contests.html` | Searchable table of supported contests — **generated**, do not hand-edit. |
| `tools/contests/` | Generator + vendored data for the contest list page (`build_contests.py`, see its README). |
| `LookingGlass/` | Third-party PHP looking-glass tool (ping/traceroute/mtr/host). |

## Filename / versioning convention

Versions are `4.<minor>.<patch>`. **The naming convention changed over time:**
- Older dirs (≤ ~4.97): underscore — `tr4w_setup_4_97.11.exe`.
- Newer dirs: dots — `tr4w_setup_4.150.0.exe`.

Localized builds append a 3-letter suffix before `.exe`: `_cze _esp _ger _mng _rom _rus _ser _ukr`
(Czech, Spanish, German, Mongolian, Romanian, Russian, Serbian, Ukrainian).

> **Never hardcode the current version in docs — read it.** The single source of truth is the
> `RewriteRule` in `public_html/.htaccess`:
> ```sh
> grep -oE 'tr4w_setup_[0-9.]+' public_html/.htaccess | head -1
> ```
> Releases happen roughly monthly; any version written into prose here is stale by definition.
> (This paragraph exists because `CLAUDE.md` sat four releases behind reality.)

Installers are binary — never `cat`/read them; exclude `public_html/**/*.exe` from bulk search.

## Download redirect (how the homepage links work)

The download buttons in `index.html` point at **stable, version-free URLs** and never change:

```
https://tr4w.net/download/tr4w_setup.exe          (main installer)
https://tr4w.net/download/tr4w_setup_<lang>.exe   (ukr/rom/ser/ger/rus/cze/mng)
```

`public_html/.htaccess` 302-redirects those to the current versioned files via one rule:

```apache
# shape only — the live version is whatever is in the file, see above
RewriteRule ^download/tr4w_setup(_[a-z]{3})?\.exe$ https://tr4w.net/<MAJOR>/tr4w_setup_<VER>$1.exe [R=302,L]
```

So a release only changes **one line** here (and the display labels in `index.html`), not 9 links.

> **⚠️ Server dependency — do not lose this.** This redirect only works because the host
> (Apache 2.4, Ubuntu) was configured to honor `.htaccess` for this docroot. Ubuntu's stock
> `AllowOverride None` on `/var/www/` silently ignores all `.htaccess` files. The fix is on the
> server in `/etc/apache2/conf-available/tr4w-override.conf`:
> ```apache
> <Directory /var/www/tr4w.net/public_html>
>     AllowOverride All
>     Require all granted
> </Directory>
> ```
> plus `a2enmod rewrite headers`. If `/download/...` ever starts returning **404**, this override
> (or `mod_rewrite`) got disabled — check there first, not the `.htaccess`.

## Releases

**One command, after the GitHub release is published:**

```sh
bin/publish-release.sh <VER> "<MONTH YEAR>"     # e.g. 4.150.0 "August 2026"
```

`bin/publish-release.sh` is the executable form of
[`bin/RELEASE_RUNBOOK.md`](bin/RELEASE_RUNBOOK.md) — **read the runbook before changing
either.** It fetches the 9 installers from the GitHub release, uploads them to the host,
refreshes the standalone `TRMASTER.DTA`, runs `bin/release.sh`, commits, pushes to `main`,
waits for the deploy workflow, and verifies the live redirects. It stops at the first
failed check, and prompts `y/N` before every irreversible action (`--dry-run` to rehearse,
`--yes` to skip prompts).

Three things it decides by hashing rather than asking, which you should not undo:
- **The `TRMASTER.DTA` inside the installer is authoritative**, not the copy committed to
  `TR4W/TR4W`. The repo copy is a cross-check; a mismatch means the build machine shipped
  something it didn't commit.
- **Whether the callsign DB changed** is determined **installer-to-installer** — this
  release's DTA vs the one in the currently advertised release — not against the live
  standalone file, so the answer survives a re-run after a partial failure. It drives the
  `Callsign database · <MONTH>` label: `bin/release.sh` advances *every* date on the page,
  so `publish-release.sh` reverts that one when the DB is unchanged.
- **Whether the standalone file needs uploading** is a separate check against the live copy,
  purely so a re-run skips a redundant upload. Don't collapse these two back together.

**A release resets the standalone `TRMASTER.DTA` to the installer's copy — mid-month builds
are transient by design.** Hand-building a DTA between releases is normal practice (e.g. the
2026-07-10 WRTC2026 special callsigns); the next release overwrites it because the
regenerated database supersedes it. Intended, not data loss — the live copy is backed up to
`TRMASTER.DTA.bak-<YYYYMMDD>` first. **Do not "fix" the script to preserve a divergent
standalone file.** See the runbook for the full reasoning.

The pieces it drives, if you ever need them individually:

1. Installers are built in the **TR4W/TR4W** repo and uploaded to `<DOCROOT>/<MAJOR>/`
   (9 files: main + 8 langs). They are gitignored — they never go through this repo.
2. `bin/release.sh <version> "<month year>"` validates all 9 installers are live
   (curl → 200) before editing — refusing otherwise — then rewrites the `.htaccess`
   redirect target and the display labels in `index.html` and prints a diff. It does
   **not** commit or deploy.
3. **Deploy is automatic.** Merging/pushing to `main` triggers the GitHub Actions
   workflow (`.github/workflows/deploy.yml`), which rsyncs the changed text files to
   the server. Watch the run in the repo's **Actions** tab.
4. Verify: `curl -sI https://tr4w.net/download/tr4w_setup.exe` → expect `302` to the new dir.

> **GitHub is the single source of truth for deploys — never rsync from a laptop.**
> `bin/deploy.sh` is the rsync used *by CI only*: it refuses to run unless `DEPLOY_DEST`
> is set (which only the workflow sets), so a local working copy can't be pushed to prod.

## LookingGlass (`LookingGlass/`)

Vendored copy of Nick Adams' "User friendly PHP Looking Glass" v1.3.0 (MIT). Runs server-side
network diagnostics against a user-supplied host.

- `LookingGlass.php` — command class; builds shell commands via `proc_open` and streams output.
- `Config.php` — site config (generated by `configure.sh`).
- `RateLimit.php` — per-IP hourly rate limiting via `ratelimit.db` (SQLite); disabled when limit is `0`.
- `lookingglass-http.nginx.conf` — sample nginx vhost (upstream author's paths; not tr4w-specific).

**Security caution:** this tool executes network commands with user input. It sanitizes via
`filter_var(..., FILTER_SANITIZE_URL)`, strips single quotes, and validates IPs/URLs, but it is
still a remote-command surface. If asked to modify command construction or input handling, treat it
as security-sensitive — preserve the validation/sanitization; do not introduce new shell
interpolation of unvalidated input.

## Working in this repo

- **No build/test/lint for the site.** Edits to `index.html`/PHP/`.htaccess` are the deliverable;
  verify by inspection (and curl against the live site after deploy).
- **Deployment = push to `main`; GitHub Actions rsyncs to prod.** `.github/workflows/deploy.yml`
  is the only thing that deploys (rsync **without** `--delete`, binaries excluded). Do **not**
  rsync from a laptop — GitHub is the single source of truth. Apache config and the one-off
  server-state changes (host hygiene, backups before overwriting) are still manual and, per global
  rules, **never** done without explicit approval.
- **Server hygiene (already handled, don't regress):** `info.php` (phpinfo) is removed (404);
  `serial+key.txt` (an old third-party Delphi 7 key, not ours) is blocked (403). The public
  `NSIS/` toolkit + `full.nsi` on the server are harmless leftover cruft, low-priority cleanup.
- **Binary installers** (`*.exe`) are large/numerous — never read them; exclude from bulk ops.
