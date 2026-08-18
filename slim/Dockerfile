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
        && ./configure --prefix=/opt/ta-lib --build=$(/bin/arch)-unknown-linux-gnu \
        && make \
        && make install \
        && cd / \
        && rm -rf /tmp/ta-lib*

FROM python:${PYTHON_TAG}
ARG PYTHON_TAG
ARG TA_LIB_VERSION
ARG CREATED_AT=unset
COPY --from=builder /opt/ta-lib /opt/ta-lib
RUN if [ -d /usr/lib/x86_64-linux-gnu ]; then \
        cp /opt/ta-lib/lib/libta-lib* /usr/lib/x86_64-linux-gnu/; \
        cp -r /opt/ta-lib/include/ta-lib /usr/include/ta-lib; \
        ldconfig /usr/lib/x86_64-linux-gnu; \
    else \
        cp /opt/ta-lib/lib/libta-lib* /usr/lib/; \
        cp -r /opt/ta-lib/include/ta-lib /usr/include/ta-lib; \
        ldconfig; \
    fi
LABEL org.opencontainers.image.title="danazkari/python-talib-slim" \
      org.opencontainers.image.description="python:${PYTHON_TAG} + TA-Lib v${TA_LIB_VERSION} C library (runtime + headers)" \
      org.opencontainers.image.source="https://github.com/danazkari/python-talib-slim" \
      org.opencontainers.image.created="${CREATED_AT}"
RUN python3 -c "import ctypes; ctypes.CDLL('libta-lib.so.0'); print('ta-lib system lib OK')"
