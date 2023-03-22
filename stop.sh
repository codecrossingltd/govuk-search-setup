#!/usr/bin/env bash
set -eoux pipefail

docker-compose -p govuk-docker down --remove-orphans
