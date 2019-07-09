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
project(rtiroutingservice-plugin-helper C)
cmake_minimum_required(VERSION 3.7.0)

set(RSHELPER_DIR                ${CMAKE_CURRENT_LIST_DIR})
include(${RSHELPER_DIR}/cmake/rtiroutingservice_plugin.cmake)

###############################################################################
###############################################################################

set(RSPLUGIN_NAME               rtiroutingservice-plugin-helper)
set(RSPLUGIN_PREFIX             RSHELPER)

check_plugin_args()
default_plugin_options()

set(CMOCKA_DIR      ${RSHELPER_DIR}/modules/cmocka
    CACHE INTERNAL "Local clone of CMocka")

# if(RSHELPER_ENABLE_TESTS)
#     configure_cmocka()
# endif()