# Stage 1: nix env without app package
FROM ubuntu:latest AS base

# install curl
RUN apt update -y
RUN apt install curl -y

# Get a default.nix with R and rix
RUN curl -O https://raw.githubusercontent.com/ropensci/rix/main/inst/extdata/default.nix

# Install nix package manager from determinate systems
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux \
  --extra-conf "sandbox = false" \
  --init none \
  --no-confirm

# Set env vars for Nix installation
ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"
ENV user=root

# Copy bootstrapping env script
COPY gen_env.R .

# Set up rstats-on-nix cache
# No need to use the cachix client inside Docker
RUN nix-shell --run "Rscript -e 'rix::setup_cachix()'"

# This will overwrite the default.nix we downloaded with a new one
RUN nix-shell --run "Rscript gen_env.R"

# build the environment
RUN nix-build

# Stage 2: nix env plus app package
FROM base

# Set env vars
ENV INSTALL_APP_PACKAGE=1
ENV user=root

# Copy bootstrapping env script
COPY gen_env.R .

# Copy package source installer file
COPY nhanes.shinyapp_*.tar.gz app.tar.gz

# Generate a new default.nix with the package added
RUN nix-shell --run "Rscript gen_env.R"

# build the environment
RUN nix-build

# trick to cache the package deps as a layer
RUN nix-shell --run exit

ARG shiny_port_value=7320
ENV SHINY_PORT=${shiny_port_value}

# expose necessary port
EXPOSE ${shiny_port_value}

# Run application
CMD ["nix-shell", "--run", "Rscript -e \"options(shiny.port=as.numeric(Sys.getenv('SHINY_PORT')), shiny.host='0.0.0.0'); library(nhanes.shinyapp); nhanes.shinyapp::run_app()\""]
