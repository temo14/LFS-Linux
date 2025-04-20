#!/bin/bash

set -e

# Set environment variables
export LFS=/mnt/lfs
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export LFS_DISK=/dev/sdb
umask 022

# Mount the LFS partition if not already mounted
if ! grep -q "$LFS" /proc/mounts; then
    echo "Mounting LFS partition..."
    source setupdisk.sh "$LFS_DISK"
    sudo mount "${LFS_DISK}2" "$LFS"
    sudo chown -v $USER "$LFS"
fi

# Create directory structure
sudo mkdir -pv $LFS
sudo mkdir -pv $LFS/sources
sudo chmod -v a+wt $LFS/sources

# Copy scripts and source files to the partition
sudo chown -R "$USER" *.sh chapter* packages.csv "$LFS/sources"
cp -rf *.sh chapter* packages.csv "$LFS/sources"

# Download packages
cd "$LFS/sources"
source download.sh

# Prepare filesystem hierarchy
sudo mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}
for i in bin lib sbin; do
    if [ ! -L $LFS/$i ]; then
        sudo ln -sv usr/$i $LFS/$i
    fi
done

case $(uname -m) in
    x86_64) sudo mkdir -pv $LFS/lib64 ;;
esac

sudo mkdir -pv $LFS/tools

# Create lfs user if not already present
if ! id -u lfs &>/dev/null; then
    echo "Creating LFS user..."
    source lfs_user.sh
fi

# Set permissions
sudo chown -R lfs:lfs $LFS/tools
sudo chown -R lfs:lfs $LFS/sources

# Make sure build script is ready
sudo chmod +x $LFS/sources/build_temporary_tools.sh
sudo chown lfs:lfs $LFS/sources/build_temporary_tools.sh

echo "✅ LFS setup completed."
echo "🔧 Running build_temporary_tools.sh as lfs user..."

sudo -u lfs bash << 'EOF'
set +h
umask 022
export LFS=/mnt/lfs
export LC_ALL=POSIX
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export PATH=$LFS/tools/bin:/usr/bin:/bin
export CONFIG_SITE=$LFS/usr/share/config.site
cd $LFS/sources
./build_temporary_tools.sh
EOF
