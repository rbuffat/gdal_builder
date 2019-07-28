#!/bin/sh
set -e

ls -lh $GHPAGESDIR

# Create build dir if not exists
if [ ! -d "$PROJBUILD" ]; then
  mkdir $PROJBUILD;
fi

if [ ! -d "$PROJINST" ]; then
  mkdir $PROJINST;
fi

ls -l $PROJINST

if [ ! "$GHPAGESDIR/proj_$PROJVERSION-1_amd64.deb" ]; then
    cd $PROJBUILD

    wget http://download.osgeo.org/proj/proj-$PROJVERSION.tar.gz
    tar -xzf proj-$PROJVERSION.tar.gz
    cd proj-$PROJVERSION
    ./configure --prefix=$PROJINST/proj-$PROJVERSION
    make -j 2

    # Create deb package
    echo "gdal binary created to be used on travis. Do not use this file if you don't know what you are doing!" > description-pak
    checkinstall -D --nodoc --install=no -y

    ls -lh        
    mv "proj_$PROJVERSION-1_amd64.deb" "$GHPAGESDIR"

    rm -rf $PROJBUILD
fi

ls -lh $GHPAGESDIR

# change back to travis build dir
cd $TRAVIS_BUILD_DIR
