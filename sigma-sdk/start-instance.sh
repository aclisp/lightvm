#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Need parameters: INSTANCE_NAME"
    exit 1
fi
source functions.sh
# Verify current image name
INSTANCE_NAME=$1
INSTANCE_SPEC=$(read_pod $INSTANCE_NAME)
CURRENT_IMAGE=$(echo $INSTANCE_SPEC | jq --raw-output '.spec.containers[0].image')
if [[ $CURRENT_IMAGE != $SIGMA_PAUSE_IMAGE ]]; then
    echo "Can not start. Aborted."
    exit 1
fi

revert_pod $INSTANCE_NAME
