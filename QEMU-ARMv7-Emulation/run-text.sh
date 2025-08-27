#!/bin/bash

DIR=$(dirname $0)
[ -f "$DIR/config.sh" ] && . "$DIR/config.sh"

echo "Starting VM in TEXT-ONLY mode..."
echo "A login prompt should appear in this terminal."

qemu-system-arm \
    -M virt \
    -cpu max \
    -m 3G \
    -kernel "$VM_DIR/vmlinuz-installed" \
    -initrd "$VM_DIR/initrd-installed" \
    -append "root=/dev/vda2 rw console=ttyAMA0" \
    -drive "if=none,id=hd,file=$QCOW_FILE,format=qcow2" \
    -device "virtio-blk-device,drive=hd" \
    -netdev "user,id=net0" \
    -device "virtio-net-device,netdev=net0" \
    -display none \
    -serial stdio

echo "VM shutdown."