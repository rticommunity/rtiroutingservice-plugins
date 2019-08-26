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
# configure_plugin_deps()
###############################################################################
# 
###############################################################################
macro(configure_plugin_deps)
    set_if_undefined(RSPLUGIN_CXX       false)
    set(${RSPLUGIN_PREFIX}_CXX          ${RSPLUGIN_CXX}
        CACHE INTERNAL "A flag indicating whether project ${RSPLUGIN_NAME} should be built by a C++ compiler")
    if (${RSPLUGIN_PREFIX}_CXX)
        set(CMAKE_CXX_STANDARD 11)
    endif()

    if(NOT ${RSPLUGIN_PREFIX}_NO_CONNEXTDDS)
        configure_connextdds()
    endif()

    if(${RSPLUGIN_PREFIX}_ENABLE_SSL)
        configure_openssl()
    endif()
endmacro()


###############################################################################
# find_connextdds()
###############################################################################
# 
###############################################################################
macro(find_connextdds       shared)
    if(RTIConnextDDS_FOUND)
        log_warning("avoiding searching RTI Connext DDS libraries again")
    else()
        set(build_shared_libs_prev      ${BUILD_SHARED_LIBS})
        set(BUILD_SHARED_LIBS ${shared})
        set(CONNEXTDDS_DIR          ${${RSPLUGIN_PREFIX}_CONNEXTDDS_DIR})
        set(CONNEXTDDS_ARCH         ${${RSPLUGIN_PREFIX}_CONNEXTDDS_ARCH})

        append_to_list(CMAKE_MODULE_PATH
            "${${RSPLUGIN_PREFIX}_CONNEXTDDS_DIR}/resource/cmake")
        
        set_if_undefined(${RSPLUGIN_PREFIX}_CONNEXT_COMPONENTS
                            core
                            routing_service)

        find_package(RTIConnextDDS      "${${RSPLUGIN_PREFIX}_CONNEXTDDS_VERSION}"
            REQUIRED
            COMPONENTS ${${RSPLUGIN_PREFIX}_CONNEXT_COMPONENTS}
        )

        unset(BUILD_SHARED_LIBS)
        set(BUILD_SHARED_LIBS           ${build_shared_libs_prev})
        if(NOT RTIConnextDDS_FOUND)
            log_error("no compatible version of RTI Connext DDS found")
        endif()
    endif()
endmacro()

###############################################################################
# configure_connextdds()
###############################################################################
# Helper macro to configure Connext DDS and Routing Service dependencies
###############################################################################
macro(configure_connextdds)
    log_status("configuring Connext DDS...")

    set_if_undefined(${RSPLUGIN_PREFIX}_CONNEXTDDS_VERSION         "6.0.0")
    check_not_empty(${RSPLUGIN_PREFIX}_CONNEXTDDS_VERSION)

    set_if_undefined(${RSPLUGIN_PREFIX}_CONNEXTDDS_DIR   ${CONNEXTDDS_DIR})
    set_if_empty(${RSPLUGIN_PREFIX}_CONNEXTDDS_DIR   $ENV{CONNEXTDDS_DIR})
    check_not_empty(${RSPLUGIN_PREFIX}_CONNEXTDDS_DIR
        "Please point CONNEXTDDS_DIR to an installation of RTI Connext DDS ${CONNEXTDDS_VERSION} with RTI Routing Service SDK")

    set_if_undefined(${RSPLUGIN_PREFIX}_CONNEXTDDS_ARCH  ${CONNEXTDDS_ARCH})
    set_if_empty(${RSPLUGIN_PREFIX}_CONNEXTDDS_ARCH  $ENV{CONNEXTDDS_ARCH})
    check_not_empty(${RSPLUGIN_PREFIX}_CONNEXTDDS_ARCH

    set(${RSPLUGIN_PREFIX}_CONNEXTDDS_VERSION  "${${RSPLUGIN_PREFIX}_CONNEXTDDS_VERSION}"
        CACHE STRING "Version number of Connext DDS libraries to use for ${RSPLUGIN_NAME}")
    set(${RSPLUGIN_PREFIX}_CONNEXTDDS_DIR      "${${RSPLUGIN_PREFIX}_CONNEXTDDS_DIR}"
        CACHE PATH "Installation of Connext DDS ${${RSPLUGIN_PREFIX}_CONNEXTDDS_VERSION} with RTI Routing Service SDK for ${RSPLUGIN_NAME}")
        "Please set CONNEXTDDS_ARCH to a valid RTI architecture identifier")
    set(${RSPLUGIN_PREFIX}_CONNEXTDDS_ARCH            "${${RSPLUGIN_PREFIX}_CONNEXTDDS_ARCH}"
        CACHE STRING "RTI architecture identifier for target build platform for ${RSPLUGIN_NAME}")
    
    log_plugin_var(CONNEXTDDS_VERSION)
    log_plugin_var(CONNEXTDDS_DIR)
    log_plugin_var(CONNEXTDDS_ARCH)
    
    # set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" 
    #         CACHE INTERNAL "CMake module path" FORCE)

    # We always link Connext libraries dynamically. Makes it easier to
    # incorporate the library into existing projects.
    find_connextdds(ON)

    set(RTIDDSGEN               "${CONNEXTDDS_DIR}/bin/rtiddsgen")

    set_if_undefined(${RSPLUGIN_PREFIX}_CONNEXT_CXX_LIBS
                        RTIConnextDDS::cpp2_api
                        RTIConnextDDS::routing_service_cpp2)
    
    set_if_undefined(${RSPLUGIN_PREFIX}_CONNEXT_C_LIBS
                        RTIConnextDDS::c_api
                        RTIConnextDDS::routing_service_c)

    if(${RSPLUGIN_PREFIX}_CXX)
        append_to_list(${RSPLUGIN_PREFIX}_LIBS
                        ${${RSPLUGIN_PREFIX}_CONNEXT_CXX_LIBS})
    else()
        append_to_list(${RSPLUGIN_PREFIX}_LIBS
                        ${${RSPLUGIN_PREFIX}_CONNEXT_C_LIBS})
    endif()
    
    append_to_list(${RSPLUGIN_PREFIX}_INCLUDES
                    ${CONNEXTDDS_INCLUDE_DIRS})

    append_to_list(${RSPLUGIN_PREFIX}_DEFINES
                    ${CONNEXTDDS_COMPILE_DEFINITIONS})

endmacro()



###############################################################################
# default_plugin_options()
###############################################################################
# Helper macro to define common option flags
###############################################################################
macro(define_plugin_option opt desc def_val)
    if(NOT DEFINED ${RSPLUGIN_PREFIX}_${opt})
        set_if_undefined(${opt} ${def_val})
        option(${RSPLUGIN_PREFIX}_${opt} "${desc}" ${${opt}})
    endif()
    log_status("build OPTION ${RSPLUGIN_PREFIX}_${opt} = ${${RSPLUGIN_PREFIX}_${opt}}")
endmacro()

macro(default_plugin_options)
    define_plugin_option(ENABLE_SSL    
            "Enable support for SSL/TLS for ${RSPLUGIN_NAME}" OFF)
    define_plugin_option(ENABLE_LOG
            "Enable logging to stdout for ${RSPLUGIN_NAME}" OFF)
    define_plugin_option(DISABLE_LOG
            "Disable logging to stdout for ${RSPLUGIN_NAME}" OFF)
    define_plugin_option(ENABLE_TRACE
            "Enable support for trace-level logging for ${RSPLUGIN_NAME}" OFF)
    define_plugin_option(ENABLE_TESTS
            "Build tester applications for ${RSPLUGIN_NAME}" OFF)
    define_plugin_option(ENABLE_EXAMPLES
            "Build example applications for ${RSPLUGIN_NAME}" OFF)
    define_plugin_option(ENABLE_DOCS
            "Build documentation for ${RSPLUGIN_NAME}" OFF)
    define_plugin_option(INSTALL_DEPS
            "Build documentation for ${RSPLUGIN_NAME}" ON)

endmacro()

###############################################################################
# check_plugin_args()
###############################################################################
# Helper macro to check user provided arguments
###############################################################################
macro(check_plugin_args)
    check_not_empty(RSHELPER_DIR)
    check_not_empty(RSPLUGIN_PREFIX)
    set_if_undefined(RSPLUGIN_NAME      "${CMAKE_PROJECT_NAME}")
    set_if_empty(CMAKE_BUILD_TYPE       Debug)
    check_not_empty(CMAKE_BUILD_TYPE
        "CMAKE_BUILD_TYPE must be set to either 'Release' or 'Debug'")
    log_var(CMAKE_BUILD_TYPE)

    if(NOT ${RSPLUGIN_PREFIX} STREQUAL RSHELPER)
        configure_plugin_as_dep(rtiroutingservice-plugin-helper
                                RSHELPER
                                modules/plugin-helper)
    endif()
endmacro()

###############################################################################
# configure_openssl()
###############################################################################
# Helper macro to configure OpenSSL variables
###############################################################################
macro(configure_openssl)
    set_if_undefined(${RSPLUGIN_PREFIX}_OPENSSLHOME     ${OPENSSLHOME})
    set_if_empty(${RSPLUGIN_PREFIX}_OPENSSLHOME         $ENV{OPENSSLHOME})
    check_not_empty(${RSPLUGIN_PREFIX}_OPENSSLHOME)
    
    log_plugin_var(OPENSSLHOME)

    set(${RSPLUGIN_PREFIX}_OPENSSLHOME   "${${RSPLUGIN_PREFIX}_OPENSSLHOME}"
            CACHE PATH "Installation of OpenSSL for ${RSPLUGIN_NAME}")
    
    if(NOT EXISTS "${${RSPLUGIN_PREFIX}_OPENSSLHOME}" OR
       NOT EXISTS "${${RSPLUGIN_PREFIX}_OPENSSLHOME}/include" OR
       NOT EXISTS "${${RSPLUGIN_PREFIX}_OPENSSLHOME}/lib")
        log_error("invalid installation of OpenSSL: '${${RSPLUGIN_PREFIX}_OPENSSLHOME}'")
    endif()

endmacro()


###############################################################################
# configure_plugin_env()
###############################################################################
# Helper macro to set plugin environment
###############################################################################
macro(configure_plugin_env)
   check_not_empty(RSPLUGIN_PREFIX)
   check_not_empty(RSPLUGIN_NAME)

   set(${RSPLUGIN_PREFIX}_DIR                   "${CMAKE_CURRENT_LIST_DIR}"
           CACHE INTERNAL "Base directory for ${RSPLUGIN_NAME}")

   set(${RSPLUGIN_PREFIX}_SRC_DIR               "${${RSPLUGIN_PREFIX}_DIR}/src"
           CACHE INTERNAL "Directory containing source files for ${RSPLUGIN_NAME}")
   set(${RSPLUGIN_PREFIX}_INC_DIR               "${${RSPLUGIN_PREFIX}_DIR}/include"
           CACHE INTERNAL "Directory containing header files for ${RSPLUGIN_NAME}")
   set(${RSPLUGIN_PREFIX}_IDL_DIR               "${${RSPLUGIN_PREFIX}_DIR}/idl"
           CACHE INTERNAL "Directory containing IDL files for ${RSPLUGIN_NAME}")
   set(${RSPLUGIN_PREFIX}_DOC_DIR               "${${RSPLUGIN_PREFIX}_DIR}/doc"
           CACHE INTERNAL "Base directory for all documentation for ${RSPLUGIN_NAME}")
   set(${RSPLUGIN_PREFIX}_MOD_DIR               "${${RSPLUGIN_PREFIX}_DIR}/modules"
           CACHE INTERNAL "Directory containing external dependencies for ${RSPLUGIN_NAME}")
   set(${RSPLUGIN_PREFIX}_TEST_DIR              "${${RSPLUGIN_PREFIX}_DIR}/test"
           CACHE INTERNAL "Directory containing test files for ${RSPLUGIN_NAME}")
   set(${RSPLUGIN_PREFIX}_EXAMPLES_DIR          "${${RSPLUGIN_PREFIX}_DIR}/example"
           CACHE INTERNAL "Directory containing examples for ${RSPLUGIN_NAME}")

#    set(${RSPLUGIN_PREFIX}_DIST_DIR              "${${RSPLUGIN_PREFIX}_DIR}/dist/${CONNEXTDDS_ARCH}"
    # set_if_undefined(RSPLUGIN_SHARED_INSTALL     "${${RSPLUGIN_PREFIX}_DIR}/install")

    set(${RSPLUGIN_PREFIX}_DIST_DIR              "${CMAKE_INSTALL_PREFIX}"
       CACHE PATH "Directory containing output files in distributable form for ${RSPLUGIN_NAME}")

    # set(CMAKE_INSTALL_PREFIX                    "${${RSPLUGIN_PREFIX}_DIST_DIR}"
    #     CACHE INTERNAL "CMake install path")

    set(${RSPLUGIN_PREFIX}_LIB_DIR               "lib"
            CACHE PATH "Directory containing binary files shipped by ${RSPLUGIN_NAME}")
    set(${RSPLUGIN_PREFIX}_DIST_INC_DIR           "include"
            CACHE PATH "Directory containing shipped header files for ${RSPLUGIN_NAME}")
    set(${RSPLUGIN_PREFIX}_DIST_BIN_DIR           "bin"
            CACHE PATH "Directory containing shipped executables files for ${RSPLUGIN_NAME}")
    set(${RSPLUGIN_PREFIX}_RESOURCE_INSTALL_DIR   "share/${RSPLUGIN_NAME}"
            CACHE PATH "Directory containing output resource generated by ${RSPLUGIN_NAME}")
    set(${RSPLUGIN_PREFIX}_IDL_INSTALL_DIR        "${${RSPLUGIN_PREFIX}_RESOURCE_INSTALL_DIR}/idl"
            CACHE PATH "Directory containing output resource generated by ${RSPLUGIN_NAME}")
    set(${RSPLUGIN_PREFIX}_TEST_DIST_DIR         "test"
        CACHE PATH "Installation directory containing test files for ${RSPLUGIN_NAME}")
    set(${RSPLUGIN_PREFIX}_EXAMPLES_DIST_DIR     "example"
        CACHE PATH "Installation directory containing examples for ${RSPLUGIN_NAME}")

    set(${RSPLUGIN_PREFIX}_BUILD_DIR             "${CMAKE_CURRENT_BINARY_DIR}"
            CACHE INTERNAL "Build directory for ${RSPLUGIN_NAME}")
    string(REPLACE  "${${RSPLUGIN_PREFIX}_DIR}" 
                   "${${RSPLUGIN_PREFIX}_BUILD_DIR}"
                   ${RSPLUGIN_PREFIX}_BUILD_IDL_DIR
                   "${${RSPLUGIN_PREFIX}_IDL_DIR}")
   set(${RSPLUGIN_PREFIX}_BUILD_IDL_DIR      "${${RSPLUGIN_PREFIX}_BUILD_IDL_DIR}"
           CACHE INTERNAL "Directory for code generated from IDL for ${RSPLUGIN_NAME}")

    set(${RSPLUGIN_PREFIX}_INCLUDE_PREFIX        "${RSPLUGIN_INCLUDE_PREFIX}"
            CACHE INTERNAL "Base name for public header files for ${RSPLUGIN_NAME}")
    
    set_if_undefined(RSPLUGIN_INCLUDE_PREFIX_DIR    "${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX}")
    set(${RSPLUGIN_PREFIX}_INCLUDE_PREFIX_DIR       "${RSPLUGIN_INCLUDE_PREFIX_DIR}"
            CACHE INTERNAL "Sub-directory for public header files for ${RSPLUGIN_NAME}")
    
    set(${RSPLUGIN_PREFIX}_IDL_NAMES       "${RSPLUGIN_IDL}"
            CACHE INTERNAL "List of IDs of IDL files for ${RSPLUGIN_NAME}")
    
    # append_to_list(RSPLUGIN_IDL_INCLUDE_DIRS ${${RSPLUGIN_PREFIX}_BUILD_DIR})
    set(${RSPLUGIN_PREFIX}_IDL_INCLUDE_DIRS   ${RSPLUGIN_IDL_INCLUDE_DIRS}
            CACHE INTERNAL "List of include directories for IDL generation for ${RSPLUGIN_NAME}")

    set(${RSPLUGIN_PREFIX}_ROOT_IDL   "${${RSPLUGIN_PREFIX}_IDL_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX}_types.idl"
            CACHE FILEPATH "Root IDL description of DDS types used by ${RSPLUGIN_NAME}")

    set(${RSPLUGIN_PREFIX}_ROOT_XML   "${${RSPLUGIN_PREFIX}_BUILD_IDL_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX}_types.xml"
            CACHE FILEPATH "Root XML description of DDS types used by ${RSPLUGIN_NAME}")

    if(EXISTS "${${RSPLUGIN_PREFIX}_ROOT_IDL}")
        set_if_undefined(${RSPLUGIN_PREFIX}_IDL_GENERATE        true)
    else()
        set_if_undefined(${RSPLUGIN_PREFIX}_IDL_GENERATE        false)
    endif()

    set(${RSPLUGIN_PREFIX}_IDL_GENERATE   ${${RSPLUGIN_PREFIX}_IDL_GENERATE}
            CACHE INTERNAL "Enable IDL code generation for ${RSPLUGIN_NAME}")

    set(${RSPLUGIN_PREFIX}_INCLUDE_C_PUBLIC_NAMES     "${RSPLUGIN_INCLUDE_C_PUBLIC}"
            CACHE INTERNAL "List of names of public C header files for ${RSPLUGIN_NAME}")

    set(${RSPLUGIN_PREFIX}_INCLUDE_C_NAMES     "${RSPLUGIN_INCLUDE_C}"
            CACHE INTERNAL "List of names of internal C header files for ${RSPLUGIN_NAME}")
    
    set(${RSPLUGIN_PREFIX}_SOURCE_C_NAMES     "${RSPLUGIN_SOURCE_C}"
            CACHE INTERNAL "List of names of C source files for ${RSPLUGIN_NAME}")

    set(${RSPLUGIN_PREFIX}_INCLUDE_CXX_PUBLIC_NAMES     "${RSPLUGIN_INCLUDE_CXX_PUBLIC}"
            CACHE INTERNAL "List of names of public C++ header files for ${RSPLUGIN_NAME}")

    set(${RSPLUGIN_PREFIX}_INCLUDE_CXX_NAMES     "${RSPLUGIN_INCLUDE_CXX}"
            CACHE INTERNAL "List of names of internal C++ header files for ${RSPLUGIN_NAME}")
    
    set(${RSPLUGIN_PREFIX}_SOURCE_CXX_NAMES     "${RSPLUGIN_SOURCE_CXX}"
            CACHE INTERNAL "List of names of C++ source files for ${RSPLUGIN_NAME}")
    
    set(${RSPLUGIN_PREFIX}_INCLUDE_DIRS     "${RSPLUGIN_INCLUDE_DIRS}"
            CACHE INTERNAL "List of additional include directories for ${RSPLUGIN_NAME}")

    set(${RSPLUGIN_PREFIX}_DEPS     "${RSPLUGIN_DEPS}"
            CACHE INTERNAL "List of target dependencies for ${RSPLUGIN_NAME}")
    
    set_if_undefined(RSPLUGIN_LIBRARY   ${RSPLUGIN_NAME})
    set(${RSPLUGIN_PREFIX}_LIBRARY          ${RSPLUGIN_LIBRARY}
        CACHE INTERNAL "Name of library file that will be built for ${RSPLUGIN_NAME}")

    set_if_undefined(RSPLUGIN_LIBRARY_IDL   ${${RSPLUGIN_PREFIX}_LIBRARY}_idl)
    set(${RSPLUGIN_PREFIX}_LIBRARY_IDL          ${RSPLUGIN_LIBRARY_IDL}
        CACHE INTERNAL "Name of library file that will be built with IDL Code for ${RSPLUGIN_NAME}")

    if(${RSPLUGIN_PREFIX}_CXX)
        set(${RSPLUGIN_PREFIX}_EXT_INC      "hpp")
        set(${RSPLUGIN_PREFIX}_EXT_SRC      "cxx")
    else()
        set(${RSPLUGIN_PREFIX}_EXT_INC      "h")
        set(${RSPLUGIN_PREFIX}_EXT_SRC      "c")
    endif()

    log_plugin_var(INCLUDE_PREFIX)
    log_plugin_var(IDL_NAMES)
    log_plugin_var(IDL_INCLUDE_DIRS)
    log_plugin_var(INCLUDE_C_PUBLIC_NAMES)
    log_plugin_var(INCLUDE_C_NAMES)
    log_plugin_var(SOURCE_C_NAMES)
    log_plugin_var(CXX)
    log_plugin_var(INCLUDE_CXX_PUBLIC_NAMES)
    log_plugin_var(INCLUDE_CXX_NAMES)
    log_plugin_var(SOURCE_CXX_NAMES)
    log_plugin_var(INCUDE_DIRS)
    log_plugin_var(LIBRARY)
endmacro()

