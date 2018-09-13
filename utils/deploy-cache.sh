#!/bin/bash
source ${0%/*}/common.sh

CACHE_ROOT='cache'

$UTILS_DIR/init-common.sh

message "Deploying cache to $ROOT"
rsync -av --delete $CACHE_ROOT/raspi/tools $ROOT/raspi
rsync -av --delete $CACHE_ROOT/raspbian/${RASPBIAN_BASENAME}.img $ROOT/raspbian
rsync -av --delete $CACHE_ROOT/modules $ROOT
