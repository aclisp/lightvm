#!/bin/bash
source functions.sh
create_replication_controller "$CLUSTER_NAME" "$IMAGE_NAME:$IMAGE_VERSION" "$CONFIG_NAME:$CONFIG_VERSION" "$SSH_PUBLIC_KEY"
