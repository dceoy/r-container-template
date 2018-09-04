FROM dceoy/r-tidyverse:latest

ENV CRAN_URL https://cloud.r-project.org/

RUN set -e \
      && apt-get -y update \
      && apt-get -y dist-upgrade \
      && apt-get -y install --no-install-recommends --no-install-suggests \
                            librsvg2-bin lmodern texlive-fonts-recommended texlive-xetex \
      && apt-get -y autoremove \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

RUN set -e \
      && clir update \
      && clir install --devt=cran doParallel foreach gridExtra rmarkdown tidyverse \
      && clir validate dbplyr doParallel foreach gridExtra rmarkdown tidyverse

ENTRYPOINT ["/usr/bin/R"]
