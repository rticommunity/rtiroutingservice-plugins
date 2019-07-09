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
project(rtiroutingservice-transform-simple C)
cmake_minimum_required(VERSION 3.7.0)

include(${RSHELPER_DIR}/cmake/rtiroutingservice_plugin.cmake)

###############################################################################
###############################################################################

set(RSPLUGIN_NAME                   rtiroutingservice-transform-simple)
set(RSPLUGIN_PREFIX                 RTI_TSFM)
set(RSPLUGIN_INCLUDE_PREFIX         rtitransform_simple)
set(RSPLUGIN_INCLUDE_PREFIX_DIR     rti)
set(RSPLUGIN_IDL                    )
set(RSPLUGIN_INCLUDE_C_PUBLIC       platform
                                    log
                                    noop
                                    tmplt_declare
                                    tmplt_define)

set(RSPLUGIN_INCLUDE_C              common/Infrastructure.h
                                    common/TransformationPlugin.h
                                    common/Transformation.h)

set(RSPLUGIN_SOURCE_C               common/Infrastructure.c
                                    common/TransformationPlugin.c
                                    common/Transformation.c
                                    common/UserPlugin.c
                                    noop/NoopTransformation.c)

set(RSPLUGIN_LIBRARY                rtirssimpletransf)

set(RSPLUGIN_TESTER_PREFIX          rtitsfmsimple_)

###############################################################################
###############################################################################

check_plugin_args()
default_plugin_options()
configure_plugin_deps()
configure_plugin()