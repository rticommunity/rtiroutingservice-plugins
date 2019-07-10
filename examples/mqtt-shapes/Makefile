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

RSHELPER_DIR			?= ../../helpers/plugin-build-helper
RTI_MQTT_DIR			?= ../../plugins/adapters/mqtt
CONFIG_MK				?= ../../config.mk

RSPLUGIN_ROOT           := $(shell pwd)
RSPLUGIN_PREFIX         := RTI_MQTTSHAPES
RSPLUGIN_NAME           := rtiroutingservice-example-mqtt-shapes
RSPLUGIN_NEEDS_CONFIG   := y
RSPLUGIN_CONFIG_VARS    := SHAPES_RATE \
                           SHAPES_CONFIG \
                           SHAPES_TYPE \
                           SHAPES_AGENT \
                           SHAPES_AGENT_TYPE \
                           TMUX_SESSION \
                           MOSQUITTO \
                           MOSQUITTO_PORT \
                           MOSQUITTO_CONF \
                           AGENT_ARGS \
                           SESSION_ENABLED_AGENT \
                           SESSION_ENABLED_SHAPES \
                           SESSION_ENABLED_IO \
                           IO_USERNAME \
                           IO_KEY

RSPLUGIN_TARGETS        := shapes \
                           agent-dds \
                           agent-dds-gdb \
                           agent-dds-valgrind \
                           monitor \
                           tmux \
                           tmux-stop \
                           mqtt-publisher \
                           mqtt-subscriber \
                           demo \
                           broker-start \
                           broker-stop \
                           broker-log

# RSPLUGIN_MODULES        := adapter-mqtt \
#                            transform-plugin \
#                            transform-shapes \
#                            transform-field \
#                            processor-cbr

RTI_MQTTSHAPES_ENABLE_SSL_DEFAULT       ?= ON
RTI_MQTTSHAPES_INSTALL_DEPS_DEFAULT     ?= ON
RTI_MQTTSHAPES_CONFIG_EXAMPLE_COMPUTE   ?= config.example.mk
RTI_MQTTSHAPES_SHAPES_RATE_DEFAULT      ?= 1
RTI_MQTTSHAPES_SHAPES_CONFIG_DEFAULT    ?= etc/shapes_demo_workspace.xml
RTI_MQTTSHAPES_SHAPES_TYPE_DEFAULT      ?= Shape
RTI_MQTTSHAPES_ROUTER_FILE_DEFAULT      ?= etc/shapes_bridge.xml
RTI_MQTTSHAPES_ROUTER_NAME_DEFAULT      ?= shapes_bridge
RTI_MQTTSHAPES_ROUTER_VERBOSITY_DEFAULT ?= 5
RTI_MQTTSHAPES_TMUX_SESSION_DEFAULT     ?= DEMO
RTI_MQTTSHAPES_SESSION_ENABLED_IO_DEFAULT ?= true
RTI_MQTTSHAPES_SESSION_ENABLED_AGENT_DEFAULT ?= true
RTI_MQTTSHAPES_SESSION_ENABLED_SHAPES_DEFAULT ?= true
RTI_MQTTSHAPES_INSTALL_DIR_DEFAULT      ?= ../../install
RTI_MQTTSHAPES_MOSQUITTO_DEFAULT        ?= mosquitto
RTI_MQTTSHAPES_MOSQUITTO_PORT_DEFAULT   ?= 1883
RTI_MQTTSHAPES_MOSQUITTO_CONF_DEFAULT   ?= etc/mosquitto/mosquitto.conf

include $(RSHELPER_DIR)/make/rtiroutingservice_plugin_env.mk

include $(RSHELPER_DIR)/make/rtiroutingservice_plugin_targets.mk

demo: setup \
      tmux

broker-start:
	if [ -z "$$(ps aux | grep "mosquitto " | grep -v grep)" ]; then \
	  cd $(RTI_MQTTSHAPES_INSTALL_DIR) && \
	  $(RTI_MQTTSHAPES_MOSQUITTO) \
		                      -c $(RTI_MQTTSHAPES_MOSQUITTO_CONF) \
		                      -p $(RTI_MQTTSHAPES_MOSQUITTO_PORT) \
		                      -d  && \
		echo "Started Mosquitto";\
	else \
		echo "Mosquitto already running";\
	fi

broker-stop:
	killall $$(basename $(RTI_MQTTSHAPES_MOSQUITTO)) && \
			echo "Killed Mosquitto" || \
	    echo "Mosquitto not started"

broker-log:
	tail -f $(RTI_MQTT_INSTALL_DIR)/mosquitto.log

shapes:
	cd $(RTI_MQTTSHAPES_INSTALL_DIR) && \
	$(RTI_MQTTSHAPES_CONNEXTDDS_DIR)/bin/rtishapesdemo \
	                    -compact -workspaceFile $(RTI_MQTTSHAPES_SHAPES_CONFIG) \
	                    -dataType $(RTI_MQTTSHAPES_SHAPES_TYPE) \
	                    -pubInterval $(shell expr $(RTI_MQTTSHAPES_SHAPES_RATE) \* 1000)

agent-dds:
	cd $(RTI_MQTTSHAPES_INSTALL_DIR) && \
    $(RTI_MQTTSHAPES_BIN_DIR)/shapes-agent-dds $(RTI_MQTTSHAPES_AGENT_ARGS)
	
agent-dds-gdb:
	cd $(RTI_MQTTSHAPES_INSTALL_DIR) && \
    gdb --args \
        $(RTI_MQTTSHAPES_BIN_DIR)/shapes-agent-dds $(RTI_MQTTSHAPES_AGENT_ARGS)

agent-dds-valgrind:
	cd $(RTI_MQTTSHAPES_INSTALL_DIR) && \
	valgrind $(VALGRIND_ARGS) \
	    $(RTI_MQTTSHAPES_BIN_DIR)/shapes-agent-dds $(RTI_MQTTSHAPES_AGENT_ARGS)

monitor:
	top -c -o +RES -p $$(pgrep -d',' "rti|shapes-agent|mosquitto")

mqtt-publisher:
	$(RTI_MQTTSHAPES_BIN_DIR)/shapes_mqtt_publisher.sh GREEN

mqtt-subscriber:
	$(RTI_MQTTSHAPES_BIN_DIR)/shapes_mqtt_subscriber.sh

tmux:
	$(RTI_MQTTSHAPES_BIN_DIR)/tmux_session.sh || \
	    tmux at -t $(RTI_MQTTSHAPES_TMUX_SESSION)

tmux-stop:
	tmux kill-ses -t $(RTI_MQTTSHAPES_TMUX_SESSION)
