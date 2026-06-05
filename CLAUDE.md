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
| `public_html/4.NN/` | One directory per TR4W release (4.31 → 4.148, ~116 dirs). Holds the Windows installer plus 8 localized builds. |
| `public_html/*/tr4wmaintlist.html` | Per-version maintenance/changelog pages. |
| `bin/release.sh` | Release helper — repoints the site at a new major version (see Releases). |
| `public_html/tr4w_contests.html` | Searchable table of supported contests — **generated**, do not hand-edit. |
| `tools/contests/` | Generator + vendored data for the contest list page (`build_contests.py`, see its README). |
| `LookingGlass/` | Third-party PHP looking-glass tool (ping/traceroute/mtr/host). |

## Filename / versioning convention

Versions are `4.<minor>.<patch>`. **The naming convention changed over time:**
- Older dirs (≤ ~4.97): underscore — `tr4w_setup_4_97.11.exe`.
- Current dirs (e.g. 4.148): dots — `tr4w_setup_4.148.1.exe`.

Localized builds append a 3-letter suffix before `.exe`: `_cze _esp _ger _mng _rom _rus _ser _ukr`
(Czech, Spanish, German, Mongolian, Romanian, Russian, Serbian, Ukrainian). The current advertised release
is **4.148.1**. Installers are binary — never `cat`/read them; exclude `public_html/**/*.exe` from
bulk search.

## Download redirect (how the homepage links work)

The download buttons in `index.html` point at **stable, version-free URLs** and never change:

```
https://tr4w.net/download/tr4w_setup.exe          (main installer)
https://tr4w.net/download/tr4w_setup_<lang>.exe   (ukr/rom/ser/ger/rus/cze/mng)
```

`public_html/.htaccess` 302-redirects those to the current versioned files via one rule:

```apache
RewriteRule ^download/tr4w_setup(_[a-z]{3})?\.exe$ https://tr4w.net/4.148/tr4w_setup_4.148.1$1.exe [R=302,L]
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

When a new major release ships (e.g. 4.149 in July 2026):

1. Build the installers (in the TR4W/TR4W repo) and **upload them to the server** under the new
   dir, e.g. `/var/www/tr4w.net/public_html/4.149/` (9 files: main + 8 langs). They are gitignored,
   so they do not go through this repo.
2. Run `bin/release.sh <version> "<month year>"`, e.g. `bin/release.sh 4.149.1 "July 2026"`.
   It **validates all 8 installers are live** (curl → 200) before editing — refusing otherwise —
   then rewrites the `.htaccess` redirect target and the display labels in `index.html`, and prints
   a diff. It does **not** commit or deploy.
3. Review the diff, `git commit`, and get it onto `main` (PR from a branch, or push
   straight to `main`).
4. **Deploy is automatic.** Merging/pushing to `main` triggers the GitHub Actions
   workflow (`.github/workflows/deploy.yml`), which rsyncs the changed text files to
   the server. Installers are already up (uploaded out-of-band). Watch the run in the
   repo's **Actions** tab.
5. Verify: `curl -sI https://tr4w.net/download/tr4w_setup.exe` → expect `302` to the new dir.

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
