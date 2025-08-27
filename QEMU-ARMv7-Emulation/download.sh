#!/bin/bash

# Config import source wasn't recognized but . is an alias
DIR=$(dirname $0)
[ -f "$DIR/config.sh" ] && . "$DIR/config.sh"

echo "[INFO] Downloading Started for VM Files"

# Creating ~/Desktop/vm and ~/Desktop/vm/armhf-rootfs
mkdir $VM_DIR && cd $VM_DIR 
mkdir $FS_DIR && cd $FS_DIR

# Package Installation + File Downloads
sudo apt-get update && sudo apt-get install $PACKAGES

# Creating the disk image.
qemu-img create -f qcow2 $QCOW_FILE $QCOW_FILE_SIZE

# Downloading the VM Files (Kernel, InitRD, ISO)
wget $KERNEL_LINK -O $KERNEL_FILE
wget $INITRD_LINK -O $INITRD_FILE
wget $ISO_LINK -O $ISO_FILE

echo "[INFO] Downloading complete."
echo "Next step: Installation"
echo "Commands:"
echo "gnome-terminal"
echo "sh $DIR/install.sh"