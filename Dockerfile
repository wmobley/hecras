FROM debian:bullseye-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bash \
       python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tapis

COPY run.sh ./run.sh
COPY Linux_RAS_v66 ./Linux_RAS_v66
COPY scripts ./scripts

RUN chmod +x /tapis/run.sh \
    && find /tapis/Linux_RAS_v66 -type f -name "*.sh" -exec chmod +x {} \; \
    && find /tapis/scripts -type f -name "*.py" -exec chmod +x {} \;

ENTRYPOINT [ "/tapis/run.sh" ]
