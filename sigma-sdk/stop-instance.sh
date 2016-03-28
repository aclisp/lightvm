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
if [[ $CURRENT_IMAGE == $SIGMA_PAUSE_IMAGE ]]; then
    echo "Already stopped."
    exit 1
fi

update_pod NAME=$INSTANCE_NAME IMAGE=$SIGMA_PAUSE_IMAGE
