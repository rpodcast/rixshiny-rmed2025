## code to prepare assorted nhanes data sets
library(nhanesA)
library(dplyr)

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

bp_table_names <- paste0("BPX_", c("G", "H", "I", "J"))

bp_df_list <- purrr::map(bp_table_names, ~{
  message(glue::glue("downloading {.x}"))
  df <- nhanesA::nhanes(.x)
  return(df)
})

nhanes_demo <- dplyr::bind_rows(dm_df_list)
nhanes_bp <- dplyr::bind_rows(bp_df_list)
usethis::use_data(nhanes_demo, overwrite = TRUE)
usethis::use_data(nhanes_bp, overwrite = TRUE)
