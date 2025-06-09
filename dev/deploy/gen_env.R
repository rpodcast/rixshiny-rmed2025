library(rix)

path_default_nix <- "."

if (nzchar(Sys.getenv("INSTALL_APP_PACKAGE"))) {
  local_r_pkgs <- "app.tar.gz"
} else {
  local_r_pkgs <- NULL
}

rix(
  date = "2025-05-26",
  r_pkgs = c(
    "nhanesA",
    "golem",
    "shiny",
    "cards",
    "gt",
    "gtsummary",
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
    "survey",
    "srvyr",
    "teal.slice",
    "rix"
  ),
  local_r_pkgs = local_r_pkgs,
  system_pkgs = "quarto",
  ide = "none",
  project_path = path_default_nix,
  overwrite = TRUE,
  print = FALSE
)
