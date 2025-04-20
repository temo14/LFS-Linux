#!/bin/bash

set -e

# CHAPTER 5
for package in binutils gcc linux-api-headers glibc libstdc++; do
  case "$package" in
    linux-api-headers)
      source packageinstall.sh 5 "linux" "$package"
      ;;
    libstdc++)
      source packageinstall.sh 5 "gcc" "$package"
      ;;
    *)
      source packageinstall.sh 5 "$package" "$package"
      ;;
  esac
done

# CHAPTER 6
for package in m4 ncurses bash coreutils diffutils file findutils gawk grep gzip make patch sed tar xz binutils gcc; do
  source packageinstall.sh 6 "$package" "$package"
done


# Prepare for chroot
echo "Preparing for chroot environment..."
cd "$LFS/sources"

sudo chown -R lfs:lfs $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
  x86_64) sudo chown -R lfs:lfs $LFS/lib64 ;;
esac

sudo chmod ugo+x preparechroot.sh
sudo chmod ugo+x insidechroot*.sh
sudo chmod ugo+x teardownchroot.sh

sudo ./preparechroot.sh "$LFS"

# Enter chroot environment
for script in "/sources/insidechroot.sh" "/sources/insidechroot2.sh" "/sources/insidechroot3.sh" "/sources/insidechroot4.sh"; do
  echo "RUNNING $script IN CHROOT ENVIROMENT..."
  sleep 3
  sudo chroot "$LFS" /usr/bin/env -i \
      HOME=/root \
      TERM="$TERM" \
      PS1='(lfs chroot) \u:\w\$ ' \
      PATH=/usr/bin:/usr/sbin:/bin:/sbin \
      MAKEFLAGS="-j$(nproc)" \
      TESTSUITEFLAGS="-j$(nproc)" \
      /bin/bash --login +h -c "$script"
done

sudo ./teardownchroot.sh "$LFS" "$USER" "$(id -gn)"
