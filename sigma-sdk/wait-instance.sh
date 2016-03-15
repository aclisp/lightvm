#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Need parameters: INSTANCE_NAME"
    exit 1
fi
source functions.sh

function is_ready () {
    if [[ $(echo $INSTANCE_SPEC | 2>/dev/null jq --raw-output \
        '.status.conditions[]|select(.type=="Ready")|.status') \
        == "True" ]]; then
        return 0
    else
        return 1
    fi
}

function ready_exit () {
    echo "$INSTANCE_NAME is ready"
    exit 0
}

INSTANCE_NAME=$1
INSTANCE_SPEC=$(read_pod $INSTANCE_NAME)
if [[ $(echo $INSTANCE_SPEC | jq --raw-output '.kind') != "Pod" ]]; then
    fatal "$INSTANCE_NAME is not found"
elif is_ready; then
    ready_exit
fi

RETRY=60
INTERVAL=5

while (( $RETRY > 0 )); do
    RETRY=$(( $RETRY - 1 ))
    sleep $INTERVAL
    INSTANCE_SPEC=$(read_pod $INSTANCE_NAME)
    if is_ready; then
        ready_exit
    fi
    echo "still waiting..."
done

echo "$INSTANCE_NAME is timeout, check it on Sigma Console."
exit 1
