#!/bin/bash
source functions.sh

RETRY=6
INTERVAL=5

while (( $RETRY > 0 )); do
    RETRY=$(( $RETRY - 1 ))
    REMAINS=$(read_replication_controller $CLUSTER_NAME \
            | jq --raw-output '.spec.replicas - .status.replicas')
    if (( $REMAINS == 0 )); then
        echo "$CLUSTER_NAME has enough replicas"
        break
    fi
    sleep $INTERVAL
    echo "still waiting..."
done

INSTANCE_LIST=$(http_get pods managed-by=$CLUSTER_NAME | jq --raw-output '.items[] | .metadata.name')
for instance in $INSTANCE_LIST; do
    bash wait-instance.sh $instance "Pending"
done
