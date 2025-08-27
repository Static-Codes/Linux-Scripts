#!bin/bash

DIR=$(dirname $0)
[ -f "$DIR/config.sh" ] && . "$DIR/config.sh"

sudo umount "$FS_DIR/mnt/host"
sudo umount "$FS_DIR/proc"
sudo umount "$FS_DIR/sys"
sudo umount "$FS_DIR/dev"
