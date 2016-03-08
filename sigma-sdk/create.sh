#!/bin/bash
. functions.sh
create_replication_controller test-only mysql:latest data-volume:latest
