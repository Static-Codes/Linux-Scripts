#!/bin/bash

# Directories + File Paths

USER_DIR=$HOME

# Fallback
if [ $USER_DIR = "/root" ]; then
    read -p "Enter the path to your user directory [Eg: /home/username]: " USER_DIR
fi


VM_DIR="$USER_DIR/Desktop/vm"
FS_DIR="$VM_DIR/armhf-rootfs"
KERNEL_FILE="$VM_DIR/vmlinuz-armhf"
INITRD_FILE="$VM_DIR/initrd-armhf.gz"
QCOW_FILE="$VM_DIR/debian-armhf.qcow2"
ISO_FILE="$VM_DIR/debian-12.5.0-armhf-netinst.iso"

# Download Links
KERNEL_LINK=http://ftp.debian.org/debian/dists/bookworm/main/installer-armhf/current/images/netboot/vmlinuz
INITRD_LINK=http://ftp.debian.org/debian/dists/bookworm/main/installer-armhf/current/images/netboot/initrd.gz
ISO_LINK=https://cdimage.debian.org/cdimage/archive/12.5.0/armhf/iso-cd/debian-12.5.0-armhf-netinst.iso

# Other Vars
PACKAGES="qemu-system-arm qemu-utils qemu-nbd tigervnc-viewer gnome-terminal"
QCOW_FILE_SIZE="50G"
VNC_DISPLAY=":0"

