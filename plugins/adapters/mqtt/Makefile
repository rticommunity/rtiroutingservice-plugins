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

RSHELPER_DIR			?= ../rtiroutingservice-plugin-helper

RSPLUGIN_ROOT         := $(shell pwd)
RSPLUGIN_PREFIX				:= RTI_MQTT
RSPLUGIN_NAME					:= rtiroutingservice-adapter-mqtt
RSPLUGIN_NEEDS_CONFIG	:= y

RSPLUGIN_TARGETS			:= agent \
                         agent-run \
                         agent-gdb \
                         broker-start \
                         broker-stop \
                         broker-log

RSPLUGIN_CONFIG_VARS	:= MOSQUITTO \
                         MOSQUITTO_PORT \
                         MOSQUITTO_CONF \
                         AGENT_ARGS

RTI_MQTT_MOSQUITTO_DEFAULT        ?= mosquitto
RTI_MQTT_MOSQUITTO_PORT_DEFAULT 	?= 1883
RTI_MQTT_MOSQUITTO_CONF_DEFAULT		?= etc/mosquitto/mosquitto.conf

TESTER_PREFIX := rtimqtt_

include $(RSHELPER_DIR)/make/rtiroutingservice_plugin_env.mk

include $(RSHELPER_DIR)/make/rtiroutingservice_plugin_targets.mk

agent: setup \
       agent-run

agent-run:
	export LD_LIBRARY_PATH="$(RTI_MQTT_LD_LIBRARY_PATH)" && \
	cd $(RTI_MQTT_INSTALL_DIR)/example/mqtt-agent && \
	./mqtt-agent $(RTI_MQTT_AGENT_ARGS)

agent-gdb: setup
	export LD_LIBRARY_PATH="$(RTI_MQTT_LD_LIBRARY_PATH)" && \
	cd $(RTI_MQTT_INSTALL_DIR)/example/mqtt-agent && \
	gdb --args ./mqtt-agent $(RTI_MQTT_AGENT_ARGS)

broker-start:
	if [ -z "$$(ps aux | grep "mosquitto " | grep -v grep)" ]; then \
	  cd $(RTI_MQTT_INSTALL_DIR) && \
	  $(RTI_MQTT_MOSQUITTO) -c $(RTI_MQTT_MOSQUITTO_CONF) \
		                      -p $(RTI_MQTT_MOSQUITTO_PORT) \
		                      -d  && \
		echo "Started Mosquitto";\
	else \
		echo "Mosquitto already running";\
	fi

broker-stop:
	killall $$(basename $(RTI_MQTT_MOSQUITTO)) && \
			echo "Killed Mosquitto" || \
	    echo "Mosquitto not started"

broker-log:
	tail -f $(RTI_MQTT_INSTALL_DIR)/mosquitto.log