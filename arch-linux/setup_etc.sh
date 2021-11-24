#!/usr/bin/env bash
set -e

# Get fastest mirror
if [[ ! -e /etc/pacman.d/mirrorlist.backup ]]
then
  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
fi
reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

# Parallel Make
nc=$(grep -c ^processor /proc/cpuinfo)
nc=${1:-nc}
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
echo "Changing the compression settings for "$nc" cores."
sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf

