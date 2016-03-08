#!/bin/bash
source functions.sh
read -p "!!! About to delete replication controller $CLUSTER_NAME !!! Are you sure? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
	delete_replication_controller $CLUSTER_NAME
fi

# Delete every instance managed by the replication controller
INSTANCE_LIST=$(http_get pods managed-by=$CLUSTER_NAME | jq --raw-output '.items[] | .metadata.name')
for instance in $INSTANCE_LIST; do
    read -p "!!! About to delete instance $instance !!! Are you sure? " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        delete_pod $instance
    fi
done
