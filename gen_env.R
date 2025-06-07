library(rix)

path_default_nix <- "."

rix(
  date = "2025-05-26",
  r_pkgs = c(
    "nhanesA",
    "golem",
    "shiny",
    "cards",
    "gt",
    "echarts4r",
    "reactable",
    "dplyr",
    "tidyr",
    "purrr",
    "renv",
    "attachment",
    "openxlsx2",
    "devtools",
    "testthat",
    "dotenv",
    "markdown",
    "pool",
    "DBI",
    "lubridate",
    "stringr",
    "survey"
  ),
  ide = "none",
  project_path = path_default_nix,
  overwrite = TRUE,
  print = FALSE
)
