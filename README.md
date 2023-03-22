# govuk-search-setup
A repository with setup scripts for getting search-related parts of GOV.UK running locally

## Motivation
There isn't currently a documented way to get a minimal set of search applications up and running,
without having to follow several bits of documentation and downloading production data. This is a
lightweight set of scripts to do this setup, so I can reliabily and repeatably create and tear down
local dev environments.

## Scripts
- `make.sh`: Runs `govuk-docker`'s `make` tasks for all required projects
- `up.sh`: Starts all required projects
- `destroy.sh`: Completely removes all Docker containers, images, and volumes
- `create_data.sh`: Creates a minimal set of data across applications to get search to work
