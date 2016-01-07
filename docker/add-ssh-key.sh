#!/bin/bash

# The /data may be externally mounted, so it is empty at this time!
# We cp the content from /root without overwrite some existing files!
cp -Rn /root/. /data
# Externally mounted dir has mod 777, which prohibits ssh auth.
# The home directory should be writable only by root!
chmod go-w /data

# We add SSH_PUBLIC_KEY only if the user specified it and it was not added!
if [ -n "$SSH_PUBLIC_KEY" ]; then
    if ! grep -q "$SSH_PUBLIC_KEY" /data/.ssh/authorized_keys; then
        echo "$SSH_PUBLIC_KEY" >> /data/.ssh/authorized_keys
    fi
fi
