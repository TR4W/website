# Release runbook — getting a new version onto the website

**After you publish a GitHub release, do this to update tr4w.net:**

```sh
bin/publish-release.sh <VER> "<MONTH YEAR>"      # e.g. 4.150.0 "August 2026"
```

That's the whole thing. The script is the executable form of this document — it runs
every step below in order, verifies each one, and stops on the first failure. Rehearse
it first with `--dry-run` if you want to see the plan without writing anything.

> **The website never reads GitHub releases.** It serves installers hosted on
> *its own* server (`public_html/<MAJOR>/`) and points the Download button there
> via a single `.htaccess` redirect line. Publishing on GitHub is step 0 — it does
> **nothing** to the site by itself. The installers must be physically on the
> tr4w.net host or nothing downstream works.

Notation used below:
- `<VER>`   — full version, e.g. `4.150.0`
- `<MAJOR>` — major dir, e.g. `4.150`  (`<VER>` with the patch dropped)
- `<TAG>`   — the GitHub release tag, e.g. `v4.150.0-all`
- `<MONTH YEAR>` — release month, e.g. `August 2026`

The 8 language suffixes are: `_ukr _rom _ser _ger _rus _cze _mng _esp`.

---

## What the script does

| # | Step | Refuses to continue if… |
|---|------|--------------------------|
| 1 | Preflight: tools, `gh` auth, on `main`, clean tree, up to date with origin, ssh works | any of those fail, or the site already advertises `<VER>` |
| 2 | Downloads the 9 installers from the GitHub release | fewer than 9 assets match `tr4w_setup_<VER>*.exe` |
| 3 | **Extracts `TRMASTER.DTA` from the installer** and compares it to `TR4W/TR4W:tr4w/target/TRMASTER.DTA` | they differ (prompts; the installer's copy wins) |
| 4 | rsyncs the installers to `<MAJOR>/`, then curls all 9 | any URL is not `200` |
| 5 | Backs up and replaces the standalone `TRMASTER.DTA` — **only if the DB actually changed** | the live copy doesn't hash-match afterwards |
| 6 | Runs `bin/release.sh`, then un-does the callsign-database date if the DB didn't change | `release.sh` fails |
| 7 | Commits, pushes to `main`, waits for the deploy workflow | the workflow fails |
| 8 | Verifies all 9 `/download/` URLs 302 to `<MAJOR>/`, and the homepage labels | any redirect or label is wrong |

Options: `--dry-run`, `--yes` (no prompts), `--skip-upload` (installers already on the
host), `--no-push` (stop after the local commit), `--tag <TAG>` (non-default tag name).

Every irreversible action — uploading to the host, overwriting the live `TRMASTER.DTA`,
pushing to `main` — prompts `y/N` first unless you pass `--yes`.

### Two judgment calls the script makes for you

**Which `TRMASTER.DTA` is authoritative?** The one *inside the installer*. The standalone
download at `https://tr4w.net/TRMASTER.DTA` exists so people can grab just the database;
it must match what the installer ships. The copy committed to `TR4W/TR4W` is used only as
a cross-check, and a mismatch means the build machine didn't commit what it shipped.

> This inverts the old procedure, which trusted the repo copy blind with only a `wc -c`
> sanity check. That catches an HTML error page but *not* a stale-yet-valid database —
> so there was no way to tell "the build machine failed" from "the build machine is fine".

**A release resets the standalone `TRMASTER.DTA` to the installer's copy, so any mid-month
build is transient by design.** Publishing a hand-built DTA between releases is fine and
expected — e.g. `2026-07-10`, special callsigns for WRTC2026 — but the next release
overwrites it, because by then the regenerated database supersedes it. This is intended,
not data loss: step 5 backs the live copy up to `TRMASTER.DTA.bak-<YYYYMMDD>` first. Don't
"fix" the script to preserve a divergent standalone file.

**Did the callsign database change?** Decided by hashing, not by asking: the script
compares the installer's DTA against what the site currently serves. Identical means the
DB didn't change, so it skips the upload *and* leaves the
`TRMASTER.DTA — Callsign database · <MONTH>` label in `index.html` alone. (`bin/release.sh`
advances every date string on the page, including that one — the script reverts it.)

---

## Manual fallback

If the script is broken or you need to run one step in isolation, this is what it
automates. **Prefer the script** — these steps have no cross-checks.

### 1. Upload the 9 installers to the web server  *(webserver side)*

```sh
gh release download <TAG> --repo TR4W/TR4W --pattern 'tr4w_setup_<VER>*.exe' --dir /tmp/<MAJOR>
rsync -av /tmp/<MAJOR>/ TR4W:/var/www/tr4w.net/public_html/<MAJOR>/
```

Nine files total: `tr4w_setup_<VER>.exe` + the 8 language builds.

### 2. Verify they are live

```sh
for f in "" _ukr _rom _ser _ger _rus _cze _mng _esp; do
  curl -sS -o /dev/null -w "%{http_code}  https://tr4w.net/<MAJOR>/tr4w_setup_<VER>$f.exe\n" \
    "https://tr4w.net/<MAJOR>/tr4w_setup_<VER>$f.exe"
done
```

Every line must be `200`. If any is `404`, step 4 will refuse to run.

### 3. Refresh the standalone TRMASTER.DTA  *(webserver side)*

Take it from the installer, not from the repo — that is the copy users actually receive:

```sh
7z e -y /tmp/<MAJOR>/tr4w_setup_<VER>.exe -o/tmp/dta 'TRMASTER.DTA' -r
shasum -a 256 /tmp/dta/TRMASTER.DTA
```

Cross-check that the build machine committed the same bytes (a mismatch is a build-side
bug — publish the installer's copy anyway, then go fix the build):

```sh
curl -fL -o /tmp/repo.DTA \
  "https://raw.githubusercontent.com/TR4W/TR4W/master/tr4w/target/TRMASTER.DTA"
cmp /tmp/dta/TRMASTER.DTA /tmp/repo.DTA && echo "match"
```

Then check whether it differs from what is already live — if it does **not**, skip the
rest of this step and do **not** let `release.sh` advance the `TRMASTER.DTA — Callsign
database · <MONTH>` label:

```sh
curl -fsL -o /tmp/live.DTA https://tr4w.net/TRMASTER.DTA
cmp -s /tmp/dta/TRMASTER.DTA /tmp/live.DTA && echo "DB unchanged — skip the upload"
```

Back up before overwriting, then upload and verify:

```sh
ssh TR4W 'cp -p /var/www/tr4w.net/public_html/TRMASTER.DTA \
             /var/www/tr4w.net/public_html/TRMASTER.DTA.bak-$(date +%Y%m%d)'
rsync -av /tmp/dta/TRMASTER.DTA TR4W:/var/www/tr4w.net/public_html/TRMASTER.DTA
curl -fsL https://tr4w.net/TRMASTER.DTA | shasum -a 256   # must match the hash above
```

### 4. Repoint the site  *(repo side)*

```sh
bin/release.sh <VER> "<MONTH YEAR>"
```

It re-checks all 9 installers return `200`, then rewrites the single `.htaccess`
redirect target and the version/date labels in `index.html`, and prints a diff.
It does **not** commit or deploy. (Note: it advances **every** date string in
`index.html`, including the TRMASTER line — see the caveat in step 3.)

### 5. Commit + push to `main`

Review the diff, commit, and push (branch + PR, or straight to `main`).
Pushing/merging to `main` triggers `.github/workflows/deploy.yml`, which rsyncs
the changed text files to the server.

> **Never rsync the site from a laptop** — GitHub is the single source of truth.
> `bin/deploy.sh` refuses to run unless `DEPLOY_DEST` is set, which only CI sets.

### 6. Confirm the Download button

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
