FROM dceoy/r-tidyverse

ENV CRAN_URL https://cloud.r-project.org/

RUN set -e \
      && apt-get -y update \
      && apt-get -y upgrade \
      && apt-get -y install librsvg2-bin texlive-xetex \
      && apt-get -y autoremove \
      && apt-get clean

RUN set -e \
      && R -e "\
      pkgs <- c('docopt', 'doParallel', 'foreach', 'gridExtra', 'rmarkdown', 'tidyverse'); \
      devtools::update_packages(pkgs = pkgs, dependencies = TRUE, repos = '${CRAN_URL}'); \
      sapply(pkgs, require, character.only = TRUE);"

ENTRYPOINT ["/usr/bin/R"]
