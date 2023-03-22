#!/usr/bin/env bash
set -eoux pipefail

# Run `govuk-docker`'s Makefile for all applications for a local experience
# Time: ~20 minutes from scratch

(
  # Change into GOV.UK Docker directory (in a subshell to not affect shell)
  govuk_docker_dir="${GOVUK_ROOT_DIR:-$HOME/govuk}/govuk-docker"
  cd "$govuk_docker_dir"

  # Ensure nginx-proxy is running
  #   (required for my Colima setup so that the services can talk to each other at the expected
  #   domains)
  govuk-docker up -d nginx-proxy

  # Set up publishing applications
  make publishing-api
  make content-publisher
  make government-frontend
  make whitehall

  # Set up search applications
  make search-api
  make finder-frontend
)
