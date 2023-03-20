#!/usr/bin/env bash
set -eoux pipefail

# Run `govuk-docker`'s Makefile for all applications for a local experience
# Time: ~20 minutes from scratch

# Start Elasticsearch before search-api so it has time to come up (race condition)
govuk-docker up -d elasticsearch-6

# Ensure nginx-proxy is running
#   (required for my Colima setup so that the services can talk to each other at the expected
#   domains)
govuk-docker up -d nginx-proxy

# Set up publishing applications
make publishing-api
make content-publisher
make content-tagger
make government-frontend
make whitehall

# Set up search applications
make search-api
make finder-frontend
