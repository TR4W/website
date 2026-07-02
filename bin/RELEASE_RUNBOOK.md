# Release runbook — getting a new version onto the website

**After you publish a GitHub release, do these steps to update tr4w.net.**

> **The website never reads GitHub releases.** It serves installers hosted on
> *its own* server (`public_html/<MAJOR>/`) and points the Download button there
> via a single `.htaccess` redirect line. Publishing on GitHub is step 0 — it does
> **nothing** to the site by itself. The installers must be physically on the
> tr4w.net host or nothing downstream works.

Notation used below:
- `<VER>`   — full version, e.g. `4.149.0`
- `<MAJOR>` — major dir, e.g. `4.149`  (`<VER>` with the patch dropped)
- `<TAG>`   — the GitHub release tag, e.g. `v4.149.0-all`
- `<MONTH YEAR>` — release month, e.g. `July 2026`

The 8 language suffixes are: `_ukr _rom _ser _ger _rus _cze _mng _esp`.

---

## 1. Upload the 9 installers to the web server  *(webserver side)*

The site serves from `public_html/<MAJOR>/`, **not** GitHub. Pull the release
assets and drop them on the host. They are gitignored — they do **not** go
through this repo.

```sh
gh release download <TAG> --repo TR4W/TR4W --pattern 'tr4w_setup_<VER>*.exe' --dir /tmp/<MAJOR>
rsync -av /tmp/<MAJOR>/ TR4W:/var/www/tr4w.net/public_html/<MAJOR>/
```

Nine files total: `tr4w_setup_<VER>.exe` + the 8 language builds.

## 2. Verify they are live

```sh
for f in "" _ukr _rom _ser _ger _rus _cze _mng _esp; do
  curl -sS -o /dev/null -w "%{http_code}  https://tr4w.net/<MAJOR>/tr4w_setup_<VER>$f.exe\n" \
    "https://tr4w.net/<MAJOR>/tr4w_setup_<VER>$f.exe"
done
```

Every line must be `200`. If any is `404`, step 4 will refuse to run.

## 3. Refresh the standalone TRMASTER.DTA  *(webserver side, only if the callsign DB changed)*

`TRMASTER.DTA` ships **inside** the installer, but a standalone copy also lives at
`https://tr4w.net/TRMASTER.DTA` for people who want just the database. It is
gitignored and lives only on the server. If this release includes a new callsign
database, refresh it from the app repo:

```sh
# Download the RAW file (NOT the github.com/.../blob/... page — that's HTML).
# -f fails on HTTP errors instead of saving an error page; -L follows redirects.
curl -fL -o /tmp/TRMASTER.DTA \
  "https://raw.githubusercontent.com/TR4W/TR4W/master/tr4w/target/TRMASTER.DTA"

wc -c /tmp/TRMASTER.DTA        # sanity-check: a real .DTA, not a stray error page

rsync -av /tmp/TRMASTER.DTA TR4W:/var/www/tr4w.net/public_html/TRMASTER.DTA
```

Verify:
```sh
curl -sI https://tr4w.net/TRMASTER.DTA | grep -i content-length
```

> If the DB did **not** change this release, skip this step — but then do **not**
> let `release.sh` (step 4) advance the `TRMASTER.DTA — Callsign database · <MONTH>`
> date in `index.html`; that date should track the DB, not the app version.

## 4. Repoint the site  *(repo side)*

```sh
bin/release.sh <VER> "<MONTH YEAR>"
```

It re-checks all 8 installers return `200`, then rewrites the single `.htaccess`
redirect target and the version/date labels in `index.html`, and prints a diff.
It does **not** commit or deploy. (Note: it advances **every** date string in
`index.html`, including the TRMASTER line — see the caveat in step 3.)

## 5. Commit + push to `main`

Review the diff, commit, and push (branch + PR, or straight to `main`).
Pushing/merging to `main` triggers `.github/workflows/deploy.yml`, which rsyncs
the changed text files to the server.

> **Never rsync the site from a laptop** — GitHub is the single source of truth.
> `bin/deploy.sh` refuses to run unless `DEPLOY_DEST` is set, which only CI sets.

## 6. Confirm the Download button

```sh
curl -sI https://tr4w.net/download/tr4w_setup.exe | grep -i location
```

Expect a `302` to `https://tr4w.net/<MAJOR>/tr4w_setup_<VER>.exe`.

---

### The one thing people trip on

A GitHub release doesn't touch the site. If the Download button is serving an old
version after a release, check **step 1 first**: are the installers actually live
on the host (`curl` the `/<MAJOR>/` URLs)? A `404` there is the usual culprit —
not `.htaccess`, not `index.html`.
