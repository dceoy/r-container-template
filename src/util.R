#!/usr/bin/env Rscript

sapply(c('devtools', 'rmarkdown', 'tidyverse'),
       require, character.only = TRUE, quietly = TRUE)

to_pdf <- function(graph, path, w = 13, h = 8, to_png = TRUE) {
  if (file.exists(path)) file.remove(path)
  if (to_png) {
    png_path <- str_replace_all(path, 'pdf', 'png')
    png(png_path, width = w * 100, height = h * 100)
    if (file.exists(png_path)) file.remove(png_path)
    dev_pdf <- dev.cur()
  }
  pdf(path, width = w, height = h, onefile = FALSE)
  dev.control('enable')
  graph
  if (to_png) {
    dev.copy(which = dev_pdf)
    message(str_c('  ', png_path))
    dev.off()
  }
  message(str_c('  ', path))
  dev.off()
}

to_svg <- function(graph, path, w = 13, h = 8) {
  svg(path, width = w, height = h)
  graph
  dev.off()
  message(str_c('  ', path))
}

to_rds <- function(object, path, use_cache = FALSE) {
  if (use_cache && file.exists(path)) {
    return(readRDS(path))
  } else {
    saveRDS(object, file = path)
    message(str_c('  ', path))
    return(object)
  }
}

to_csv <- function(df, path, append = FALSE, use_cache = FALSE) {
  if (use_cache && file.exists(path)) {
    return(readr::read_csv(path))
  } else {
    readr::write_csv(df, path = path, append = append)
    message(str_c('  ', path))
    return(df)
  }
}

write_session <- function(dir = './') {
  r_version_txt <- file.path(dir, 'r_version.txt')
  suppressMessages(capture.output(version, file = r_version_txt))
  message(str_c('  ', r_version_txt))
  session_info_txt <- file.path(dir, 'session_info.txt')
  suppressMessages(capture.output(devtools::session_info(),
                                  file = session_info_txt))
  message(str_c('  ', session_info_txt))
}

write_pkg_bib <- function(pkgs, dir = './') {
  sapply(union('base', pkgs),
         function(p) {
           path <- file.path(dir, str_c(p, '.bib'))
           write(toBibtex(citation(p)), file = path)
           message(str_c('  ', path))
         })
}

render_rmd <- function(path, out_dir, quiet = FALSE) {
  lapply(list(list(ext = 'html', format = 'html_document'),
              list(ext = 'docx', format = 'word_document'),
              list(ext = 'pdf', format = 'pdf_document'),
              list(ext = 'md', format = 'md_document')),
         function(l, path, name) {
           render(path, output_dir = file.path(out_dir, l$ext),
                  output_format = l$format, quiet = quiet)
           message(str_c('  ',
                         file.path(out_dir, l$ext, str_c(name, '.', l$ext))))
         },
         path = path,
         name = str_replace(basename(path), '.Rmd', ''))
}
