#!/bin/bash
DIR=$(dirname $0)
[ -f "$DIR/config.sh" ] && . "$DIR/config.sh"

echo "--- Preparing to extract boot files ---"

echo "[INFO] Cleaning up previous mounts and connections..."
sudo umount -l /mnt/arm-vm 2>/dev/null || true
sudo qemu-nbd --disconnect /dev/nbd0 2>/dev/null || true
sleep 1

echo "[INFO] Connecting virtual disk: $QCOW_FILE"
sudo modprobe nbd max_part=8
sudo qemu-nbd --connect=/dev/nbd0 "$QCOW_FILE"
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to connect qemu-nbd. Aborting."
    exit 1
fi

echo "[INFO] Mounting boot partition /dev/nbd0p1..."
sudo mkdir -p /mnt/arm-vm
sudo mount -t ext4 /dev/nbd0p1 /mnt/arm-vm
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to mount /dev/nbd0p1. Aborting."
    sudo qemu-nbd --disconnect /dev/nbd0
    exit 1
fi

echo "[INFO] Contents of the boot partition:"
ls -l /mnt/arm-vm


echo "[INFO] Copying kernel and initrd..."
sudo cp /mnt/arm-vm/vmlinuz "$VM_DIR/vmlinuz-installed"
sudo cp /mnt/arm-vm/initrd.img "$VM_DIR/initrd-installed"


if [ -f "$VM_DIR/vmlinuz-installed" ] && [ -f "$VM_DIR/initrd-installed" ]; then
    echo "[SUCCESS] Boot files extracted successfully!"
else
    echo "[ERROR] Failed to copy boot files. The files may not exist in the root of the boot partition."
fi


echo "[INFO] Cleaning up..."
sudo umount /mnt/arm-vm
sudo qemu-nbd --disconnect /dev/nbd0

echo "Setup complete."
echo "Next step: Running"
echo "Commands:"
echo "gnome-terminal"
echo "chmod +x $DIR/run-text.sh"
echo "$DIR/run-text.sh"