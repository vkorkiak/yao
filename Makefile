Y_MAKEDIR=/usr/lib/yorick
Y_EXE=/usr/lib/yorick/bin/yorick
Y_EXE_PKGS=
Y_EXE_HOME=/usr/lib/yorick
Y_EXE_SITE=/usr/lib/yorick

# ----------------------------------------------------- optimization flags

COPT=$(COPT_DEFAULT)
TGT=$(DEFAULT_TGT)

# ------------------------------------------------ macros for this package

PKG_NAME=yao
PKG_I=yao_utils.i yao_fast.i

OBJS=aoSimulUtils.o utils.o yao_fast.o

# change to give the executable a name other than yorick
PKG_EXENAME=yorick

FFTW3_PATH=/usr

# PKG_DEPLIBS=-Lsomedir -lsomelib   for dependencies of this package
PKG_DEPLIBS=-L$(FFTW3_PATH)/lib -lfftw3f
# set compiler or loader (rare) flags specific to this package
PKG_CFLAGS=
PKG_LDFLAGS=

# list of additional package names you want in PKG_EXENAME
# (typically Y_EXE_PKGS should be first here)
EXTRA_PKGS=$(Y_EXE_PKGS)

# list of additional files for clean
PKG_CLEAN=

# autoload file for this package, if any
PKG_I_START=

# -------------------------------- standard targets and rules (in Makepkg)

# set macros Makepkg uses in target and dependency names
# DLL_TARGETS, LIB_TARGETS, EXE_TARGETS
# are any additional targets (defined below) prerequisite to
# the plugin library, archive library, and executable, respectively
PKG_I_DEPS=$(PKG_I)

include $(Y_MAKEDIR)/Make.cfg
include $(Y_MAKEDIR)/Makepkg
include $(Y_MAKEDIR)/Make$(TGT)

# override macros Makepkg sets for rules and other macros
# Y_HOME and Y_SITE in Make.cfg may not be correct (e.g.- relocatable)
Y_HOME=$(Y_EXE_HOME)
Y_SITE=$(Y_EXE_SITE)

# reduce chance of yorick-1.5 corrupting this Makefile
MAKE_TEMPLATE = protect-against-1.5

# ------------------------------------- targets and rules for this package

# simple example:
#myfunc.o: myapi.h
# more complex example (also consider using PKG_CFLAGS above):
#myfunc.o: myapi.h myfunc.c
#	$(CC) $(CPPFLAGS) $(CFLAGS) -DMY_SWITCH -o $@ -c myfunc.c

# -------------------------------------------------------- end of Makefile


# for the binary package production (add full path to lib*.a below):
PKG_DEPLIBS_STATIC=-lm /usr/lib/libfftw3f.a
PKG_ARCH = $(OSTYPE)-$(MACHTYPE)
# The above usually don't work. Edit manually and change the PKG_ARCH below:
PKG_ARCH = linux-x86
PKG_VERSION = $(shell (awk '{if ($$1=="Version:") print $$2}' $(PKG_NAME).info))
# .info might not exist, in which case he line above will exit in error.

# packages or devel_pkgs:
PKG_DEST_URL = packages

package:
	$(MAKE)
	$(LD_DLL) -o $(PKG_NAME).so $(OBJS) ywrap.o $(PKG_DEPLIBS_STATIC) $(DLL_DEF)
	mkdir -p binaries/$(PKG_NAME)/dist/y_home/lib
	mkdir -p binaries/$(PKG_NAME)/dist/y_home/i-start
	mkdir -p binaries/$(PKG_NAME)/dist/y_site/i0
	mkdir -p binaries/$(PKG_NAME)/dist/y_site/g
	mkdir -p binaries/$(PKG_NAME)/dist/y_site/python
	mkdir -p binaries/$(PKG_NAME)/dist/y_site/glade
	mkdir -p binaries/$(PKG_NAME)/dist/y_site/contrib/yao/examples
	cp -p *.i binaries/$(PKG_NAME)/dist/y_site/i0/
	rm binaries/$(PKG_NAME)/dist/y_site/i0/check.i
	if test -n "$(PKG_I_START)"; then rm binaries/$(PKG_NAME)/dist/y_site/i0/$(PKG_I_START); fi
	cp -p $(PKG_NAME).so binaries/$(PKG_NAME)/dist/y_home/lib/
	if test -f "check.i"; then cp -p check.i binaries/$(PKG_NAME)/.; fi
	if test -n "$(PKG_I_START)"; then cp -p $(PKG_I_START) \
	  binaries/$(PKG_NAME)/dist/y_home/i-start/; fi
	cat $(PKG_NAME).info | sed -e 's/OS:/OS: $(PKG_ARCH)/' > tmp.info
	mv tmp.info binaries/$(PKG_NAME)/$(PKG_NAME).info
	cp -p *.i binaries/$(PKG_NAME)/dist/y_site/i0/.
	cp -p README binaries/$(PKG_NAME)/dist/y_site/contrib/yao/.
	cp -p INSTALL binaries/$(PKG_NAME)/dist/y_site/contrib/yao/.
	cp -p LICENSE binaries/$(PKG_NAME)/dist/y_site/contrib/yao/.
	cp -p yao.py binaries/$(PKG_NAME)/dist/y_site/python/.
	cp -p yao.glade binaries/$(PKG_NAME)/dist/y_site/glade/.
	cp -p aosimul3.gs binaries/$(PKG_NAME)/dist/y_site/g/.
	cp -p letter.gs binaries/$(PKG_NAME)/dist/y_site/g/.
	cp -p examples/* binaries/$(PKG_NAME)/dist/y_site/contrib/yao/examples/.	
	cd binaries; tar zcvf $(PKG_NAME)-$(PKG_VERSION)-$(PKG_ARCH).tgz $(PKG_NAME)

distbin:
	if test -f "binaries/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_ARCH).tgz" ; then \
	  ncftpput -f $(HOME)/.ncftp/maumae www/yorick/$(PKG_DEST_URL)/$(PKG_ARCH)/tarballs/ \
	  binaries/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_ARCH).tgz; fi
	if test -f "binaries/$(PKG_NAME)/$(PKG_NAME).info" ; then \
	  ncftpput -f $(HOME)/.ncftp/maumae www/yorick/$(PKG_DEST_URL)/$(PKG_ARCH)/info/ \
	  binaries/$(PKG_NAME)/$(PKG_NAME).info; fi

distsrc:
	make clean; rm -rf binaries
	cd ../..; tar --exclude binaries --exclude .svn -zcvf \
	   $(PKG_NAME)-$(PKG_VERSION)-src.tgz $(PKG_NAME);\
	ncftpput -f $(HOME)/.ncftp/maumae www/yorick/$(PKG_DEST_URL)/src/ \
	   $(PKG_NAME)-$(PKG_VERSION)-src.tgz


# -------------------------------------------------------- end of Makefile