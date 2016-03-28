#!/bin/bash

if [[ $# -lt 1 ]]; then
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

function is_new () {
    if [[ $(container_id) == $CONTAINER_ID ]]; then
        return 1
    else
        return 0
    fi
}

function exit_success () {
    case $INSTANCE_PHASE in
        "Pending")
            echo "$INSTANCE_NAME is created"
            ;;
        "Running")
            echo "$INSTANCE_NAME is changed"
            ;;
    esac
    exit 0
}

function check_instance () {
    case $INSTANCE_PHASE in
        "Pending")
            is_ready
            ;;
        "Running")
            is_ready && is_new
            ;;
        "Succeeded" | "Failed")
            fatal "$INSTANCE_NAME is terminated"
            ;;
        *)
            fatal "$INSTANCE_NAME is unknown"
            ;;
    esac
}

function container_id () {
    echo $INSTANCE_SPEC | 2>/dev/null jq --raw-output \
    ".status.containerStatuses[]|select(.name==\"$CONTAINER_NAME\")|.containerID"
}

INSTANCE_NAME=$1
CONTAINER_NAME=${INSTANCE_NAME%-*}
INSTANCE_SPEC=$(read_pod $INSTANCE_NAME)
INSTANCE_PHASE=${2:-$(echo $INSTANCE_SPEC | 2>/dev/null jq --raw-output '.status.phase')}
CONTAINER_ID=$(container_id)

if [[ $(echo $INSTANCE_SPEC | jq --raw-output '.kind') != "Pod" ]]; then
    fatal "$INSTANCE_NAME is not found"
elif check_instance; then
    exit_success
fi

case $INSTANCE_PHASE in
    "Pending")  # Give more time when create the instance
        RETRY=24
        INTERVAL=5
        ;;
    *)          # Expect instance change in this period
        RETRY=6
        INTERVAL=5
        ;;
esac

while (( $RETRY > 0 )); do
    RETRY=$(( $RETRY - 1 ))
    sleep $INTERVAL
    INSTANCE_SPEC=$(read_pod $INSTANCE_NAME)
    if check_instance; then
        exit_success
    fi
    echo "still waiting..."
done

echo "$INSTANCE_NAME is timeout"
exit 1
