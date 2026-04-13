FROM alpine:3.23

RUN apk add curl libosmium g++ make cmake zlib-dev expat-dev bzip2-dev lz4-dev
RUN apk add duckdb --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/
RUN duckdb -c 'INSTALL spatial; INSTALL osmium FROM community;'

COPY process.sh entrypoint.sh postprocess.sh /run/layercake/
COPY sql /run/layercake/sql
WORKDIR /run/layercake

RUN chmod +x process.sh entrypoint.sh

ENTRYPOINT ["/run/layercake/entrypoint.sh"]
