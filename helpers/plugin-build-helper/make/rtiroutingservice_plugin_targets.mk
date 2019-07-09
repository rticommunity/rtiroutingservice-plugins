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

##############################################################################
# Declare phony targets
##############################################################################
.PHONY: $($(RSPLUGIN_PREFIX)_TARGETS)

ifneq ($(call FN_TARGET_ENABLED,all),)
##############################################################################
# Default makefile target
##############################################################################
all: $(call FN_TARGET_ENABLED,setup)
else
$(call FN_TARGET_DISABLED,all)
endif

##############################################################################
# Target to create a directory
##############################################################################
%.dir:
	mkdir -p $*

ifneq ($(call FN_TARGET_ENABLED,setup),)
##############################################################################
# Target to configure and perform build
##############################################################################
setup: $(call FN_TARGET_ENABLED,configure)\
       $(call FN_TARGET_ENABLED,install)
else
$(call FN_TARGET_DISABLED,setup)
endif

ifneq ($(call FN_TARGET_ENABLED,configure),)
##############################################################################
# Target to configure build
##############################################################################
configure: $($(RSPLUGIN_PREFIX)_BUILD_DIR).dir
	LD_LIBRARY_PATH="" \
	$($(RSPLUGIN_PREFIX)_CMAKE) \
	         -B$($(RSPLUGIN_PREFIX)_BUILD_DIR) \
	         -H. \
	         -G "$($(RSPLUGIN_PREFIX)_CMAKE_GENERATOR)" \
	         -DCMAKE_BUILD_TYPE=$($(RSPLUGIN_PREFIX)_CMAKE_BUILD_TYPE) \
	         -DCMAKE_INSTALL_PREFIX=$($(RSPLUGIN_PREFIX)_INSTALL_DIR) \
	         -DCONNEXTDDS_ARCH=$($(RSPLUGIN_PREFIX)_CONNEXTDDS_ARCH) \
	         -DCONNEXTDDS_DIR="$($(RSPLUGIN_PREFIX)_CONNEXTDDS_DIR)" \
	         -DOPENSSLHOME="$($(RSPLUGIN_PREFIX)_OPENSSLHOME)" \
	         $(foreach config_var,$($(RSPLUGIN_PREFIX)_CONFIG_VARS),\
	             $(if $($(RSPLUGIN_PREFIX)_$(config_var)),\
	                 -D$(config_var)="$($(RSPLUGIN_PREFIX)_$(config_var))",\
	                 )) \
	         $($(RSPLUGIN_PREFIX)_CMAKE_ARGS)
else
$(call FN_TARGET_DISABLED,configure)
endif

ifneq ($(call FN_TARGET_ENABLED,build),)
##############################################################################
# Target to perform build
##############################################################################
build: $($(RSPLUGIN_PREFIX)_BUILD_DIR).dir
	LD_LIBRARY_PATH="" \
	$($(RSPLUGIN_PREFIX)_CMAKE) \
	        --build $($(RSPLUGIN_PREFIX)_BUILD_DIR) -- \
	        $($(RSPLUGIN_PREFIX)_CMAKE_BUILD_ARGS) \
	        install
else
$(call FN_TARGET_DISABLED,build)
endif

ifneq ($(call FN_TARGET_ENABLED,install),)
##############################################################################
# Target to perform installation
##############################################################################
install: $(call FN_TARGET_ENABLED,build)
else
$(call FN_TARGET_DISABLED,install)
endif

ifneq ($(call FN_TARGET_ENABLED,clean),)
##############################################################################
# Target to clean build
##############################################################################
clean: $($(RSPLUGIN_PREFIX)_BUILD_DIR).dir
	LD_LIBRARY_PATH="" \
	$($(RSPLUGIN_PREFIX)_CMAKE) --build $($(RSPLUGIN_PREFIX)_BUILD_DIR) -- clean
else
$(call FN_TARGET_DISABLED,clean)
endif

ifneq ($(call FN_TARGET_ENABLED,clean-all),)
##############################################################################
# Target to clean repository
##############################################################################
clean-all: $(foreach module,$($(RSPLUGIN_PREFIX)_MODULES),\
               $(module).module-clean-all) \
           clean-docs
	rm -rf $($(RSPLUGIN_PREFIX)_BUILD_DIR) $($(RSPLUGIN_PREFIX)_INSTALL_DIR)

##############################################################################
# Targets to clean submodules
##############################################################################
%.module-clean-all:
	@printf "CLEANING ALL MODULE: %s\n" "$*"
	$(call FN_MAKE_MODULE,$*,clean-all)
else
$(call FN_TARGET_DISABLED,clean-all)
$(call FN_TARGET_DISABLED,%.module-clean-all)
endif

ifneq ($(call FN_TARGET_ENABLED,clean-docs),)
##############################################################################
# Target to clean repository documentation
##############################################################################
clean-docs: $(foreach module,$($(RSPLUGIN_PREFIX)_MODULES),\
                $(module).module-clean-docs)
	 find . -name __pycache__ -o -name doxyoutput -exec rm -rf {} \;


# [ ! -d "$($(RSPLUGIN_PREFIX)_DOC_DIR)" ] || \
#     (cd "$($(RSPLUGIN_PREFIX)_DOC_DIR)" && \
#       rm -rf __pycache__ _build extlinks.pyc api doxyoutput)
##############################################################################
# Targets to clean documentation in submodules
##############################################################################
%.module-clean-docs:
	@printf "CLEANING DOCS MODULE: %s\n" "$*"
	$(call FN_MAKE_MODULE,$*,clean-docs)
else
$(call FN_TARGET_DISABLED,clean-docs)
$(call FN_TARGET_DISABLED,%.module-clean-docs)
endif

ifneq ($(call FN_TARGET_ENABLED,docs),)
##############################################################################
# Target to generate repository documentation
##############################################################################
docs:
	LD_LIBRARY_PATH="" \
	$($(RSPLUGIN_PREFIX)_CMAKE) --build $($(RSPLUGIN_PREFIX)_BUILD_DIR) -- docs
else
$(call FN_TARGET_DISABLED,docs)
endif

ifneq ($(call FN_TARGET_ENABLED,update),)
##############################################################################
# Target to update repository
##############################################################################
update: $(foreach module,$($(RSPLUGIN_PREFIX)_MODULES_ALL),\
            $(module).module-update) \
	git pull --recurse-submodule
	git submodule update --recursive
##############################################################################
# Targets to update submodules
##############################################################################
%.module-update:
	@printf "UPDATING MODULE: %s\n" "$*"
	$(call FN_MAKE_MODULE,$*,update)
else
$(call FN_TARGET_DISABLED,update)
$(call FN_TARGET_DISABLED,%.module-update)
endif

ifneq ($(call FN_TARGET_ENABLED,commit-helper),)
##############################################################################
# Targets to commit changes in plugin-helper submodule and to update it in
# all other submodules.
##############################################################################
HELPER_COMMIT_MSG ?= Automatic commit of plugin-helper
commit-helper:
	(cd "$($(RSPLUGIN_PREFIX)_MOD_DIR)/plugin-helper" && \
	    git add -A && \
	    git commit -m "$(HELPER_COMMIT_MSG)" && \
	    git push)
	for d in $($(RSPLUGIN_PREFIX)_MODULES); do \
   	    (cd $($(RSPLUGIN_PREFIX)_MOD_DIR)/$${d}/modules/plugin-helper && \
            git pull && \
            cd ../.. && \
            git add modules/plugin-helper && \
            git commit -m "$(HELPER_COMMIT_MSG)" && \
            git push) || \
        printf "Something went wrong updating helper for module: %s\n" \
	           "$${d}"; \
	done
	git add "$($(RSPLUGIN_PREFIX)_MOD_DIR)/"*
	git commit -m "$(HELPER_COMMIT_MSG) (updated submodules)"
	git push
else
$(call FN_TARGET_DISABLED,commit-helper)
endif


ifneq ($(call FN_TARGET_ENABLED,commit-modules),)
##############################################################################
# Targets to commit changes to all submodules and updated them to the new 
# revisions
##############################################################################
MODULES_COMMIT_MSG ?= Automatic commit from $($(RSPLUGIN_PREFIX)_NAME)
commit-modules:
	for d in $($(RSPLUGIN_PREFIX)_MODULES); do \
   	    (cd $($(RSPLUGIN_PREFIX)_MOD_DIR)/$${d} && \
            git commit -a -m "$(MODULES_COMMIT_MSG)" && \
            git push) || \
        (printf "Something went wrong commit changes for module: %s\n" \
	           "$${d}" && exit 1); \
	done
	git add "$($(RSPLUGIN_PREFIX)_MOD_DIR)/"*
	git commit -m "$(MODULES_COMMIT_MSG) (updated submodules)"
	git push
else
$(call FN_TARGET_DISABLED,commit-helper)
endif

ifneq ($(call FN_TARGET_ENABLED,init-config),)
##############################################################################
# Targets to generate a user configuration file
##############################################################################
init-config:
	cp -i $($(RSPLUGIN_PREFIX)_CONFIG_EXAMPLE) config.mk
else
$(call FN_TARGET_DISABLED,init-config)
endif

ifneq ($(call FN_TARGET_ENABLED,init-gitignore),)
##############################################################################
# Targets to generate a gitignore file
##############################################################################
init-gitignore:
	cp -i $($(RSPLUGIN_PREFIX)_GITIGNORE_EXAMPLE) .gitignore
else
$(call FN_TARGET_DISABLED,init-gitignore)
endif

ifneq ($(call FN_TARGET_ENABLED,init-module),)
##############################################################################
# Targets to add a submodule
##############################################################################
init-module:
	[ -z "$(MODULE_URL)" ] && \
	    printf "no MODULE_URL specified\n" && \
		exit 1 || [ -n "$(MODULE_URL)" ]
	[ -z "$(MODULE_NAME)" ] && \
	    printf "no MODULE_NAME specified\n" && \
		exit 1 || [ -n "$(MODULE_NAME)" ]
	git submodule add "$(MODULE_URL)" \
	                  "$($(RSPLUGIN_PREFIX)_MOD_DIR)/$(MODULE_NAME)"
else
$(call FN_TARGET_DISABLED,init-module)
endif

ifneq ($(call FN_TARGET_ENABLED,init-repo),)
##############################################################################
# Targets to initialize the repository
##############################################################################
init-repo: $(call FN_TARGET_ENABLED,init-config) \
           $(call FN_TARGET_ENABLED,init-gitignore)
else
$(call FN_TARGET_DISABLED,init-repo)
endif

ifneq ($(call FN_TARGET_ENABLED,router),)
##############################################################################
# Targets to run routing service
##############################################################################
router:
	cd $($(RSPLUGIN_PREFIX)_INSTALL_DIR) && \
	$($(RSPLUGIN_PREFIX)_ROUTER_BIN) \
	              	    -verbosity $($(RSPLUGIN_PREFIX)_ROUTER_VERBOSITY) \
	                    -cfgFile $($(RSPLUGIN_PREFIX)_ROUTER_FILE) \
	                    -cfgName $($(RSPLUGIN_PREFIX)_ROUTER_NAME) \
                        $($(RSPLUGIN_PREFIX)_ROUTER_ARGS)
else
$(call FN_TARGET_DISABLED,router)
endif

ifneq ($(call FN_TARGET_ENABLED,router-valgrind),)
##############################################################################
# Targets to run routing service with valgring
##############################################################################
router-valgrind:
	cd $($(RSPLUGIN_PREFIX)_INSTALL_DIR) && \
	valgrind $($(RSPLUGIN_PREFIX)_VALGRIND_ARGS) \
	  $($(RSPLUGIN_PREFIX)_ROUTER_EXEC) \
	              	    -verbosity $($(RSPLUGIN_PREFIX)_ROUTER_VERBOSITY) \
	                    -cfgFile $($(RSPLUGIN_PREFIX)_ROUTER_FILE) \
	                    -cfgName $($(RSPLUGIN_PREFIX)_ROUTER_NAME) \
                        $($(RSPLUGIN_PREFIX)_ROUTER_ARGS)
else
$(call FN_TARGET_DISABLED,router-valgrind)
endif

ifneq ($(call FN_TARGET_ENABLED,router-gdb),)
##############################################################################
# Targets to run routing service with gdb
##############################################################################
router-gdb:
	cd $($(RSPLUGIN_PREFIX)_INSTALL_DIR) && \
	gdb $($(RSPLUGIN_PREFIX)_GDB_ARGS) --args \
	  $($(RSPLUGIN_PREFIX)_ROUTER_EXEC) \
	              	    -verbosity $($(RSPLUGIN_PREFIX)_ROUTER_VERBOSITY) \
	                    -cfgFile $($(RSPLUGIN_PREFIX)_ROUTER_FILE) \
	                    -cfgName $($(RSPLUGIN_PREFIX)_ROUTER_NAME) \
                        $($(RSPLUGIN_PREFIX)_ROUTER_ARGS)
else
$(call FN_TARGET_DISABLED,router-gdb)
endif



ifneq ($(call FN_TARGET_ENABLED,test),)
##############################################################################
# Targets to build repository and run test executables directly
##############################################################################
test: $(call FN_TARGET_ENABLED,setup) \
      $(call FN_TARGET_ENABLED,test-run)
else
$(call FN_TARGET_DISABLED,test)
endif

ifneq ($(call FN_TARGET_ENABLED,test-run),)
##############################################################################
# Targets to run test executables directly
##############################################################################
TEST_LINE := -------------------------------------------------------------------------------
test-run:
	@([ -z "$($(RSPLUGIN_PREFIX)_TESTER_PREFIX)" ] && \
		printf "ERROR: please set TESTER_PREFIX to run tests with this target\n" && \
		exit 1 || \
		printf "%s\n" "$(TEST_LINE)" && \
		printf "Running tests with prefix '%s' from directory '%s'\n" \
		       "$($(RSPLUGIN_PREFIX)_TESTER_PREFIX)" \
			   "$($(RSPLUGIN_PREFIX)_TEST_DIR)" && \
		([ -n "$($(RSPLUGIN_PREFIX)_TEST_OUTPUT_FILTER)" -a \
		   -z "$($(RSPLUGIN_PREFIX)_TEST_VERBOSE)" ] && \
		    printf "Use TEST_VERBOSE=y to display test output.\n" || \
			printf "" )) && \
	unset tester_prefix && \
	[ -z "$($(RSPLUGIN_PREFIX)_TEST_VALGRIND)" ] || \
		export tester_prefix="valgrind $($(RSPLUGIN_PREFIX)_VALGRIND_ARGS)" && \
	printf "" > $($(RSPLUGIN_PREFIX)_TEST_LOG) && \
	for tester in $$(find $($(RSPLUGIN_PREFIX)_TEST_DIR) \
	                      -name "$($(RSPLUGIN_PREFIX)_TESTER_PREFIX)*"); do \
		export tester_cmd="$${tester_prefix} $${tester}" && \
		printf "%s\n" "$(TEST_LINE)" && \
	    printf " Run test: %s\n" "$${tester_cmd}" && \
		printf "%s\n" "$(TEST_LINE)" $($(RSPLUGIN_PREFIX)_TEST_OUTPUT_FILTER) && \
		unset tester_failed= && \
	    if eval "$${tester_cmd}" $($(RSPLUGIN_PREFIX)_TEST_OUTPUT_FILTER); then \
	        res="    PASSED    "; \
			res_dot="*"; \
	    else \
			[ -n "$($(RSPLUGIN_PREFIX)_TEST_IGNORE_ERRORS)" ] || export tester_failed=y; \
	        res="xxx FAILED xxx"; \
			res_dot="x"; \
	    fi && \
	    printf " %s %-60s %s\n" \
		       "$${res_dot}" \
			   "$$(basename $${tester})" \
			   "$${res}" >> $($(RSPLUGIN_PREFIX)_TEST_LOG); \
		[ -z "$${tester_failed}" ] || exit 1; \
	done && \
	printf "%s\n" "$(TEST_LINE)" && \
	printf " %s\n" "Summary:" && \
	printf "%s\n" "$(TEST_LINE)" && \
	cat $($(RSPLUGIN_PREFIX)_TEST_LOG) && \
	printf "%s\n" "$(TEST_LINE)" && \
	rm $($(RSPLUGIN_PREFIX)_TEST_LOG)
else
$(call FN_TARGET_DISABLED,test-run)
endif


ifneq ($(call FN_TARGET_ENABLED,ctest),)
##############################################################################
# Targets to build repository and run tests with ctest
##############################################################################
ctest: $(call FN_TARGET_ENABLED,setup) \
       $(call FN_TARGET_ENABLED,ctest-run)
else
$(call FN_TARGET_DISABLED,ctest)
endif

ifneq ($(call FN_TARGET_ENABLED,ctest-run),)
##############################################################################
# Targets to run tests with ctest
##############################################################################
ifneq ($($(RSPLUGIN_PREFIX)_TEST_VERBOSE),)
ctest-run:
	cd $($(RSPLUGIN_PREFIX)_BUILD_DIR) && ctest
else
ctest-run:
	cd $($(RSPLUGIN_PREFIX)_BUILD_DIR) && ctest -V
endif
else
$(call FN_TARGET_DISABLED,ctest-run)
endif
