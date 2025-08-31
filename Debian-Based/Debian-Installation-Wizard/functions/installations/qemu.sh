#!/bin/bash

install_qemu_x86(){
    echo "[INFO] Installing QEMU."
    sudo apt-get install qemu-system -y
}

install_qemu_arm(){
    echo "[INFO] Installing QEMU ARM."
    sudo apt-get install \
    qemu-system \
    qemu-system-arm \
    qemu-utils \
    tigervnc-viewer \
    gnome-terminal -y
}