#!/bin/sh

SCRIPT=/init-script/run
LOG=/shared-volume/init-script.log

fatal() {
    >&2 echo " !!! $(date -Is) $1"
    exit 0
}

log() {
    echo " *** $(date -Is) $1"
}

call_script() {
    chmod +x $SCRIPT
    log "calling $SCRIPT"
    $SCRIPT || fatal "$SCRIPT must exit 0"
}

copy_data() {
    log "copying data"
    cp -Rf /init-data/. /shared-volume || fatal "copy failed"
}

main() {
    call_script
    copy_data
    log "mark COMPLETE"
    touch /shared-volume/COMPLETE
}

main >>$LOG 2>&1
