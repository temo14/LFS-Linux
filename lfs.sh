#!/bin/bash
# Main LFS build script following LFS 12.3

# Set up environment variables
export LFS=/mnt/lfs
umask 022
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export LFS_DISK=/dev/sdb

# Ensure the partition is mounted
if ! grep -q "$LFS" /proc/mounts; then
    echo "Mounting LFS partition..."
    source setupdisk.sh "$LFS_DISK"
    sudo mount "${LFS_DISK}2" "$LFS"
    sudo chown -v $USER "$LFS"
fi

# Create directory structure
mkdir -pv $LFS
mkdir -pv $LFS/sources
chmod -v a+wt $LFS/sources

# Copy necessary scripts and files to partition
cp -rf *.sh chapter* packages.csv "$LFS/sources"

# Download packages
cd "$LFS/sources"
source download.sh

# Set up directory structure
sudo mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

for i in bin lib sbin; do
    sudo ln -sv usr/$i $LFS/$i
done

case $(uname -m) in
    x86_64) sudo mkdir -pv $LFS/lib64 ;;
esac

mkdir -pv $LFS/tools

# Create LFS user if it doesn't exist
if ! id -u lfs &>/dev/null; then
    echo "Creating LFS user..."
    source lfs-user.sh
fi

# Give LFS user ownership of directories
sudo chown -R lfs:lfs $LFS/tools
sudo chown -R lfs:lfs $LFS/sources

# Chapter 5 and chapter 6
echo "Building temporary tools as LFS user..."
sudo -u lfs bash << EOF
cd $LFS/sources
# Set up environment properly for LFS user
set +h
umask 022
export LFS=$LFS
export LC_ALL=POSIX
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export PATH=/usr/bin:/bin
export PATH=$LFS/tools/bin:$PATH
export CONFIG_SITE=$LFS/usr/share/config.site
export MAKEFLAGS=-j$(nproc)

# CHAPTER 5
for package in binutils gcc linux-api-headers glibc libstdc++; do
  case "\$package" in
    linux-api-headers)
      source packageinstall.sh 5 "linux" "\$package"
      ;;
    libstdc++)
      source packageinstall.sh 5 "gcc" "\$package"
      ;;
    *)
      source packageinstall.sh 5 "\$package" "\$package"
      ;;
  esac
done

# CHAPTER 6
for package in m4 ncurses bash coreutils diffutils file findutils gawk grep gzip make patch sed tar xz binutils gcc; do
  source packageinstall.sh 6 \$package \$package
done
EOF

# Prepare for chroot
echo "Preparing for chroot environment..."
cd "$LFS/sources"
sudo chmod ugo+x preparechroot.sh
sudo chmod ugo+x insidechroot.sh
sudo ./preparechroot.sh "$LFS"

# Step 10: Enter chroot environment
echo "ENTERING CHROOT ENVIRONMENT..."
sleep 3
sudo chroot "$LFS" /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin:/bin:/sbin \
    MAKEFLAGS="-j$(nproc)" \
    TESTSUITEFLAGS="-j$(nproc)" \
    /bin/bash --login
