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

RSPLUGIN_ROOT           := $(shell pwd)
RSPLUGIN_PREFIX			:= RTI_PLUGINS
RSPLUGIN_NAME			:= rtiroutingservice-plugins
RSPLUGIN_NEEDS_CONFIG	:= y
TESTER_PREFIX 			:= rtiplugins_
INSTALL_DIR				?= $(RSPLUGIN_ROOT)/install

include helpers/plugin-build-helper/make/rtiroutingservice_plugin_env.mk
include helpers/plugin-build-helper/make/rtiroutingservice_plugin_targets.mk
