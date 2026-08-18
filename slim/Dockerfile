ARG PYTHON_TAG=3.12-slim
ARG TA_LIB_VERSION=0.6.3

FROM python:${PYTHON_TAG} AS builder
ARG TA_LIB_VERSION
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        wget \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /tmp
RUN wget -q https://github.com/TA-Lib/ta-lib/releases/download/v${TA_LIB_VERSION}/ta-lib-${TA_LIB_VERSION}-src.tar.gz \
    && tar -xvf ta-lib-${TA_LIB_VERSION}-src.tar.gz \
    && cd ta-lib-${TA_LIB_VERSION} \
    && ./configure --prefix=/usr --build=$(/bin/arch)-unknown-linux-gnu \
    && make \
    && make install \
    && ldconfig \
    && cd / \
    && rm -rf /tmp/ta-lib*

FROM python:${PYTHON_TAG}
ARG PYTHON_TAG
ARG TA_LIB_VERSION
ARG CREATED_AT=unset
COPY --from=builder /usr/lib/libta_lib* /usr/lib/
COPY --from=builder /usr/include/ta-lib /usr/include/ta-lib
RUN ldconfig
LABEL org.opencontainers.image.title="danazkari/python-talib-slim" \
      org.opencontainers.image.description="python:${PYTHON_TAG} + TA-Lib v${TA_LIB_VERSION} C library (runtime + headers)" \
      org.opencontainers.image.source="https://github.com/danazkari/python-talib-slim" \
      org.opencontainers.image.created="${CREATED_AT}"
RUN python3 -c "import ctypes; ctypes.CDLL('libta_lib.so.0'); print('ta-lib OK')"
