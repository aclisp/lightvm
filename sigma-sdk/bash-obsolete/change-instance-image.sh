#!/bin/bash
if [[ $# -ne 3 ]]; then
    echo "Need parameters: INSTANCE_NAME IMAGE_NAME IMAGE_VERSION"
    exit 1
fi
source functions.sh
update_pod NAME=$1 IMAGE=$2:$3
