#!/bin/bash

#REMOTE="http://faun.rc.fas.harvard.edu/mjuric/lsd-setup/"
REMOTE="http://nebel.rc.fas.harvard.edu/mjuric/lsd-setup/"
DEFAULT_DEST="$HOME/lsd"

# Create destination directory
cat <<EOF

Large Survey Database Automated Installer
=========================================

This script will download and prepare an installation of a sandboxed
instance of the Large Survey Database.  The downloaded packages include most
LSD prerequisites, such as Python 2.7, lapack, ipython, numpy, scipy and
matplotlib among others.  Your system only needs to provide the basic gcc
toolchain (gcc, g++ and gfortran), as well as gtk+2.0 header files (if you
want to use interactive plotting with matplotlib).  These are usually
installed by default on many RedHat setups (including derivatives like
CentOS, Scientific Linux, etc.).

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
echo "All source packages downloaded."
echo

# Ask to build lsd
echo -n "Should I go ahead and build LSD and its prerequisites ([yes]/no)? "
read -e ANS
if [ "x$ANS" == x"yes" -o "x$ANS" == x"y" -o "x$ANS" == x"" ]; then
	$DEST/bin/lsd-pkg build || exit $?
else:
cat << EOF

Congratulations, you have successfully downloaded LSD, but chosen not to
build it at this time. When you're ready to build it, run:

	$DEST/bin/lsd-pkg build

to build it. This will build everything needed to run LSD.
EOF
fi

# Ask to build matplotlib
echo -n "Should I go ahead and build matplotlib, the plotting package for Python ([yes]/no)? "
read -e ANS
if [ "x$ANS" == x"yes" -o "x$ANS" == x"y" -o "x$ANS" == x"" ]; then
	$DEST/bin/lsd-pkg build matplotlib || exit $?
else:
cat << EOF
You have chosen not to build matplotlib at this time. If you change your mind,
you can always build it with:

	$DEST/bin/lsd-pkg build matplotlib

Note that unless you have GTK+2 toolkit header files, you won't be able to
use matplotlib's interactive plotting mode.
EOF
fi
