#!/bin/sh
set -e

ls -lh $GHPAGESDIR

# Create build dir if not exists
if [ ! -d "$PROJBUILD" ]; then
  mkdir $PROJBUILD;
fi

if [ ! -d "$GDALINST" ]; then
  mkdir $GDALINST;
fi

if [ ! -d "$GDALINST/gdal-$GDALVERSION/share/proj" ] || [ $FORCE_BUILD="yes" ]; then
    
    cd $PROJBUILD

    wget -q http://download.osgeo.org/proj/proj-$PROJVERSION.tar.gz
    tar -xzf proj-$PROJVERSION.tar.gz
    cd proj-$PROJVERSION
    ./configure --prefix=$GDALINST/gdal-$GDALVERSION
    make -j 2
    
    make install
    
    # Clean up
    rm -rf $PROJBUILD

else
    echo "Proj found, skipping"
fi

# change back to travis build dir
cd $TRAVIS_BUILD_DIR


echo "Done building proj"
