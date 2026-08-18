# AGENTS.md

Repo instructions for AI agents (and humans) working on
`danazkari/python-talib-slim`. Read this before editing anything.

## What's in this repo

A set of slim Python TA-Lib base Docker images. The point: compile TA-Lib
once, version the result, then reused by downstream `Dockerfile`s via
`FROM ghcr.io/danazkari/python-talib-slim:<tag>`.

Layout:

```
.
|- .github/workflows/release.yml      # builds + pushes on push-to-main and on-demand
|- renovate.json                       # tracks TA-Lib upstream releases, opens PRs
|- README.md                           # human-facing overview
|- VERSIONING.md                       # tag scheme + rev-bump rules
|- slim/Dockerfile                     # the multi-stage slim TA-Lib-on-python-slim image
|- slim/build.sh                       # local dev helper (no push)
|- slim/VERSIONS                       # r-counter, incremented by the release workflow
+- slim/LAST_TAG                       # (gitignored) tag of the latest local build
```

## Hard rules

1. **Never hand-edit the `rev` counter in `slim/VERSIONS`**. The release
   workflow is the sole writer.
2. **Never push to GHCR or Docker Hub directly**. Both go through the
   workflow. If a one-shot local push is needed for an emergency fix, open
   a PR titled `release: hotfix <reason>` and let CI ship it.
3. **Never lower the `<rev>`**. Old revs stay available so downstream
   references remain valid.
4. **One image per build run**. Don't batch two `(py, talib)` pairs into
   a single workflow dispatch; run twice.

## Common tasks

### Bump TA-Lib version

Renovate opens a PR (see `renovate.json`). Merge it; `release.yml` builds
the new `<py>-talib<talib>-r1` and mirrors. Update downstream consumers
after the workflow completes.

If Renovate is off, manually edit `slim/Dockerfile`'s `ARG TA_LIB_VERSION`
line and open a PR titled `release: bump TA-Lib to <version>`.

### Add a new Python-base variant

PR with two changes:

- Update `release.yml`'s default `py_tag` inputs (if you want it on the
  menu).
- Update `README.md`'s tag table.

Then `workflow_dispatch` with `py_tag=3.13-slim` triggers the new
`<py>-talib<talib>-r1`.

### Local dev iteration on the Dockerfile

```bash
PY_TAG=3.12-slim TA_LIB_VER=0.6.3 bash slim/build.sh
docker run --rm danazkari/python-talib-slim:stable python3 -c \
    "import ctypes; ctypes.CDLL('libta_lib.so.0'); print('ok')"
```

Smoke-test before pushing. If the smoke-test passed, the layered
`ldconfig` + `import` worked and headers are at `/usr/include/ta-lib`.

### Verify a tag's contents

```bash
ghcr_image="ghcr.io/danazkari/python-talib-slim:3.12-slim-talib0.6.3-r1"
docker pull "$ghcr_image"
docker run --rm "$ghcr_image" python3 -c "
import ctypes, glob
print('libta_lib:', sorted(glob.glob('/usr/lib/libta_lib*')))
ctypes.CDLL('libta_lib.so.0')
import sys; print('python:', sys.version.split()[0])
"
```

What you should see:

- `/usr/lib/libta_lib.so.0` and `/usr/include/ta-lib/ta_abstract.h` exist.
- `ctypes.CDLL` returns without erroring.
- Python version matches the tag prefix.

## Smoke-test before merge

Whichever path you used (local or CI), the smoke-test is the same:

```bash
docker run --rm <tag> python3 -c "import ctypes; ctypes.CDLL('libta_lib.so.0'); print('TA-Lib OK')"
```

If that fails, do not merge. The image is broken; surface the failure.

## What this repo is NOT

- A general Python image registry. Use python:<x> for that.
- A TA-Lib Python-wrapper project. Use `pip install TA-Lib` against our
  base if you need the wheel.
- A replacement for `danazkari/python-talib` (the CUDA-heavy one). That
  image lives elsewhere; this one is the CPU/slim line.

## Communication with downstream

`auguris` (and similar consumers) pin via tag+digest in a
`BASE_IMAGE`/`LAST_TAG`-style file. Bump the upstream reference **only
after** the rev tag is published here. If you tag and push synchronously,
downstream CI may pull a half-published image.
