#!/bin/bash

export LFS="$1"


if [ "$LFS" == "" ]; then
    exit 1
fi

sudo chown -R $USER *.sh chapter* packages.csv "$LFS/sources"
cp -rf *.sh chapter* packages.csv "$LFS/sources"

chmod ugo+x preparechroot.sh
sudo ./preparechroot.sh "$LFS"

sudo chroot "$LFS" /usr/bin/env \
      HOME=/root \
      TERM="$TERM" \
      PS1='(lfs chroot) \u:\w\$ ' \
      PATH=/usr/bin:/usr/sbin:/bin:/sbin \
      MAKEFLAGS="-j$(nproc)" \
      TESTSUITEFLAGS="-j$(nproc)" \
      /bin/bash --login +h

chmod ugo+x teardownchroot.sh
sudo ./teardownchroot.sh "$LFS" "$USER" "$(id -gn)"

