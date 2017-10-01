FROM dceoy/r-tidyverse

ENV CRAN_URL https://cran.ism.ac.jp/

RUN set -e \
      && apt-get -y update \
      && apt-get -y upgrade \
      && apt-get clean

RUN set -e \
      && R -e "\
      pkgs <- c('docopt', 'doParallel', 'foreach', 'gridExtra', 'rmarkdown', 'tidyverse'); \
      devtools::update_packages(pkgs = pkgs, dependencies = TRUE, repos = '${CRAN_URL}'); \
      sapply(pkgs, require, character.only = TRUE);"

ENTRYPOINT ["/usr/bin/Rscript"]
