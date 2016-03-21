#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Need parameters: INSTANCE_NAME"
    exit 1
fi
source functions.sh

NAME=$1
PATCH="{
        \"spec\": {
            \"containers\": [
                {
                    \"name\": \"${NAME%-*}\",
                    \"resources\": {
                        \"limits\": {
                            \"cpu\": \"11\",
                            \"memory\": \"22Gi\"
                        }
                    }
                }
            ]
        }
    }"

http_patch pods/$NAME "$PATCH"
