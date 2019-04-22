#!/bin/sh
set -e

wget http://download.osgeo.org/proj/proj-$PROJVERSION.tar.gz
tar -xzf proj-$PROJVERSION.tar.gz
cd proj-$PROJVERSION
./configure --prefix=/usr/local
make -j 2
checkinstall --install=no  --pkgname="libproj" --pkgversion="$PROJVERSION" --pkgrelease="1"  --default 

# change back to travis build dir
cd $TRAVIS_BUILD_DIR
