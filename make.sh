#!/usr/bin/env bash
set -eoux pipefail

# Run `govuk-docker`'s Makefile for all applications for a local experience

# Ensure nginx-proxy is running
#   (required for my Colima setup so that the services can talk to each other at the expected
#   domains)
govuk-docker up -d nginx-proxy

# Set up search applications
make search-api
make publishing-api
make finder-frontend

# Set up publishing applications
make content-publisher
make content-tagger
make government-frontend
make whitehall
