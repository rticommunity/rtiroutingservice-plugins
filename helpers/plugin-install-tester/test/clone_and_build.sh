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

SH_DIR=$(cd "$(dirname "${0}")" && pwd)
TEST_CONFIG="${SH_DIR}/test_config.sh"
. ${TEST_CONFIG}

clone_and_build_test()
{
    printf "TESTING REPOSITORIES: %s\n" "${TEST_TARGETS}"

    for plugin in ${TEST_TARGETS}; do
        (test_plugin_repo ${plugin}) || exit $?
    done
}

test_perform clone_and_build_test
