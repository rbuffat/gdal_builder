#!/bin/bash
#
# Based on proj/gdal install scripts of Toblerity/Fiona and mapbox/rasterio

set -e

ls -lh $GHPAGESDIR

# Create build dir if not exists
if [ ! -d "$PROJBUILD" ]; then
  mkdir $PROJBUILD;
fi

if [ ! -d "$PROJINST" ]; then
  mkdir $PROJINST;
fi

echo "PROJ VERSION: $PROJVERSION FORCE_BUILD: $FORCE_BUILD" 

ARCHIVE_NAME="$GHPAGESDIR/proj_${PROJVERSION}_${DISTRIB_CODENAME}.tar.gz"
echo "$ARCHIVE_NAME"

if [ "$FORCE_BUILD" = "yes" ] && [ -f "$ARCHIVE_NAME" ] ; then
    echo "Delete existing archive"
    rm $ARCHIVE_NAME
fi

if [ ! -f "$ARCHIVE_NAME" ]; then

    echo "Build proj $PROJVERSION from source"
    
    cd $PROJBUILD

    wget -q http://download.osgeo.org/proj/proj-$PROJVERSION.tar.gz
    tar -xzf proj-$PROJVERSION.tar.gz
    cd proj-$PROJVERSION

    ./configure --prefix=$PROJINST/proj-$PROJVERSION
    make -j 2

    make install

    tar -czvf $ARCHIVE_NAME -C $HOME projinstall

    # Clean up
    rm -rf $PROJBUILD

else

    echo "Use previously built proj $PROJVERSION"
    
    tar -xzvf $ARCHIVE_NAME -C $HOME $PROJINST

fi

echo "Files in $PROJINST"
find $PROJINST

# change back to travis build dir
cd $TRAVIS_BUILD_DIR

echo "Done building proj"
