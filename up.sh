#!/usr/bin/env bash
set -eoux pipefail

# Start all applications
(
  # Change into GOV.UK Docker directory (in a subshell to not affect shell)
  govuk_docker_dir="${GOVUK_ROOT_DIR:-$HOME/govuk}/govuk-docker"
  cd "$govuk_docker_dir"

  GOVUK_DOCKER_COMMAND='govuk-docker up -d'

  # Start dependencies that are needed for applications
  $GOVUK_DOCKER_COMMAND nginx-proxy
  $GOVUK_DOCKER_COMMAND redis
  $GOVUK_DOCKER_COMMAND rabbitmq

  # Sleep to avoid race conditions where services aren't ready before apps try and bind to them
  sleep 5

  # Ensure search-api has its required message queues (these don't persist container restarts)
  govuk-docker run --rm search-api-lite bundle exec rake message_queue:create_queues

  # Start publishing applications
  $GOVUK_DOCKER_COMMAND publishing-api-app
  $GOVUK_DOCKER_COMMAND content-publisher-app
  $GOVUK_DOCKER_COMMAND government-frontend-app
  $GOVUK_DOCKER_COMMAND whitehall-app

  # Start search applications
  $GOVUK_DOCKER_COMMAND search-api-app
  $GOVUK_DOCKER_COMMAND finder-frontend-app
)
