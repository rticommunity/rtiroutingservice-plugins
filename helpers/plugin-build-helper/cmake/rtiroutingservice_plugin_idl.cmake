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
# rtiddsgen_command()
###############################################################################
# 
###############################################################################
function(rtiddsgen_command idl outdir outfiles convert_to_xml idl_deps)

    if(${RSPLUGIN_PREFIX}_CXX)
        set(idl_lang            C++11)
        # set(idl_extra_args      -namespace)
    else()
        set(idl_lang            C)
    endif()

    get_filename_component(idl_name "${idl}" NAME_WE)
    list(LENGTH ${RSPLUGIN_PREFIX}_IDL_INCLUDE_DIRS idl_inc_dirs_len)
    set(idl_inc_dirs    ${${RSPLUGIN_PREFIX}_IDL_INCLUDE_DIRS})

    if(convert_to_xml)
        set(idl_convert_to_xml      "-convertToXml")
    endif()

    set(idl_file_deps  )
    foreach(idl_dep ${idl_deps})
        list_idl_type_sypport(${idl_dep} true true idl_dep_files)
        append_to_list(idl_file_deps ${idl_dep_files})
    endforeach()

    if(${idl_inc_dirs_len} EQUAL 0)

        add_custom_command(OUTPUT ${outfiles}
                       COMMAND ${CMAKE_COMMAND} -E make_directory "${outdir}"
                       COMMAND ${RTIDDSGEN} -unboundedSupport
                                            -qualifiedEnumerator
                                            -replace
                                            -language ${idl_lang}
                                            ${idl_convert_to_xml}
                                            -d ${outdir}
                                            ${idl_extra_args}
                                            ${idl}
                       DEPENDS ${idl}
                       VERBATIM)

    elseif(${idl_inc_dirs_len} EQUAL 1)

        list(GET idl_inc_dirs 0 idl_inc_dir_0)

        add_custom_command(OUTPUT ${outfiles}
                       COMMAND ${CMAKE_COMMAND} -E make_directory "${outdir}"
                       COMMAND ${RTIDDSGEN} -unboundedSupport
                                            -qualifiedEnumerator
                                            -replace
                                            -language ${idl_lang}
                                            ${idl_convert_to_xml}
                                            -d ${outdir}
                                            ${idl_extra_args}
                                            -I ${idl_inc_dir_0}
                                            ${idl}
                       DEPENDS ${idl}
                               ${idl_inc_dir_0}
                       VERBATIM)

    elseif(${idl_inc_dirs_len} EQUAL 2)

        list(GET idl_inc_dirs 0 idl_inc_dir_0)
        list(GET idl_inc_dirs 1 idl_inc_dir_1)

        add_custom_command(OUTPUT ${outfiles}
                       COMMAND ${CMAKE_COMMAND} -E make_directory "${outdir}"
                       COMMAND ${RTIDDSGEN} -unboundedSupport
                                            -qualifiedEnumerator
                                            -replace
                                            -language ${idl_lang}
                                            ${idl_convert_to_xml}
                                            -d ${outdir}
                                            ${idl_extra_args}
                                            -I ${idl_inc_dir_0}
                                            -I ${idl_inc_dir_1}
                                            ${idl}
                       DEPENDS ${idl}
                               ${idl_inc_dir_0} ${idl_inc_dir_1}
                       VERBATIM)

    elseif(${idl_inc_dirs_len} EQUAL 3)

        list(GET idl_inc_dirs 0 idl_inc_dir_0)
        list(GET idl_inc_dirs 1 idl_inc_dir_1)
        list(GET idl_inc_dirs 2 idl_inc_dir_2)

        add_custom_command(OUTPUT ${outfiles}
                       COMMAND ${CMAKE_COMMAND} -E make_directory "${outdir}"
                       COMMAND ${RTIDDSGEN} -unboundedSupport
                                            -qualifiedEnumerator
                                            -replace
                                            -language ${idl_lang}
                                            ${idl_convert_to_xml}
                                            -d ${outdir}
                                            ${idl_extra_args}
                                            -I ${idl_inc_dir_0}
                                            -I ${idl_inc_dir_1}
                                            -I ${idl_inc_dir_2}
                                            ${idl}
                       DEPENDS ${idl}
                               ${idl_inc_dir_0} ${idl_inc_dir_1} ${idl_inc_dir_2}
                       VERBATIM)

    elseif(${idl_inc_dirs_len} EQUAL 4)

        list(GET idl_inc_dirs 0 idl_inc_dir_0)
        list(GET idl_inc_dirs 1 idl_inc_dir_1)
        list(GET idl_inc_dirs 2 idl_inc_dir_2)
        list(GET idl_inc_dirs 3 idl_inc_dir_3)

        add_custom_command(OUTPUT ${outfiles}
                       COMMAND ${CMAKE_COMMAND} -E make_directory "${outdir}"
                       COMMAND ${RTIDDSGEN} -unboundedSupport
                                            -qualifiedEnumerator
                                            -replace
                                            -language ${idl_lang}
                                            ${idl_convert_to_xml}
                                            -d ${outdir}
                                            ${idl_extra_args}
                                            -I ${idl_inc_dir_0}
                                            -I ${idl_inc_dir_1}
                                            -I ${idl_inc_dir_2}
                                            -I ${idl_inc_dir_3}
                                            ${idl}
                       DEPENDS ${idl}
                               ${idl_inc_dir_0} ${idl_inc_dir_1} ${idl_inc_dir_2}
                               ${idl_inc_dir_3}
                       VERBATIM)

    elseif(${idl_inc_dirs_len} GREATER_EQUAL 5)

        if(${idl_inc_dirs_len} GREATER 5)
            log_warning("too many IDL include dirs. Only first 5 will be used: ${idl_inc_dirs}")
        endif()

        list(GET idl_inc_dirs 0 idl_inc_dir_0)
        list(GET idl_inc_dirs 1 idl_inc_dir_1)
        list(GET idl_inc_dirs 2 idl_inc_dir_2)
        list(GET idl_inc_dirs 3 idl_inc_dir_3)
        list(GET idl_inc_dirs 4 idl_inc_dir_4)

        add_custom_command(OUTPUT ${outfiles}
                       COMMAND ${CMAKE_COMMAND} -E make_directory "${outdir}"
                       COMMAND ${RTIDDSGEN} -unboundedSupport
                                            -qualifiedEnumerator
                                            -replace
                                            -language ${idl_lang}
                                            ${idl_convert_to_xml}
                                            -d ${outdir}
                                            ${idl_extra_args}
                                            -I ${idl_inc_dir_0}
                                            -I ${idl_inc_dir_1}
                                            -I ${idl_inc_dir_2}
                                            -I ${idl_inc_dir_3}
                                            -I ${idl_inc_dir_4}
                                            ${idl}
                       DEPENDS ${idl}
                               ${idl_inc_dir_0} ${idl_inc_dir_1} ${idl_inc_dir_2}
                               ${idl_inc_dir_3} ${idl_inc_dir_4}
                       VERBATIM)

    endif()


    log_status("RTIDDSGEN COMMAND:")
    log_status("  - IDL: ${idl}")
    log_status("  - OUTDIR: ${outdir}")
    log_status("  - OUTFILES: ${outfiles}")
    log_status("  - XML: ${convert_to_xml}")
    log_status("  - INCLUDE_DIRS: ${idl_inc_dirs}")

    if(convert_to_xml)
        set(idl_tgt ${idl_name}-xml)
    else()
        set(idl_tgt ${idl_name})
    endif()
    if(NOT TARGET idl)
        add_custom_target(idl ALL)
    endif()
    if(NOT TARGET ${RSPLUGIN_NAME}-idl)
        add_custom_target(${RSPLUGIN_NAME}-idl)
        add_dependencies(idl ${RSPLUGIN_NAME}-idl)
    endif()
    add_custom_target(${RSPLUGIN_NAME}-idl-${idl_tgt} 
                        DEPENDS ${outfiles})
    add_dependencies(${RSPLUGIN_NAME}-idl
                        ${RSPLUGIN_NAME}-idl-${idl_tgt})
endfunction()



###############################################################################
# idl_to_xml(idl outdir)
###############################################################################
# Helper function to generate an XML representation of the DDS types
###############################################################################
function(idl_to_xml idl outdir installdir outfile)

    # log_status("generate XML from IDL: ${idl} -> ${outfile}")

    rtiddsgen_command(${idl} ${outdir} "${outfile}" TRUE "")

    get_filename_component(outfile_name "${outfile}" NAME)
    string(REPLACE "/" "_" outfile_tgt "${outfile_name}")
    install(FILES       "${outfile}" DESTINATION "${installdir}")
endfunction()

###############################################################################
# generate_type_support(idl outdir)
###############################################################################
# Helper function to generate type support code for DDS types
###############################################################################
function(generate_type_support  idl outdir idl_deps)

    get_filename_component(idl_name "${idl}" NAME_WE)
    set(idl_files_head  "${outdir}/${idl_name}.${${RSPLUGIN_PREFIX}_EXT_INC}"
                        "${outdir}/${idl_name}Plugin.${${RSPLUGIN_PREFIX}_EXT_INC}")
    set(idl_files_src   "${outdir}/${idl_name}.${${RSPLUGIN_PREFIX}_EXT_SRC}"
                        "${outdir}/${idl_name}Plugin.${${RSPLUGIN_PREFIX}_EXT_SRC}")

    if (NOT ${RSPLUGIN_PREFIX}_CXX)
        append_to_list(idl_files_head
                "${outdir}/${idl_name}Support.${${RSPLUGIN_PREFIX}_EXT_INC}")
        append_to_list(idl_files_src
                "${outdir}/${idl_name}Support.${${RSPLUGIN_PREFIX}_EXT_SRC}")
    endif()

    set(idl_files       ${idl_files_head} ${idl_files_src})

    # log_status("generate TypeSupport from IDL: ${idl} -> ${idl_files}")

    rtiddsgen_command(${idl} ${outdir} "${idl_files}" FALSE "${idl_deps}")

endfunction()

###############################################################################
# install_type_support(idl srcdir outdir)
###############################################################################
# Helper function to install header files for type support code
###############################################################################
function(install_type_support  idl srcdir prefix outdir)
    get_filename_component(idl_name "${idl}" NAME_WE)
    set(idl_files       "${srcdir}/${idl_name}.${${RSPLUGIN_PREFIX}_EXT_INC}"
                        "${srcdir}/${idl_name}Plugin.${${RSPLUGIN_PREFIX}_EXT_INC}")
    if (NOT ${RSPLUGIN_PREFIX}_CXX)
        append_to_list(idl_files
                "${srcdir}/${idl_name}Support.${${RSPLUGIN_PREFIX}_EXT_INC}")
    endif()
    
    install(FILES ${idl_files} DESTINATION ${outdir}/${prefix})
endfunction()

###############################################################################
# idl_file()
###############################################################################
# 
###############################################################################

function(list_idl_type_sypport idl_id list_source list_headers outvar)
    if("${idl_id}" STREQUAL "ROOT")
        set(idl_suffix "")
    else()
        set(idl_suffix "_${idl_id}")
    endif()
    if(list_source)
        append_to_list(idl_source
            ${${RSPLUGIN_PREFIX}_BUILD_IDL_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX}_types${idl_suffix}.${${RSPLUGIN_PREFIX}_EXT_SRC}
            ${${RSPLUGIN_PREFIX}_BUILD_IDL_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX}_types${idl_suffix}Plugin.${${RSPLUGIN_PREFIX}_EXT_SRC})
        if (NOT ${RSPLUGIN_PREFIX}_CXX)
            append_to_list(idl_source
                ${${RSPLUGIN_PREFIX}_BUILD_IDL_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX}_types${idl_suffix}Support.${${RSPLUGIN_PREFIX}_EXT_SRC})
        endif()
    endif()    
    if(list_headers)
        append_to_list(idl_source
            ${${RSPLUGIN_PREFIX}_BUILD_IDL_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX}_types${idl_suffix}.${${RSPLUGIN_PREFIX}_EXT_INC}
            ${${RSPLUGIN_PREFIX}_BUILD_IDL_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX}_types${idl_suffix}Plugin.${${RSPLUGIN_PREFIX}_EXT_INC})
        if (NOT ${RSPLUGIN_PREFIX}_CXX)
            append_to_list(idl_source
                ${${RSPLUGIN_PREFIX}_BUILD_IDL_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX}_types${idl_suffix}Support.${${RSPLUGIN_PREFIX}_EXT_INC})
        endif()
    endif()
    set(${outvar} ${idl_source} PARENT_SCOPE)
endfunction()


macro(idl_file idl_id idl_deps)
    
    set(${RSPLUGIN_PREFIX}_IDL_${idl_id}   "${${RSPLUGIN_PREFIX}_IDL_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX}_types_${idl_id}.idl"
            CACHE INTERNAL "IDL description of ${idl_id} DDS types used by ${RSPLUGIN_NAME}")
    set(${RSPLUGIN_PREFIX}_XML_${idl_id}   "${${RSPLUGIN_PREFIX}_BUILD_IDL_DIR}/${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX}_types_${idl_id}.xml"
            CACHE INTERNAL "XML description of ${idl_id} DDS types used by ${RSPLUGIN_NAME}")
    
    if(${RSPLUGIN_PREFIX}_CXX)
        list_idl_type_sypport(${idl_id} true  false ${RSPLUGIN_PREFIX}_IDL_${idl_id}_SOURCE_CXX)
        list_idl_type_sypport(${idl_id} false true  ${RSPLUGIN_PREFIX}_IDL_${idl_id}_INCLUDE_CXX)

        append_to_list(${RSPLUGIN_PREFIX}_SOURCE_CXX_IDL
                    ${${RSPLUGIN_PREFIX}_IDL_${idl_id}_SOURCE_CXX})
        append_to_list(${RSPLUGIN_PREFIX}_INCLUDE_CXX_IDL
                    ${${RSPLUGIN_PREFIX}_IDL_${idl_id}_INCLUDE_CXX})
    else()
        list_idl_type_sypport(${idl_id} true  false ${RSPLUGIN_PREFIX}_IDL_${idl_id}_SOURCE_C)
        list_idl_type_sypport(${idl_id} false true  ${RSPLUGIN_PREFIX}_IDL_${idl_id}_INCLUDE_C)

        append_to_list(${RSPLUGIN_PREFIX}_SOURCE_C_IDL
                    ${${RSPLUGIN_PREFIX}_IDL_${idl_id}_SOURCE_C})
        append_to_list(${RSPLUGIN_PREFIX}_INCLUDE_C_IDL
                    ${${RSPLUGIN_PREFIX}_IDL_${idl_id}_INCLUDE_C})
    endif()
    
    append_to_list(${RSPLUGIN_PREFIX}_IDL_FILES ${${RSPLUGIN_PREFIX}_IDL_${idl_id}})
    append_to_list(${RSPLUGIN_PREFIX}_XML_FILES ${${RSPLUGIN_PREFIX}_XML_${idl_id}})

    idl_to_xml(${${RSPLUGIN_PREFIX}_IDL_${idl_id}} 
                ${${RSPLUGIN_PREFIX}_BUILD_IDL_DIR}
                ${${RSPLUGIN_PREFIX}_IDL_INSTALL_DIR}
                ${${RSPLUGIN_PREFIX}_XML_${idl_id}})

    # foreach(idl_dep ${${idl_deps}})
    #     append_to_list(${RSPLUGIN_PREFIX}_IDL_${idl_id}_DEPS
    #                     ${${RSPLUGIN_PREFIX}_IDL_${idl_id}})
    # endforeach()

    set(${RSPLUGIN_PREFIX}_IDL_${idl_id}_DEPS  ${${idl_deps}}
            CACHE INTERNAL "List of other IDL files that must be built before ${idl_id} DDS types used by ${RSPLUGIN_NAME}")
    
endmacro()

###############################################################################
# configure_idl_files()
###############################################################################
# 
###############################################################################
macro(configure_idl_files)
    log_status("configuring IDL files for ${RSPLUGIN_NAME}")
    
    if(${RSPLUGIN_PREFIX}_CXX)
        list_idl_type_sypport(ROOT true  false ${RSPLUGIN_PREFIX}_IDL_ROOT_SOURCE_CXX)
        list_idl_type_sypport(ROOT false true  ${RSPLUGIN_PREFIX}_IDL_ROOT_INCLUDE_CXX)

        append_to_list(${RSPLUGIN_PREFIX}_SOURCE_CXX_IDL
                    ${${RSPLUGIN_PREFIX}_IDL_ROOT_SOURCE_CXX})
        append_to_list(${RSPLUGIN_PREFIX}_INCLUDE_CXX_IDL
                    ${${RSPLUGIN_PREFIX}_IDL_ROOT_INCLUDE_CXX})
    else()
        list_idl_type_sypport(ROOT true  false ${RSPLUGIN_PREFIX}_IDL_ROOT_SOURCE_C)
        list_idl_type_sypport(ROOT false true  ${RSPLUGIN_PREFIX}_IDL_ROOT_INCLUDE_C)

        append_to_list(${RSPLUGIN_PREFIX}_SOURCE_C_IDL
                    ${${RSPLUGIN_PREFIX}_IDL_ROOT_SOURCE_C})
        append_to_list(${RSPLUGIN_PREFIX}_INCLUDE_C_IDL
                    ${${RSPLUGIN_PREFIX}_IDL_ROOT_INCLUDE_C})
    endif()
    
    append_to_list(${RSPLUGIN_PREFIX}_IDL_FILES ${${RSPLUGIN_PREFIX}_ROOT_IDL})
    append_to_list(${RSPLUGIN_PREFIX}_XML_FILES ${${RSPLUGIN_PREFIX}_ROOT_XML})

    if(${RSPLUGIN_PREFIX}_IDL_GENERATE)

        idl_to_xml(${${RSPLUGIN_PREFIX}_ROOT_IDL}
                    ${${RSPLUGIN_PREFIX}_BUILD_IDL_DIR}
                    ${${RSPLUGIN_PREFIX}_IDL_INSTALL_DIR}
                    ${${RSPLUGIN_PREFIX}_ROOT_XML})

        set(processed_idl_files     )
        foreach(idl_id ${${RSPLUGIN_PREFIX}_IDL_NAMES})
            idl_file(${idl_id} processed_idl_files)
            append_to_list(processed_idl_files ${idl_id})
        endforeach()
        generate_type_supports()
        install_type_supports()

    else()
        log_warning("no IDL generation for ${RSPLUGIN_NAME}")
    endif()

endmacro()

###############################################################################
# generate_type_supports()
###############################################################################
# 
###############################################################################
macro(generate_type_supports)
    foreach(idl_id ${${RSPLUGIN_PREFIX}_IDL_NAMES})
        log_status("generating type support for IDL(${idl_id}): ${${RSPLUGIN_PREFIX}_IDL_${idl_id}}")
        generate_type_support(${${RSPLUGIN_PREFIX}_IDL_${idl_id}} 
                            ${${RSPLUGIN_PREFIX}_BUILD_IDL_DIR}
                            "${${RSPLUGIN_PREFIX}_IDL_${idl_id}_DEPS}")
    endforeach()
    generate_type_support(${${RSPLUGIN_PREFIX}_ROOT_IDL}
                            ${${RSPLUGIN_PREFIX}_BUILD_IDL_DIR}
                            "${${RSPLUGIN_PREFIX}_IDL_NAMES}")
endmacro()

###############################################################################
# install_type_supports()
###############################################################################
# 
###############################################################################
macro(install_type_supports)
    foreach(idl_id ${${RSPLUGIN_PREFIX}_IDL_NAMES})
        install_type_support(${${RSPLUGIN_PREFIX}_IDL_${idl_id}}
                        ${${RSPLUGIN_PREFIX}_BUILD_IDL_DIR}
                        ${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX_DIR}
                        ${${RSPLUGIN_PREFIX}_DIST_INC_DIR})
    endforeach()
    install_type_support(${${RSPLUGIN_PREFIX}_ROOT_IDL}
                        ${${RSPLUGIN_PREFIX}_BUILD_IDL_DIR}
                        ${${RSPLUGIN_PREFIX}_INCLUDE_PREFIX_DIR}
                        ${${RSPLUGIN_PREFIX}_DIST_INC_DIR})
endmacro()


macro(import_idl)

    add_custom_command(OUTPUT ${${RSPLUGIN_PREFIX}_SOURCE_C_IDL}
                              ${${RSPLUGIN_PREFIX}_INCLUDE_C_IDL}
                              ${${RSPLUGIN_PREFIX}_SOURCE_CXX_IDL}
                              ${${RSPLUGIN_PREFIX}_INCLUDE_CXX_IDL}
                              ${${RSPLUGIN_PREFIX}_XML_FILES}
                COMMAND ${CMAKE} -E echo "Generated code and XML files from IDL files for ${RSPLUGIN_NAME}"
                DEPENDS ${RSPLUGIN_NAME}-idl)
endmacro()

