#!/bin/bash
source functions.sh
CURRENT_REPLICAS=$(read_replication_controller $CLUSTER_NAME | jq '.spec.replicas')
read -p "! About to scale replication controller $CLUSTER_NAME ! Current replicas $CURRENT_REPLICAS ! Input required replicas: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[0-9]+$ ]]; then
    echo "Required replicas $REPLY"
    REQUIRED_REPLICAS=$REPLY
else
    echo "Invalid input. Aborted."
    exit 1
fi
update_replication_controller NAME=$CLUSTER_NAME REPLICAS=$REQUIRED_REPLICAS
