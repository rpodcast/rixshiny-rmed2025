library(dplyr)
library(nhanesA)



# list tables available for "DEMO" category
# year cutoff seems to be 2018
purrr::walk(2005:2020, ~print(nhanesTables("DEMO", .x)))

demo_tables <- nhanesA::nhanesTables("DEMO", 2018)

demo_df <- nhanes("DEMO_J")

nhanesTableVars('DEMO', 'DEMO_J') |> View()

lab_tables <- nhanesTables("LAB", 2018)

exam_tables <- nhanesTables("EXAM", 2018)

bp_df <- nhanes("BPX_J")

nhanesTableVars("EXAM", "BPX_J") |> View()
