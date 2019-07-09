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
project(rtiroutingservice-processor-fwd C CXX)
cmake_minimum_required(VERSION 3.7.0)

include(${RSHELPER_DIR}/cmake/rtiroutingservice_plugin.cmake)

###############################################################################
###############################################################################

set(RSPLUGIN_CXX                    true)
set(RSPLUGIN_NAME                   rtiroutingservice-processor-fwd)
set(RSPLUGIN_PREFIX                 RTI_PRCS_FWD)
set(RSPLUGIN_INCLUDE_PREFIX         rtiprocess_fwd)
set(RSPLUGIN_INCLUDE_PREFIX_DIR     rti)
set(RSPLUGIN_IDL                    )
set(RSPLUGIN_INCLUDE_CXX_PUBLIC     platform
                                    properties
                                    log)

set(RSPLUGIN_INCLUDE_CXX            json.h)

set(RSPLUGIN_SOURCE_CXX             ForwardingEngine.cxx
                                    ByInputNameForwardingEngine.cxx
                                    ByInputValueForwardingEngine.cxx
                                    Properties.cxx
                                    json.c)
                                    
set(RSPLUGIN_LIBRARY                rtirsfwdprocessor)

set(RSPLUGIN_TESTER_PREFIX          rtiprcsfwd_)

###############################################################################
###############################################################################

check_plugin_args()
default_plugin_options()
configure_plugin_deps()
configure_plugin()

