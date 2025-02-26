FROM python:3.12-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

COPY deconcat.py .

RUN pip install mappy

WORKDIR /data

COPY deconcat.py /data/deconcat.py

CMD ["/bin/bash"]
