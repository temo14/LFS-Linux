
mkdir -p build
cd       build

meson setup --prefix=/usr ..    \
            --sbindir=/usr/sbin \
            --buildtype=release \
            -D manpages=false

ninja

ninja install
