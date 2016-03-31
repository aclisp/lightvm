#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Need parameters: INSTANCE_NAME"
    exit 1
fi
source functions.sh

INSTANCE_NAME=$1
INSTANCE_SPEC=$(read_pod $INSTANCE_NAME)
UPDATED_INSTANCE_SPEC=$(echo $INSTANCE_SPEC | jq '.status.containerStatuses[].restartCount = 0')
http_put pods/$INSTANCE_NAME/status "$UPDATED_INSTANCE_SPEC" | tail -n 1
