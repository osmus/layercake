FROM alpine:3.23

RUN apk add curl libosmium g++ make cmake zlib-dev expat-dev bzip2-dev lz4-dev

ENV DUCKDB_VERSION 1.5.1
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64)  DIST="linux-amd64-musl" ;; \
        aarch64) DIST="linux-arm64-musl" ;; \
        *) echo "Unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    wget -q "https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/duckdb_cli-${DIST}.zip" \
         -O /tmp/duckdb.zip && \
    unzip /tmp/duckdb.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/duckdb && \
    rm /tmp/duckdb.zip
RUN duckdb -c 'INSTALL spatial; INSTALL osmium FROM community;'

COPY process.sh entrypoint.sh postprocess.sh /run/layercake/
COPY sql /run/layercake/sql
WORKDIR /run/layercake

RUN chmod +x process.sh entrypoint.sh

ENTRYPOINT ["/run/layercake/entrypoint.sh"]
