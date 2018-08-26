#!/bin/bash

source ${0%/*}/common.sh
cd_root ; 

mkdir -p raspbian ; cd raspbian

# Mount and extract the raspbian sysroot
message 'Creating sysroot - test'
message "${RASPBIAN_BASENAME}.img"
ls -la

echo 1
sudo mknod /dev/loop0 b 7 0
echo 1_1
sudo ls -la /dev/loop*
echo 1_2
sudo lsmod | grep loop
echo 1_3
sudo chmod 0777 ${RASPBIAN_BASENAME}.img
echo 1_4
ls -la
echo 1_5
sudo chmod 0777 /dev/loop0
echo 1_6
sudo ls -la /dev/loop*
echo 2
sudo losetup -v -P /dev/loop0 ${RASPBIAN_BASENAME}.img
echo 3
sudo mkdir /mnt/raspbian
echo 4
sudo mount /dev/loop0p2 /mnt/raspbian
echo 5

# Copy all sysroot from .img
mkdir sysroot-full
sudo rsync -a /mnt/raspbian/ sysroot-full/

sudo umount /mnt/raspbian
sudo losetup -d /dev/loop0
sudo apt-get -y install qemu-user-static
sudo cp /usr/bin/qemu-arm-static sysroot-full/usr/bin/

# Mount sysroot-full part
sudo mount -o bind /proc sysroot-full/proc
sudo mount -o bind /dev sysroot-full/dev
sudo mount -o bind /sys sysroot-full/sys

# comment preload conf to avoid the following error during apt-get build-dep command
# qemu: uncaught target signal 4 (Illegal instruction) - core dumped
# Illegal instruction
sudo sed -i '/./s/^/#/g' sysroot-full/etc/ld.so.preload

# Uncomment deb-src to have access to dev packages
sudo sed -i '/deb-src/s/^#//g' sysroot-full/etc/apt/sources.list

# Install Qt dependencies
sudo chroot sysroot-full /bin/bash -c 'apt-get update'
sudo chroot sysroot-full /bin/bash -c 'apt-get install -y apt-transport-https'
sudo chroot sysroot-full /bin/bash -c 'apt-get build-dep -y qt4-x11 qtbase-opensource-src'
sudo chroot sysroot-full /bin/bash -c 'apt-get install -y libudev-dev libinput-dev libts-dev libxcb-xinerama0-dev libxcb-xinerama0 libraspberrypi-dev'

sudo umount sysroot-full/sys
sudo umount sysroot-full/dev
sudo umount sysroot-full/proc

sudo chown -R $USER:$USER sysroot-full

$UTILS_DIR/sysroot-relativelinks.py sysroot-full

