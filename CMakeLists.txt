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
project(rtiroutingservice-plugins C)
cmake_minimum_required(VERSION 3.7.0)

set(RSPLUGIN_PREFIX                 RTI_PLUGINS)

set(RSHELPER_DIR                    ${CMAKE_CURRENT_LIST_DIR}/helpers/plugin-build-helper
    CACHE INTERNAL "Clone of plugin helper repository")

include(${RSHELPER_DIR}/cmake/rtiroutingservice_plugin.cmake)
check_plugin_args()
default_plugin_options()
define_plugin_option(ENABLE_ALL
                     "Build everything"                                 ON)
define_plugin_option(ENABLE_ALL_PLUGINS
                     "Build all plugins"                                ${RTI_PLUGINS_ENABLE_ALL})
define_plugin_option(ENABLE_ALL_EXAMPLES
                     "Build all examples"                               ${RTI_PLUGINS_ENABLE_ALL})
define_plugin_option(ENABLE_ADAPTER_FILE
                     "Build plugin: File Adapter"                       ${RTI_PLUGINS_ENABLE_ALL_PLUGINS})
define_plugin_option(ENABLE_ADAPTER_MQTT
                     "Build plugin: MQTT Adapter"                       ${RTI_PLUGINS_ENABLE_ALL_PLUGINS})
define_plugin_option(ENABLE_TRANSFORMATION_SIMPLE
                     "Build plugin: Simple Transformation"              ${RTI_PLUGINS_ENABLE_ALL_PLUGINS})
define_plugin_option(ENABLE_TRANSFORMATION_FIELD
                     "Build plugin: Field Transformation"               ${RTI_PLUGINS_ENABLE_ALL_PLUGINS})
define_plugin_option(ENABLE_TRANSFORMATION_JSON
                     "Build plugin: JSON Transformation"                ${RTI_PLUGINS_ENABLE_ALL_PLUGINS})
define_plugin_option(ENABLE_PROCESSOR_FWD
                     "Build plugin: Forwarding Engine"                  ${RTI_PLUGINS_ENABLE_ALL_PLUGINS})
define_plugin_option(ENABLE_EXAMPLE_MQTTSHAPES
                     "Build example: MQTT Shapes"                       ${RTI_PLUGINS_ENABLE_ALL_EXAMPLES})
# configure_plugin_env()

set(RTI_MQTT_DIR            "${CMAKE_CURRENT_LIST_DIR}/plugins/adapters/mqtt"
    CACHE INTERNAL "Local clone of MQTT Adapter plugin")
set(RTI_ADAPT_FILE_DIR      "${CMAKE_CURRENT_LIST_DIR}/plugins/adapters/file"
    CACHE INTERNAL "Local clone of File Adapter plugin")
set(RTI_TSFM_DIR            "${CMAKE_CURRENT_LIST_DIR}/plugins/transformations/simple"
    CACHE INTERNAL "Local clone of Simple Transformation plugin")
set(RTI_TSFM_FIELD_DIR      "${CMAKE_CURRENT_LIST_DIR}/plugins/transformations/field"
    CACHE INTERNAL "Local clone of Field Transformation plugin")
set(RTI_TSFM_JSON_DIR     "${CMAKE_CURRENT_LIST_DIR}/plugins/transformations/json"
    CACHE INTERNAL "Local clone of JSON Transformation plugin")
set(RTI_PRCS_FWD_DIR      "${CMAKE_CURRENT_LIST_DIR}/plugins/processors/fwd"
    CACHE INTERNAL "Local clone of Forwarding Engine plugin")
set(RTI_MQTTSHAPES_DIR      "${CMAKE_CURRENT_LIST_DIR}/examples/mqtt-shapes"
    CACHE INTERNAL "Local clone of CMAKE_CURRENT_LIST_DIR Shapes example")


add_subdirectory(${RSHELPER_DIR})

if(RTI_PLUGINS_ENABLE_ADAPTER_MQTT)
    add_subdirectory(${RTI_MQTT_DIR})
endif()

if(RTI_PLUGINS_ENABLE_ADAPTER_FILE)
    add_subdirectory(${RTI_ADAPT_FILE_DIR})
endif()

if(RTI_PLUGINS_ENABLE_TRANSFORMATION_SIMPLE)
    add_subdirectory(${RTI_TSFM_DIR})
endif()

if(RTI_PLUGINS_ENABLE_TRANSFORMATION_FIELD)
    add_subdirectory(${RTI_TSFM_FIELD_DIR})
endif()

if(RTI_PLUGINS_ENABLE_TRANSFORMATION_JSON)
    add_subdirectory(${RTI_TSFM_JSON_DIR})
endif()

if(RTI_PLUGINS_ENABLE_PROCESSOR_FWD)
    add_subdirectory(${RTI_PRCS_FWD_DIR})
endif()

if(RTI_PLUGINS_ENABLE_EXAMPLE_MQTTSHAPES)
    add_subdirectory(${RTI_MQTTSHAPES_DIR})
endif()
