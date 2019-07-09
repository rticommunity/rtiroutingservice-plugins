
###############################################################################
# CMake project declarations
###############################################################################
project(rtiroutingservice-transform-doc C)
cmake_minimum_required(VERSION 3.7.0)

include(${RSHELPER_DIR}/cmake/rtiroutingservice_plugin.cmake)

set(RSPLUGIN_DOC_SOURCES    configuration.rst
                            copyright.rst
                            extlinks.py
                            introduction.rst
                            installation.rst
                            building.rst
                            release_notes.rst
                            modules.rst
                            vars.rst)

configure_doc_dir()
