#!/usr/bin/env Rscript

'Run a data analysis worlkflow

Usage:
  main.R [--in=<dir>] [--out=<dir>] [--thread=<int>] [--seed=<int>] [--debug]

Options:
  -v, --version   Print version and exit
  -h, --help      Print help and exit
  --in=<dir>      Set an input directory [default: ./input]
  --out=<dir>     Set an output directory [default: ./output]
  --thread=<int>  Limit multithreading
  --seed=<int>    Set a random seed
  --debug         Run with debug logging' -> doc

script_version <- 'v0.0.1'


fetch_script_root <- function() {
  ca <- commandArgs(trailingOnly = FALSE)
  fa <- ca[grepl('^--file=', ca)]
  return(paste0(ifelse(length(fa) == 1, dirname(sub('--file=', '', fa)), getwd()), '/'))
}


main <- function(opts, rscripts = NULL, rmd = NULL, pkgs = NULL, root_dir = fetch_script_root()) {
  options(warn = 1)

  if(opts[['--debug']]) print(opts)
  n_thread <- ifelse(is.null(opts[['--thread']]), parallel::detectCores(), opts[['--thread']])

  if(! is.null(opts[['--seed']])) {
    message('>>> Set a random seed')
    set.seed(opts[['--seed']])
    message(opts[['--seed']])
  }

  message('>>> Load functions')
  all_pkgs <- union(c('devtools', 'rmarkdown', 'stringr', 'tidyverse'), pkgs)
  print(suppressMessages(sapply(all_pkgs, require, character.only = TRUE)))
  lapply(str_c(root_dir, rscripts), source)

  message('>>> Set io directories')
  dirs <- lapply(c(i = '--in', o = '--out'),
                 function(f, opts) {
                   return(ifelse(str_detect(opts[[f]], '/$'), opts[[f]], str_c(opts[[f]], '/')))
                 },
                 opts = opts)
  print(unlist(dirs), quote = FALSE)

  message('>>> Make output directories')
  print(sapply(str_c(dirs$o,
                     c('bib/', 'csv/', 'docx/', 'html/', 'md/', 'pdf/', 'png/', 'rds/', 'svg/',
                       'txt/')),
               dir.create, showWarnings = opts[['--debug']], recursive = TRUE))

  message('>>> Write session information')
  write_session(dir = str_c(dirs$o, 'txt/'))
  write_pkg_bib(all_pkgs, dir = str_c(dirs$o, 'bib/'))

  if(n_thread > 1) {
    message('>>> Make a cluster')
    registerDoParallel(cl <- makeCluster(n_thread))
    message(n_thread)
  }

  #
  # message('>>> Start the anaysis workflow')
  # start_some_analyses()
  #

  if(! is.null(rmd)) {
    message('>>> Render Rmarkdown')
    render_rmd(str_c(root_dir, rmd), out_dir = dirs$o, quiet = ! opts[['--debug']])
  }

  if(n_thread > 1) {
    message('>>> Stop a cluster')
    stopCluster(cl)
  }
}


if(interactive()) {
  #
  # message('>>> Start interactive anayses')
  # prepare_interactive_analyses()
  #
} else {
  require('docopt', quietly = TRUE)
  main(opts = docopt::docopt(doc, version = script_version),
       rscripts = c('R/util.R'), rmd = 'Rmd/index.Rmd',
       pkgs = c('doParallel', 'foreach', 'gridExtra'))
}
