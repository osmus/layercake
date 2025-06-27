FROM debian:12

RUN apt update && apt install -y python3 python3-pip python3-venv python-is-python3
COPY . /run/layercake
WORKDIR /run/layercake

RUN python -m venv venv
RUN venv/bin/pip install -r requirements.txt

ENTRYPOINT ["/run/layercake/entrypoint.sh"]
