
cat packages.csv | grep -v "^package" | while IFS=, read -r name version url md5 ; do
    NAME="$name"
    VERSION="$version"
    URL=$(echo "$url" | sed "s/@/$version/g")
    MD5SUM="$md5"
    CACHEFILE="$(basename "$URL")"

    if [ ! -f "$CACHEFILE" ]; then
        echo "Downloading $URL"
        wget "$URL"
        if ! echo "$MD5SUM $CACHEFILE" | md5sum -c >/dev/null; then
            rm -f "$CACHEFILE"
            echo "Verification of $CACHEFILE failed! MD5 mismatch!"
            exit 1
        fi
    fi
done
