## code to prepare assorted nhanes data sets
library(nhanesA)
library(dplyr)
library(labelled)

years_to_download <- 2012:2018

dm_table_names <- purrr::map_chr(years_to_download, ~nhanesA::nhanesTables("DEMO", .x, namesonly = TRUE)) |>
  unique()

dm_df_list <- purrr::map(dm_table_names, ~{
  message(glue::glue("downloading {.x}"))
  df <- nhanesA::nhanes(.x) |>
    dplyr::select(
      SEQN,
      SDDSRVYR,
      RIAGENDR,
      RIDAGEYR,
      RIDRETH1,
      RIDRETH3,
      RIDEXPRG,
      SDMVPSU,
      SDMVSTRA
    )
  return(df)
})

nhanes_demo_labels <- nhanesA::nhanesTableVars("DEMO", "DEMO_J") |>
  dplyr::filter(Variable.Name %in% c(
    'SEQN',
    'SDDSRVYR',
    'RIAGENDR',
    'RIDAGEYR',
    'RIDRETH1',
    'RIDRETH3',
    'RIDEXPRG',
    'SDMVPSU',
    'SDMVSTRA'
  )
)

bp_table_names <- paste0("BPX_", c("G", "H", "I", "J"))

bp_df_list <- purrr::map(bp_table_names, ~{
  message(glue::glue("downloading {.x}"))
  df <- nhanesA::nhanes(.x)
  return(df)
})

nhanes_bp_labels <- purrr::map(bp_table_names, ~{
  df <- nhanesA::nhanesTableVars("EXAM", .x)
  return(df)
}) |>
  dplyr::bind_rows() |>
  dplyr::distinct()

nhanes_demo <- dplyr::bind_rows(dm_df_list)
nhanes_bp <- dplyr::bind_rows(bp_df_list)

demo_labels <- stats::setNames(
  as.list(
    nhanes_demo_labels$Variable.Description
  ),
  nhanes_demo_labels$Variable.Name
)

nhanes_demo <- nhanes_demo |>
  set_variable_labels(
    .labels = demo_labels,
    .strict = FALSE
  )

bp_labels <- stats::setNames(
  as.list(
    nhanes_bp_labels$Variable.Description
  ),
  nhanes_bp_labels$Variable.Name
)

nhanes_bp <- nhanes_bp |>
  set_variable_labels(
    .labels = bp_labels,
    .strict = FALSE
  )

usethis::use_data(nhanes_demo, overwrite = TRUE)
usethis::use_data(nhanes_demo_labels, overwrite = TRUE)
usethis::use_data(nhanes_bp, overwrite = TRUE)
usethis::use_data(nhanes_bp_labels, overwrite = TRUE)

