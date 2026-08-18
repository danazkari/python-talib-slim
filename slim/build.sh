#!/usr/bin/env bash
set -euo pipefail

PY_TAG="${PY_TAG:-3.12-slim}"
TA_LIB_VER="${TA_LIB_VER:-0.6.3}"
PLATFORM="${PLATFORM:-linux/amd64}"
CREATED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

COUNT_FILE="slim/VERSIONS"
[[ -f "$COUNT_FILE" ]] || echo "0" > "$COUNT_FILE"
REV=$(( $(cat "$COUNT_FILE") + 1 ))
echo "$REV" > "$COUNT_FILE"

TAG="${PY_TAG}-talib${TA_LIB_VER}-r${REV}"

docker buildx build \
  --platform "${PLATFORM}" \
  --load \
  --build-arg PYTHON_TAG="${PY_TAG}" \
  --build-arg TA_LIB_VERSION="${TA_LIB_VER}" \
  --build-arg CREATED_AT="${CREATED_AT}" \
  -t "danazkari/python-talib-slim:${TAG}" \
  -t "danazkari/python-talib-slim:stable" \
  -f slim/Dockerfile \
  .

echo "${TAG}" > slim/LAST_TAG
echo "Built: danazkari/python-talib-slim:${TAG}"
