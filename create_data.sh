#!/usr/bin/env bash
set -eoux pipefail

# Set up bare minimum required data for a minimal GOV.UK setup required for publishing things for
# search-related services
# NOTE: This script isn't necessarily idempotent - only run it on a fresh

# Publishing API: Create and publish homepage
curl -H "Content-Type: application/json" -XPUT http://publishing-api.dev.gov.uk/v2/content/f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a -d '{"analytics_identifier":null,"base_path":"/","content_id":"f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a","document_type":"homepage","first_published_at":"2016-02-26T11:53:52.000+00:00","locale":"en","phase":"live","public_updated_at":"2019-06-21T11:52:37.000+00:00","publishing_app":"frontend","rendering_app":"frontend","schema_name":"homepage","title":"GOV.UK homepage","description":"","details":{},"routes":[{"path":"/","type":"exact"}]}'
curl -H "Content-Type: application/json" -XPOST http://publishing-api.dev.gov.uk/v2/content/f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a/publish -d '{"update_type":"major"}'
