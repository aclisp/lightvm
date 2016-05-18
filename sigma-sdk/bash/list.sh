#!/bin/bash
source functions.sh
SEARCH_CRITERIAL="$1"
http_get pods | jq --raw-output '.items[]|.metadata.name' | grep "$SEARCH_CRITERIAL"
