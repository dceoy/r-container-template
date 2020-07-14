#!/usr/bin/env Rscript

'Run a data analysis worlkflow

Usage:
  main.R [-v] [--in=<dir>] [--out=<dir>] [--thread=<int>] [--seed=<int>]

Options:
  --in=<dir>      Set an input directory [default: ./input]
  --out=<dir>     Set an output directory [default: ./output]
  --thread=<int>  Limit multithreading
  --seed=<int>    Set a random seed
  -v              Run with debug logging
   --version      Print version and exit
  -h, --help      Print help and exit
' -> doc

script_version <- 'v0.0.1'


fetch_script_root <- function() {
  ca <- commandArgs(trailingOnly = FALSE)
  fa <- ca[startsWith(ca, '--file=')]
  if (length(fa) >= 1) {
    f <- strsplit(fa[1], '=')[[1]][2]
    l <- Sys.readlink(f)
    if (l == '') {
      script_path <- normalizePath(f)
    } else if (startsWith(l, '/')) {
      script_path <- normalizePath(l)
    } else {
      script_path <- normalizePath(file.path(dirname(f), l))
    }
    return(dirname(script_path))
  } else {
    return(normalizePath(getwd()))
  }
}


main <- function(opts, rscripts = NULL, rmd = NULL, pkgs = NULL,
                 root_dir = fetch_script_root()) {
  options(warn = 1)

  if (opts[['-v']]) print(opts)
  n_thread <- ifelse(is.null(opts[['--thread']]),
                     parallel::detectCores(), as.integer(opts[['--thread']]))

  if (! is.null(opts[['--seed']])) {
    message('>>> Set a random seed')
    set.seed(opts[['--seed']])
    message(opts[['--seed']])
  }

  message('>>> Load functions')
  all_pkgs <- union(c('devtools', 'rmarkdown', 'tidyverse'), pkgs)
  print(suppressMessages(sapply(all_pkgs, require, character.only = TRUE)))
  lapply(file.path(root_dir, rscripts), source)

  message('>>> Set io directories')
  dirs <- lapply(c(i = '--in', o = '--out'),
                 function(f, opts) return(opts[[f]]), opts = opts)
  print(unlist(dirs), quote = FALSE)

  message('>>> Make output directories')
  print(sapply(file.path(dirs$o,
                         c('bib', 'csv', 'docx', 'html', 'md', 'pdf', 'png',
                           'rds', 'svg', 'txt')),
               dir.create, showWarnings = opts[['-v']], recursive = TRUE))

  message('>>> Write session information')
  write_session(dir = file.path(dirs$o, 'txt'))
  write_pkg_bib(all_pkgs, dir = file.path(dirs$o, 'bib'))

  if (n_thread > 1) {
    message('>>> Make a cluster')
    registerDoParallel(cl <- makeCluster(n_thread))
    message(n_thread)
  }

  #
  # message('>>> Start the anaysis workflow')
  # start_some_analyses()
  #

  if (! is.null(rmd)) {
    message('>>> Render Rmarkdown')
    render_rmd(file.path(root_dir, rmd),
               out_dir = dirs$o, quiet = ! opts[['-v']])
  }

  if (n_thread > 1) {
    message('>>> Stop a cluster')
    stopCluster(cl)
  }
}


if (interactive()) {
  #
  # message('>>> Start interactive anayses')
  # prepare_interactive_analyses()
  #
} else {
  require('docopt', quietly = TRUE)
  main(opts = docopt::docopt(doc, version = script_version),
       rscripts = c('src/util.R'), rmd = 'src/index.Rmd',
       pkgs = c('doParallel', 'foreach', 'gridExtra'))
}
