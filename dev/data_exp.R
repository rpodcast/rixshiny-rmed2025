library(dplyr)
library(nhanesA)
library(survey)
library(srvyr)

# list tables available for "DEMO" category
# year cutoff seems to be 2018
#purrr::walk(2005:2020, ~print(nhanesTables("DEMO", .x)))

demo_tables <- nhanesA::nhanesTables("DEMO", 2018)

demo_df <- nhanes("DEMO_J")

nhanesTableVars('DEMO', 'DEMO_J') |> View()

lab_tables <- nhanesTables("LAB", 2018)

exam_tables <- nhanesTables("EXAM", 2018)

bp_df <- nhanes("BPX_J")

nhanesTableVars("EXAM", "BPX_J") |> View()

# replicate analyses from vignette on survey techniques
df <- dplyr::left_join(demo_df, bp_df, by = "SEQN")

# using classical survey package approach
nhanesDesign <- svydesign(
  id = ~SDMVPSU,  # Primary Sampling Units (PSU)
  strata  = ~SDMVSTRA, # Stratification used in the survey
  weights = ~WTMEC2YR,   # Survey weights
  nest    = TRUE,      # Whether PSUs are nested within strata
  data    = df
)

dfsub <- subset(nhanesDesign, df$RIDAGEYR >= 40)

# using tidy approach with srvyr
# this is "stratified, cluster design"
nhanes_tidydesign <- df |>
  as_survey_design(
    weights = WTMEC2YR,
    strata = SDMVSTRA,
    ids = SDMVPSU,
    nest = TRUE
  )

summary(nhanes_tidydesign)

dfsub2 <- nhanes_tidydesign |>
  filter(RIDAGEYR >= 40)