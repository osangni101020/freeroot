#!/bin/sh

ROOTFS_DIR=$(pwd)
export PATH=$PATH:~/.local/usr/bin
timeout=1
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
  ARCH_ALT=amd64
elif [ "$ARCH" = "aarch64" ]; then
  ARCH_ALT=arm64
else
  printf "Unsupported CPU architecture: ${ARCH}"
  exit 1
fi

download_rootfs() {
  while true; do
    echo "Downloading Ubuntu rootfs..."
    curl -L --max-time $timeout -o /tmp/rootfs.tar.gz \
      "http://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release/ubuntu-base-20.04.4-base-${ARCH_ALT}.tar.gz"
    
    if [ $? -eq 0 ] && [ -s /tmp/rootfs.tar.gz ]; then
      echo "Download successful!"
      break
    else
      echo "Download failed. Retrying in 1 second..."
      rm -f /tmp/rootfs.tar.gz
      sleep 1
    fi
  done
}

if [ ! -e $ROOTFS_DIR/.installed ]; then
  echo "#######################################################################################"
  echo "#"
  echo "#                                      Foxytoux INSTALLER"
  echo "#"
  echo "#                           Copyright (C) 2024, RecodeStudios.Cloud"
  echo "#"
  echo "#######################################################################################"

  read -p "Do you want to install Ubuntu? (YES/no): " install_ubuntu
fi

case $install_ubuntu in
  [yY][eE][sS])
    download_rootfs
    tar -xf /tmp/rootfs.tar.gz -C $ROOTFS_DIR
    ;;
  *)
    echo "Skipping Ubuntu installation."
    ;;
esac

if [ ! -e $ROOTFS_DIR/.installed ]; then
  mkdir -p $ROOTFS_DIR/usr/local/bin

  while true; do
    echo "Downloading proot binary..."
    curl -L --max-time $timeout -o $ROOTFS_DIR/usr/local/bin/proot \
      "https://raw.githubusercontent.com/foxytouxxx/freeroot/main/proot-${ARCH}"

    if [ $? -eq 0 ] && [ -s $ROOTFS_DIR/usr/local/bin/proot ]; then
      chmod 755 $ROOTFS_DIR/usr/local/bin/proot
      break
    else
      echo "Failed to download proot. Retrying in 1 second..."
      rm -f $ROOTFS_DIR/usr/local/bin/proot
      sleep 1
    fi
  done
fi

if [ ! -e $ROOTFS_DIR/.installed ]; then
  printf "nameserver 1.1.1.1\nnameserver 1.0.0.1" > ${ROOTFS_DIR}/etc/resolv.conf
  rm -rf /tmp/rootfs.tar.xz /tmp/sbin
  touch $ROOTFS_DIR/.installed
fi

CYAN='\e[0;36m'
WHITE='\e[0;37m'
RESET_COLOR='\e[0m'

display_gg() {
  echo -e "${WHITE}___________________________________________________${RESET_COLOR}"
  echo -e ""
  echo -e "           ${CYAN}-----> Mission Completed ! <----${RESET_COLOR}"
}

clear
display_gg

$ROOTFS_DIR/usr/local/bin/proot \
  --rootfs="${ROOTFS_DIR}" \
  -0 -w "/root" -b /dev -b /sys -b /proc -b /etc/resolv.conf --kill-on-exit
