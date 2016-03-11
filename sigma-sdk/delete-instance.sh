#!/bin/bash
if [[ $# -ne 1 ]]; then
    echo "Need parameters: INSTANCE_NAME"
    exit 1
fi
source functions.sh
INSTANCE_NAME=$1
CONTROLLER_NAME=${INSTANCE_NAME%-*}
CONTROLLER_SPEC=$(read_replication_controller $CONTROLLER_NAME)

if [[ $(echo $CONTROLLER_SPEC | jq --raw-output '.kind') != "ReplicationController" ]]; then
    fatal "No controller for instance $INSTANCE_NAME"
fi

delete_replication_controller $CONTROLLER_NAME
delete_pod $INSTANCE_NAME

CONTROLLER_SPEC=$(echo $CONTROLLER_SPEC | jq '.spec.replicas -= 1|.metadata.resourceVersion = ""')
http_post replicationcontrollers "$CONTROLLER_SPEC"
