FROM python:3.12-slim

COPY histogram.py .

RUN pip install pysam
RUN pip install matplotlib

WORKDIR /data

COPY histogram.py /data/histogram.py

CMD ["/bin/bash"]
