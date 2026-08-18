# Versioning

## Tag scheme

```
ghcr.io/<owner>/python-talib-slim:<py>-talib<talib>-r<rev>
example:                3.12-slim-talib0.6.3-r3
```

| Part | Meaning | Bumps when |
|---|---|---|
| `<py>` | Python base tag (e.g. `3.12-slim`, `3.14-slim`) | Major Python upgrade |
| `<talib>` | TA-Lib release (e.g. `0.6.3`) | TA-Lib publishes a new release |
| `<rev>` | Rebuild counter inside one (py, talib) pair | TA-Lib C library or BuildKit cache invalidation requires a re-bake |

`:stable` is a mutable pointer to the latest pushed tag and is updated by the
release workflow.

## When rev bumps

`r` does **not** bump on every commit. It bumps when the rebuilt image differs
from the previous build of the same `(py, talib)` pair. Practical triggers:

- A change to `slim/Dockerfile` (e.g. update `ldconfig`, change layer order).
- A change to the base image dependency (`python:<py>`).
- A Renovate PR that updates `TA_LIB_VERSION`.
- Manual `workflow_dispatch` with a forced `rev` (rare; usually for re-bakes
  after a TA-Lib CVE).

## Compatibility matrix

The downstream consumer (e.g. auguris `Dockerfile.slim`) pins exactly one
tag, e.g. `:3.12-slim-talib0.6.3-r3`. Bumping requires:

1. New revision published here (Greens CI; whitelist only).
2. Consumer repo updates `BASE_IMAGE` reference and pins to the new tag.
3. Consumer `Dockerfile.slim` rebuild tested end-to-end.

Until 2-3 complete, the previous tag stays accessible via its immutable
name. We never delete tags; old revs are deprecated in name only.

## Rollback

Pin the previous tag in the consumer. The base repo's `slim/VERSIONS`
contains the latest `r` value; rollback = ref `--build-arg BASE_IMAGE=...
`rev<N-1>.

## Why immutable + mirror

- **Immutable**: each `r<N>` is content-addressed. Downstream digest-pins
  prevent silent image swaps.
- **Mirror**: Docker Hub is a long-standing discovery surface; the canonical
  GHCR copy is the source of truth.
