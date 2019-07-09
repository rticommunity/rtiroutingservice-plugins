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
# Check required arguments
###############################################################################
ifeq ($(RSPLUGIN_PREFIX),)
    $(error No RSPLUGIN_PREFIX specified)
endif
ifeq ($(RSPLUGIN_NAME),)
    $(error No RSPLUGIN_NAME specified)
endif
ifeq ($(RSPLUGIN_ROOT),)
    $(error No RSPLUGIN_ROOT specified)
endif

###############################################################################
# Helper function to check if a target should be enabled
###############################################################################
define FN_TARGET_ENABLED
	$(filter $(1),$($(RSPLUGIN_PREFIX)_TARGETS))
endef

###############################################################################
# Helper function to log a disabled target
###############################################################################
define FN_TARGET_DISABLED
	$(warning TARGET DISABLED: $(1) [$(call FN_TARGET_ENABLED,$(1))])
endef

###############################################################################
# Helper function to call a make target on a submodule
###############################################################################
define FN_MAKE_MODULE
	$(MAKE) -C "$($(RSPLUGIN_PREFIX)_MOD_DIR)/$(1)" \
			CONFIG_MK=$(CONFIG_MK) \
			$(2)
endef

###############################################################################
# Helper function to print info on a config var computation
###############################################################################
# define FN_CONFIG_VAR_SET
#     $(if $($(RSPLUGIN_PREFIX)_VERBOSE),\
#         $(info [$(1)] $(2) = $($(2))),\
#         )
# endef
ifneq ($(VERBOSE),)
define FN_CONFIG_VAR_SET
    $(info [$(1)] $(2) = $($(2)))
endef
else
define FN_CONFIG_VAR_SET
    
endef
endif

###############################################################################
# Set DEFAULT values for RSPLUGIN_ variables
###############################################################################

RSPLUGIN_CONFIG_VARS_REQUIRED_DEFAULT ?= CMAKE_BUILD_TYPE \
                                         CONNEXTDDS_DIR \
                                         CONNEXTDDS_ARCH

RSPLUGIN_CONFIG_VARS_DEFAULT	?= NAME \
                                   MODULES \
                                   MODULES_ALL \
                                   NEEDS_CONFIG \
                                   CONFIG_VARS \
                                   CONFIG_VARS_REQUIRED \
                                   TARGETS \
                                   CMAKE_BUILD_TYPE \
                                   CONNEXTDDS_DIR \
                                   CONNEXTDDS_ARCH \
                                   CONNEXTDDS_ARCH_HOST \
                                   OPENSSLHOME \
                                   ENABLE_SSL \
                                   ENABLE_LOG \
                                   DISABLE_LOG \
                                   ENABLE_TRACE \
                                   ENABLE_TESTS \
                                   ENABLE_EXAMPLES \
                                   ENABLE_DOCS \
                                   INSTALL_DEPS \
                                   BIN_DIR \
                                   MOD_DIR \
                                   DOC_DIR \
                                   TEST_DIR \
                                   BUILD_DIR \
                                   INSTALL_DIR \
                                   CMAKE \
                                   CMAKE_ARGS_CUSTOM \
                                   CMAKE_ARGS_INTERNAL \
                                   CMAKE_ARGS \
                                   CMAKE_BUILD_JOBS \
                                   CMAKE_BUILD_ARGS \
                                   CMAKE_GENERATOR \
                                   ROUTER_EXEC \
                                   ROUTER_BIN \
                                   LD_LIBRARY_PATH_SYS \
                                   LD_LIBRARY_PATH_CUSTOM \
                                   LD_LIBRARY_PATH \
                                   CONFIG_EXAMPLE \
                                   ROUTER_FILE \
                                   ROUTER_NAME \
                                   ROUTER_VERBOSITY \
                                   ROUTER_ARGS \
                                   ROUTER_EXEC \
                                   ROUTER_BIN \
                                   VALGRIND_ARGS \
                                   GDB_ARGS \
                                   VERBOSE \
                                   TEST_LOG \
                                   TEST_VERBOSE \
                                   TEST_IGNORE_ERRORS \
                                   TEST_OUTPUT_FILTER \
                                   TEST_VALGRIND \
                                   TESTER_PREFIX
                                   

RSPLUGIN_TARGETS_DEFAULT    ?= all \
                               setup \
                               configure \
                               build \
                               install \
                               clean \
                               clean-all \
                               clean-docs \
                               docs \
                               router \
                               router-valgrind \
                               router-gdb \
                               update \
                               commit-helper \
                               commit-modules \
                               init-config \
                               init-gitignore \
                               init-module \
                               init-repo \
                               test \
                               test-run \
                               ctest \
                               ctest-run

RSPLUGIN_MODULES_DEFAULT	?= 

###############################################################################
# Set basic variables that pretty much everything else depends on
###############################################################################
$(RSPLUGIN_PREFIX)_NAME			:= $(RSPLUGIN_NAME)

$(RSPLUGIN_PREFIX)_NEEDS_CONFIG := $(RSPLUGIN_NEEDS_CONFIG)
$(RSPLUGIN_PREFIX)_CONFIG_VARS 	:= $(RSPLUGIN_CONFIG_VARS_DEFAULT) \
                                   $(RSPLUGIN_CONFIG_VARS)
$(RSPLUGIN_PREFIX)_CONFIG_VARS_REQUIRED	:= $(RSPLUGIN_CONFIG_VARS_REQUIRED) \
                                           $(RSPLUGIN_CONFIG_VARS_REQUIRED_DEFAULT)
$(RSPLUGIN_PREFIX)_TARGETS 		:= $(sort $(RSPLUGIN_TARGETS) \
                                   $(RSPLUGIN_TARGETS_DEFAULT))

$(RSPLUGIN_PREFIX)_MODULES 		:= $(RSPLUGIN_MODULES) \
                                   $(RSPLUGIN_MODULES_DEFAULT)

$(RSPLUGIN_PREFIX)_MODULES_ALL	:= $($(RSPLUGIN_PREFIX)_MODULES) \
                                   plugin-helper

##############################################################################
# Default values for default config vars
##############################################################################
$(RSPLUGIN_PREFIX)_CMAKE_BUILD_TYPE_DEFAULT		?= Debug
$(RSPLUGIN_PREFIX)_ENABLE_LOG_DEFAULT			?= OFF
$(RSPLUGIN_PREFIX)_DISABLE_LOG_DEFAULT			?= OFF
$(RSPLUGIN_PREFIX)_ENABLE_TRACE_DEFAULT			?= OFF
$(RSPLUGIN_PREFIX)_ENABLE_TESTS_DEFAULT			?= OFF
$(RSPLUGIN_PREFIX)_ENABLE_EXAMPLES_DEFAULT		?= OFF
$(RSPLUGIN_PREFIX)_ENABLE_DOCS_DEFAULT			?= OFF
$(RSPLUGIN_PREFIX)_ENABLE_SSL_DEFAULT			?= OFF
$(RSPLUGIN_PREFIX)_BIN_DIR_DEFAULT				?= bin
$(RSPLUGIN_PREFIX)_TEST_DIR_DEFAULT				?= $(RSPLUGIN_ROOT)/install/test
$(RSPLUGIN_PREFIX)_MOD_DIR_DEFAULT				?= $(RSPLUGIN_ROOT)/modules
$(RSPLUGIN_PREFIX)_DOC_DIR_DEFAULT				?= $(RSPLUGIN_ROOT)/doc
$(RSPLUGIN_PREFIX)_BUILD_DIR_DEFAULT			?= $(RSPLUGIN_ROOT)/build
$(RSPLUGIN_PREFIX)_INSTALL_DIR_DEFAULT			?= $(RSPLUGIN_ROOT)/install
$(RSPLUGIN_PREFIX)_CMAKE_DEFAULT				?= cmake
$(RSPLUGIN_PREFIX)_CMAKE_GENERATOR_DEFAULT 		?= Unix Makefiles
$(RSPLUGIN_PREFIX)_CMAKE_BUILD_JOBS_DEFAULT 	?= 4
$(RSPLUGIN_PREFIX)_ROUTER_VERBOSITY_DEFAULT		?= 5

##############################################################################
# Computed default values for default config vars
##############################################################################
$(RSPLUGIN_PREFIX)_CMAKE_BUILD_ARGS_COMPUTE ?= \
	-j$($(RSPLUGIN_PREFIX)_CMAKE_BUILD_JOBS)

$(RSPLUGIN_PREFIX)_ROUTER_EXEC_COMPUTE ?= \
	$($(RSPLUGIN_PREFIX)_CONNEXTDDS_DIR)/resource/app/bin/$($(RSPLUGIN_PREFIX)_CONNEXTDDS_ARCH_HOST)/rtiroutingservice

$(RSPLUGIN_PREFIX)_ROUTER_BIN_COMPUTE ?= \
	$($(RSPLUGIN_PREFIX)_CONNEXTDDS_DIR)/bin/rtiroutingservice

$(RSPLUGIN_PREFIX)_CMAKE_ARGS_COMPUTE ?= \
	$($(RSPLUGIN_PREFIX)_CMAKE_ARGS_INTERNAL) \
	$($(RSPLUGIN_PREFIX)_CMAKE_ARGS_CUSTOM) \

$(RSPLUGIN_PREFIX)_LD_LIBRARY_PATH_SYS_COMPUTE ?= \
	$(if $(filter OFF,$($(RSPLUGIN_PREFIX)_ENABLE_SSL)),\
	    $($(RSPLUGIN_PREFIX)_CONNEXTDDS_DIR)/lib/$($(RSPLUGIN_PREFIX)_CONNEXTDDS_ARCH),\
		$($(RSPLUGIN_PREFIX)_CONNEXTDDS_DIR)/lib/$($(RSPLUGIN_PREFIX)_CONNEXTDDS_ARCH):$($(RSPLUGIN_PREFIX)_OPENSSLHOME))/lib

$(RSPLUGIN_PREFIX)_LD_LIBRARY_PATH_COMPUTE ?= \
	$($(RSPLUGIN_PREFIX)_LD_LIBRARY_PATH_CUSTOM):$($(RSPLUGIN_PREFIX)_LD_LIBRARY_PATH_SYS):$($(RSPLUGIN_PREFIX)_INSTALL_DIR)/lib:lib

$(RSPLUGIN_PREFIX)_HELPER_DIR_COMPUTE ?= \
	$($(RSPLUGIN_PREFIX)_MOD_DIR)/plugin-helper

$(RSPLUGIN_PREFIX)_CONFIG_EXAMPLE_COMPUTE ?= \
	$($(RSPLUGIN_PREFIX)_HELPER_DIR)/make/config.example.mk

$(RSPLUGIN_PREFIX)_TEST_LOG_COMPUTE ?= \
	$($(RSPLUGIN_PREFIX)_TESTER_PREFIX)test-$(shell date +%Y%m%d-%H%M%S).log

$(RSPLUGIN_PREFIX)_TEST_OUTPUT_FILTER_COMPUTE ?= \
	$(if $($(RSPLUGIN_PREFIX)_TEST_VERBOSE),,1>/dev/null 2>&1)

# $(RSPLUGIN_PREFIX)_TESTER_PREFIX_COMPUTE ?= \
# 	$($(RSPLUGIN_PREFIX)_NAME)_

##############################################################################
# Load user configuration
##############################################################################
CONFIG_MK	?= $(shell pwd)/config.mk

ifeq ($($(RSPLUGIN_PREFIX)_NEEDS_CONFIG),)
-include $(CONFIG_MK)
else
include $(CONFIG_MK)
endif

export CONFIG_MK

##############################################################################
# Assign config vars from user values and defaults
##############################################################################
$(foreach config_var,$($(RSPLUGIN_PREFIX)_CONFIG_VARS),\
    $(if $($(config_var)), \
        $(eval export $(RSPLUGIN_PREFIX)_$(config_var) := $($(config_var))) \
        $(call FN_CONFIG_VAR_SET,CUSTOM,$(RSPLUGIN_PREFIX)_$(config_var)),\
        $(if $($(RSPLUGIN_PREFIX)_$(config_var)_COMPUTE),\
            $(eval export $(RSPLUGIN_PREFIX)_$(config_var) := $(call $(RSPLUGIN_PREFIX)_$(config_var)_COMPUTE)) \
            $(call FN_CONFIG_VAR_SET,COMPUTED,$(RSPLUGIN_PREFIX)_$(config_var)),\
            $(if $($(RSPLUGIN_PREFIX)_$(config_var)_DEFAULT),\
                $(eval export $(RSPLUGIN_PREFIX)_$(config_var) := $($(RSPLUGIN_PREFIX)_$(config_var)_DEFAULT)) \
                $(call FN_CONFIG_VAR_SET,DEFAULT,$(RSPLUGIN_PREFIX)_$(config_var)),\
                $(if $($(RSPLUGIN_PREFIX)_$(config_var)), \
                    $(eval export $(RSPLUGIN_PREFIX)_$(config_var)) \
                    $(call FN_CONFIG_VAR_SET,PRESET,$(RSPLUGIN_PREFIX)_$(config_var)),\
                    $(call FN_CONFIG_VAR_SET,NONE,$(RSPLUGIN_PREFIX)_$(config_var)))))));

##############################################################################
# Check that required config vars are non-empty
##############################################################################
$(foreach config_var,$($(RSPLUGIN_PREFIX)_CONFIG_VARS), \
    $(if $(filter $(config_var),$($(RSPLUGIN_PREFIX)_CONFIG_VARS_REQUIRED)),\
        $(if $($(RSPLUGIN_PREFIX)_$(config_var)), \
            ,\
            $(error Found EMPTY required var $(RSPLUGIN_PREFIX)_$(config_var))),\
        ))

##############################################################################
# Print out config vars
##############################################################################
# ifneq ($($(RSPLUGIN_PREFIX)_VERBOSE),)
# $(foreach config_var,$($(RSPLUGIN_PREFIX)_CONFIG_VARS), \
#     $(info $(RSPLUGIN_PREFIX)_$(config_var) = $($(RSPLUGIN_PREFIX)_$(config_var))));
# endif

##############################################################################
# Export config vars so they are available to all subshells
##############################################################################
# export $($(RSPLUGIN_PREFIX)_CONFIG_VARS)
# $(foreach config_var,$($(RSPLUGIN_PREFIX)_CONFIG_VARS), \
#     $(eval export $(RSPLUGIN_PREFIX)_$(config_var) = $($(RSPLUGIN_PREFIX)_$(config_var))));

export LD_LIBRARY_PATH := $($(RSPLUGIN_PREFIX)_LD_LIBRARY_PATH)
