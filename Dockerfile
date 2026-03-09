FROM alpine:3.23

RUN apk add curl libosmium g++ make cmake python3 python3-dev py3-pip py3-virtualenv py3-pyarrow zlib-dev expat-dev bzip2-dev lz4-dev
RUN apk add duckdb --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/
RUN duckdb -c 'INSTALL SPATIAL'

COPY . /run/layercake
WORKDIR /run/layercake

RUN python -m venv --system-site-packages venv
RUN venv/bin/pip install -r requirements.txt

ENTRYPOINT ["/run/layercake/entrypoint.sh"]
