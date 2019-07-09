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
project(rtiroutingservice-transform-field C)
cmake_minimum_required(VERSION 3.7.0)

include(${RSHELPER_DIR}/cmake/rtiroutingservice_plugin.cmake)

###############################################################################
# configure_rtitransform()
###############################################################################
# Helper macro to configure build of rtitransform
###############################################################################
macro(configure_rtitransform)
    log_status("configuring rtitransform...")

    if(NOT TARGET rtirssimpletransf)
        check_not_empty(RTI_TSFM_DIR
            "Please set RTI_TSFM_DIR to a clone of rtiroutingservice-transform-simple")
        add_subdirectory(${RTI_TSFM_DIR} modules/transform)
    endif()

    append_to_list(RSPLUGIN_INCLUDE_DIRS        ${RTI_TSFM_INCLUDES})
    append_to_list(RSPLUGIN_LIBS                rtirssimpletransf-shared)
    append_to_list(RSPLUGIN_DEPS                rtirssimpletransf-shared)
    append_to_list(RSPLUGIN_IDL_INCLUDE_DIRS    ${RTI_TSFM_IDL_DIR})
endmacro()

###############################################################################
###############################################################################

set(RSPLUGIN_NAME                   rtiroutingservice-transform-field)
set(RSPLUGIN_PREFIX                 RTI_TSFM_FIELD)
set(RSPLUGIN_INCLUDE_PREFIX         rtitransform_field)
set(RSPLUGIN_INCLUDE_PREFIX_DIR     rti)
set(RSPLUGIN_IDL                    )
set(RSPLUGIN_INCLUDE_C_PUBLIC       primitive)

set(RSPLUGIN_INCLUDE_C              common/Infrastructure.h)

set(RSPLUGIN_SOURCE_C               common/Infrastructure.c
                                    primitive/PrimitiveFieldTransformation.c)
                                    
set(RSPLUGIN_LIBRARY                rtirsfieldtransf)

set(RSPLUGIN_TESTER_PREFIX          rtitsfmfield_)

###############################################################################
###############################################################################

check_plugin_args()
default_plugin_options()
configure_plugin_as_dep(rtiroutingservice-transform-simple
                        RTI_TSFM
                        modules/transform)
configure_plugin_deps()
configure_plugin()

