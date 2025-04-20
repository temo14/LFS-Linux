
CHAPTER="$1"
PACKAGE="$2"
FILE="$3"

cat packages.csv | grep -i "^$PACKAGE," | grep -i -v "\.patch;" | while IFS=, read -r name version url md5; do
    export VERSION="$version"
    URL=$(echo "$url" | sed "s/@/$version/g")
    CACHEFILE="$(basename "$URL")"
    DIRNAME="$(echo $CACHEFILE | sed 's/\(.*\)\.tar\..*/\1/')"

    if [ -d "$DIRNAME" ]; then
        rm -rf "$DIRNAME"
    fi
    mkdir -pv "$DIRNAME"

    echo "Extracting $CACHEFILE"
    tar -xf "$CACHEFILE" -C "$DIRNAME"

    pushd "$DIRNAME"

        if [ "$(ls -1A | wc -l)" == "1" ]; then
            mv $(ls -1A)/{*,.*} ./ 2>/dev/null || true
        fi

        echo "Compiling $PACKAGE"
        sleep 5

        mkdir -pv "../log/chapter$CHAPTER/"

        if ! source "../chapter$CHAPTER/$FILE.sh" 2>&1 | tee "../log/chapter$CHAPTER/$FILE.log" ; then
            echo "Compiling $PACKAGE FAILED!"
            popd
            exit 1
        fi

        echo "Done Compiling $PACKAGE"
    popd
done
