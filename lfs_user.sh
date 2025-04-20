#!/bin/bash

# Create group and user
sudo groupadd lfs
sudo useradd -s /bin/bash -g lfs -m -k /dev/null lfs

# Set password (optional)
echo "Setting password for lfs user..."
echo "lfs:lfs" | sudo chpasswd

# Configure .bash_profile
sudo bash -c "cat > /home/lfs/.bash_profile" << 'EOF'
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

# Configure .bashrc
sudo bash -c "cat > /home/lfs/.bashrc" << 'EOF'
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export MAKEFLAGS=-j$(nproc)
EOF

# Set ownership
sudo chown lfs:lfs /home/lfs/.bash_profile /home/lfs/.bashrc
