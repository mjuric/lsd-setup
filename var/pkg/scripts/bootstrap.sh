#!/bin/bash

REMOTE="http://faun.rc.fas.harvard.edu/mjuric/lsd-setup/"
DEFAULT_DEST=/home/mjuric/xxx
#REMOTE="http://localhost/lsd-setup/var/pkg"
#DEFAULT_DEST=/home/mjuric/xxx

# Create destination directory
cat <<EOF

Large Survey Databse Bootstrap Script
=====================================

This script will download and prepare an installation of a sandboxed
instance of the Large Survey Database.  The downloaded packages include most
LSD prerequisites, including Python 2.7, lapack, ipython, numpy, scipy and
matplotlib among others.  Your system only needs to provide the basic gcc
toolchain (gcc, g++ and gfortran), as well as gtk header files.  These are
usually installed by default on most RedHat setups (including derivatives
like CentOS, Scientific Linux, etc.)

Contact Mario Juric <mjuric@cfa.harvard.edu> if you encounter problems.

EOF

echo -n "LSD environment destination directory (default: $DEFAULT_DEST): "
read -e DEST
if [ "x$DEST" == "x" ]; then
	DEST="$DEFAULT_DEST"
fi
echo

# Pull down the 'pkg' tree
mkdir -p $DEST $DEST/var/pkg/scripts && touch $DEST/.pkgroot || exit $?

wget -q -P $DEST/var/pkg/scripts "$REMOTE/scripts/Makefile" && \
wget -q -P $DEST/var/pkg/scripts "$REMOTE/scripts/lsd-pkg" && \
chmod +x "$DEST/var/pkg/scripts/lsd-pkg" || { echo "Failed to download packaging scripts."; exit -1; }

# Initialize
(cd $DEST/var/pkg/scripts && make tree) || { echo "Failed to initialize the package directory."; exit -1; }
echo $REMOTE > $DEST/var/pkg/etc/remote

# Download
$DEST/var/pkg/scripts/lsd-pkg download || { echo "Failed to download the source files."; exit -1; }

cat << EOF

Congratulations, you have successfully downloaded LSD. Now run:

	$DEST/bin/lsd-pkg build

to build it. This will build everything needed to run LSD.

If you have GTK+2 toolkit development files installed, you may also want to
build matplotlib, a plotting library for python:

	$DEST/bin/lsd-pkg build matplotlib

EOF
