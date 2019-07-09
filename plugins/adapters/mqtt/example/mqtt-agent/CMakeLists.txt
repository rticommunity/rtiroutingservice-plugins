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

project(rtiroutingservice-adapter-mqtt-examples-agent C)
cmake_minimum_required(VERSION 3.7.0)

###############################################################################

set(MQTTAGENT_SRC_DIR           src)
set(MQTTAGENT_INCLUDE_C         MqttAgent.h)
set(MQTTAGENT_SOURCE_C          main.c
                                MqttAgent.c
                                MqttAgentSubscriber.c
                                MqttAgentPublisher.c)
set(MQTTAGENT_INSTALL_BIN_DIR   ${RTI_MQTT_RESOURCE_INSTALL_DIR}/example/mqtt-agent)
set(MQTTAGENT_INSTALL_DIR       ${RTI_MQTT_RESOURCE_INSTALL_DIR}/example/mqtt-agent)
set(MQTTAGENT_INSTALL_DIRS      etc)

configure_plugin_exec(mqtt-agent MQTTAGENT)

###############################################################################
