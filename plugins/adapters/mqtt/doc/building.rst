.. include:: vars.rst

.. _section-build:

********************
Building from source
********************

Since |RSMQTT| is distributed in source format, it must be compiled into a
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

|OPENSSL| must be available on the build system, if support for SSL/TLS is 
required.

.. note:: The location where |OPENSSL| is installed will be referred to as
          ``OPENSSLHOME``. This directory must contain header files in an
          ``include/`` subdirectory, and libraries in a ``lib/`` subdirectory.

Compiling with |CMAKE|
======================

Configuration
-------------

Create a build directory and run ``cmake`` to create build files for the
build system of your preference.

At a minimum, you will need to specify:

  - ``CONNEXTDDS_DIR``, to select an |RTI_CONNEXT| installation.
  - ``CONNEXTDDS_ARCH``, to provide a label for the target build architecture.
  - ``OPENSSLHOME``, to select an |OPENSSL| installation.
  
Optionally, you can use ``CMAKE_BUILD_TYPE`` to select the type of libraries to
build (either ``Release``, or ``Debug``, default: ``Debug``).

It is also recommended (albeit not required) that you also change the value of
variable ``CMAKE_PREFIX_INSTALL``, to specify a custom installation directory
where all build artefacts will be copied after building. This directory can be
copied, and deployed independently of the source and build directories.

.. note:: The example uses architecture ``x64Linux3gcc5.4.0``, which is
          suitable for 64-bit Linux system. Change this value according to
          your system configuration and your |RTI_CONNEXT| installation.

.. code-block:: sh

    # The build/ and install/ directories can be created inside the git clone
    # (they are ignored via .gitignore)
    mkdir rtiroutingservice-adapter-mqtt/build \
          rtiroutingservice-adapter-mqtt/install

    cd rtiroutingservice-adapter-mqtt/build/

    # CONNEXTDDS_DIR and CONNEXTDDS_ARCH will be read from the
    # shell environment if not passed explicitly to cmake
    cmake .. -DCONNEXTDDS_DIR=/path/to/rti_connext_dds/ \
             -DCONNEXTDDS_ARCH=x64Linux3gcc5.4.0        \
             -DOPENSSLHOME=/path/to/openssl             \
             -DCMAKE_BUILD_TYPE=Release                 \
             -DCMAKE_INSTALL_PREFIX=../install


If you do not with to include SSL/TLS support (e.g. if |OPENSSL| is not
available for the target build architecture), you can disable it by disabling
option ``ENABLE_SSL`` (e.g. by passing ``-DENABLE_SSL=OFF`` to ``cmake``).

Compilation
-----------

Once the project has been configured, libraries can be built using the selected
toolchain, e.g.:

.. code-block:: sh

    # Replace BUILD_DIR with the location of your build directory.
    cmake --build BUILD_DIR


Installation
------------

It is recommended that you also run the ``install``, e.g.:

.. code-block:: sh

    # Pass install to the "native" builder (this will work e.g. when
    # using make or ninja to build the project).
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

OPENSSLHOME
^^^^^^^^^^^

:Required: Yes (only if ``ENABLE_SSL`` is also enabled)
:Default: None
:Description: If SSL/TLS support is enabled, |OPENSSL| must be provided using
              this variable to specify a location containing an ``include/``,
              and a ``lib/`` subdirectories, containing |OPENSSL| header files
              and libraries respectively.

ENABLE_SSL
^^^^^^^^^^

:Required: No
:Default: ON
:Description: When this option is enabled, SSL/TLS support will be compiled in
              |RSMQTT|, and |PAHO_ASYNC|. ``OPENSSLHOME`` must also be
              specified to provide the required |OPENSSL| dependencies.

ENABLE_LOG
^^^^^^^^^^

:Required: No
:Default: ``OFF`` (for ``Release``), ``ON`` (for ``Debug``)
:Description: By default, |RSMQTT| will not print any messages to standard
              output when built in ``Release`` mode. When built in ``Debug``
              mode, or if ``ENABLE_LOG`` is enabled, |RSMQTT| will print
              informational and error messages to standard output. These
              messages cannot be disabled at run-time.

ENABLE_TRACE
^^^^^^^^^^^^

:Required: No
:Default: ``OFF``
:Description: If enabled, this option will cause |RSMQTT| to produce a much
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
:Description: |RSMQTT| comes with a test suite which can be optionally enabled
              and built. If enabled, the :link_cmocka:`cmocka <>` framework
              will also be configured and built.

ENABLE_EXAMPLES
^^^^^^^^^^^^^^^

:Required: No
:Default: ``OFF``
:Description: |RSMQTT| includes some example applications which can be used to
              the *DDS*/*MQTT* integration. Note that you will need to provide
              an |MQTT_BROKER|. The example assume that you have ``mosquitto``
              installed locally.


ENABLE_DOCS
^^^^^^^^^^^

:Required: No
:Default: ``OFF``
:Description: If you want to build |RSMQTT|'s documentation (i.e. these
              documents that you are reading), make sure to have Sphinx,
              Breathe, and Doxygen installed.

