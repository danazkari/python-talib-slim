# danazkari/python-talib-slim images

Base Docker images that pair a slim Debian Python with the TA-Lib C library
(lib + headers). Published primarily to GHCR; mirrored to Docker Hub.

## Why

Compiling TA-Lib from source takes ~20 minutes. The `slim/` image bakes that
one-time so any downstream `Dockerfile` that needs TA-Lib can `FROM` here and
skip the build.

## Image layout

| Tag | Base | TA-Lib | Use |
|---|---|---|---|
| `3.12-slim-talib0.6.3-r<N>` | `python:3.12-slim` | 0.6.3 | prod default for slim profile |
| `3.13-slim-talib0.6.3-r<N>` | `python:3.13-slim` | 0.6.3 | future-proofing |
| `stable` | latest pushed | latest | human-friendly default |

`<N>` is the immutability counter — every rebuild bumps it.

## How to consume

In a downstream Dockerfile:

```dockerfile
ARG BASE_IMAGE_DEFAULT=ghcr.io/danazkari/python-talib-slim:3.12-slim-talib0.6.3-r1
FROM ${BASE_IMAGE_DEFAULT}
USER root
RUN pip install --no-cache-dir uv
# ... rest of your build
```

To verify TA-Lib is wired up in the resulting container:

```bash
docker run --rm <your-image> python3 -c "import ctypes; ctypes.CDLL('libta_lib.so.0')"
```

## Build locally

```bash
PY_TAG=3.12-slim TA_LIB_VER=0.6.3 bash slim/build.sh
docker run --rm danazkari/python-talib-slim:stable python3 -c "import ctypes; ctypes.CDLL('libta_lib.so.0')"
```

`PLATFORM=linux/arm64` is supported by `--platform`.

## Release flow

Pushing to `main` runs `.github/workflows/release.yml`:

1. Reads inputs (or defaults: `py_tag=3.12-slim`, `ta_lib_version=0.6.3`).
2. Computes next `r{N}` from `slim/VERSIONS`.
3. Builds + pushes `ghcr.io/<owner>/python-talib-slim:<tag>` and `:stable`.
4. Mirrors to Docker Hub if `DOCKERHUB_USERNAME` + `DOCKERHUB_TOKEN` secrets
   are present.
5. Bumps `slim/VERSIONS` and commits.

Manual runs (`workflow_dispatch`) accept `py_tag`, `ta_lib_version`, and
optional forced `rev`.

See [VERSIONING.md](./VERSIONING.md) for rev rules and compatibility matrix.
