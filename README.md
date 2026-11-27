# n8nbuild

Source of **`ghcr.io/mrtlearns/n8n-runners-pdflib`**, the external n8n task-runner image
(`n8nio/runners` + extras) used by our n8n queue-mode stack (`task-runners-main` / `task-runners-worker`).

## What is in the image

- Base: `docker.io/n8nio/runners:${N8N_VERSION}`
- JS runner: `pdf-lib`, `@pdf-lib/fontkit`, `uuid`, `date-fns`, `lodash`, `axios`
- Python runner venv: `pypdf`, `pikepdf`, `requests`, `beautifulsoup4`, `pydantic`, `ocrmypdf`
- OS tools: `qpdf`, `ghostscript`, `imagemagick`, `tesseract-ocr`, `unpaper` (`apk` is removed again after install)
- `runners/n8n-task-runners.json`: the upstream default launcher config for that n8n version
  (keeps upstream hardening args) plus our allowlist: JS external `pdf-lib`, builtin `crypto`;
  Python stdlib `json`, no external modules. Being installed in the image does **not** make a module
  importable from a Code node; the allowlist decides that.

## Build

`.github/workflows/build-runners.yml` runs on every push to `main` that touches `runners/**` or the
workflow, and on manual dispatch (Actions → "Build n8n runners image (pdf-lib)" → Run workflow).
It builds, runs `runners/smoke.sh` inside the image, and only then pushes:

- `ghcr.io/mrtlearns/n8n-runners-pdflib:<N8N_VERSION>`
- `ghcr.io/mrtlearns/n8n-runners-pdflib:<N8N_VERSION>-<git sha7>` (immutable)

There is no schedule and no `:latest` push. The old `:latest` tag is a stale 2.0.3-era image; do not deploy it.

## Bumping n8n (important)

`N8N_VERSION` (the `ARG N8N_VERSION=` default in `runners/Dockerfile`) **must be bumped together with
the n8n main/worker image pin** of the deployment. Runner and n8n versions must match.

1. Update `ARG N8N_VERSION=` in `runners/Dockerfile`.
2. Diff `runners/n8n-task-runners.json` against the upstream default of the new version
   (`docker run --rm --entrypoint cat n8nio/runners:<new> /etc/n8n-task-runners.json`) and carry over
   any new upstream args/env, keeping our allowlist.
3. Push to `main`, wait for the green run, note the digest from the run summary.
4. With the n8n queue idle, move main/worker **and** both runner services to the new version at the same
   time, then confirm the worker logs `Registered runner "launcher-javascript"` / `"launcher-python"`.

Re-running the build for an unchanged version re-pushes `:<N8N_VERSION>` with a **new digest**
(builds are not reproducible). Hosts that auto-update by tag will pick that up, so verify each run's
smoke output. Rollback = pin the previous digest (`ghcr.io/mrtlearns/n8n-runners-pdflib@sha256:…`).
