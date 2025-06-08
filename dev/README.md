# NHANES Explorer Shiny Application Developer Guide

This document contains additional details on setting up a development environment for building the NHANES Data Explorer Shiny application as well as information on additional services utilized in the backend. 

## Pre-requisites

While a portion of the development procedures below are written under the context of the administrator of this application, another developer who takes over the project could execute all of the development steps assuming the necessary external accounts are established and any development tooling is installed on their local system. The external accounts referenced in the procedures are the following:

* [GitHub](https://github.com) account with administrative rights to this repository
* [Dockerhub](https://hub.docker.com) account to host the Docker container images of the application
* [Fly.io](https://fly.io) account for external hosting of the Shiny application
* Optional: [Tailscale](https://tailscale.com) to provide external connection to a self-hosted version of the Shiny application running in a Docker container.

## Development Environment

This project uses the [Nix package manager](https://nixos.org/) to install the development libraries used to create and execute the application. The Nix configuration files was created using the [`{rix}`](https://docs.ropensci.org/rix/index.html) R package. To set up the development environment, follow the instructions below:

* Install the [Determinant Nix](https://determinate.systems/posts/determinate-nix-installer) installer on your system.
* Run the following command in a terminal to establish a nix-shell ready for creating the Nix configuration file:

```bash
nix-shell --expr "$(curl -sl https://raw.githubusercontent.com/ropensci/rix/main/inst/extdata/default.nix)"
```

* In the same prompt, launch R and run the following command to create a new file called `default.nix` in the root of your local copy of the repository:

```r
source("dev/deploy/gen_env.R")
```

* Exit R and exit from the nix shell by typing `exit` in the terminal.
* Initialize the Nix environment by running `nix-build` in the terminal. Note that this could take a few minutes depending on bandwidth.
* Activate the development environment by running `nix-shell` in the terminal. 

## Environment Variables

TBD (May not be applicable)

## Authentication

TBD (May not be applicable)

## Docker Container Build & Push Instructions

### Build Docker Images on Local System

To build the Docker images, navigate to the `dev/deploy` directory and run the following build commands (changing the Docker user name as appropriate), depending on whether the app is being built for staging or production mode:

```bash
# staging
docker build --build-arg shiny_port_value=7320 -f Dockerfile -t rpodcast/nhanes.shinyapp:staging .

# production
docker build --build-arg shiny_port_value=8320 -f Dockerfile -t rpodcast/nhanes.shinyapp:main .
```

Verify that the container version of the application runs correctly on your local development system. In the examples below, each version of the built image is utilizing a different default port for the Shiny application, however the port mapping is using the host port 6320 mapped to the respective container port. Also, note that the `.env` file reference in the command contains the credentials necessary for the application to authenticate to the required services. In this example, the environment file has been copied to the `dev/deploy` directory (without being version-controlled):

```bash
# staging
docker run --rm -p 6320:7320 --name nhanes.shinyapp rpodcast/nhanes.shinyapp:staging

# production
docker run --rm -p 6320:8320 --name nhanes.shinyapp rpodcast/nhanes.shinyapp:main
```

In a web browser, visit `http://localhost:6320`.

**SIDE NOTE**: If you encounter errors or other issues with the app, here's a general procedure for debugging:

* Stop the docker container

```bash
docker stop nhanes.shinyapp
```

* Modify source code of application as needed. Ensure that you bump the package version in `DESCRIPTION` either manually or running `usethis::use_version("dev", push = FALSE)`.
* Run these snippets from `dev/03_deploy.R` to refresh package build

```r
# dev/03_deploy.R
unlink("dev/deploy/*.tar.gz")
devtools::build(path = "dev/deploy")
```

* Re-build the Docker container image using the same build commands as mentioned previously, and then run the container using the same run command as previously.

### Push Docker Images to Dockerhub

Ensure that you are able to push to Docker Hub by running the following command to log in to the service and set credentials for future operations (substituting for your Dockerhub user name as appropriate):

```bash
docker login -u rpodcast
```

Once the login is successful run the following:

```bash
# staging
docker push rpodcast/nhanes.shinyapp:staging

# production
docker push rpodcast/nhanes.shinyapp:main
```

## App Deployment

A key advantage of using Docker to create a container image for the application is having a robust set of options for deploying the application. We cover two methods in the procedures below:

### Fly.io

[Fly.io](https://fly.io) is a platform allowing developers to host containerized web applications. Refer to the excellent [Hosting Shiny Apps on Fly.io: a Review](https://hosting.analythium.io/hosting-shiny-apps-on-fly-io-a-review/) article by Peter Solymos for a comprehensive overview of the service. Here are the steps to deploy the Shiny application (adapted from the [Make Your Shiny App Fly](https://hosting.analythium.io/make-your-shiny-app-fly) guide):

* If necessary, install the [`flyctl`](https://fly.io/docs/flyctl/install/) command line tool. If you are using the Nix environment configured for this project, you will already have the utility installed.
* Authenticate to the Fly.io service using this command:

```bash
flyctl auth login
```

* Ensure that a placeholder application is created on the service using the following commands:

```bash
# staging
flyctl apps create nhanes-shinyapp-staging

# production
flyctl apps create nhanes-shinyapp
```

* Using the appropriate application configuration files (`fly-staging.toml` or `fly-prod.toml`), supply the custom secrets contained in the environment variable file:

```bash
# staging
cat .env | tr '\n' ' ' | xargs flyctl secrets -a rnhanes-shinyapp-staging set

# production
cat .env | tr '\n' ' ' | xargs flyctl secrets -a nhanes-shinyapp set
```

* Deploy the application:

```bash
# staging
flyctl deploy --wait-timeout "20m0s" -c fly-staging.toml

# production
flyctl deploy --wait-timeout "20m0s" -c fly-prod.toml
```

* Once the application has finished deployment, it will be available at the following URLs:
    + Staging: <https://nhanes-shinyapp-staging.fly.io>
    + Production: <https://nhanes-shinyapp.fly.io>

**Caveats**: On the Fly.io service, the application may fail to load initially. While further investigation is required, the containers seem to have a long startup time when a user first visits the application URL. After a few minutes, the application will render successfully.

### Tailscale

The [tailscale](https://tailscale.com) service provides users a software-defined network across devices (and optionally open to the external internet) wrapping the Wireguard Linux networking protocol. Tailscale can be combined with Docker to provide secure network protocols (i.e. https) to securely host any containerized application or web service. In the `tailscale_example` directory, you will find an example Docker Compose file alongside additional Tailscale configuration files for hosting the Shiny application on a local host running Docker, using the templates discussed in the [Contain your excitement: A deep dive into using Tailscale with Docker](https://tailscale.com/blog/docker-tailscale-guide) blog post from the Tailscale blog.

## GitHub Actions

With the exception of the Tailscale deployment method, each of the steps to build the application container and deploy to the Fly.io service have been automated using GitHub actions, with individual configurations for the Staging and Production workflows:

* Staging: `build-app-staging.yml`
* Production: `build-app-prod.yml`

Ensure that all environment variables defined in the `.env` file have been defined as GitHub Action Secrets in the settings of the repository, otherwise the GitHub actions will fail.

### Running GitHub Action Locally

Use the novel [act](https://nektosact.com/) tool to run GitHub actions locally with Docker. Here is a command to test the docker build & push workflow file:

```bash
# staging
act --secret-file dev/deploy/.env -W '.github/workflows/build-app-staging.yml'

# production
act --secret-file dev/deploy/.env -W '.github/workflows/build-app-prod.yml'
```
