#!/usr/bin/env bash
set -eoux pipefail

# Start all applications
(
  # Change into GOV.UK Docker directory for running `make`
  govuk_docker_dir="${GOVUK_ROOT_DIR:-$HOME/govuk}/govuk-docker"
  cd "$govuk_docker_dir"

  GOVUK_DOCKER_COMMAND='govuk-docker up -d'

  # Start publishing applications
  $GOVUK_DOCKER_COMMAND publishing-api-app
  $GOVUK_DOCKER_COMMAND content-publisher-app
  $GOVUK_DOCKER_COMMAND government-frontend-app
  $GOVUK_DOCKER_COMMAND whitehall-app

  # Start search applications
  $GOVUK_DOCKER_COMMAND search-api-app
  $GOVUK_DOCKER_COMMAND finder-frontend-app
)
