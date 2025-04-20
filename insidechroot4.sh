
export LFS=""
cd sources

cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point    type     options             dump  fsck
# order

/dev/sdb2      /              ext2    defaults            1     1
/dev/sdb1      /boot          ext2    defaults            1     1
proc           /proc          proc     nosuid,noexec,nodev 0     0
sysfs          /sys           sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts       devpts   gid=5,mode=620      0     0
tmpfs          /run           tmpfs    defaults            0     0
devtmpfs       /dev           devtmpfs mode=0755,nosuid    0     0
tmpfs          /dev/shm       tmpfs    nosuid,nodev        0     0
cgroup2        /sys/fs/cgroup cgroup2  nosuid,noexec,nodev 0     0

# End /etc/fstab
EOF

source packageinstall.sh 10 linux linux

grub-install --target i386-pc /dev/sdb

cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5
insmod ext2
set root=(hd0,msdos1)
menuentry "GNU/Linux, Linux 6.13.4-lfs-12.3" {
        linux   /vmlinuz-6.13.4-lfs-12.3 root=/dev/sdb2 rw
}
EOF
