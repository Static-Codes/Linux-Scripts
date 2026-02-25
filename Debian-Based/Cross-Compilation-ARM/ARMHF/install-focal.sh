#!/bin/bash

PLAT="armhf"
CHROOT_PATH="/mnt/focal-$PLAT"

# Adds the specified architecture to the host system

sudo dpkg --add-architecture "$PLAT"
echo "Added '$PLAT' to dpkg-architecture"
sleep 0.5

dpkg --print-foreign-architectures

sudo apt update
sudo apt install -y qemu-user-static debootstrap


echo "Installing virtual environment for cross compilation, please wait..."
sleep 1

# Creates a new Ubuntu 20.04 (Focal Fossa) environment with the specified architecture
sudo debootstrap --arch="$PLAT" focal $CHROOT_PATH http://ports.ubuntu.com/ubuntu-ports

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

  # Adds the universe repository to the sources list
  echo 'deb http://ports.ubuntu.com/ubuntu-ports focal main universe restricted multiverse
  deb-src http://ports.ubuntu.com/ubuntu-ports focal main universe restricted multiverse' > /etc/apt/sources.list
  
  # Updates the package list within the chroot
  apt update

  # Installs required packages
  apt install -y python3-pip python3.8-dev libbrotli-dev libzstd-dev libffi-dev

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
sudo cp $CHROOT_PATH/root/*.whl ~/Desktop/

echo "Successfully copied cross-compiled wheels to ~/Desktop/"

echo "Once you've confirmed these files exist, please run the following commands:\n"
echo "sudo chown $USER ~/Desktop/*.whl"
echo "sudo rm -rf $CHROOT_PATH"