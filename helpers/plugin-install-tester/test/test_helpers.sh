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

test_get_repo_var()
{
    repo_pfx=${1}
    repo_var=${2}

    eval "echo \${${repo_pfx}_${2}}"
}

test_get_repo_clone_dir()
{
    test_get_repo_var ${1} CLONE_DIR
}

test_get_repo_url()
{
    test_get_repo_var ${1} URL
}

test_get_repo_branch()
{
    test_get_repo_var ${1} BRANCH
}

test_get_repo_deps()
{
    test_get_repo_var ${1} DEPS
}

test_get_repo_install_dir()
{
    repo_pfx=${1}
    repo_dir="$(test_get_repo_clone_dir ${repo_pfx})"

    if [ -n "${TEST_MAKE}" ]; then
        printf "%s" "${TEST_ROOT}/${repo_dir}/install"
    else
        printf "%s" "${TEST_ROOT}/${repo_dir}-${TEST_CMAKE_INSTALL_DIR}"
    fi
}

test_get_repo_build_dir()
{
    repo_pfx=${1}
    repo_dir="$(test_get_repo_clone_dir ${repo_pfx})"

    if [ -n "${TEST_MAKE}" ]; then
        printf "%s" "${TEST_ROOT}/${repo_dir}/build"
    else
        printf "%s" "${TEST_ROOT}/${repo_dir}-${TEST_CMAKE_BUILD_DIR}"
    fi
}

test_error_msg()
{
    printf "ERROR: %s\n" "${@}" >&2
    exit 1
}

set_test_env()
{
    if [ ! -d "${CONNEXTDDS_DIR}" -o -z "${CONNEXTDDS_ARCH}" ]; then
        test_error_msg "Please set CONNEXTDDS_DIR and CONNEXTDDS_ARCH"
    fi

    if [ -n "${TEST_SSL}" -a ! -d "${OPENSSLHOME}" ]; then
        test_error_msg "Please set OPENSSLHOME"
    fi

    MAKE_BIN=$(which make)
    CMAKE_BIN=$(which cmake)
    GIT_BIN=$(which git)

    if [ -n "${TEST_MAKE}" -a ! -x "${MAKE_BIN}" ]; then
        test_error_msg "make not found in PATH"
    fi
    if [ ! -x "${CMAKE_BIN}" ]; then
        test_error_msg "cmake not found in PATH"
    fi
    if [ -z "${TEST_CMAKE_SKIP_INSTALL}" ]; then
        TEST_CMAKE_BUILD_ARGS="${TEST_CMAKE_BUILD_ARGS} install"
    fi
}

test_get_make_args()
{
    plugin_pfx=${1}

    printf -- "CMAKE_ARGS='%s' CMAKE_BUILD_TYPE='%s'" \
            "$(test_get_cmake_args ${plugin_pfx})" \
            "${TEST_CMAKE_BUILD_TYPE}"
}
test_get_cmake_args()
{
    plugin_pfx=${1}

    if [ -n "${TEST_SSL}" ]; then
        printf -- " -DENABLE_SSL=ON -DOPENSSLHOME=%s" "${OPENSSLHOME}"
    fi

    if [ -n "${TEST_TESTS}" ]; then
        printf -- " -DENABLE_TESTS=ON"
    fi

    if [ -n "${TEST_DOCS}" ]; then
        printf -- " -DENABLE_DOCS=ON"
    fi

    if [ -n "${TEST_EXAMPLES}" ]; then
        printf -- " -DENABLE_EXAMPLES=ON"
    fi

    plugin_deps="$(test_get_repo_deps ${plugin_pfx})"
    for p_dep in ${plugin_deps}; do
        p_dep_dir="$(test_get_repo_clone_dir ${p_dep})"
        printf -- " -D${p_dep}_DIR=${TEST_ROOT}/${p_dep_dir}"
    done
}

test_plugin_repo()
{
    plugin_pfx=${1}
    plugin_mode=${2:-clone_and_build}
    plugin_url="$(test_get_repo_url ${plugin_pfx})"
    plugin_branch="$(test_get_repo_branch ${plugin_pfx})"
    plugin_dir="$(test_get_repo_clone_dir ${plugin_pfx})"
    plugin_deps="$(test_get_repo_deps ${plugin_pfx})"

    case "${plugin_mode}" in
    clone_and_build)
        printf "TESTING Repository %s [%s]...\n" "${plugin_dir}" "${plugin_url}"
        ;;
    *)
        printf "CLONING Repository %s [%s]...\n" "${plugin_dir}" "${plugin_url}"
        ;;
    esac

    for p_dep in ${plugin_deps}; do
        (test_plugin_repo ${p_dep} clone_only) || exit $?
    done

    plugin_clone_dir="${TEST_ROOT}/${plugin_dir}"
    plugin_build_dir="$(test_get_repo_build_dir ${plugin_pfx})"
    plugin_install_dir="$(test_get_repo_install_dir ${plugin_pfx})"

    if [ "${plugin_mode}" != "clone_and_build" -a \
         -d "${plugin_clone_dir}" ]; then
        printf "ALREADY CLONED %s\n" "${plugin_dir}"
        exit 0
    fi

    (
        git clone --recurse-submodules -b ${plugin_branch} \
                                          ${plugin_url} \
                                          "${plugin_clone_dir}"  || exit $?

        if [ "${plugin_mode}" != "clone_and_build" ]; then
            printf "CLONED %s\n" "${plugin_dir}"
            exit 0
        fi

        set +x
        if [ -n "${TEST_MAKE}" ]; then
            printf "BUILDING %s with Make (args: %s)\n" \
                   "${plugin_dir}" "$(test_get_make_args ${plugin_pfx})"
            ${MAKE_BIN} -C "${plugin_clone_dir}" \
                        $(test_get_make_args ${plugin_pfx}) \
                        ${TEST_MAKE_TGT_BUILD} || exit $?
        else
            printf "CONFIGURING %s with CMake (args: %s)\n" \
                   "${plugin_dir}" "$(test_get_cmake_args ${plugin_pfx})"
            mkdir "${plugin_build_dir}"
            ${CMAKE_BIN} -H"${plugin_clone_dir}" \
                        -B"${plugin_build_dir}" \
                        -DCMAKE_INSTALL_PREFIX="${plugin_install_dir}" \
                        -DCMAKE_BUILD_TYPE="${TEST_CMAKE_BUILD_TYPE}" \
                        -DCONNEXTDDS_ARCH=${CONNEXTDDS_ARCH} \
                        -DCONNEXTDDS_DIR="${CONNEXTDDS_DIR}" \
                        $(test_get_cmake_args ${plugin_pfx}) || exit $?
            printf "BUILDING %s with CMake (dir: %s)\n" \
                   "${plugin_dir}" "${plugin_build_dir}"
            ${CMAKE_BIN} --build "${plugin_build_dir}" -- \
                    ${TEST_CMAKE_BUILD_ARGS} || exit $?
        fi
        set -x
    ) >> ${TEST_LOG} 2>&1
    test_plugin_rc=$?

    if [ "${plugin_mode}" != "clone_and_build" ]; then
        exit ${test_plugin_rc}
    fi

    if [ -z "${KEEP}" ]; then
        rm -rf "${plugin_build_dir}"
        rm -rf "${plugin_install_dir}"
        rm -rf "${plugin_clone_dir}"

        for p_dep in ${plugin_deps}; do
            p_dep_dir="$(test_get_repo_clone_dir ${p_dep})"
            rm -rf "${TEST_ROOT}/${p_dep_dir}"
        done
    fi

    if [ ${test_plugin_rc} -ne 0 ]; then
        printf "TEST %s FAILED (%d)\n" \
               "${plugin_dir}" "${test_plugin_rc}"
    else
        printf "TEST %s OK\n" "${plugin_dir}"
    fi

    exit ${test_plugin_rc}
}

test_ended()
{
    log_rc="${1}"

    if [ ${log_rc} -ne 2 ]; then
        log_file="$(basename "${TEST_LOG}")"
        cp ${TEST_LOG} "${log_file}"
        printf "LOG FILE: %s\n" "${log_file}"
    fi

    if [ -z "${KEEP}" ]; then
        rm -rf ${TEST_ROOT}
    fi

    if [ -n "${VERBOSE_TAIL_PID}" ]; then
        kill ${VERBOSE_TAIL_PID}
        wait ${VERBOSE_TAIL_PID}
    fi

    exit ${log_rc}
}

test_failed()
{
    printf "TEST FAILED\n"
    test_ended 1
}

test_ok()
{
    printf "TEST PASSED\n"
    test_ended 0
}
test_interrupted()
{
    printf "\nTEST INTERRUPTED\n"
    test_ended 2
}

test_init()
{
    if [ -z "${CONNEXTDDS_DIR}" -o ! -d "${CONNEXTDDS_DIR}" ]; then
        printf "ERROR: invalid CONNEXTDDS_DIR [%s]\n" "${CONNEXTDDS_DIR}" >&2
        exit 1
    fi

    if [ -z "${CONNEXTDDS_ARCH}" -o ! -d "${CONNEXTDDS_DIR}/lib/${CONNEXTDDS_ARCH}" ]; then
        printf "ERROR: invalid CONNEXTDDS_ARCH or libraries not found in %s\n" "${CONNEXTDDS_DIR}/lib" >&2
        exit 1
    fi

    if [ -n "${TEST_SSL}" ] &&
       [ -z "${OPENSSLHOME}" -o \
         ! -d "${OPENSSLHOME}/lib" -o \
         ! -d "${OPENSSLHOME}/include" ]; then
        printf "ERROR: invalid OPENSSLHOME [${OPENSSLHOME}]\n" >&2
        exit 1
    fi

    rm -rf "${TEST_ROOT}"
    trap test_interrupted INT
    mkdir -p "$(dirname ${TEST_LOG})"
    if [ -n "${VERBOSE}" ]; then
        touch "${TEST_LOG}"
        tail -f "${TEST_LOG}" &
        VERBOSE_TAIL_PID=$!
    fi
    set_test_env
}

test_perform()
{
    ( ${1} ) && test_ok || test_failed
}