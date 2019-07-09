#!/bin/sh
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
###############################################################################

RTI_PLUGINS_CLONE_DIR=rtiroutingservice-plugins
RTI_PLUGINS_URL=https://bitbucket.rti.com/scm/~asorbini/rtiroutingservice-plugins.git
RTI_PLUGINS_BRANCH=master

RSHELPER_CLONE_DIR=rtiroutingservice-plugin-helper
RSHELPER_URL=https://bitbucket.rti.com/scm/~asorbini/rtiroutingservice-plugin-helper.git
RSHELPER_BRANCH=release

RTI_MQTT_CLONE_DIR=rtiroutingservice-adapter-mqtt
RTI_MQTT_URL=https://bitbucket.rti.com/scm/~asorbini/rtiroutingservice-adapter-mqtt.git
RTI_MQTT_BRANCH=release
RTI_MQTT_DEPS="
RSHELPER
"

RTI_TSFM_CLONE_DIR=rtiroutingservice-transform
RTI_TSFM_URL=https://bitbucket.rti.com/scm/~asorbini/rtiroutingservice-transform.git
RTI_TSFM_BRANCH=release
RTI_TSFM_DEPS="
RSHELPER
"

RTI_TSFM_FIELD_CLONE_DIR=rtiroutingservice-transform-field
RTI_TSFM_FIELD_URL=https://bitbucket.rti.com/scm/~asorbini/rtiroutingservice-transform-field.git
RTI_TSFM_FIELD_BRANCH=release
RTI_TSFM_FIELD_DEPS="
RSHELPER
RTI_TSFM
"

RTI_TSFM_JSON_CLONE_DIR=rtiroutingservice-transform-json
RTI_TSFM_JSON_URL=https://bitbucket.rti.com/scm/~asorbini/rtiroutingservice-transform-json.git
RTI_TSFM_JSON_BRANCH=release
RTI_TSFM_JSON_DEPS="
RSHELPER
RTI_TSFM
"

RTI_PRCS_FWD_CLONE_DIR=rtiroutingservice-process-fwd
RTI_PRCS_FWD_URL=https://bitbucket.rti.com/scm/~asorbini/rtiroutingservice-process-fwd.git
RTI_PRCS_FWD_BRANCH=release
RTI_PRCS_FWD_DEPS="
RSHELPER
"

RTI_MQTTSHAPES_CLONE_DIR=rtiroutingservice-example-mqtt-shapes
RTI_MQTTSHAPES_URL=https://bitbucket.rti.com/scm/~asorbini/rtiroutingservice-example-mqtt-shapes.git
RTI_MQTTSHAPES_BRANCH=release
RTI_MQTTSHAPES_DEPS="
RSHELPER
RTI_MQTT
RTI_TSFM
RTI_TSFM_FIELD
RTI_TSFM_JSON
RTI_PRCS_FWD
"

RTI_PLUGINS_ALL="
RTI_PLUGINS
RTI_MQTT
RTI_TSFM
RTI_TSFM_FIELD
RTI_TSFM_JSON
RTI_PRCS_FWD
RTI_MQTTSHAPES
"
###############################################################################
###############################################################################

SH_DIR=$(cd "$(dirname "${0}")" && pwd)
TEST_HELPERS="${SH_DIR}/test_helpers.sh"
. ${TEST_HELPERS}

###############################################################################

TEST_TARGETS="${TEST_TARGETS:-${RTI_PLUGINS_ALL}}"

TEST_MAKE_TGT_BUILD=${TEST_MAKE_TGT_BUILD:-}
TEST_MAKE_TGT_CLEAN=${TEST_MAKE_TGT_CLEAN:-clean-all}
TEST_CMAKE_BUILD_DIR="${TEST_CMAKE_BUILD_DIR:-build}"
TEST_CMAKE_INSTALL_DIR="${TEST_CMAKE_INSTALL_DIR:-install}"
TEST_CMAKE_GENERATOR="${TEST_CMAKE_GENERATOR:-Unix Makefiles}"
TEST_CMAKE_SKIP_INSTALL="${TEST_CMAKE_SKIP_INSTALL:-}"
TEST_CMAKE_BUILD_TYPE="${TEST_BUILD_TYPE:-Release}"

TEST_ROOT="${TEST_ROOT:-$(pwd)/.test-tmp}"
TEST_LOG="${TEST_LOG:-${TEST_ROOT}/test-$(date +%Y%m%d-%H%M%S).log}"

###############################################################################

test_init
