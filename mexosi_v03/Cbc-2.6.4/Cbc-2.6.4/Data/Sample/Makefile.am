# Copyright (C) 2006 International Business Machines and others.
# All Rights Reserved.
# This file is distributed under the Common Public License.

## $Id: Makefile.am 150 2010-06-13 17:59:52Z stefan $

# Author:  Andreas Waechter           IBM    2006-04-13

AUTOMAKE_OPTIONS = foreign

########################################################################
#                List files that should be distributed                 #
########################################################################

EXTRA_DIST = $(EXAMPLE_FILES) README AUTHORS LICENSE

DISTCLEANFILES = $(EXAMPLE_CLEAN_FILES)

datacoindir = $(datadir)/coin/Data/Sample
datacoin_DATA = $(EXAMPLE_FILES)

coindocdir = $(datadir)/coin/doc/Data/Sample
coindoc_DATA = README AUTHORS LICENSE

pkgconfiglibdir = $(libdir)/pkgconfig
pkgconfiglib_DATA = coindatasample.pc

include BuildTools/Makemain.inc
