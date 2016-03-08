set -eo pipefail

source common-parameters.conf
source settings.conf

CURL_OPTIONS="--show-error --silent --insecure --user $API_USER:$API_PASSWORD"

function get_stack () {
    STACK=""
    # to avoid noise we start with 1 to skip get_stack caller
    local i
    local stack_size=${#FUNCNAME[1]}
    for (( i=1; i<$stack_size ; i++ )); do
        local func="${FUNCNAME[$i]}"
        [ x$func = x ] && func=MAIN
        local linen="${BASH_LINENO[(( i - 1 ))]}"
        local src="${BASH_SOURCE[$i]}"
        [ x"$src" = x ] && src=non_file_source

        STACK+='\n'"    at "$func"("$src":"$linen")"
    done
}

function fatal () {
    local MSG=$1
    local CODE=$2

    [[ -n $MSG ]] && >&2 echo -e "$MSG"'\n'
    [[ -z $CODE ]] && CODE=1
    get_stack
    >&2 echo "Stack trace:"
    >&2 echo -e "$STACK"'\n'
    exit $CODE
}

function api_endpoint () {
    local OBJ=$1

    echo "$API_SERVER/api/v1/namespaces/$API_NAMESPACE/$OBJ"
}

function http_post () {
    local OBJ=$1
    local SPEC=$2

    curl $CURL_OPTIONS --request POST --data-binary "$SPEC" $(api_endpoint $OBJ)
}

function http_get () {
    local OBJ=$1
    local LABEL_SELECTOR=$2

    curl $CURL_OPTIONS --get --data-urlencode "labelSelector=$LABEL_SELECTOR" $(api_endpoint $OBJ)
}

function http_delete () {
    local OBJ=$1

    curl $CURL_OPTIONS --request DELETE $(api_endpoint $OBJ)
}

function http_patch () {
    local OBJ=$1
    local SPEC=$2

    curl $CURL_OPTIONS --request PATCH --header "Content-Type: application/strategic-merge-patch+json" --data-binary "$SPEC" $(api_endpoint $OBJ)
}

function create_replication_controller () {
    if (( $# != 4 )); then
        fatal "Invalid arguments."
    fi

    local NAME=$1
    local IMAGE=$2
    local CONFIG=$3
    local SSH_PUBLIC_KEY=$4

    local SPEC=$(jq ".metadata.name=\"$NAME\" \
       |.spec.selector[\"managed-by\"]=\"$NAME\" \
       |.spec.template.metadata.labels[\"managed-by\"]=\"$NAME\" \
       |.spec.template.spec.containers[0].name=\"$NAME\" \
       |.spec.template.spec.containers[0].image=\"$IMAGE_REGISTRY/$IMAGE\" \
       |.spec.template.spec.containers[1].image=\"$IMAGE_REGISTRY/$CONFIG\" \
       |.spec.template.spec.containers[0].env[0].value=\"$SSH_PUBLIC_KEY\" \
       " replication-controller.json)

    http_post replicationcontrollers "$SPEC"
}

function read_replication_controller () {
    if (( $# != 1 )); then
        fatal "Invalid arguments."
    fi

    http_get replicationcontrollers/$1
}

function update_replication_controller () {
    if (( $# < 1 )); then
        fatal "Invalid arguments."
    fi

    local NAME IMAGE CONFIG REPLICAS  # reset first
    local "$@"

    [[ -z $NAME ]] && fatal "NAME is not set."
    local SPEC=$(read_replication_controller $NAME)
    local LAST_IMAGE=$(echo $SPEC | jq --raw-output '.spec.template.spec.containers[0].image')
    local LAST_CONFIG=$(echo $SPEC | jq --raw-output '.spec.template.spec.containers[1].image')
    local LAST_REPLICAS=$(echo $SPEC | jq --raw-output '.spec.replicas')
    [[ -z $IMAGE ]] && IMAGE=$LAST_IMAGE
    [[ -z $CONFIG ]] && CONFIG=$LAST_CONFIG
    [[ -z $REPLICAS ]] && REPLICAS=$LAST_REPLICAS

    local PATCH="{
        \"metadata\": {
            \"annotations\": {
                \"last-image\": \"$LAST_IMAGE\",
                \"last-config\": \"$LAST_CONFIG\"
            }
        },
        \"spec\": {
            \"replicas\": $REPLICAS,
            \"template\": {
                \"spec\": {
                    \"containers\": [{
                        \"name\": \"$NAME\",
                        \"image\": \"$IMAGE\"
                    }, {
                        \"name\": \"data-volume\",
                        \"image\": \"$CONFIG\"
                    }]}}}}"
    http_patch replicationcontrollers/$NAME "$PATCH"
}

function delete_replication_controller () {
    if (( $# != 1 )); then
        fatal "Invalid arguments."
    fi

    http_delete replicationcontrollers/$1
}

function revert_replication_controller () {
    if (( $# != 1 )); then
        fatal "Invalid arguments."
    fi

    local NAME=$1
    local SPEC=$(read_replication_controller $NAME)
    local LAST_IMAGE=$(echo $SPEC | jq --raw-output '.metadata.annotations["last-image"]')
    local LAST_CONFIG=$(echo $SPEC | jq --raw-output '.metadata.annotations["last-config"]')
    if [[ $LAST_IMAGE == "null" ]]; then
        fatal "Can not revert."
    fi

    update_replication_controller NAME=$NAME IMAGE=$LAST_IMAGE CONFIG=$LAST_CONFIG
}

