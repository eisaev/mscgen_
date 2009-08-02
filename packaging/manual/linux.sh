#!/bin/bash

(cd ../../
 make distclean
 ./autogen.sh 
 ./configure 
 make distcheck || (echo "Distcheck failed!"; exit))

DIST_FILE=`ls ../../mscgen-*.tar.gz`
DIST_VER=`echo "$DIST_FILE" | sed "s/^.*-\([0-9]\+.[0-9]\+\).*$/\1/"`

rm -rf binstage buildstage mscgen-$DIST_VER

# Copy any unpack the source bundle
cp $DIST_FILE mscgen-src-$DIST_VER.tar.gz
tar -xzf mscgen-src-$DIST_VER.tar.gz

# Build the dynamic version
mkdir -p buildstage/dynamic
mkdir -p binstage/dynamic/mscgen-$DIST_VER
(cd buildstage/dynamic &&
 ../../mscgen-$DIST_VER/configure \
  --prefix="`pwd`/../../binstage/dynamic/mscgen-$DIST_VER" \
  && make install-strip)
tar -C binstage/dynamic -czf mscgen-$DIST_VER.tar.gz mscgen-$DIST_VER

# Build the static version
mkdir -p buildstage/static
mkdir -p binstage/static/mscgen-$DIST_VER
(cd buildstage/static &&
 ../../mscgen-$DIST_VER/configure \
  --prefix="`pwd`/../../binstage/static/mscgen-$DIST_VER" \
  CFLAGS="-static" \
  LDFLAGS="-Wl,-static" \
  GDLIB_CFLAGS="`pkg-config --static --cflags gdlib`" \
  GDLIB_LIBS="-lgd -lpng12 -lz -lm" \
  && make install-strip)
tar -C binstage/static -czf mscgen-static-$DIST_VER.tar.gz mscgen-$DIST_VER

# Clean up
rm -rf binstage buildstage mscgen-$DIST_VER

# Create MD5 file
for F in `ls *.tar.gz` ; do
  md5sum $F > $F.md5
done

# END OF SCRIPT