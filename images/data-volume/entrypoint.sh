#!/bin/sh
cp -Rf /init-data/. /shared-volume
touch /shared-volume/COMPLETE
exec /pause
