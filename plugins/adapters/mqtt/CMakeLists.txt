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
project(rtiroutingservice-adapter-mqtt C)
cmake_minimum_required(VERSION 3.7.0)

include(${RSHELPER_DIR}/cmake/rtiroutingservice_plugin.cmake)

###############################################################################
# configure_paho()
###############################################################################
# Helper macro to configure build of Paho (Posix C) and to add it as a
# build dependency.
###############################################################################
macro(configure_paho_c)
    log_status("configuring Paho (C Posix) Client MQTT library...")

    set(RTI_MQTT_PAHO_C_DIR            ${CMAKE_CURRENT_LIST_DIR}/modules/paho.mqtt.c
        CACHE PATH "Directory containing buildable source for Paho (C Posix)")

    set(RTI_MQTT_PAHO_C_INC_DIR        "${RTI_MQTT_PAHO_C_DIR}/src"
        CACHE INTERNAL "Directory with header files for Paho (C Posix) library")
    
    set(RTI_MQTT_PAHO_C_LIB_A          "paho-mqtt3a"
        CACHE INTERNAL "Static library for Paho (C Posix) Asynchronous API")
    
    set(RTI_MQTT_PAHO_C_LIB_AS         "paho-mqtt3as"
        CACHE INTERNAL "Static library for Paho (C Posix) Asynchronous API with SSL/TLS support")

    set(PAHO_BUILD_STATIC               false
        CACHE INTERNAL "Enable building Paho (C Posix)'s static libraries"
        FORCE)
    set(PAHO_WITH_SSL                   ${RTI_MQTT_ENABLE_SSL}
        CACHE INTERNAL "Enable building Paho (C Posix) with OpenSSL support"
        FORCE)
    
    if(RTI_MQTT_ENABLE_SSL)
    set(OPENSSL_SEARCH_PATH             "${RTI_MQTT_OPENSSLHOME}"
        CACHE INTERNAL "Directory searched by Paho (C Posix) for OpenSSL files"
        FORCE)
    endif()

    set(PAHO_BUILD_DOCUMENTATION        false
        CACHE INTERNAL "Enable building Paho (C Posix)'s documentation"
        FORCE)
    set(PAHO_BUILD_SAMPLES              false
        CACHE INTERNAL "Enable building Paho (C Posix)'s sample programs"
        FORCE)
    set(PAHO_BUILD_DEB_PACKAGE          false
        CACHE INTERNAL "Enable building Paho (C Posix)'s Debian package"
        FORCE)
    set(PAHO_ENABLE_TESTING             false
        CACHE INTERNAL "Enable building and running Paho (C Posix)'s tests"
        FORCE)
    set(PAHO_ENABLE_CPACK               false
        CACHE INTERNAL "Enable use of CPack to generate Paho (C Posix) bundles"
        FORCE)

    add_subdirectory(${RTI_MQTT_PAHO_C_DIR})

    if(RTI_MQTT_ENABLE_SSL)
        append_to_list(RSPLUGIN_LIBS
                        ${RTI_MQTT_PAHO_C_LIB_AS})
    else()
        append_to_list(RSPLUGIN_LIBS
                        ${RTI_MQTT_PAHO_C_LIB_A})
    endif()

    append_to_list(RSPLUGIN_INCLUDE_DIRS
                    ${RTI_MQTT_PAHO_C_INC_DIR})
    
endmacro()

###############################################################################
# configure_mosquitto()
###############################################################################
# Helper macro to configure build of Mosquitto and to add it as a build
# dependency.
###############################################################################
macro(configure_mosquito)
    log_status("configuring Mosquitto Client MQTT library...")
    log_error("Mosquitto not supported yet")
endmacro()

###############################################################################
# configure_mqtt_client()
###############################################################################
# 
###############################################################################
macro(configure_mqtt_client)
    if(RTI_MQTT_CLIENT_PAHO_C AND 
       RTI_MQTT_CLIENT_MOSQUITTO)
        log_error("multiple MQTT Client library selected: paho_c=${CLIENT_PAHO_C} mosquitto=paho_c=${CLIENT_MOSQUITTO}")
    elseif(NOT RTI_MQTT_CLIENT_PAHO_C AND 
           NOT RTI_MQTT_CLIENT_MOSQUITTO)
        log_error("no MQTT Client library selected.")
    endif()

    if(RTI_MQTT_CLIENT_PAHO_C)
        configure_paho_c()
    elseif(CLIENT_MOSQUITTO)
        configure_mosquitto()
    endif()
endmacro()

###############################################################################
###############################################################################

set(RSPLUGIN_NAME               rtiroutingservice-adapter-mqtt)

set(RSPLUGIN_PREFIX             RTI_MQTT)

set(RSPLUGIN_IDL                message
                                client
                                adapter)

set(RSPLUGIN_INCLUDE_PREFIX     rtiadapt_mqtt)
set(RSPLUGIN_INCLUDE_PREFIX_DIR rti)

set(RSPLUGIN_INCLUDE_C_PUBLIC   adapter
                                client
                                log
                                log_messages)

set(RSPLUGIN_INCLUDE_C          mqtt/Client.h
                                mqtt/ClientApi.h
                                mqtt/ClientApiPaho.h
                                mqtt/Subscription.h
                                mqtt/Publication.h
                                mqtt/Message.h
                                mqtt/Infrastructure.h
                                adapter/Plugin.h
                                adapter/BrokerConnection.h
                                adapter/MessageReader.h
                                adapter/MessageWriter.h
                                adapter/Properties.h)

set(RSPLUGIN_SOURCE_C           mqtt/Client.c
                                mqtt/ClientApiPaho.c
                                mqtt/Subscription.c
                                mqtt/Publication.c
                                mqtt/Message.c
                                mqtt/Infrastructure.c
                                adapter/Plugin.c
                                adapter/BrokerConnection.c
                                adapter/MessageReader.c
                                adapter/MessageWriter.c
                                adapter/Properties.c)

set(RSPLUGIN_LIBRARY            rtirsmqttadapter)

set(RSPLUGIN_TESTER_PREFIX      rtimqtt_)

check_plugin_args()
default_plugin_options()
define_plugin_option(ENABLE_STATIC_TYPES
        "Enable support for statically typed messages"  OFF)
define_plugin_option(CLIENT_PAHO_C 
        "Use Paho (C Posix) as MQTT Client library"     ON)
define_plugin_option(CLIENT_MOSQUITTO 
        "Use Mosquitto as MQTT Client library"          OFF)

if(RTI_MQTT_ENABLE_STATIC_TYPES)
    append_to_list(RSPLUGIN_DEFINES   RTI_MQTT_ENABLE_STATIC_TYPES)
endif()

configure_plugin_deps()

configure_mqtt_client()

configure_plugin()