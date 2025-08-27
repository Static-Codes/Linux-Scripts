#!/bin/bash
DIR=$(dirname $0)
[ -f "$DIR/config.sh" ] && . "$DIR/config.sh"

echo "[INFO] Starting VM for installation..."

handle_interrupt() {
    printf "\r\033[K" # ANSI ESCAPE
    echo "[INFO] Terminating installation process"
    echo "If this was intentional, you can run the following command:"
    echo "chmod +x $DIR/extract.sh"
    echo "$DIR/extract.sh"
    exit 130 # Exit code for CTRL+C interrupt

}
# Handling Control C interupt in both bash and shell
trap 'handle_interrupt' SIGINT 

qemu-system-arm \
    -M virt \
    -cpu cortex-a15 \
    -m 4G \
    -kernel "$KERNEL_FILE" \
    -initrd "$INITRD_FILE" \
    -append "root=/dev/vda2 console=ttyAMA0" \
    -drive "if=none,id=hd,file=$QCOW_FILE,format=qcow2" \
    -device virtio-blk-device,drive=hd \
    -netdev user,id=net0 \
    -device virtio-net-device,netdev=net0 \
    -nographic

