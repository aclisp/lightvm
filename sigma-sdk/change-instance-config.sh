#!/bin/bash
if [[ $# -ne 3 ]]; then
    echo "Need parameters: INSTANCE_NAME CONFIG_NAME CONFIG_VERSION"
    exit 1
fi
source functions.sh
update_pod NAME=$1 CONFIG=$2:$3
