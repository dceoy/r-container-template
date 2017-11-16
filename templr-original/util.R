#!/usr/bin/env Rscript

sapply(c('devtools', 'rmarkdown', 'stringr', 'tidyverse'),
       require, character.only = TRUE, quietly = TRUE)

name_v <- function(v, name) {
  names(v) <- name
  return(v)
}

to_svg <- function(graph, file, w = 12, h = 9, svg2png = TRUE, svg2pdf = TRUE) {
  svg(file, width = w, height = h)
  graph
  dev.off()
  message(str_c('  ', file))
  if(svg2png) {
    png_file <- str_replace_all(file, 'svg', 'png')
    system(str_c('rsvg-convert -f png -o ', png_file, ' -w 1000 ', file))
    message(str_c('  ', png_file))
  }
  if(svg2pdf) {
    pdf_file <- str_replace_all(file, 'svg', 'pdf')
    system(str_c('rsvg-convert -f pdf -o ', pdf_file, ' ', file))
    message(str_c('  ', pdf_file))
  }
}

to_rds <- function(object, file, force = FALSE) {
  if(force || (! file.exists(file))) {
    saveRDS(object, file = file)
    message(str_c('  ', file))
    return(object)
  } else {
    return(readRDS(file))
  }
}

write_session <- function(dir = './') {
  suppressMessages({
    capture.output(version, file = str_c(dir, 'r_version.txt'))
    capture.output(devtools::session_info(), file = str_c(dir, 'session_info.txt'))
  })
}

write_pkg_bib <- function(pkgs, dir = './') {
  sapply(union('base', pkgs),
         function(p) write(toBibtex(citation(p)), file = str_c(dir, p, '.bib')))
}

render_rmd <- function(path, out_dir, quiet = FALSE) {
  lapply(list(list(ext = 'html', format = 'html_document'),
              list(ext = 'docx', format = 'word_document'),
              list(ext = 'pdf', format = 'pdf_document'),
              list(ext = 'md', format = 'md_document')),
         function(l, path, name) {
           render(path, output_dir = str_c(out_dir, l$ext),
                  output_format = l$format, quiet = quiet)
           message(str_c('  ', out_dir, l$ext, '/', name, '.', l$ext))
         },
         path = path,
         name = str_replace(basename(path), '.Rmd', ''))
}
