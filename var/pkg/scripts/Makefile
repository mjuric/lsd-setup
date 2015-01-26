#############################################################
# DO NOT INVOKE THIS MAKEFILE DIRECTLY. USE lsd-pkg INSTEAD #
#############################################################
#
# `make' must be invoked from var/pkg/installed (for build/update)
# or var/pkg/sources (for download)
#
LSDVER=anaconda-updates
LSDPKG=lsd-$(LSDVER)

SHELL:=/bin/bash

DEST := $(shell cd ../../.. && pwd)
PKG:=$(DEST)/var/pkg
BUILD:=$(PKG)/build
INST:=$(PKG)/sources
INSTLOG:=$(PKG)/log
MODULES:=$(DEST)/usr/local

NCPU:=$(shell cat /proc/cpuinfo  | grep processor | wc |  awk '{print $$1}')

all: lsd
	@echo ...

dlall: lsd
	@echo ...

#
# List of all python packages that can be installed
#

PY_PACKAGES:=urlgrabber-3.9.1 Polygon-2.0.2-mjuric-3 scottransom-pyslalib-97cfc40
PY_SPECIAL_PKGS:=scikits.ann-0.2.dev-r803-mjuric-3 $(LSDPKG)

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
lsd: $(LSDPKG)
	@
matplotlib: ipython-0.10.2 matplotlib-1.1.0
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
$(LSDPKG): scikits.ann-0.2.dev-r803-mjuric-3 scottransom-pyslalib-97cfc40 Polygon-2.0.2-mjuric-3 urlgrabber-3.9.1 zlib-1.2.5

scikits.ann-0.2.dev-r803-mjuric-3: ann_1.1.2-mjuric
ann_1.1.2-mjuric: swig-2.0.4
swig-2.0.4: pcre-8.12 zlib-1.2.5
pcre-8.12: zlib-1.2.5

ENV:=env -u PYTHONHOME PKG_CONFIG_PATH="$(DEST)/lib/pkgconfig:$$PKG_CONFIG_PATH" PATH=$(MODULES)/bin:$(DEST)/bin:$$PATH LD_LIBRARY_PATH=$(DEST)/lib:$$LD_LIBRARY_PATH PYTHONPATH=$(MODULES)/lib/python
FLAGS=CFLAGS="-I$(DEST)/include" LDFLAGS="-L$(DEST)/lib"
CMD_MAKE=$(ENV) $(MAKE)
CMD_PREP=@(echo -n "Building $@ ... " 1>&2) && (cd $(BUILD) && rm -rf $@ && echo "$(INST)/$@.tar.bz2" && tar xjf $(INST)/$@.tar.bz2 && cd $@ && 
CMD_CONF_MAKE_INSTALL=$(ENV) $(FLAGS) ./configure --prefix=$(DEST) && $(CMD_MAKE) -j$(NCPU) && $(CMD_MAKE) install
CMD_LOG=) > $(INSTLOG)/$@.log 2>&1 && touch $@ && (echo done. 1>&2)
CMD_PYTHON=$(ENV) python
CMD_PY_INSTALL=$(CMD_PYTHON) setup.py install --home=$(MODULES)

ifdef DOWNLOAD
.PRECIOUS: ../sources/%.tar.bz2

# Fetch LSD from github
$(LSDPKG):
	@echo -n "Downloading lsd-$(LSDVER) from GitHub ... " 1>&2
	@wget -q -O - https://github.com/mjuric/lsd/archive/$(LSDVER).tar.gz | gunzip | bzip2 > $@.tmp && mv $@.tmp $@.tar.bz2
	@ echo "OK." 1>&2

../sources/%.tar.bz2:
	@echo -n "Downloading $(shell basename $@ .tar.bz2) ... " 1>&2
	@wget -q -c $(REMOTE)/repo/`basename $@` -O $@.tmp && mv $@.tmp $@
	@ echo "OK." 1>&2

% : ../sources/%.tar.bz2
	@

else

zlib-1.2.5 git-1.7.6 readline-6.2 sqlite-autoconf-3070701 freetype-2.4.6:
	$(CMD_PREP) $(CMD_CONF_MAKE_INSTALL) $(CMD_LOG)

libpng-1.4.8:
	$(CMD_PREP) \
	cp $(DEST)/include/zlib.h $(DEST)/include/zconf.h . && \
	$(CMD_CONF_MAKE_INSTALL) \
	$(CMD_LOG)

bzip2-1.0.6:
	$(CMD_PREP) \
	$(CMD_MAKE) -f Makefile-libbz2_so && $(CMD_MAKE) install PREFIX=$(DEST) && mkdir -p $(DEST)/lib && cp -a libbz2.so.1.0* $(DEST)/lib \
	$(CMD_LOG)

ncurses-5.9:
	$(CMD_PREP) \
	./configure --prefix=$(DEST) --with-shared $(FLAGS) && $(CMD_MAKE) -j$(NCPU) && $(CMD_MAKE) install \
	$(CMD_LOG)

gdbm-1.8.3:
	$(CMD_PREP) \
	$(CMD_CONF_MAKE_INSTALL) BINOWN=`id -u -n` BINGRP=`id -g -n` $(FLAGS) \
	$(CMD_LOG)

lzo-2.05:
	$(CMD_PREP) \
	./configure --prefix=$(DEST) --enable-shared $(FLAGS) && $(CMD_MAKE) -j$(NCPU) && $(CMD_MAKE) install \
	$(CMD_LOG)

Python-2.7.2:
	$(CMD_PREP) \
	./configure --prefix=$(DEST) CFLAGS="-I$(DEST)/include/ncurses -I$(DEST)/include" LDFLAGS="-L$(DEST)/lib" && $(CMD_MAKE) -j$(NCPU) && $(CMD_MAKE) install \
	$(CMD_LOG)

hdf5-1.8.7:
	$(CMD_PREP) \
	./configure --prefix=$(DEST) --enable-cxx $(FLAGS) && make -j$(NCPU) && make install \
	$(CMD_LOG)

lapack-3.3.1-mjuric:
	$(CMD_PREP) \
	$(CMD_MAKE) -j$(NCPU) blaslib && $(CMD_MAKE) -j$(NCPU) lapacklib && $(CMD_MAKE) && cp -a liblapack.a libblas.a $(DEST)/lib \
	$(CMD_LOG)

openssl-1.0.0d:
	$(CMD_PREP) \
	./config --prefix=$(DEST) --libdir=lib shared threads && $(CMD_MAKE) && $(CMD_MAKE) install \
	$(CMD_LOG)

libssh2-1.2.8:
	$(CMD_PREP) \
	./configure --prefix=$(DEST) --with-openssl=$(DEST) $(FLAGS) && $(CMD_MAKE) -j$(NCPU) && $(CMD_MAKE) install \
	$(CMD_LOG)

curl-7.21.7:
	$(CMD_PREP) \
	./configure --prefix=$(DEST) --with-libssh2=$(DEST) $(FLAGS) && make -j$(NCPU) && make install \
	$(CMD_LOG)

pcre-8.12:
	$(CMD_PREP) \
	./configure --prefix=$(DEST) --enable-pcregrep-libz --enable-pcregrep-libbz2 $(FLAGS) && make -j$(NCPU) && make install \
	$(CMD_LOG)

swig-2.0.4:
	$(CMD_PREP) \
	./configure --prefix=$(DEST) --with-pcre-prefix=$(DEST) $(FLAGS) && make -j$(NCPU) $(FLAGS) && make install \
	$(CMD_LOG)

ann_1.1.2-mjuric:
	$(CMD_PREP) \
	$(CMD_MAKE) linux-g++ && cp lib/* $(DEST)/lib && cp -r include/ANN $(DEST)/include \
	$(CMD_LOG)

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

$(LSDPKG):
	$(CMD_PREP) \
	$(CMD_PYTHON) setup.py install --home=$(DEST)/opt/lsd/$@ && \
	 (cd $(DEST)/opt/lsd && rm -f current && ln -sf "$@" current) && \
	 echo -e 'export PATH=$(DEST)/opt/lsd/$@/bin:$$PATH\nexport LD_LIBRARY_PATH=$(DEST)/opt/lsd/$@/lib:$$LD_LIBRARY_PATH\nexport PYTHONPATH=$(DEST)/opt/lsd/$@/lib/python:$$PYTHONPATH' > $(DEST)/opt/lsd/$@/lsd_environment.sh && \
	 rm -f $(DEST)/lsd_environment.sh && \
	 echo -e 'export PATH=$(DEST)/opt/lsd/current/bin:$$PATH\nexport LD_LIBRARY_PATH=$(DEST)/opt/lsd/current/lib:$$LD_LIBRARY_PATH\nexport PYTHONPATH=$(DEST)/opt/lsd/current/lib/python:$$PYTHONPATH' > $(DEST)/lsd_environment.sh \
	$(CMD_LOG)

endif
