.. include:: vars.rst

.. _section-build:

********************
Building from source
********************

Since |RSTSFM| is distributed in source format, it must be compiled into a
shared library before it can be used by |RS|.

The code can be built using |CMAKE|, version 3.7.0 or greater.

.. _section-build-env:

Build Setup
===========

|RTI_CONNEXT| (version |CONNEXT_VERSION_MIN| or greater) must be available
on the build system. The installation must include libraries for the
target build architecture, and ``rtiddsgen``.

.. note:: The location where |RTI_CONNEXT| is installed will be referred to
          as ``CONNEXTDDS_DIR``, while the target build architecture will
          be ``CONNEXTDDS_ARCH``.

Compiling with |CMAKE|
======================

Configuration
-------------

Create a build directory and run ``cmake`` to create build files for the
build system of your preference.

At a minimum, you will need to specify ``CONNEXTDDS_DIR``, and
``CONNEXTDDS_ARCH`` to select an |RTI_CONNEXT| installation, and provide a
label for the selected target build architecture, along with
``CMAKE_BUILD_TYPE``, to select the type of library to build (either
``Release``, or ``Debug``).

.. note:: The example uses architecture ``x64Linux3gcc5.4.0``, which is
          suitable for 64-bit Linux system. Change this value according to
          your system configuration.

.. code-block:: sh

    # The build directory can be created inside the git clone
    # (it is ignored via .gitignore)
    mkdir rtiroutingservice-adapter-mqtt/build/
    cd rtiroutingservice-adapter-mqtt/build/

    # CONNEXTDDS_DIR and CONNEXTDDS_ARCH will be read from the
    # shell environment if not passed explicitly to cmake
    cmake .. -DCONNEXTDDS_DIR=/path/to/rti_connext_dds/ \
             -DCONNEXTDDS_ARCH=x64Linux3gcc5.4.0        \
             -DCMAKE_BUILD_TYPE=Release

If supported by the ``CMAKE_GENERATOR`` of your choice, it is recommended to
specify an installation location using ``CMAKE_INSTALL_PREFIX``:

.. code-block:: sh

    # dist/ is also ignored via .gitignore
    cmake .. -DCONNEXTDDS_DIR=/path/to/rti_connext_dds/ \
             -DCONNEXTDDS_ARCH=x64Linux3gcc5.4.0        \
             -DCMAKE_BUILD_TYPE=Release                 \
             -DENABLE_SSL=ON                            \
             -DOPENSSLHOME=/path/to/openssl             \
             -DCMAKE_INSTALL_PREFIX=../dist

When the ``install`` target is later built, all libraries, header files, and
other generated resources will be copied in simpler directory structure
within the specified location. The directory can be copied and deployed 
independently of the source and build directories.

Compilation
-----------

Once the project has been configured, build libraries using the selected
toolchain:

.. code-block:: sh

    # Replace BUILD_DIR with the location of your build directory.
    cmake --build BUILD_DIR


Installation
------------

It is recommended that you also run the ``install`` target (assuming that you
customized ``CMAKE_INSTALL_PREFIX`` during configuration):

.. code-block:: sh

    # Pass install to the "native" builder (this will work when
    # building with make and ninja).
    # Replace BUILD_DIR with the location of your build directory.
    cmake --build BUILD_DIR -- install

CMake Options
-------------

This section summarizes all available |CMAKE| options and configuration
variables.

CONNEXTDDS_DIR
^^^^^^^^^^^^^^

:Required: Yes
:Default: None
:Description: The installation location of |RTI_CONNEXT| must be specified
              using this variable.

CONNEXTDDS_ARCH
^^^^^^^^^^^^^^^

:Required: Yes
:Default: None
:Description: The identifier for the target build architecture must be
              specified using this variables. Required |RTI_CONNEXT| libraries
              must be available within path
              ``CONNEXTDDS_DIR/lib/CONNEXTDDS_ARCH``.

ENABLE_LOG
^^^^^^^^^^

:Required: No
:Default: ``OFF`` (for ``Release``), ``ON`` (for ``Debug``)
:Description: By default, |RSTSFM| will not print any messages to standard
              output when built in ``Release`` mode. When built in ``Debug``
              mode, or if ``ENABLE_LOG`` is enabled, |RSTSFM| will print
              informational and error messages to standard output. These
              messages cannot be disabled at run-time.

ENABLE_TRACE
^^^^^^^^^^^^

:Required: No
:Default: ``OFF``
:Description: If enabled, this option will cause |RSTSFM| to produce a much
              more verbose logging output, which can be used to trace all
              function calls within the adapter code.

DISABLE_LOG
^^^^^^^^^^^

:Required: No
:Default: ``OFF``
:Description: If enabled, this option will disable logging for ``Debug``
              libraries. Option ``ENABLE_LOG`` takes precedence if set
              explicitly.

ENABLE_TESTS
^^^^^^^^^^^^

:Required: No
:Default: ``OFF``
:Description: |RSTSFM| comes with a test suite which can be optionally enabled
              and built. If enabled, the :link_cmocka:`cmocka <>` framework
              will also be configured and built.

ENABLE_DOCS
^^^^^^^^^^^

:Required: No
:Default: ``OFF``
:Description: If you want to build |RSTSFM|'s documentation (i.e. these
              documents that you are reading), make sure to have Sphinx,
              Breathe, and Doxygen installed.

