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
# configure_plugin_examples()
###############################################################################
# 
###############################################################################
macro(configure_plugin_examples)
    if(${RSPLUGIN_PREFIX}_ENABLE_EXAMPLES)
        if (NOT EXISTS ${${RSPLUGIN_PREFIX}_EXAMPLES_DIR})
            log_warning("no EXAMPLES for ${RSPLUGIN_NAME}")
        else()
            set(${RSPLUGIN_PREFIX}_ROOT_PATH    ${CMAKE_CURRENT_BINARY_DIR})
            add_subdirectory(${${RSPLUGIN_PREFIX}_EXAMPLES_DIR})
        endif()
    endif()
endmacro()

