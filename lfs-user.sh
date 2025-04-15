#!/bin/bash
# Script to create the LFS user

# Create the LFS user and group
sudo groupadd lfs
sudo useradd -s /bin/bash -g lfs -m -k /dev/null lfs

# Set a password for the LFS user
echo "Setting password for LFS user..."
echo "lfs:lfs" | sudo chpasswd

# Create bash profile for the LFS user
sudo bash -c "cat > /home/lfs/.bash_profile << 'EOF'
exec env -i HOME=\$HOME TERM=\$TERM PS1='\u:\w\$ ' /bin/bash
EOF"

# Create bashrc for the LFS user
sudo bash -c "cat > /home/lfs/.bashrc << 'EOF'
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=\$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:\$PATH; fi
PATH=\$LFS/tools/bin:\$PATH
CONFIG_SITE=\$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export MAKEFLAGS=-j\$(nproc)
EOF"

# Set proper permissions for the profile files
sudo chown lfs:lfs /home/lfs/.bash_profile /home/lfs/.bashrc

echo "LFS user created successfully."
