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

project(rtiroutingservice-example-mqtt-shapes C)
cmake_minimum_required(VERSION 3.7.0)

include(${RSHELPER_DIR}/cmake/rtiroutingservice_plugin.cmake)

###############################################################################
###############################################################################

macro(configure_deps)
    configure_plugin_as_dep(rtiroutingservice-adapter-mqtt
                            RTI_MQTT
                            modules/adapt-mqtt)

    configure_plugin_as_dep(rtiroutingservice-transform-simple
                            RTI_TSFM
                            modules/transform-simple)

    configure_plugin_as_dep(rtiroutingservice-transform-field
                            RTI_TSFM_FIELD
                            modules/transform-field)

    configure_plugin_as_dep(rtiroutingservice-transform-json
                            RTI_TSFM_JSON
                            modules/transform-json)

    configure_plugin_as_dep(rtiroutingservice-process-fwd
                            RTI_PRCS_FWD
                            modules/process-fwd)

    append_to_list(RSPLUGIN_LIBS            RTIConnextDDS::c_api)
endmacro()

###############################################################################
###############################################################################

set(RSPLUGIN_PREFIX                 RTI_MQTTSHAPES)

configure_deps()

check_plugin_args()
default_plugin_options()
configure_plugin_deps()
configure_plugin_env()
configure_plugin_files()


###############################################################################
###############################################################################

set(SHAPESAGENT_INCLUDE_C           shapes-agent/ShapesAgentDds.h
                                    shapes-agent/termcolor.h)

set(SHAPESAGENT_SOURCE_C            shapes-agent/main.c
                                    shapes-agent/ShapesAgentDds.c
                                    shapes-agent/ShapesAgentDdsSubscriber.c
                                    shapes-agent/ShapesAgentDdsPublisher.c)

set(SHAPESAGENT_SRC_DIR             ${RTI_MQTTSHAPES_SRC_DIR})

if(NOT "$ENV{RTI_MQTTSHAPES_SHAPES_RATE}" STREQUAL "")
    append_to_list(SHAPESAGENT_DEFINES      "-DSHAPES_AGENT_WRITER_LOOP_SEC=$ENV{RTI_MQTTSHAPES_SHAPES_RATE}")
endif()

configure_plugin_exec(shapes-agent-dds SHAPESAGENT)

###############################################################################
###############################################################################

install(DIRECTORY   etc DESTINATION .)

###############################################################################
###############################################################################
