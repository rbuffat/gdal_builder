#!/bin/sh
set -e

GDALOPTS="  --with-ogr \
            --with-geos \
            --with-expat \
            --without-libtool \
            --with-libtiff=internal \
            --with-geotiff=internal \
            --without-gif \
            --without-pg \
            --without-grass \
            --without-libgrass \
            --without-cfitsio \
            --without-pcraster \
            --without-netcdf \
            --with-png=internal \
            --with-jpeg=internal \
            --without-gif \
            --without-ogdi \
            --without-fme \
            --without-hdf4 \
            --without-hdf5 \
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
            
for GDALVERSION in $GDAL_VERSIONS; do

    echo "Processing gdal: $GDALVERSION"

    # Gdal beta versions have file name 3.0.0b1, but present themselv as
    BASE_GDALVERSION=$(sed 's/[a-zA-Z].*//g' <<< $GDALVERSION)

    # Create build dir if not exists
    if [ ! -d "$GDALBUILD" ]; then
    mkdir $GDALBUILD;
    fi

    if [ ! -d "$GDALINST" ]; then
    mkdir $GDALINST;
    fi

    ls -l $GDALINST

    
    # only build if not already installed
    if [ ! -f "$GHPAGESDIR/gdal_$GDALVERSION-1_amd64.deb" ]; then
    
        # GDAL proj option
        GDALOPTS_PROJ=""
        DEB_DEPENDENCIES=""
        if $(dpkg --compare-versions "$GDALVERSION" "ge" "2.5"); then
            GDALOPTS_PROJ="--with-proj=$PROJINST/proj-$PROJVERSION";
            # DEB_DEPENDENCIES='--requires="proj (= $PROJVERSION)"'
            echo $DEB_DEPENDENCIES
            
            # install proj dependency
            if [ ! -f "$GHPAGESDIR/proj_$PROJVERSION-1_amd64.deb" ]; then
                echo "Proj deb not found: $GHPAGESDIR/proj_$PROJVERSION-1_amd64.deb"
                exit 1
            else
                sudo dpkg -i "$GHPAGESDIR/proj_$PROJVERSION-1_amd64.deb"
            fi
            
        fi

        cd $GDALBUIL

        if ( curl -o/dev/null -sfI "http://download.osgeo.org/gdal/$BASE_GDALVERSION/gdal-$GDALVERSION.tar.gz" ); then
            wget http://download.osgeo.org/gdal/$BASE_GDALVERSION/gdal-$GDALVERSION.tar.gz
        else
            wget http://download.osgeo.org/gdal/old_releases/gdal-$GDALVERSION.tar.gz
        fi

        tar -xzf gdal-$GDALVERSION.tar.gz
        
        if [ -d "gdal-$BASE_GDALVERSION" ]; then
            cd gdal-$BASE_GDALVERSION
        elif [ -d "gdal-$GDALVERSION" ]; then
            cd gdal-$GDALVERSION
        fi
        
        echo $GDALOPTS $GDALOPTS_PROJ
        ./configure --prefix=$GDALINST/gdal-$GDALVERSION $GDALOPTS $GDALOPTS_PROJ
        make -j 2

        # Create deb package
        echo "gdal binary created to be used on travis. Do not use this file if you don't know what you are doing!" > description-pak
        checkinstall -D $DEB_DEPENDENCIES --nodoc --install=no -y
        
        ls -lh        
        mv "gdal_$BASE_GDALVERSION-1_amd64.deb" "$GHPAGESDIR/gdal_$GDALVERSION-1_amd64.deb"


        # Clean
        rm -rf $GDALBUILD
        rm -rf $GDALINST
        
        if $(dpkg --compare-versions "$GDALVERSION" "ge" "2.5"); then
            sudo dpkg -r proj
        fi
    
    else
        echo "Deb found, skipping"
    
    fi
    

    # change back to travis build dir
    cd $TRAVIS_BUILD_DIR
done

echo "Done building gdal"

ls -lh $GHPAGESDIR

