library(rix)

rix(
  r_ver = "4.4.3",
  r_pkgs = c("shiny"),
  system_pkgs = c("pokemonsay"),
  git_pkgs = list(
    list(
      package_name = "doltr",
      repo_url = "https://github.com/ecohealthalliance/doltr/",
      commit = "ffb5bc68003e83ebdb9f352654bab2515ca6bf3a"
    )
  ),
  project_path = ".",
  overwrite = TRUE
)
