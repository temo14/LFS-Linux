
make mrproper

make headers
find usr/include -type f ! -name '*.h' -delete
sudo cp -rv usr/include $LFS/usr
