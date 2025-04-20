
sed -i 's/extras//' Makefile.in

./configure --prefix=/usr

make

make install

ln -sv gawk.1 /usr/share/man/man1/awk.1

install -vDm644 doc/{awkforai.txt,*.{eps,pdf,jpg}} -t /usr/share/doc/gawk-$VERSION
