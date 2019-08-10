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

DEB_PATH="$GHPAGESDIR/proj_${PROJVERSION}-1_amd64_${DISTRIB_CODENAME}.deb"

echo "$DEB_PATH"

if [ ! -f "$DEB_PATH" ]; then
    
    cd $PROJBUILD

    wget -q http://download.osgeo.org/proj/proj-$PROJVERSION.tar.gz
    tar -xzf proj-$PROJVERSION.tar.gz
    cd proj-$PROJVERSION
    ./configure --prefix=$PROJINST/proj-$PROJVERSION
    make -s -j 2

    # Create deb package
    echo "proj binary created to be used on travis. Do not use this file if you don't know what you are doing!" > description-pak
    checkinstall -D --nodoc --install=no -y

    ls -lh        
    mv "proj_$PROJVERSION-1_amd64.deb" "$DEB_PATH"
    
else
    echo "Deb found, skipping"
fi

# change back to travis build dir
cd $TRAVIS_BUILD_DIR

# Clean up
rm -rf $PROJBUILD
rm -rf $PROJINST

echo "Done building proj"
ls -lh $GHPAGESDIR
