#!/bin/bash
if [[ $# -ne 1 ]]; then
    echo "Need parameters: INSTANCE_NAME"
    exit 1
fi
source functions.sh
INSTANCE_NAME=$1
CONTROLLER_NAME=${INSTANCE_NAME%-*}
CONTROLLER_SPEC=$(read_replication_controller $CONTROLLER_NAME)
INSTANCE_SPEC=$(read_pod $INSTANCE_NAME)

if [[ $(echo $CONTROLLER_SPEC | jq --raw-output '.kind') != "ReplicationController" ]]; then
    fatal "No controller for instance $INSTANCE_NAME"
fi

if [[ $(echo $INSTANCE_SPEC | jq --raw-output '.kind') != "Pod" ]]; then
	fatal "$INSTANCE_NAME is not found"
elif [[ $(echo $INSTANCE_SPEC | jq --raw-output '.metadata.deletionTimestamp') != "null" ]]; then
	fatal "$INSTANCE_NAME is terminating"
fi

STATUS=$(delete_replication_controller $CONTROLLER_NAME | tail -n 1 | cut -f1 -d' ')
if (($STATUS != 200)); then
	fatal "Got $STATUS when deleting controller"
fi

delete_pod $INSTANCE_NAME

CONTROLLER_SPEC=$(echo $CONTROLLER_SPEC | jq '.spec.replicas -= 1|.metadata.resourceVersion = ""')
http_post replicationcontrollers "$CONTROLLER_SPEC"
