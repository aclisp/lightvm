#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Need parameters: INSTANCE_NAME"
    exit 1
fi

# Verify current image name
INSTANCE_NAME=$1
INSTANCE_SPEC=$(bash query-instance.sh ${INSTANCE_NAME})
CURRENT_IMAGE=$(echo ${INSTANCE_SPEC} | jq --raw-output '.spec.containers[0].image')
if [[ ${CURRENT_IMAGE} != "sigmas/pause:0.8.0" ]]; then
    echo "Can not start. Aborted."
    exit 1
fi

bash rollback-instance-image.sh $1
