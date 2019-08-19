import sys
import os
import glob
import shutil

install_dir = sys.argv[1]
deb_dir = sys.argv[2]
gdalversion = sys.argv[3]

if not os.path.exists(deb_dir):
    os.mkdir(deb_dir)

# Create Debian Directory
DEBIAN_dir = os.path.join(deb_dir, "DEBIAN")
if not os.path.exists(DEBIAN_dir):
    os.mkdir(DEBIAN_dir)

# Create control
control_txt = """Package: gdal
Architecture: amd64
Maintainer: gdal_builder
Depends: libhdf5-serial-dev, libatlas-dev, libatlas-base-dev, gfortran
Priority: optional
Version: {GDALVERSION}
Description: Package for gdal and proj to be used on travis.
 Do not use this package if you don't know what you are doing!

""".format(GDALVERSION=gdalversion)

control_path = os.path.join(DEBIAN_dir, "control")
with open(control_path, "w") as f:
    f.write(control_txt)


# Copy files
deb_gdalinstall_path = os.path.join(deb_dir, 'home', 'travis', 'gdalinstall')
os.makedirs(deb_gdalinstall_path)

shutil.copytree(install_dir, os.path.join(deb_gdalinstall_path, 'gdal-{}'.format(gdalversion)))

