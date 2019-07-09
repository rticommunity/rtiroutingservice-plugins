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

include(${CMAKE_CURRENT_LIST_DIR}/rtiroutingservice_plugin_helpers.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/rtiroutingservice_plugin_bootstrap.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/rtiroutingservice_plugin_idl.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/rtiroutingservice_plugin_example.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/rtiroutingservice_plugin_docs.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/rtiroutingservice_plugin_test.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/rtiroutingservice_plugin_library.cmake)



###############################################################################
# configure_plugin()
###############################################################################
# 
###############################################################################
macro(configure_plugin)

    log_var(RSPLUGIN_NAME)
    log_var(RSPLUGIN_PREFIX)
    log_var(RSPLUGIN_IDL)
    log_var(RSPLUGIN_IDL_INCLUDE_DIRS)
    log_var(RSPLUGIN_INCLUDE_PREFIX)
    log_var(RSPLUGIN_INCLUDE_C_PUBLIC)
    log_var(RSPLUGIN_INCLUDE_C)
    log_var(RSPLUGIN_SOURCE_C)
    log_var(RSPLUGIN_LIBRARY)
    log_var(RSPLUGIN_TESTER_PREFIX)

    configure_plugin_env()
    configure_plugin_files()
    configure_plugin_defines()
    configure_plugin_library()
    configure_plugin_tests()
    configure_plugin_examples()
    configure_plugin_docs()
endmacro()
