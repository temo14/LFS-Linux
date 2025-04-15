#!/bin/bash
export LFS=/mnt/lfs
export LFS_TGT=x86_64-lfs-linux-gnu
export LFS_DISK=/dev/sdb
if ! grep -q "$LFS" /proc/mounts; then
     source setupdisk.sh "$LFS_DISK"
     sudo mount "${LFS_DISK}2" "$LFS"
     sudo chown -v $USER "$LFS"
fi

mkdir -pv $LFS/sources
mkdir -pv $LFS/tools
mkdir -pv $LFS/boot
mkdir -pv $LFS/etc
mkdir -pv $LFS/bin
mkdir -pv $LFS/lib
mkdir -pv $LFS/sbin
mkdir -pv $LFS/usr
mkdir -pv $LFS/var

case $(uname -m) in
  x86_64) mkdir -pv $LFS/lib64 ;;
esac

cp -rf .sh chapter packages.csv "$LFS/sources"
cd "$LFS/sources"
export PATH="$LFS/tools/bin:$PATH"
source download.sh
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
  source packageinstall.sh 6 $package $package
done
chmod ugo+x preparechroot.sh
chmod ugo+x insidechroot.sh
sudo ./preparechroot.sh "$LFS"
echo "ENTERING CHROOT ENVIROMENT..."
sleep 3
sudo chroot "$LFS" /usr/bin/env \
  HOME=/root \
  TERM="$TERM" \
  PS1='(lfs chroot) \u:\w\$ ' \
  PATH=/usr/bin:/usr/sbin:/bin:/sbin \
  MAKEFLAGS="-j$(nproc)" \
  TESTSUITEFLAGS="-j$(nproc)" \
  /bin/bash --login +h -c "/sources/insidechroot.sh" #!/bin/bash
