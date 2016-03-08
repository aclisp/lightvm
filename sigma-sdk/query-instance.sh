#!/bin/bash
source functions.sh
if [[ $# -eq 1 ]]; then
    read_pod $1
else
    http_get pods managed-by=$CLUSTER_NAME
fi
