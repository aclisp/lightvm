#!/bin/sh
cp --recursive /init-data/* /shared-volume
touch /shared-volume/COMPLETE
exec /pause
