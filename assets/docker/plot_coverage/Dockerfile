FROM python:3.12-slim

COPY coverage.py .

RUN pip install pysam
RUN pip install matplotlib
RUN pip install Bio

WORKDIR /data

COPY coverage.py /data/coverage.py

CMD ["/bin/bash"]
