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
# configure_cmocka()
###############################################################################
# Helper macro to configure build of CMocka and to add it as a
# build dependency.
###############################################################################
macro(configure_cmocka)
    if(NOT TARGET cmocka)
        check_not_empty(CMOCKA_DIR
            "Please set CMOCKA_DIR to a clone of cmocka")
        log_status("configuring CMocka...")
        add_subdirectory(${CMOCKA_DIR} modules/cmocka)
    else()
        log_status("CMocka already configured")
    endif()
endmacro()


###############################################################################
# configure_tester()
###############################################################################
# 
###############################################################################
macro(configure_tester)
    find_connextdds(OFF)

    log_status("CONFIGURING tester: ${TESTER_EXEC}")

    set(TESTER_COMMON_DIR           ${${RSPLUGIN_PREFIX}_TEST_DIR}/common)
    set(TESTER_COMMON_SOURCES       ${TESTER_COMMON_DIR}/TestFramework.c)
    set(TESTER_COMMON_HEADERS       ${TESTER_COMMON_DIR}/TestFramework.h)
    set(TESTER_COMMON_LIBS          cmocka
                                    ${${RSPLUGIN_PREFIX}_LIBS})
    set(TESTER_COMMON_INCLUDES      ${CMAKE_CURRENT_LIST_DIR}
                                    ${TESTER_COMMON_DIR}
                                    ${CMOCKA_PUBLIC_INCLUDE_DIRS}
                                    ${${RSPLUGIN_PREFIX}_INCLUDES})
    
    set(TESTER_COMMON_DEFINES       ${${RSPLUGIN_PREFIX}_DEFINES})


    if (TESTER_MOCK)
        log_status("MOCK ENABLED: ${TESTER_EXEC}")
        # generate_type_supports()

        import_idl()

        set(TESTER_COMMON_SOURCES       ${TESTER_COMMON_SOURCES}
                                        ${${RSPLUGIN_PREFIX}_SOURCES})
        set(TESTER_COMMON_HEADERS       ${TESTER_COMMON_HEADERS}
                                        ${${RSPLUGIN_PREFIX}_HEADERS})
    else()
        set(TESTER_COMMON_LIBS          ${TESTER_COMMON_LIBS}
                                        ${${RSPLUGIN_PREFIX}_LIBRARY}-shared)
    endif()

    set_if_undefined(TESTER_PREFIX  ${RSPLUGIN_TESTER_PREFIX})
    set_if_undefined(TESTER_TARGET  ${TESTER_PREFIX}${TESTER_EXEC})

    add_executable(${TESTER_TARGET} ${TESTER_SOURCES}
                                    ${TESTER_HEADERS}
                                    ${TESTER_COMMON_SOURCES}
                                    ${TESTER_COMMON_HEADERS})
    
    target_link_libraries(${TESTER_TARGET} 
                            PUBLIC  ${TESTER_LIBS}
                                    ${TESTER_COMMON_LIBS})
    target_include_directories(${TESTER_TARGET}
                            PUBLIC  ${TESTER_INCLUDES}
                                    ${TESTER_COMMON_INCLUDES})
    target_compile_definitions(${TESTER_TARGET}
                            PUBLIC  ${TESTER_DEFINES}
                                    ${TESTER_COMMON_DEFINES})
    
    if (TESTER_MOCK)
        set_if_undefined(TESTER_LINK_FLAGS      "")
        foreach(wrap_fn IN LISTS TESTER_WRAP)
            string(APPEND TESTER_LINK_FLAGS " -Wl,--wrap=${wrap_fn}")
        endforeach()
        set_target_properties(${TESTER_TARGET}
            PROPERTIES LINK_FLAGS ${TESTER_LINK_FLAGS})
    endif()

    install(TARGETS ${TESTER_TARGET}
            RUNTIME DESTINATION ${${RSPLUGIN_PREFIX}_TEST_DIST_DIR})
    

    add_test(${TESTER_TARGET}  ${CMAKE_CURRENT_BINARY_DIR}/${TESTER_TARGET})

    set_tests_properties(${TESTER_TARGET} 
            PROPERTIES ENVIRONMENT "LD_LIBRARY_PATH=${${RSPLUGIN_PREFIX}_LIB_DIR}:${CONNEXTDDS_DIR}/lib/${CONNEXTDDS_ARCH}:${OPENSSLHOME}/lib")
endmacro()

###############################################################################
# configure_plugin_tests()
###############################################################################
# 
###############################################################################
macro(configure_plugin_tests)
    if(${RSPLUGIN_PREFIX}_ENABLE_TESTS)
        if (NOT EXISTS ${${RSPLUGIN_PREFIX}_TEST_DIR})
            log_warning("no TESTS for ${RSPLUGIN_NAME}")
        else()
            option(${RSPLUGIN_PREFIX}_TESTER_MOCK  "enable mocking of C functions" OFF)
            enable_testing()
            configure_cmocka()
            add_subdirectory(${${RSPLUGIN_PREFIX}_TEST_DIR})
        endif()
    endif()
endmacro()
