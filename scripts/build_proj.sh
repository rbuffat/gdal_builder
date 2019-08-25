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

ARCHIVE_NAME="$GHPAGESDIR/proj_${PROJVERSION}_${DISTRIB_CODENAME}.tar.gz"

echo "$ARCHIVE_NAME"

if [ ! -f "$ARCHIVE_NAME" ] || [ "$FORCE_BUILD" = "yes" ]; then

    echo "Build proj $PROJVERSION from source"
    
    cd $PROJBUILD

    wget -q http://download.osgeo.org/proj/proj-$PROJVERSION.tar.gz
    tar -xzf proj-$PROJVERSION.tar.gz
    cd proj-$PROJVERSION
    ./configure --prefix=$PROJINST/proj-$PROJVERSION
    make -j 2

    make install

    tar -czvf $ARCHIVE_NAME $PROJINST
    
else
    echo "Use previously built proj $PROJVERSION"
    
    tar -xzvf $ARCHIVE_NAME -C $PROJINST

fi

find $PROJINST

# change back to travis build dir
cd $TRAVIS_BUILD_DIR

echo "Done building proj"
ls -lh $GHPAGESDIR
