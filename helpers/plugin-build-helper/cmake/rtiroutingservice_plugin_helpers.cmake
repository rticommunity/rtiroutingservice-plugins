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
###############################################################################
####    CMAKE HELPERS    ######################################################
###############################################################################
###############################################################################

###############################################################################
# set_if_undefined(var defval)
###############################################################################
# Helper macro to set a variable to a default value if not already defined.
###############################################################################
macro(set_if_undefined var)
    if(NOT DEFINED ${var})
        set(${var} ${ARGN})
    endif()
endmacro()

###############################################################################
# set_if_empty(var defval)
###############################################################################
# Helper macro to set a variable to a default value if empty
###############################################################################
macro(set_if_empty var)
    if("${${var}}" STREQUAL "")
        set(${var} ${ARGN})
    endif()
endmacro()

###############################################################################
# append_to_list(list values...)
###############################################################################
# Helper function to add elements to a list if they are not already present
###############################################################################
macro(append_to_list v_list)
    if(NOT "${ARGN}" STREQUAL "")
        list(APPEND ${v_list} ${ARGN})
        list(REMOVE_DUPLICATES ${v_list})
    endif()
endmacro()

###############################################################################
# check_not_empty(var [err_msg])
###############################################################################
# Helper function to check that a variable is not empty, or exit with an error.
###############################################################################
function(check_not_empty var)
    set(err_msg             ${ARGN})
    if("${${var}}" STREQUAL "")
        if("${err_msg}" STREQUAL "")
            log_error("variable ${var} cannot be empty")
        else()
            log_error(${err_msg})
        endif()
    endif()
endfunction()

###############################################################################
# log_status(...)
###############################################################################
function(log_status)
    message(STATUS "${ARGN}")
endfunction()

###############################################################################
# log_warning(...)
###############################################################################
function(log_warning)
    message(STATUS "[WARNING] ${ARGN}")
endfunction()

###############################################################################
# log_error(...)
###############################################################################
function(log_error)
    message(FATAL_ERROR "[ERROR] ${ARGN}")
endfunction()

###############################################################################
# log_var(var)
###############################################################################
function(log_var var)
    log_status("${var} = ${${var}}")
endfunction()

###############################################################################
# log_plugin_var(var)
###############################################################################
function(log_plugin_var var)
    log_var(${RSPLUGIN_PREFIX}_${var})
endfunction()

###############################################################################
# append_include_file()
###############################################################################
# 
###############################################################################
macro(append_include_file file_list file_path inc_list)
    append_to_list(${file_list} ${file_path})
    get_filename_component(inc_file_dir "${file_path}" DIRECTORY)
    append_to_list(${inc_list} ${inc_file_dir})
endmacro()