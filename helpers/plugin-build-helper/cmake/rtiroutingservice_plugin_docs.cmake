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
# configure_plugin_docs()
###############################################################################
# 
###############################################################################
macro(configure_plugin_docs)
    if (${RSPLUGIN_PREFIX}_ENABLE_DOCS)
        if (NOT EXISTS ${${RSPLUGIN_PREFIX}_DOC_DIR})
            log_warning("no DOCS for ${RSPLUGIN_NAME}")
        else()
            add_subdirectory(${${RSPLUGIN_PREFIX}_DOC_DIR})
        endif()
    endif()
endmacro()

###############################################################################
# configure_sphinx()
###############################################################################
# Helper macro to configure Sphinx
###############################################################################
macro(configure_sphinx)

    log_status("configuring Sphinx...")

    set_if_undefined(SPHINX_BIN             "sphinx-build")

endmacro()

###############################################################################
# configure_doxygen()
###############################################################################
# Helper macro to configure Doxygen
###############################################################################
macro(configure_doxygen)

    log_status("configuring Doxygen...")

    set_if_undefined(DOXYGEN_BIN            "doxygen")

endmacro()


###############################################################################

macro(configure_doc_dir)
    
    configure_sphinx()
    configure_doxygen()


    set(${RSPLUGIN_PREFIX}_DOC_DIR            "${CMAKE_CURRENT_LIST_DIR}"
        CACHE PATH "Base directory for all documentation")

    set(${RSPLUGIN_PREFIX}_DOC_BUILD_DIR      "${CMAKE_CURRENT_BINARY_DIR}/html"
        CACHE PATH "Base build directory for all documentation")

    set(${RSPLUGIN_PREFIX}_DOC_DOXYGEN_DIR    "${${RSPLUGIN_PREFIX}_DOC_DIR}/doxyoutput"
        CACHE PATH "Base build directory for all documentation")

    set_if_undefined(RSPLUGIN_DOC_INDEX         index.rst)
    set(${RSPLUGIN_PREFIX}_DOC_INDEX_IN         ${RSPLUGIN_DOC_INDEX})

    set(${RSPLUGIN_PREFIX}_DOC_INDEX_OUT      "${${RSPLUGIN_PREFIX}_DOC_BUILD_DIR}/index.html")

    set(${RSPLUGIN_PREFIX}_DOC_SOURCES        ${${RSPLUGIN_PREFIX}_DOC_INDEX_IN}
                                              ${RSPLUGIN_DOC_SOURCES})
    
    # generate_type_supports()
    import_idl()

    add_custom_command(OUTPUT ${${RSPLUGIN_PREFIX}_DOC_DOXYGEN_DIR}
                    COMMAND ${DOXYGEN_BIN} Doxyfile
                    WORKING_DIRECTORY ${${RSPLUGIN_PREFIX}_DOC_DIR}
                    DEPENDS ${${RSPLUGIN_PREFIX}_HEADERS} 
                            ${${RSPLUGIN_PREFIX}_SOURCES}
                            ${${RSPLUGIN_PREFIX}_XML_FILES}
                            ${${RSPLUGIN_PREFIX}_IDL_FILES}
                    VERBATIM)

    add_custom_command(OUTPUT ${${RSPLUGIN_PREFIX}_DOC_BUILD_DIR}
                    COMMAND ${SPHINX_BIN} ${${RSPLUGIN_PREFIX}_DOC_DIR}
                                        ${${RSPLUGIN_PREFIX}_DOC_BUILD_DIR}
                                        ${SPHINX_OPTS}
                    DEPENDS ${${RSPLUGIN_PREFIX}_DOC_SOURCES}
                            ${${RSPLUGIN_PREFIX}_DOC_DOXYGEN_DIR}
                    VERBATIM)

    add_custom_target(${RSPLUGIN_NAME}-clean-docs
                    COMMAND ${CMAKE_COMMAND} -E remove -f __pycache__
                                                        _build
                                                        extlinks.pyc
                                                        api
                    WORKING_DIRECTORY ${${RSPLUGIN_PREFIX}_DOC_DIR}
                    VERBATIM)

    add_custom_target(${RSPLUGIN_NAME}-docs DEPENDS ${${RSPLUGIN_PREFIX}_DOC_BUILD_DIR})

    add_dependencies(${${RSPLUGIN_PREFIX}_LIBRARY} ${RSPLUGIN_NAME}-docs)

    install(DIRECTORY ${${RSPLUGIN_PREFIX}_DOC_BUILD_DIR} 
            DESTINATION ${${RSPLUGIN_PREFIX}_RESOURCE_INSTALL_DIR}/doc)

endmacro()


