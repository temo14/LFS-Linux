
touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp

LFS=""

cd sources

# CHAPTER 7
for package in gettext bison perl python texinfo util-linux; do
  source packageinstall.sh 7 $package $package
done

# CHAPTER 8
for package in man-pages lana-etc glibc zlib bzip2 xz lz4 zstd file readline m4 bc flex tcl expect dejagnu pkgconf binutils gmp mpfr mpc attr acl libcap libxcrypt shadow gcc ncurses sed psmisc gettext bison grep bash libtool gdbm gperf expat inetutils less perl xml-parser intltool autoconf automake openssl elfutils libffi python flit-core wheel setuptools ninja meson kmod coreutils check diffutils gawk findutils groff grub gzip iproute2 kbd libpipeline make patch tar texinfo vim markupsafe jinja2 systemd man-db procps util-linux e2fsprogs sysklogd sysvinit;
do
    source packageinstall.sh 8 $package $package
done

