#!/bin/bash

if [[ $# -eq 0 ]]; then
    >&2 echo "Need parameters: INSTANCE_NAME"
    exit 1
fi

source functions.sh

INSTANCE_NAME=$1
INSTANCE_SPEC=$(read_pod $INSTANCE_NAME)
INSTANCE_NODE=$(echo $INSTANCE_SPEC | jq --raw-output '.spec.nodeName')
if [[ -z $INSTANCE_NODE ]]; then
    >&2 echo "Can not get node for instance $INSTANCE_NAME"
    exit 1
fi

INSTANCE_STATUS=$(echo $INSTANCE_SPEC | jq --raw-output '.status.message')
PORT_MAPPINGS=$(echo $INSTANCE_STATUS | sed -r 's/PortMapping\((.*)\)/\1/' | tr ',' ' ')
SSH_PORT_PATTERN='^([0-9]+)->22/TCP$'
for port_mapping in $PORT_MAPPINGS; do
    if [[ $port_mapping =~ $SSH_PORT_PATTERN ]]; then
        OUTER_PORT=${BASH_REMATCH[1]}
    fi
done
if [[ -z $OUTER_PORT ]]; then
    >&2 echo "Can not capture SSH port for instance $INSTANCE_NAME: $INSTANCE_STATUS"
    exit 1
fi

echo "ssh -p $OUTER_PORT root@$INSTANCE_NODE"
shift
exec ssh -p $OUTER_PORT root@$INSTANCE_NODE "$@"
