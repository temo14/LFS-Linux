#1/bin/bash

export LFS="$1"
export DIROWNER="$2"
export DIRGROUP="$3"

if mountpoint -q $LFS/dev/shm; then
  echo "Unmounting tmpfs from $LFS/dev/shm"
  umount $LFS/dev/shm
fi

if [ -d $LFS/dev/shm ] && [ ! -L $LFS/dev/shm ]; then
  echo "Removing $LFS/dev/shm directory"
  rmdir $LFS/dev/shm 2>/dev/null || echo "Warning: $LFS/dev/shm not empty or could not be removed"
fi

umount -vt sysfs sysfs $LFS/sys
umount -vt tmpfs tmpfs $LFS/run
umount -vt proc proc $LFS/proc

umount -v $LFS/dev/pts
umount -v $LFS/dev

chown -R $DIROWNER:$DIRGROUP $LFS/{usr,lib,var,etc,bin,sbin,tools}

case $(uname -m) in
  x86_64) chown -R $DIROWNER:$DIRGROUP $LFS/lib64 ;;
esac

