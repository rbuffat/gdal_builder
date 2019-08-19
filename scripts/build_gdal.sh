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
            

echo "Processing gdal: $GDALVERSION"


# Create build dir if not exists
if [ ! -d "$GDALBUILD" ]; then
    mkdir $GDALBUILD;
fi

if [ ! -d "$GDALINST" ]; then
    mkdir $GDALINST;
fi

if [ ! -d "$DEBDIR" ]; then
    mkdir $DEBDIR;
fi


DEB_PATH="$GHPAGESDIR/gdal_${GDALVERSION}_proj_${PROJVERSION}-1_amd64_${DISTRIB_CODENAME}.deb"

if [ "$GDALVERSION" = "master" ]; then

    GDALOPTS_PROJ="--with-proj=$GDALINST/gdal-$GDALVERSION";

    # We always rebuild master
    if [ -f $DEB_PATH ]; then
        rm $DEB_PATH
    fi

    # Checkout gdal master
    git clone -b master --single-branch --depth=1 https://github.com/OSGeo/gdal.git $GDALBUILD/master
    cd $GDALBUILD/master/gdal

    # Find current gdal version for checkinstall
    TRUNKVERSION=`cat $GDALBUILD/master/gdal/VERSION`
    PKGVERSION="--pkgversion=\"$TRUNKVERSION\""
    echo $PKGVERSION  

     # Build and install gdal
    echo $GDALOPTS $GDALOPTS_PROJ
    ./configure --prefix=$GDALINST/gdal-$GDALVERSION $GDALOPTS $GDALOPTS_PROJ
    make -j 2
    make install

    # Build deb
    python scripts/create_debian.py $GDALINST/gdal-$GDALVERSION $DEBDIR $GDALVERSION
    cd $HOME
    dpkg-deb --build $DEBDIR
    ls -lh
    mv -v "debdir.deb" "$DEB_PATH"

else

    BASE_GDALVERSION=$(sed 's/[a-zA-Z].*//g' <<< $GDALVERSION)

    # We only build gdal if no deb exists
    if [ ! -f $DEB_PATH ] || [ $FORCE_BUILD="yes" ]; then

        if $(dpkg --compare-versions "$GDALVERSION" "lt" "2.3"); then
            GDALOPTS_PROJ="--with-static-proj4=$GDALINST/gdal-$GDALVERSION";
        else
            GDALOPTS_PROJ="--with-proj=$GDALINST/gdal-$GDALVERSION";
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
        
        # Build and install gdal
        echo $GDALOPTS $GDALOPTS_PROJ
        ./configure --prefix=$GDALINST/gdal-$GDALVERSION $GDALOPTS $GDALOPTS_PROJ
        make -j 2
        make install

        # Build deb
        python scripts/create_debian.py $GDALINST/gdal-$GDALVERSION $DEBDIR $GDALVERSION
        cd $HOME
        dpkg-deb --build $DEBDIR
        ls -lh
        mv -v "debdir.deb" "$DEB_PATH"

    else
        echo "Deb found, skipping"
    fi

fi

# change back to travis build dir
cd $TRAVIS_BUILD_DIR

# Clean up
rm -rf $GDALBUILD
rm -rf $GDALINST


echo "Done building gdal"
ls -lh $GHPAGESDIR

