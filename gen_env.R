library(rix)

path_default_nix <- "."

shell_hook <- '
export PGHOST=localhost
export PGPORT=5555
export PGUSER=dev
export PGPASSWORD=example
export PGDATABASE=postgres
export TARGET=./.dev_postgres
export PGDATA=./.dev_postgres/.pg

mkdir -p $TARGET
cat >$TARGET/postgresql_add.conf <<\'EOF\'
log_min_messages = warning
log_min_error_statement = error
log_min_duration_statement = 100 # ms
log_connections = on
log_disconnections = on
log_duration = on
log_timezone = \'UTC\'
log_statement = \'all\'
log_directory = \'logs\'
log_filename = \'postgresql-%Y-%m-%d_%H%M%S.log\'
logging_collector = on
log_min_error_statement = error
EOF

CURRENT_DIR=$(pwd)
PGDATA=$CURRENT_DIR/$TARGET/.pg

[ ! -d $PGDATA ] && PGHOST=$PGDATA pg_ctl initdb -o \\"-U $PGUSER\\" && cat $TARGET/postgresql_add.conf >> $PGDATA/postgresql.conf

pg_ctl -o \\"-p $PGPORT -k $PGDATA\\" start && {
  trap \'pg_ctl stop\' EXIT
}
'

rix(
  date = "2025-05-26",
  r_pkgs = c(
    "nhanesA",
    "golem",
    "shiny",
    "cards",
    "dbplyr",
    "RPostgres",
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
    "srvyr"
  ),
  system_pkgs = "postgresql",
  shell_hook = shell_hook,
  ide = "none",
  project_path = path_default_nix,
  overwrite = TRUE,
  print = FALSE
)
