#!/usr/bin/env bash
set -eoux pipefail

# Set up bare minimum required data for a minimal GOV.UK setup required for publishing things for
# search-related services
# NOTE: This script _should_ be idempotent, but no guarantees are made. YMMV.

function json_curl() {
  local request_type=$1
  local url=$2
  local request_body=$3

  local headers=(
    "-H" "Content-Type: application/json"
    "-H" "Accept: application/json"
  )

  local curl_command=( "curl" "-g" "-X" "${request_type}" "${headers[@]}" "${url}" )
  if [ -n "${request_body}" ]; then
    curl_command+=( "-d" "${request_body}" )
  fi

  "${curl_command[@]}"
}

function create_and_publish_page() {
  local content_id=$1
  local page_data=$2

  json_curl "PUT" \
    "http://publishing-api.dev.gov.uk/v2/content/$content_id" \
    "$page_data"
  json_curl "POST" \
    "http://publishing-api.dev.gov.uk/v2/content/$content_id/publish" \
    '{"update_type":"major"}'
}

function create_topic_taxon() {
  local content_id=$1
  local parent_content_id=$2
  local base_path=$3
  local title=$4

  local payload='{"base_path":"'"$base_path"'","content_id":"'"$content_id"'","document_type":"taxon","schema_name":"taxon","title":"'"$title"'","publishing_app":"content-tagger","rendering_app":"collections","locale":"en","phase":"live","details":{"internal_name":"'"$title"'","notes_for_editors":"","visible_to_departmental_editors":true},"routes":[{"path":"'"$base_path"'","type":"exact"}]}'
  local links_payload='{"links":{"root_taxon":["'"$parent_content_id"'"]}}'

  json_curl "PUT" \
    "http://publishing-api.dev.gov.uk/v2/content/$content_id" \
    "$payload"
  json_curl "POST" \
    "http://publishing-api.dev.gov.uk/v2/content/$content_id/publish" \
    '{"update_type":"major"}'
  json_curl "PATCH" \
    "http://publishing-api.dev.gov.uk/v2/links/$content_id" \
    "$links_payload"
}

# Publishing API: Create and publish homepage
create_and_publish_page "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a" \
  '{"analytics_identifier":null,"base_path":"/","content_id":"f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a","document_type":"homepage","first_published_at":"2016-02-26T11:53:52.000+00:00","locale":"en","phase":"live","public_updated_at":"2019-06-21T11:52:37.000+00:00","publishing_app":"frontend","rendering_app":"frontend","schema_name":"homepage","title":"GOV.UK homepage","description":"","details":{},"routes":[{"path":"/","type":"exact"}]}'

# Publishing API: Create and publish `/search` page
create_and_publish_page "84e0909c-f3e6-43ee-ba68-9e33213a3cdd" \
  '{"analytics_identifier":null,"base_path":"/search","content_id":"84e0909c-f3e6-43ee-ba68-9e33213a3cdd","document_type":"search","first_published_at":"2016-02-26T11:53:54.000+00:00","locale":"en","phase":"live","public_updated_at":"2020-02-10T11:24:41.000+00:00","publishing_app":"search-api","rendering_app":"finder-frontend","schema_name":"special_route","title":"GOV.UK search results","description":"Sitewide search results are displayed here.","details":{},"routes":[{"path":"/search","type":"exact"}]}'

# Publishing API: Create and publish `/search/all` page
create_and_publish_page "dd395436-9b40-41f3-8157-740a453ac972" \
  '{"analytics_identifier":null,"base_path":"/search/all","content_id":"dd395436-9b40-41f3-8157-740a453ac972","document_type":"finder","first_published_at":"2019-02-14T14:57:43.000+00:00","locale":"en","phase":"live","public_updated_at":"2023-02-10T14:39:42.000+00:00","publishing_app":"search-api","rendering_app":"finder-frontend","schema_name":"finder","title":"Search","description":"Find content from government","details":{"sort":[{"key":"-popularity","name":"Most viewed","default":true},{"key":"-relevance","name":"Relevance"},{"key":"-public_timestamp","name":"Updated (newest)"},{"key":"public_timestamp","name":"Updated (oldest)"}],"facets":[{"key":"_unused","keys":["level_one_taxon","level_two_taxon"],"name":"topic","type":"taxon","filter_key":"all_part_of_taxonomy_tree","filterable":true,"short_name":"topic","preposition":"about","display_as_result_metadata":false},{"key":"manual","name":"Manual","type":"hidden_clearable","filterable":true,"short_name":"in","preposition":"in manual","allowed_values":[],"show_option_select_filter":false,"display_as_result_metadata":false},{"key":"content_purpose_supergroup","name":"Content type","type":"text","filterable":true,"short_name":"In","preposition":"in","allowed_values":[{"label":"Services","value":"services"},{"label":"Guidance and regulation","value":"guidance_and_regulation"},{"label":"News and communications","value":"news_and_communications"},{"label":"Research and statistics","value":"research_and_statistics"},{"label":"Policy papers and consultations","value":"policy_and_engagement"},{"label":"Transparency and freedom of information releases","value":"transparency"}],"show_option_select_filter":false,"display_as_result_metadata":false},{"key":"organisations","name":"Organisation","type":"hidden_clearable","filterable":true,"short_name":"From","preposition":"from","show_option_select_filter":true,"display_as_result_metadata":true},{"key":"world_locations","name":"World location","type":"hidden_clearable","filterable":true,"preposition":"in","show_option_select_filter":false,"display_as_result_metadata":false},{"key":"public_timestamp","name":"Updated","type":"date","filterable":true,"short_name":"Updated","preposition":"Updated","display_as_result_metadata":true},{"key":"topical_events","name":"Topical event","type":"hidden_clearable","filterable":true,"short_name":"about","preposition":"about","allowed_values":[],"show_option_select_filter":false,"display_as_result_metadata":false}],"reject":{"link":["/search/all"]},"format_name":"Documents","document_noun":"result","show_summaries":true,"default_documents_per_page":20},"routes":[{"path":"/search/all","type":"exact"}]}'

# Publishing API: Create a taxonomy topic
create_topic_taxon '9879a0a1-ff85-49d2-acbb-106e2193691e' \
  'f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a' \
  '/walking' \
  'Ways of Walking'

# Whitehall: Clear taxonomy cache (after adding a new topic)
govuk-docker run whitehall-app bundle exec rake taxonomy:rebuild_cache
