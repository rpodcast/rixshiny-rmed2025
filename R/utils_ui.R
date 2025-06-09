render_welcome <- function(golem_version = golem::get_golem_version(), render_markdown = TRUE) {
  welcome_text <- readLines(app_sys("app", "www", "docs", "welcome.md"))
  if (render_markdown) {
    welcome_text <- htmltools::HTML(markdown::mark(welcome_text, output = NULL))
  }
  return(welcome_text)
}