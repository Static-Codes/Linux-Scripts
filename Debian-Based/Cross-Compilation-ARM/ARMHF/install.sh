#!/bin/bash

PLAT="armhf"
CHROOT_PATH="/mnt/bullseye-$PLAT"

# Adds the specified architecture to the host system
sudo dpkg --add-architecture "$PLAT"
echo "Added '$PLAT' to dpkg-architecture"
sleep 0.5

dpkg --print-foreign-architectures

sudo apt update
sudo apt install -y qemu-user-static debootstrap debian-archive-keyring


echo "Installing virtual environment for cross compilation, please wait..."
sleep 1

# The --foreign flag and the official mirror are used for cross-architecture setup.
sudo debootstrap --arch="$PLAT" --foreign --keyring=/usr/share/keyrings/debian-archive-keyring.gpg bullseye $CHROOT_PATH http://archive.debian.org/debian/

# This is only a requirement when using the --foreign flag
sudo chroot "$CHROOT_PATH" /debootstrap/debootstrap --second-stage

# Mounts the emulated filesystems
sudo mount --bind /proc $CHROOT_PATH/proc
sudo mount --bind /sys $CHROOT_PATH/sys
sudo mount --bind /dev $CHROOT_PATH/dev

# Copies the DNS settings to the emulated filesystems.
sudo cp /etc/resolv.conf $CHROOT_PATH/etc/

# Opens the emulated filesystems and executes the following commands within said environment.
sudo chroot $CHROOT_PATH /bin/bash -c "
  # Cleaning up packages
  sudo apt clean
  sudo apt autoclean

  # Adds the main, contrib, and non-free repositories to the sources list
  echo 'deb http://deb.debian.org/debian bullseye main contrib non-free
  deb-src http://deb.debian.org/debian bullseye main contrib non-free
  deb http://security.debian.org/debian-security bullseye-security main contrib non-free
  deb-src http://security.debian.org/debian-security bullseye-security main contrib non-free' > /etc/apt/sources.list
  
  # Updates the package list within the chroot
  apt update

  # Installs required packages
  apt install -y python3-pip python3.9-dev libbrotli-dev libzstd-dev libffi-dev
  
  export _PYTHON_HOST_PLATFORM="linux_$PLAT"
  export CROSS_COMPILE=1

  # Compiles the wheels
  pip3 wheel brotlipy zstandard cffi
"

# Unmounts the emulated filesystems
sudo umount $CHROOT_PATH/proc
sudo umount $CHROOT_PATH/sys
sudo umount $CHROOT_PATH/dev

sudo dpkg --remove-architecture "$PLAT"

echo "Completed Cross-Compilation!"

# Copies the compiled wheels from the emulated environment to the host's Desktop
sudo cp $CHROOT_PATH/*.whl ~/Desktop/

echo "Successfully copied cross-compiled wheels to ~/Desktop/"

echo "Once you've confirmed these files exist, please run the following commands:\n"
echo "sudo chown $USER ~/Desktop/*.whl"
echo "sudo rm -rf $CHROOT_PATH"