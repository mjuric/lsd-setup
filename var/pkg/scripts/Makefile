#############################################################
# DO NOT INVOKE THIS MAKEFILE DIRECTLY. USE lsd-pkg INSTEAD #
#############################################################
#
# `make' must be invoked from var/pkg/installed (for build/update)
# or var/pkg/sources (for download)
#
DEST := $(shell cd ../../.. && pwd)
PKG:=$(DEST)/var/pkg
BUILD:=$(PKG)/build
INST:=$(PKG)/sources
INSTLOG:=$(PKG)/log
MODULES:=$(DEST)/usr/local

NCPU:=$(shell cat /proc/cpuinfo  | grep processor | wc |  awk '{print $$1}')

#
# Dirty test if prerequisites for WX exist
# Note: needs more testing, may not detect when gtk2 is present but gtk2-devel isn't
#
NO_WX=$(shell (which pkg-config > /dev/null 2>&1 && pkg-config gtk+-2.0) && echo "1" || echo "0")

all: lsd
	@echo ...

dlall: lsd matplotlib
	@echo ...

#
# List of all python packages that can be installed
#

PY_PACKAGES:=Cython-0.15 ipython-0.10.2 numexpr-1.4.2 \
             pyfits-2.4.0 PyYAML-3.10 pycurl-7.19.0 urlgrabber-3.9.1 Polygon-2.0.2-mjuric-3 \
             pywcs-1.10-4.7 matplotlib-1.0.1-mjuric scottransom-pyslalib-97cfc40
PY_SPECIAL_PKGS:=scipy-0.9.0 numpy-1.6.1 distribute-0.6.19 tables-2.2.1 scikits.ann-0.2.dev-r803-mjuric-3 lsd-0.5.4-24-g56e34c50

#
# Create package tree
#
tree:
	@ cd $(DEST) && mkdir -p usr/local/lib/python bin
	@ cd $(PKG) && mkdir -p installed log build sources etc
	@ cd $(DEST) && echo -e 'unset PYTHONHOME\nexport PATH=$(MODULES)/bin:$(DEST)/bin:$$PATH\nexport LD_LIBRARY_PATH=$(DEST)/lib:$$LD_LIBRARY_PATH\nexport PYTHONPATH=$(MODULES)/lib/python:$$PYTHONPATH' \
		> environment.sh
	@ ln -sf $(DEST)/var/pkg/scripts/lsd-pkg $(DEST)/bin
	@ touch $(DEST)/.lsdpkgroot

#
# Top-level packages and aliases
#
lsd: lsd-0.5.4-24-g56e34c50 ipython-0.10.2
	@
matplotlib: ipython-0.10.2 matplotlib-1.0.1-mjuric
	@
#
# Cleanup
#
purge:
	@ test -f .lsdpkgroot || { echo "Must run this from package root directory"; exit -1; }
	@ # TODO: add cleanup routines

clean:
	@ # Remove "built" markers to force next rebuild
	@ rm $(DEST)/var/pkg/installed/*

gc:
	@ # Remove the "build" directory
	@ rm -rf $(BUILD)/*

#
# Software dependencies
#
ifndef NO_WX
WXPYTHON=wxPython-src-2.8.12.1
endif

lsd-0.5.4-24-g56e34c50: git-1.7.6 tables-2.2.1 pyfits-2.4.0 PyYAML-3.10 \
        numpy-1.6.1 urlgrabber-3.9.1 Polygon-2.0.2-mjuric-3 \
        scikits.ann-0.2.dev-r803-mjuric-3 scottransom-pyslalib-97cfc40 pywcs-1.10-4.7
Python-2.7.2: bzip2-1.0.6 readline-6.2 ncurses-5.9 gdbm-1.8.3 sqlite-autoconf-3070701 lzo-2.05
distribute-0.6.19 ipython-0.10.2 numpy-1.6.1 numexpr-1.4.2: Python-2.7.2
Cython-0.15: numpy-1.6.1 Python-2.7.2
tables-2.2.1: numpy-1.6.1 numexpr-1.4.2 Cython-0.15 hdf5-1.8.7 Python-2.7.2
pyfits-2.4.0: numpy-1.6.1 Python-2.7.2
PyYAML-3.10: numpy-1.6.1 Python-2.7.2
pycurl-7.19.0: curl-7.21.7 Python-2.7.2
urlgrabber-3.9.1: pycurl-7.19.0 Python-2.7.2
Polygon-2.0.2-mjuric-3: numpy-1.6.1 Python-2.7.2
scikits.ann-0.2.dev-r803-mjuric-3: ann_1.1.2-mjuric Python-2.7.2 distribute-0.6.19
pywcs-1.10-4.7: numpy-1.6.1
ifndef NO_WX
wxPython-src-2.8.12.1: freetype-2.4.6 Python-2.7.2
endif
scipy-0.9.0: lapack-3.3.1-mjuric numpy-1.6.1
numpy-1.6.1: lapack-3.3.1-mjuric Python-2.7.2
matplotlib-1.0.1-mjuric: scipy-0.9.0 $(WXPYTHON)
curl-7.21.7: libssh2-1.2.8
ann_1.1.2-mjuric: swig-2.0.4
swig-2.0.4: pcre-8.12

ENV:=env -u PYTHONHOME PATH=$(MODULES)/bin:$(DEST)/bin:$$PATH LD_LIBRARY_PATH=$(DEST)/lib:$$LD_LIBRARY_PATH PYTHONPATH=$(MODULES)/lib/python
CMD_MAKE=$(ENV) $(MAKE)
CMD_PREP=@(echo -n "Building $@ ... " 1>&2) && (cd $(BUILD) && rm -rf $@ && echo "$(INST)/$@.tar.bz2" && tar xjf $(INST)/$@.tar.bz2 && cd $@ && 
CMD_CONF_MAKE_INSTALL=$(ENV) ./configure --prefix=$(DEST) && $(CMD_MAKE) -j$(NCPU) && $(CMD_MAKE) install
CMD_LOG=) > $(INSTLOG)/$@.log 2>&1 && touch $@ && (echo done. 1>&2)
CMD_PYTHON=$(ENV) python
CMD_PY_INSTALL=$(CMD_PYTHON) setup.py install --home=$(MODULES)

ifdef DOWNLOAD
.PRECIOUS: ../sources/%.tar.bz2

../sources/%.tar.bz2:
	@echo -n "Downloading $@ ... " 1>&2
	@wget -q -c $(REMOTE)/repo/`basename $@` -O $@.tmp && mv $@.tmp $@
	@ echo "$@ OK." 1>&2

% : ../sources/%.tar.bz2
	@

else

git-1.7.6 readline-6.2 sqlite-autoconf-3070701 libssh2-1.2.8 freetype-2.4.6:
	$(CMD_PREP) $(CMD_CONF_MAKE_INSTALL) $(CMD_LOG)

bzip2-1.0.6:
	$(CMD_PREP) \
	$(CMD_MAKE) -f Makefile-libbz2_so && $(CMD_MAKE) install PREFIX=$(DEST) && mkdir -p $(DEST)/lib && cp -a libbz2.so.1.0* $(DEST)/lib \
	$(CMD_LOG)

ncurses-5.9:
	$(CMD_PREP) \
	./configure --prefix=$(DEST) --with-shared && $(CMD_MAKE) -j$(NCPU) && $(CMD_MAKE) install \
	$(CMD_LOG)

gdbm-1.8.3:
	$(CMD_PREP) \
	$(CMD_CONF_MAKE_INSTALL) BINOWN=`id -u -n` BINGRP=`id -g -n` \
	$(CMD_LOG)

lzo-2.05:
	$(CMD_PREP) \
	./configure --prefix=$(DEST) --enable-shared && $(CMD_MAKE) -j$(NCPU) && $(CMD_MAKE) install \
	$(CMD_LOG)

Python-2.7.2:
	$(CMD_PREP) \
	./configure --prefix=$(DEST) CFLAGS="-I$(DEST)/include/ncurses -I$(DEST)/include" LDFLAGS="-L$(DEST)/lib" && $(CMD_MAKE) -j$(NCPU) && $(CMD_MAKE) install \
	$(CMD_LOG)

hdf5-1.8.7:
	$(CMD_PREP) \
	./configure --prefix=$(DEST) --enable-cxx && make -j$(NCPU) && make install \
	$(CMD_LOG)

lapack-3.3.1-mjuric:
	$(CMD_PREP) \
	$(CMD_MAKE) -j$(NCPU) blaslib && $(CMD_MAKE) -j$(NCPU) lapacklib && $(CMD_MAKE) && cp -a liblapack.a libblas.a $(DEST)/lib \
	$(CMD_LOG)

curl-7.21.7:
	$(CMD_PREP) \
	./configure --prefix=$(DEST) --with-libssh2=$(DEST) && make -j$(NCPU) && make install \
	$(CMD_LOG)

pcre-8.12:
	$(CMD_PREP) \
	./configure --prefix=$(DEST) --enable-pcregrep-libz --enable-pcregrep-libbz2 CFLAGS=-I$(DEST)/include LDFLAGS=-L$(DEST)/lib && make -j$(NCPU) && make install \
	$(CMD_LOG)

swig-2.0.4:
	$(CMD_PREP) \
	./configure --prefix=$(DEST) --with-pcre-prefix=$(DEST) CFLAGS=-I$(DEST)/include LDFLAGS=-L$(DEST)/lib && make -j$(NCPU) && make install \
	$(CMD_LOG)

ann_1.1.2-mjuric:
	$(CMD_PREP) \
	$(CMD_MAKE) linux-g++ && cp lib/* $(DEST)/lib && cp -r include/ANN $(DEST)/include \
	$(CMD_LOG)

ifndef NO_WX
wxPython-src-2.8.12.1:
	$(CMD_PREP) \
	mkdir bld && cd bld && $(ENV) ../configure --prefix=$(DEST) --with-gtk --enable-unicode --with-gnomeprint --enable-geometry --enable-display --enable-sound && \
	$(CMD_MAKE) -j$(NCPU) && \
	$(CMD_MAKE) install && \
	$(CMD_MAKE) -j$(NCPU) -C contrib/src/stc && \
	$(CMD_MAKE) -C contrib/src/stc install && \
	$(CMD_MAKE) -j$(NCPU) -C contrib/src/gizmos && \
	$(CMD_MAKE) -C contrib/src/gizmos install && \
	cd .. && \
	cd wxPython && \
	$(CMD_PY_INSTALL) BUILD_GLCANVAS=0 --home=$(MODULES)\
	$(CMD_LOG)
endif

$(PY_PACKAGES):
	$(CMD_PREP) \
	$(CMD_PY_INSTALL) \
	$(CMD_LOG)

scipy-0.9.0 numpy-1.6.1:
	$(CMD_PREP) \
	$(CMD_PYTHON) setup.py build --fcompiler=gnu95 install --home=$(MODULES) \
	$(CMD_LOG)

distribute-0.6.19:
	$(CMD_PREP) \
	DONT_PATCH_SETUPTOOLS=1 $(CMD_PY_INSTALL) \
	$(CMD_LOG)

tables-2.2.1:
	$(CMD_PREP) \
	$(CMD_PY_INSTALL) --hdf5=$(DEST) --lzo=$(DEST) --bzip2=$(DEST) \
	$(CMD_LOG)

scikits.ann-0.2.dev-r803-mjuric-3:
	$(CMD_PREP) \
	ANN_LIB=$(DEST)/lib ANN_INCLUDE=$(DEST)/include $(CMD_PY_INSTALL) \
	$(CMD_LOG)

lsd-0.5.4-24-g56e34c50:
	$(CMD_PREP) \
	$(CMD_PYTHON) setup.py install --home=$(DEST)/opt/lsd/$@ && \
	 echo -e 'export PATH=$(DEST)/opt/lsd/$@/bin:$$PATH\nexport LD_LIBRARY_PATH=$(DEST)/opt/lsd/$@/lib:$$LD_LIBRARY_PATH\nexport PYTHONPATH=$(DEST)/opt/lsd/$@/lib/python:$$PYTHONPATH' \
	  > $(DEST)/opt/lsd/$@/lsd_environment.sh && \
	  (cd $(DEST) && ln -sf "opt/lsd/$@/lsd_environment.sh" lsd_environment.sh) \
	$(CMD_LOG)

endif
