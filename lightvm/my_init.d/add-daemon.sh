#!/bin/bash

# We add DAEMON_MONITOR only if the user specified it and it was not added!
# e.g. DAEMON_MONITOR=foo,bar creates two symlinks in /etc/service
if [ -n "$DAEMON_MONITOR" ]; then
    IFS=',' read -a array <<< "$DAEMON_MONITOR"
    for element in "${array[@]}"; do
        ln -s /data/daemon/$element /etc/service/$element
    done
fi
