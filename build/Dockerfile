FROM dceoy/r-jupyter:latest

RUN set -e \
      && apt-get -y update \
      && apt-get -y dist-upgrade \
      && apt-get -y autoremove \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

RUN set -e \
      && clir update

ENTRYPOINT ["/usr/bin/R"]
