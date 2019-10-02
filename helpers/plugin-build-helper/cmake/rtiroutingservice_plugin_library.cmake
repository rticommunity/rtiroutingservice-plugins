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
# configure_plugin_exec()
###############################################################################
# 
###############################################################################
function(configure_plugin_exec exec_name exec_prefix)

    log_var(exec_name)
    log_var(exec_prefix)
    log_var(${exec_prefix}_SRC_DIR)
    log_var(${exec_prefix}_INCLUDE_C)
    log_var(${exec_prefix}_SOURCE_C)
    log_var(${exec_prefix}_INCLUDE_CXX)
    log_var(${exec_prefix}_SOURCE_CXX)
    log_var(${exec_prefix}_INCLUDES)
    log_var(${exec_prefix}_DEFINES)
    log_var(${exec_prefix}_LIBS)
    log_var(${exec_prefix}_DEPS)
    log_var(${exec_prefix}_INSTALL_PROGRAMS)
    log_var(${exec_prefix}_INSTALL_FILES)
    log_var(${exec_prefix}_INSTALL_DIRS)
    log_var(${exec_prefix}_INSTALL_DIR)
    log_var(${exec_prefix}_INSTALL_BIN)
    log_var(${exec_prefix}_INSTALL_BIN_DIR)

    check_not_empty(${exec_prefix}_SRC_DIR)
    set(exec_src_dir    ${${exec_prefix}_SRC_DIR})

    set_if_undefined(${exec_prefix}_INSTALL_BIN     true)
    set_if_undefined(${exec_prefix}_INSTALL_BIN_DIR ${${RSPLUGIN_PREFIX}_DIST_BIN_DIR})
    set_if_undefined(${exec_prefix}_INSTALL_DIR     ${${RSPLUGIN_PREFIX}_DIST_DIR})

    set(exec_q_prefix   ${RSPLUGIN_PREFIX}_${exec_prefix})

    ###########################################################################

    if(${RSPLUGIN_PREFIX}_CXX)
        foreach(exec_inc_file IN LISTS ${exec_prefix}_INCLUDE_CXX)
            append_include_file(${exec_q_prefix}_INCLUDE_CXX
                ${exec_src_dir}/${exec_inc_file}
                ${exec_q_prefix}_INCLUDES)
        endforeach()

        check_not_empty(${exec_prefix}_SOURCE_CXX)
        foreach(exec_src_file IN LISTS ${exec_prefix}_SOURCE_CXX)
            append_to_list(${exec_q_prefix}_SOURCE_CXX
                ${exec_src_dir}/${exec_src_file})
        endforeach()
        
        set(${exec_q_prefix}_SOURCE_C   ${${exec_q_prefix}_SOURCE_CXX}
            CACHE INTERNAL "List of C++ source files for executable ${exec_prefix} from ${RSPLUGIN_NAME}")

        set(${exec_q_prefix}_INCLUDE_CXX  ${${exec_q_prefix}_INCLUDE_CXX}
            CACHE INTERNAL "List of C++ header files for executable ${exec_prefix} from ${RSPLUGIN_NAME}")
    else()
        foreach(exec_inc_file IN LISTS ${exec_prefix}_INCLUDE_C)
            append_include_file(${exec_q_prefix}_INCLUDE_C
                ${exec_src_dir}/${exec_inc_file}
                ${exec_q_prefix}_INCLUDES)
        endforeach()

        check_not_empty(${exec_prefix}_SOURCE_C)
        foreach(exec_src_file IN LISTS ${exec_prefix}_SOURCE_C)
            append_to_list(${exec_q_prefix}_SOURCE_C
                ${exec_src_dir}/${exec_src_file})
        endforeach()
        
        set(${exec_q_prefix}_SOURCE_C   ${${exec_q_prefix}_SOURCE_C}
            CACHE INTERNAL "List of C source files for executable ${exec_prefix} from ${RSPLUGIN_NAME}")

        set(${exec_q_prefix}_INCLUDE_C  ${${exec_q_prefix}_INCLUDE_C}
            CACHE INTERNAL "List of C header files for executable ${exec_prefix} from ${RSPLUGIN_NAME}")
    endif()

    ###########################################################################

    if(NOT "${${exec_prefix}_INCLUDES}" STREQUAL "")
        append_to_list(${exec_q_prefix}_INCLUDES ${${exec_prefix}_INCLUDES})
    endif()
    set(${exec_q_prefix}_INCLUDES   ${${exec_q_prefix}_INCLUDES}
                                    ${${RSPLUGIN_PREFIX}_INCLUDES}
        CACHE INTERNAL "List of include directories for executable ${exec_prefix} from ${RSPLUGIN_NAME}")
    
    ###########################################################################

    if(NOT "${${exec_prefix}_DEFINES}" STREQUAL "")
        append_to_list(${exec_q_prefix}_DEFINES ${${exec_prefix}_DEFINES})
    endif()
    set(${exec_q_prefix}_DEFINES    ${${exec_q_prefix}_DEFINES}
                                    ${${RSPLUGIN_PREFIX}_DEFINES}
        CACHE INTERNAL "List of compiler defines for executable ${exec_prefix} from ${RSPLUGIN_NAME}")

    ###########################################################################

    if(NOT "${${exec_prefix}_LIBS}" STREQUAL "")
        append_to_list(${exec_q_prefix}_LIBS ${${exec_prefix}_LIBS})
    endif()
    if (${exec_prefix}_STATIC)
        if(TARGET ${${RSPLUGIN_PREFIX}_LIBRARY}-static)
            append_to_list(${exec_q_prefix}_LIBS    ${${RSPLUGIN_PREFIX}_LIBRARY}-static)
        endif()
    else()
        if(TARGET ${${RSPLUGIN_PREFIX}_LIBRARY}-shared)
            append_to_list(${exec_q_prefix}_LIBS    ${${RSPLUGIN_PREFIX}_LIBRARY}-shared)
        endif()
    endif()
    set(${exec_q_prefix}_LIBS   ${${exec_q_prefix}_LIBS}
                                ${${RSPLUGIN_PREFIX}_LIBS}
        CACHE INTERNAL "List of linked libraries for executable ${exec_prefix} from ${RSPLUGIN_NAME}")
    
    ###########################################################################

    if(NOT "${${exec_prefix}_DEPS}" STREQUAL "")
        append_to_list(${exec_q_prefix}_DEPS ${${exec_prefix}_DEPS})
    endif()
    set(${exec_q_prefix}_DEPS   ${${exec_q_prefix}_DEPS}
                                ${${RSPLUGIN_PREFIX}_DEPS}
        CACHE INTERNAL "List of target dependencies for executable ${exec_prefix} from ${RSPLUGIN_NAME}")
    
    ###########################################################################

    set(${exec_q_prefix}_SOURCES    ${${exec_q_prefix}_SOURCE_C}
                                    ${${exec_q_prefix}_INCLUDE_C}
                                    ${${exec_q_prefix}_SOURCE_CXX}
                                    ${${exec_q_prefix}_INCLUDE_CXX}
        CACHE INTERNAL "List of all build files for executable ${exec_prefix} from ${RSPLUGIN_NAME}")

    set(${exec_q_prefix}_INSTALL_BIN  ${${exec_prefix}_INSTALL_BIN}
        CACHE INTERNAL "Whether to install binary files for executable ${exec_prefix} from ${RSPLUGIN_NAME}")
    
    set(${exec_q_prefix}_INSTALL_BIN_DIR  ${${exec_prefix}_INSTALL_BIN_DIR}
        CACHE INTERNAL "Directory where to install binary files for executable ${exec_prefix} from ${RSPLUGIN_NAME}")
    
    set(${exec_q_prefix}_INSTALL_DIR  ${${exec_prefix}_INSTALL_DIR}
        CACHE INTERNAL "Directory where to install files for executable ${exec_prefix} from ${RSPLUGIN_NAME}")
    
    set(${exec_q_prefix}_INSTALL_PROGRAMS ${${exec_prefix}_INSTALL_PROGRAMS}
        CACHE INTERNAL "List of runnable files to be installed for executable ${exec_prefix} from ${RSPLUGIN_NAME}")

    set(${exec_q_prefix}_INSTALL_FILES ${${exec_prefix}_INSTALL_FILES}
        CACHE INTERNAL "List of files to be installed for executable ${exec_prefix} from ${RSPLUGIN_NAME}")
    
    set(${exec_q_prefix}_INSTALL_DIRS ${${exec_prefix}_INSTALL_DIRS}
        CACHE INTERNAL "List of directories to be installed for executable ${exec_prefix} from ${RSPLUGIN_NAME}")

    set(${exec_q_prefix}_EXEC  ${exec_name}
        CACHE INTERNAL "Name of executable ${exec_prefix} from ${RSPLUGIN_NAME}")

    ##########################################################################

    add_executable(${${exec_q_prefix}_EXEC}
                    ${${exec_q_prefix}_SOURCES})
    
    if (CONNEXTDDS_ARCH MATCHES "^i86")
        set_target_properties(${${exec_q_prefix}_EXEC}
                PROPERTIES COMPILE_FLAGS "-m32" LINK_FLAGS "-m32")
    endif()

    if(${exec_prefix}_STATIC)
        target_link_libraries(${${exec_q_prefix}_EXEC} -static)
    endif()

    target_link_libraries(${${exec_q_prefix}_EXEC} ${${exec_q_prefix}_LIBS})

    target_include_directories(${${exec_q_prefix}_EXEC}
            PUBLIC      ${${exec_q_prefix}_INCLUDES})
    
    target_compile_definitions(${${exec_q_prefix}_EXEC}
            PUBLIC      ${${exec_q_prefix}_DEFINES})
    
    if (NOT "${${exec_q_prefix}_DEPS}" STREQUAL "")
        add_dependencies(${${exec_q_prefix}_EXEC}   ${${exec_q_prefix}_DEPS})
    endif()

    ##########################################################################

    if (${exec_prefix}_INSTALL_BIN)
        install(TARGETS ${${exec_q_prefix}_EXEC} RUNTIME DESTINATION
                ${${exec_q_prefix}_INSTALL_BIN_DIR})
    endif()

    if (NOT "${${exec_q_prefix}_INSTALL_PROGRAMS}" STREQUAL "")
        install(PROGRAMS ${${exec_q_prefix}_INSTALL_PROGRAMS} DESTINATION
                ${${exec_q_prefix}_INSTALL_DIR})
    endif()

    if (NOT "${${exec_q_prefix}_INSTALL_FILES}" STREQUAL "")
        install(FILES ${${exec_q_prefix}_INSTALL_FILES} DESTINATION
                ${${exec_q_prefix}_INSTALL_DIR})
    endif()

    if (NOT "${${exec_q_prefix}_INSTALL_DIRS}" STREQUAL "")
        install(DIRECTORY ${${exec_q_prefix}_INSTALL_DIRS} DESTINATION
                ${${exec_q_prefix}_INSTALL_DIR})
    endif()

endfunction()

###############################################################################
# configure_plugin_files()
###############################################################################
# 
###############################################################################
macro(configure_plugin_files)

    if(${RSPLUGIN_PREFIX}_IDL_GENERATE)
        configure_idl_files()
    endif()

    ##########################################################################

    append_include_file(
        ${RSPLUGIN_PREFIX}_INCLUDE_PUBLIC
        ${${RSPLUGIN_PREFIX}_INC_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX}.${${RSPLUGIN_PREFIX}_EXT_INC}
        ${RSPLUGIN_PREFIX}_INCLUDES)
    
    ##########################################################################

    foreach(plugin_header ${${RSPLUGIN_PREFIX}_INCLUDE_C_PUBLIC_NAMES})
        append_include_file(
            ${RSPLUGIN_PREFIX}_INCLUDE_C_PUBLIC
            ${${RSPLUGIN_PREFIX}_INC_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX}_${plugin_header}.h
            ${RSPLUGIN_PREFIX}_INCLUDES)
    endforeach()

    append_to_list(${RSPLUGIN_PREFIX}_INCLUDE_PUBLIC    ${${RSPLUGIN_PREFIX}_INCLUDE_C_PUBLIC})

    foreach(plugin_src_file ${${RSPLUGIN_PREFIX}_SOURCE_C_NAMES})
        append_to_list(${RSPLUGIN_PREFIX}_SOURCE_C
            ${${RSPLUGIN_PREFIX}_SRC_DIR}/${plugin_src_file})
    endforeach()

    foreach(plugin_inc_file ${${RSPLUGIN_PREFIX}_INCLUDE_C_NAMES})
        append_include_file(${RSPLUGIN_PREFIX}_INCLUDE_C
            ${${RSPLUGIN_PREFIX}_SRC_DIR}/${plugin_inc_file}
            ${RSPLUGIN_PREFIX}_INCLUDES)
    endforeach()

    ##########################################################################

    foreach(plugin_header ${${RSPLUGIN_PREFIX}_INCLUDE_CXX_PUBLIC_NAMES})
        append_include_file(
            ${RSPLUGIN_PREFIX}_INCLUDE_CXX_PUBLIC
            ${${RSPLUGIN_PREFIX}_INC_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX}_${plugin_header}.hpp
            ${RSPLUGIN_PREFIX}_INCLUDES)
    endforeach()

    append_to_list(${RSPLUGIN_PREFIX}_INCLUDE_PUBLIC    ${${RSPLUGIN_PREFIX}_INCLUDE_CXX_PUBLIC})

    foreach(plugin_src_file ${${RSPLUGIN_PREFIX}_SOURCE_CXX_NAMES})
        append_to_list(${RSPLUGIN_PREFIX}_SOURCE_CXX
            ${${RSPLUGIN_PREFIX}_SRC_DIR}/${plugin_src_file})
    endforeach()

    foreach(plugin_inc_file ${${RSPLUGIN_PREFIX}_INCLUDE_CXX_NAMES})
        append_include_file(${RSPLUGIN_PREFIX}_INCLUDE_CXX
            ${${RSPLUGIN_PREFIX}_SRC_DIR}/${plugin_inc_file}
            ${RSPLUGIN_PREFIX}_INCLUDES)
    endforeach()

    ##########################################################################

    append_to_list(${RSPLUGIN_PREFIX}_INCLUDES
            ${${RSPLUGIN_PREFIX}_INC_DIR}
            ${${RSPLUGIN_PREFIX}_INC_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX}
            ${${RSPLUGIN_PREFIX}_BUILD_IDL_DIR})
    
    set(${RSPLUGIN_PREFIX}_IDL_FILES   ${${RSPLUGIN_PREFIX}_IDL_FILES}
            CACHE INTERNAL "List of IDL files for ${RSPLUGIN_NAME}")

    set(${RSPLUGIN_PREFIX}_XML_FILES   ${${RSPLUGIN_PREFIX}_XML_FILES}
            CACHE INTERNAL "List of XML files for ${RSPLUGIN_NAME}")
    
    set(${RSPLUGIN_PREFIX}_SOURCES      ${${RSPLUGIN_PREFIX}_SOURCE_C}
                                        ${${RSPLUGIN_PREFIX}_SOURCE_C_IDL}
                                        ${${RSPLUGIN_PREFIX}_SOURCE_CXX}
                                        ${${RSPLUGIN_PREFIX}_SOURCE_CXX_IDL}
        CACHE INTERNAL "list of source files for ${RSPLUGIN_NAME}")

    set(${RSPLUGIN_PREFIX}_HEADERS  ${${RSPLUGIN_PREFIX}_INCLUDE_C_PUBLIC}
                                    ${${RSPLUGIN_PREFIX}_INCLUDE_C}
                                    ${${RSPLUGIN_PREFIX}_INCLUDE_C_IDL}
                                    ${${RSPLUGIN_PREFIX}_INCLUDE_CXX_PUBLIC}
                                    ${${RSPLUGIN_PREFIX}_INCLUDE_CXX}
                                    ${${RSPLUGIN_PREFIX}_INCLUDE_CXX_IDL}
        CACHE INTERNAL "list of header files for ${RSPLUGIN_NAME}")
    
    set(${RSPLUGIN_PREFIX}_FILES    ${${RSPLUGIN_PREFIX}_SOURCES}
                                    ${${RSPLUGIN_PREFIX}_HEADERS}
                                    ${${RSPLUGIN_PREFIX}_IDL_FILES}
                                    ${${RSPLUGIN_PREFIX}_XML_FILES}
        CACHE INTERNAL "list of build files for ${RSPLUGIN_NAME}")
    
    set(${RSPLUGIN_PREFIX}_INCLUDE_PUBLIC   ${${RSPLUGIN_PREFIX}_INCLUDE_PUBLIC}
        CACHE INTERNAL "list of public header files for ${RSPLUGIN_NAME} (except IDL)")

    if (NOT "${RSPLUGIN_LIBS}" STREQUAL "")
        append_to_list(${RSPLUGIN_PREFIX}_LIBS ${RSPLUGIN_LIBS})
    endif()
    set(${RSPLUGIN_PREFIX}_LIBS          ${${RSPLUGIN_PREFIX}_LIBS}
        CACHE INTERNAL "external libraries linked by ${RSPLUGIN_NAME}")
    
    if (NOT "${RSPLUGIN_DEPS}" STREQUAL "")
        append_to_list(${RSPLUGIN_PREFIX}_DEPS ${RSPLUGIN_DEPS})
    endif()
    set(${RSPLUGIN_PREFIX}_DEPS          ${${RSPLUGIN_PREFIX}_DEPS}
        CACHE INTERNAL "additional target dependencies for ${RSPLUGIN_NAME}")

    set(${RSPLUGIN_PREFIX}_INCLUDES         ${${RSPLUGIN_PREFIX}_INCLUDES}
                                            ${${RSPLUGIN_PREFIX}_INCLUDE_DIRS}
        CACHE INTERNAL "Directories added to include path for ${RSPLUGIN_NAME}")

    log_plugin_var(LIBS)
    log_plugin_var(INCLUDES)
    log_plugin_var(DEFINES)
    log_plugin_var(FILES)

endmacro()


###############################################################################
# configure_plugin_defines()
###############################################################################
# 
###############################################################################
macro(configure_plugin_defines)
    
    set_if_undefined(${RSPLUGIN_PREFIX}_DEFINES ${RSPLUGIN_DEFINES})

    if (${RSPLUGIN_PREFIX}_DISABLE_LOG)
        append_to_list(${RSPLUGIN_PREFIX}_DEFINES     ${RSPLUGIN_PREFIX}_DISABLE_LOG)
    else()
        if(${RSPLUGIN_PREFIX}_ENABLE_LOG)
            append_to_list(${RSPLUGIN_PREFIX}_DEFINES ${RSPLUGIN_PREFIX}_ENABLE_LOG)
        endif()
    endif()

    if(${RSPLUGIN_PREFIX}_ENABLE_TRACE)
        append_to_list(${RSPLUGIN_PREFIX}_DEFINES     ${RSPLUGIN_PREFIX}_ENABLE_TRACE)
    endif()

    if(${RSPLUGIN_PREFIX}_ENABLE_SSL)
        append_to_list(${RSPLUGIN_PREFIX}_DEFINES     ${RSPLUGIN_PREFIX}_ENABLE_SSL)
    endif()

    set(${RSPLUGIN_PREFIX}_DEFINES     "${${RSPLUGIN_PREFIX}_DEFINES}"
            CACHE INTERNAL "List compiler defines for ${RSPLUGIN_NAME}")

endmacro()

###############################################################################
# configure_plugin_library()
###############################################################################
# 
###############################################################################
macro(configure_plugin_library)
    # if(NOT ${RSPLUGIN_PREFIX}_IDL_GENERATE)
    #     log_error("at least one root IDL file must be defined to generated a library")
    # endif()

    # Build position independent code
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)

    if(${RSPLUGIN_PREFIX}_IDL_GENERATE)
        # Create an object library with IDL Code
        add_library(${${RSPLUGIN_PREFIX}_LIBRARY_IDL} OBJECT
            ${${RSPLUGIN_PREFIX}_SOURCE_C_IDL}
            ${${RSPLUGIN_PREFIX}_INCLUDE_C_IDL}
            ${${RSPLUGIN_PREFIX}_SOURCE_CXX_IDL}
            ${${RSPLUGIN_PREFIX}_INCLUDE_CXX_IDL})
        set_target_properties(${${RSPLUGIN_PREFIX}_LIBRARY_IDL} PROPERTIES 
            POSITION_INDEPENDENT_CODE ON)
        target_include_directories(${${RSPLUGIN_PREFIX}_LIBRARY_IDL}
                PUBLIC ${${RSPLUGIN_PREFIX}_INCLUDES})
        target_compile_definitions(${${RSPLUGIN_PREFIX}_LIBRARY_IDL}
                PUBLIC ${${RSPLUGIN_PREFIX}_DEFINES})
        add_dependencies(${${RSPLUGIN_PREFIX}_LIBRARY_IDL} ${RSPLUGIN_NAME}-idl)
    endif()

    # Create an object library which we'll use to
    # provide object files for both shared and static libraries
    add_library(${${RSPLUGIN_PREFIX}_LIBRARY} OBJECT 
        ${${RSPLUGIN_PREFIX}_SOURCE_C}
        ${${RSPLUGIN_PREFIX}_INCLUDE_C_PUBLIC}
        ${${RSPLUGIN_PREFIX}_INCLUDE_C}
        ${${RSPLUGIN_PREFIX}_SOURCE_CXX}
        ${${RSPLUGIN_PREFIX}_INCLUDE_CXX_PUBLIC}
        ${${RSPLUGIN_PREFIX}_INCLUDE_CXX})
    set_target_properties(${${RSPLUGIN_PREFIX}_LIBRARY} PROPERTIES 
        POSITION_INDEPENDENT_CODE ON)
    target_include_directories(${${RSPLUGIN_PREFIX}_LIBRARY}
            PUBLIC ${${RSPLUGIN_PREFIX}_INCLUDES})
    target_compile_definitions(${${RSPLUGIN_PREFIX}_LIBRARY}
            PUBLIC ${${RSPLUGIN_PREFIX}_DEFINES})
    if(TARGET ${${RSPLUGIN_PREFIX}_LIBRARY_IDL})
        add_dependencies(${${RSPLUGIN_PREFIX}_LIBRARY} ${${RSPLUGIN_PREFIX}_LIBRARY_IDL})
        if(NOT "${${RSPLUGIN_PREFIX}_DEPS}" STREQUAL "")
            add_dependencies(${${RSPLUGIN_PREFIX}_LIBRARY_IDL} ${${RSPLUGIN_PREFIX}_DEPS})
        endif()
    else()
        if(NOT "${${RSPLUGIN_PREFIX}_DEPS}" STREQUAL "")
            add_dependencies(${${RSPLUGIN_PREFIX}_LIBRARY} ${${RSPLUGIN_PREFIX}_DEPS})
        endif()
    endif()

    if(TARGET ${${RSPLUGIN_PREFIX}_LIBRARY_IDL})
        set(${RSPLUGIN_PREFIX}_LIBRARY_OBJECTS
            $<TARGET_OBJECTS:${${RSPLUGIN_PREFIX}_LIBRARY}>
            $<TARGET_OBJECTS:${${RSPLUGIN_PREFIX}_LIBRARY_IDL}>)
    else()
        set(${RSPLUGIN_PREFIX}_LIBRARY_OBJECTS
            $<TARGET_OBJECTS:${${RSPLUGIN_PREFIX}_LIBRARY}>)
    endif()

    add_library(${${RSPLUGIN_PREFIX}_LIBRARY}-shared SHARED 
                ${${RSPLUGIN_PREFIX}_LIBRARY_OBJECTS})
    target_link_libraries(${${RSPLUGIN_PREFIX}_LIBRARY}-shared PUBLIC ${${RSPLUGIN_PREFIX}_LIBS})
    install(TARGETS ${${RSPLUGIN_PREFIX}_LIBRARY}-shared LIBRARY
            DESTINATION "${${RSPLUGIN_PREFIX}_LIB_DIR}")

    add_library(${${RSPLUGIN_PREFIX}_LIBRARY}-static STATIC
                ${${RSPLUGIN_PREFIX}_LIBRARY_OBJECTS})
    target_link_libraries(${${RSPLUGIN_PREFIX}_LIBRARY}-static PUBLIC ${${RSPLUGIN_PREFIX}_LIBS})
    install(TARGETS ${${RSPLUGIN_PREFIX}_LIBRARY}-static ARCHIVE
            DESTINATION "${${RSPLUGIN_PREFIX}_LIB_DIR}")

    set_target_properties(${${RSPLUGIN_PREFIX}_LIBRARY}-shared ${${RSPLUGIN_PREFIX}_LIBRARY}-static
        PROPERTIES OUTPUT_NAME "${${RSPLUGIN_PREFIX}_LIBRARY}")

    if (CONNEXTDDS_ARCH MATCHES "^i86")
        set_target_properties(${${RSPLUGIN_PREFIX}_LIBRARY}
                PROPERTIES COMPILE_FLAGS "-m32" LINK_FLAGS "-m32")
        set_target_properties(${${RSPLUGIN_PREFIX}_LIBRARY}-shared
                PROPERTIES COMPILE_FLAGS "-m32" LINK_FLAGS "-m32")
        set_target_properties(${${RSPLUGIN_PREFIX}_LIBRARY}-static
                PROPERTIES COMPILE_FLAGS "-m32" LINK_FLAGS "-m32")
    endif()

    install(FILES ${${RSPLUGIN_PREFIX}_INCLUDE_PUBLIC} DESTINATION 
        "${${RSPLUGIN_PREFIX}_DIST_INC_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX_DIR}")

    if(${RSPLUGIN_PREFIX}_INSTALL_DEPS)
        # Install Connext DDS libraries
        install_connextdds()
        # Install Openssl libraries
        install_openssl()
    endif()

endmacro()


function(install_openssl)
    if(${RSPLUGIN_PREFIX}_ENABLE_SSL)
        file(GLOB ${RSPLUGIN_PREFIX}_OPENSSL_LIBS ${${RSPLUGIN_PREFIX}_OPENSSLHOME}/lib/*.so)
        if ("${${RSPLUGIN_PREFIX}_OPENSSL_LIBS}" STREQUAL "")
            log_warning("no .so found in directory ${${RSPLUGIN_PREFIX}_OPENSSLHOME}/lib")
        else()
            install(FILES ${${RSPLUGIN_PREFIX}_OPENSSL_LIBS}
                    DESTINATION "${${RSPLUGIN_PREFIX}_LIB_DIR}")
        endif()
    endif()
endfunction()


macro(install_connextdds_libs   libs_type)
    if(${RSPLUGIN_PREFIX}_CXX)
        if(CONNEXTDDS_CPP2_API_LIBRARIES_${libs_type}_FOUND)
            install(FILES ${CONNEXTDDS_CPP2_API_LIBRARIES_${libs_type}}
                    DESTINATION "${${RSPLUGIN_PREFIX}_LIB_DIR}")
        else()
            log_status("RTI Connext DDS C++ API libraries (${libs_type}) NOT FOUND")
        endif()
    endif()
    if(CONNEXTDDS_C_API_LIBRARIES_${libs_type}_FOUND)
        install(FILES ${CONNEXTDDS_C_API_LIBRARIES_${libs_type}}
                DESTINATION "${${RSPLUGIN_PREFIX}_LIB_DIR}")
    else()
        log_status("RTI Connext DDS C API libraries (${libs_type}) NOT FOUND")
    endif()
    if(ROUTING_SERVICE_INFRASTRUCTURE_LIBRARIES_${libs_type}_FOUND)
        install(FILES ${ROUTING_SERVICE_INFRASTRUCTURE_LIBRARIES_${libs_type}}
                DESTINATION "${${RSPLUGIN_PREFIX}_LIB_DIR}")
    else()
        log_status("RTI Connext DDS Routing Service Infrastructure libraries (${libs_type}) NOT FOUND")
    endif()
    if(ROUTING_SERVICE_API_LIBRARIES_${libs_type}_FOUND)
        install(FILES ${ROUTING_SERVICE_API_LIBRARIES_${libs_type}}
                DESTINATION "${${RSPLUGIN_PREFIX}_LIB_DIR}")
    else()
        log_status("RTI Connext DDS Routing Service Infrastructure libraries (${libs_type}) NOT FOUND")
    endif()
endmacro()

function(install_connextdds)
    # install_connextdds_libs(DEBUG_SHARED)
    # install_connextdds_libs(RELEASE_SHARED)
    file(GLOB ${RSPLUGIN_PREFIX}_CONNEXTDDS_LIBS ${${RSPLUGIN_PREFIX}_CONNEXTDDS_DIR}/lib/${CONNEXTDDS_ARCH}/*.so)
    install(FILES ${${RSPLUGIN_PREFIX}_CONNEXTDDS_LIBS}
                DESTINATION "${${RSPLUGIN_PREFIX}_LIB_DIR}")
endfunction()


macro(configure_plugin_as_dep   plugin_name plugin_prefix  build_dir)
    if ("${${plugin_prefix}_LIBRARY}" STREQUAL "")
        check_not_empty(${plugin_prefix}_DIR
            "Please point ${plugin_prefix}_DIR to a clone of ${plugin_name}")
        add_subdirectory(${${plugin_prefix}_DIR}    ${build_dir})
    endif()
    append_to_list(RSPLUGIN_INCLUDE_DIRS        ${${plugin_prefix}_INCLUDES})
    append_to_list(RSPLUGIN_DEFINES             ${${plugin_prefix}_DEFINES})
    append_to_list(RSPLUGIN_IDL_INCLUDE_DIRS    ${${plugin_prefix}_IDL_DIR})
    if(NOT "${${plugin_prefix}_LIBRARY}" STREQUAL "")
        append_to_list(RSPLUGIN_LIBS                ${${plugin_prefix}_LIBRARY}-shared)
        append_to_list(RSPLUGIN_DEPS                ${${plugin_prefix}_LIBRARY}-shared)
    endif()
endmacro()