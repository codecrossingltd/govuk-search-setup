#!/usr/bin/env bash
set -eoux pipefail

# Start all applications

GOVUK_DOCKER_COMMAND='govuk-docker up -d'

# Start search applications
$GOVUK_DOCKER_COMMAND search-api-app
$GOVUK_DOCKER_COMMAND publishing-api-app
$GOVUK_DOCKER_COMMAND finder-frontend-app

# Start publishing applications
$GOVUK_DOCKER_COMMAND content-publisher-app
$GOVUK_DOCKER_COMMAND content-tagger-app
$GOVUK_DOCKER_COMMAND government-frontend-app
$GOVUK_DOCKER_COMMAND whitehall-app
