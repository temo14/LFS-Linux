
make mrproper

make defconfig

make -j$(nproc)

make modules_install

cp -iv arch/x86/boot/bzImage /boot/vmlinuz-$VERSION-lfs-12.3
cp -iv System.map /boot/System.map-$VERSION
cp -iv .config /boot/config-$VERSION
cp -r Documentation -T /usr/share/doc/linux-$VERSION

install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF
