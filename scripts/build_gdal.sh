#!/bin/bash
#
# Based on proj/gdal install scripts of Toblerity/Fiona and mapbox/rasterio

#!/bin/sh
set -e

cd $TRAVIS_BUILD_DIR

GDALOPTS="  --with-ogr \
            --with-geos \
            --with-expat \
            --without-libtool \
            --with-libz=internal \
            --with-libtiff=internal \
            --with-geotiff=internal \
            --without-gif \
            --without-pg \
            --without-grass \
            --without-libgrass \
            --without-cfitsio \
            --without-pcraster \
            --with-netcdf \
            --with-png=internal \
            --with-jpeg=internal \
            --without-gif \
            --without-ogdi \
            --without-fme \
            --without-hdf4 \
            --with-hdf5 \
            --without-jasper \
            --without-ecw \
            --without-kakadu \
            --without-mrsid \
            --without-jp2mrsid \
            --without-bsb \
            --without-grib \
            --without-mysql \
            --without-ingres \
            --without-xerces \
            --without-odbc \
            --with-curl \
            --with-sqlite3 \
            --without-dwgdirect \
            --without-idb \
            --without-sde \
            --without-perl \
            --without-php \
            --without-ruby \
            --without-python
            --with-oci=no \
            --without-mrf \
            --with-webp=no"
            

echo "GDAL VERSION: $GDALVERSION PROJ VERSION: $PROJVERSION FORCE_BUILD: $FORCE_BUILD" 

# Create build dir if not exists
if [ ! -d "$GDALBUILD" ]; then
    mkdir $GDALBUILD;
fi

if [ ! -d "$GDALINST" ]; then
    mkdir $GDALINST;
fi


ARCHIVE_NAME="$GHPAGESDIR/gdal_${GDALVERSION}_proj_${PROJVERSION}_${DISTRIB_CODENAME}.tar.gz"


if [ "$FORCE_BUILD" = "yes" ] && [ -f "$ARCHIVE_NAME" ] ; then
    echo "Delete existing archive"
    rm $ARCHIVE_NAME
fi


if [ "$GDALVERSION" = "master" ]; then

    PROJOPT="--with-proj=$PROJINST/proj-$PROJVERSION"

    # We always rebuild master
    if [ -f $ARCHIVE_NAME ]; then
        rm $ARCHIVE_NAME
    fi

    # Checkout gdal master
    git clone -b master --single-branch --depth=1 https://github.com/OSGeo/gdal.git $GDALBUILD/master
    cd $GDALBUILD/master/gdal

    # Find current gdal version for checkinstall
    TRUNKVERSION=`cat $GDALBUILD/master/gdal/VERSION`
    PKGVERSION="--pkgversion=\"$TRUNKVERSION\""
    echo $PKGVERSION  

    # Build gdal
    echo $GDALOPTS $PROJOPT
    ./configure --prefix=$GDALINST/gdal-$GDALVERSION $GDALOPTS $PROJOPT
    make -j 2

    make install

    tar -czvf $ARCHIVE_NAME -C $GDALINST .

else

    BASE_GDALVERSION=$(sed 's/[a-zA-Z].*//g' <<< $GDALVERSION)


    # We only build gdal if no archive exists
    if [ ! -f $ARCHIVE_NAME ]; then

        if $(dpkg --compare-versions "$GDALVERSION" "lt" "2.3"); then
            PROJOPT="--with-static-proj4=$PROJINST/proj-$PROJVERSION";
        else
            PROJOPT="--with-proj=$PROJINST/proj-$PROJVERSION";

        fi
        
        # Download and extract GDAL
        if ( curl -o/dev/null -sfI "http://download.osgeo.org/gdal/$BASE_GDALVERSION/gdal-$GDALVERSION.tar.gz" ); then
            wget -q http://download.osgeo.org/gdal/$BASE_GDALVERSION/gdal-$GDALVERSION.tar.gz
        else
            wget -q http://download.osgeo.org/gdal/old_releases/gdal-$GDALVERSION.tar.gz
        fi

        tar -xzf gdal-$GDALVERSION.tar.gz
        
        if [ -d "gdal-$BASE_GDALVERSION" ]; then
            cd gdal-$BASE_GDALVERSION
        elif [ -d "gdal-$GDALVERSION" ]; then
            cd gdal-$GDALVERSION
        fi
        
        # Build gdal
        echo $GDALOPTS $PROJOPT
        ./configure --prefix=$GDALINST/gdal-$GDALVERSION $GDALOPTS $PROJOPT
        make -j 2

        make install

        cd $HOME
        tar -czvf $ARCHIVE_NAME -C $GDALINST .

    else
        echo "Archive found, skipping"
    fi

fi

echo "Files in $GDALINST:"
find $GDALINST


# change back to travis build dir
cd $TRAVIS_BUILD_DIR


echo "Done building gdal"
ls -lh $GHPAGESDIR

