#
# (c) 2019 Copyright, Real-Time Innovations, Inc.  All rights reserved.
#
# RTI grants Licensee a license to use, modify, compile, and create derivative
# works of the Software.  Licensee has the right to distribute object form
# only for use with RTI products.  The Software is provided "as is", with no
# warranty of any type, including any warranty for fitness for any purpose.
# RTI is under no obligation to maintain or support the Software.  RTI shall
# not be liable for any incidental or consequential damages arising out of the
# use or inability to use the software.
# 

###############################################################################
# CMake project declarations
###############################################################################
project(rtiroutingservice-adapter-file C)
cmake_minimum_required(VERSION 3.7.0)

include(${RSHELPER_DIR}/cmake/rtiroutingservice_plugin.cmake)

###############################################################################
###############################################################################

set(RSPLUGIN_NAME               rtiroutingservice-adapter-file)

set(RSPLUGIN_PREFIX             RTI_ADAPT_FILE)

set(RSPLUGIN_IDL                )

set(RSPLUGIN_INCLUDE_PREFIX     rtiadapt_file)
set(RSPLUGIN_INCLUDE_PREFIX_DIR rti)

set(RSPLUGIN_INCLUDE_C_PUBLIC   )

set(RSPLUGIN_INCLUDE_C          LineConversion.h)

set(RSPLUGIN_SOURCE_C           FileAdapter.c
                                LineConversion.c)

set(RSPLUGIN_LIBRARY            rtirsfileadapter)

set(RSPLUGIN_TESTER_PREFIX      rtiadaptfile_)

check_plugin_args()
default_plugin_options()
configure_plugin_deps()
configure_plugin()