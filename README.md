# RTI Routing Service Plugins

This repository contains a collection of plugins for [RTI Routing Service](https://www.rti.com/products/routing-service).

The plugins are shared in source form, and they can be built and deployed on the architectures supported by Routing Service
(NOTE: only Linux and Darwin have been tested and are supported so far).

The repository also includes some helper resources for plugin developers, and a series of example scenarios which demonstrate
how to use multiple plugins together.

## Table of Contents

- [Plugins List](#plugins-list)
- [Cloning](#cloning)
- [Building](#building)
  - [Build Dependencies](#build-dependencies)
  - [Building with cmake](#building-with-cmake)
  - [Building with make](#building-with-make)
  - [Build Options](#build-options)
  - [Build Artefacts](#build-artefacts)
- [Configuration](#Configuration)
  - [Plugins Registration](#plugins-registration)
  - [Plugins Configuration](#plugins-configuration)
    - [Adapter: File](#adapter-file)
    - [Adapter: MQTT](#adapter-mqtt)
    - [Processor: Forwarding Engine (By Input Name)](#processor-forwarding-engine-by-input-name)
    - [Processor: Forwarding Engine (By Input Value)](#processor-forwarding-engine-by-input-value)
    - [Transformation: JSON (Flat Type)](#transformation-json-flat-type)
    - [Transformation: Field (Primitive)](#transformation-field-primitive)


## Plugins List

The following table summarizes the RTI Routing Service plugins contained in the
repository:

| Type | Plugin | Location | Description | Library | Create Function |
|:----:|:------:|:----:|:-----------:|:-------:|:---------:|
| Adapter | File | plugins/adapters/file | An adapter that reads and writes samples from a file using a custom serialization format. | rtirsfileadapter | ``RTI_RS_File_AdapterPlugin_create`` |
| Adapter | MQTT | plugins/adapters/mqtt | An adapter that allows RTI Routing Service to act as an MQTT Client and to exchange DDS data with an MQTT Broker. | rtirsmqttadapter | ``RTI_RS_MQTT_AdapterPlugin_create`` |
| Processor | Forwarding Engine (By Input Name) | plugins/processors/fwd | A processor that selects the *Output* to which a sample should be forwarded within a *Route* based on the name of the *Input* that produced it. | rtirsfwdprocessor | ``RTI_PRCS_FWD_ByInputNameForwardingEnginePlugin_create`` |
| Processor | Forwarding Engine (By Input Value) | plugins/processors/fwd | A processor that selects the *Output* to which a sample should be forwarded within a *Route* based on the value of one of the fields of the sample. | rtirsfwdprocessor | ``RTI_PRCS_FWD_ByInputValueForwardingEnginePlugin_create`` |
| Transformation | Field (Primitive) | plugins/transformations/field | A transformation that can extract a single primitive field from a sample and convert it to a string. | rtirsjsontransf | ``RTI_TSFM_Field_PrimitiveTransformationPlugin_create`` |
| Transformation | JSON (Flat Type) | plugins/transformations/json | A transformation that can convert samples of "flat" DDS types (i.e. types containing only primitive members) into their JSON representation, and viceversa. | rtirsfieldtransf | ``RTI_TSFM_Json_FlatTypeTransformationPlugin_create`` |
| Transformation | Simple | plugins/transformations/simple | An "abstract" transformation which can be used to simplify implementation of custom transformations (cannot be used "as is") | N/A | N/A |

## Cloning

The repository uses [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules), so make sure to specify
`--recurse-submodules` option when cloning the repository:

```sh
git clone --recurse-submodules https://github.com/rticommunity/rtiroutingservice-plugins.git
```

## Building

The repository and all contained plugins can be built using [CMake](https://cmake.org/install/).

On Unix platforms, `make` can also be used to simplify the build process.

### Build Dependencies

The following external dependencies are required to build the repository:

- An installation of RTI Connext DDS, version 6.0.0 or greater

  - This installation must include libraries and header files for:
  
    - The core C API.
    - The modern C++ API.
    - The Routing Service Plugin SDK.

  - The location where RTI Connext DDS is installed will be referred to using variable `CONNEXTDDS_DIR`, while
    the target build architecture will be identified by `CONNEXTDDS_ARCH` (e.g. on a Linux 64-bit system `x64Linux3gcc5.4.0`).

- An installation of OpenSSL (optional)

  - This is only required if you want to enable security features implemented by different plugins.
  
  - The installation must contain library and header files respectively in a `lib/` and `include/` subdirectories.

  - The directory will be referred to as `OPENSSLHOME`.

### Building with `cmake`

All code included in this repository is built using `cmake`.

You should be able to use your preferred `cmake` workflow (command-line, GUI, IDE integration), as long as you make sure to set
the following variables:

- `CONNEXTDDS_DIR`

- `CONNEXTDDS_ARCH`

- `OPENSSLHOME` (if you want to enable security features via `ENABLE_SSL`).

For example, to configure and run the build from the command-line using the default generator for your build platform:

```sh
# Create a build directory and enter it
mkdir build
cd build

# Configure build with cmake.
# (change variables according to your environment)
cmake /path/to/rtiroutingservice-plugins \
      -DCMAKE_INSTALL_PREFIX=../install \
      -DCONNEXTDDS_DIR=/path/to/rti_connext_dds \
      -DCONNEXTDDS_ARCH=myOsAndCompiler

# Perform build.
# (add "install" target only if your generator supports it)
cmake --build . -- install

```

By default, `CMAKE_BUILD_TYPE` will be set to `Debug` if unspecified. Add `-DCMAKE_BUILD_TYPE=Release` if you want to
build release libraries.

After building the `install` target, the build directory may be deleted if desired.

If you want to enable security features provided by the different plugins, pass
`-DENABLE_SSL=ON -DOPENSSLHOME=/path/to/openssl` to `cmake`.

### Building with `make`

The provided `make` rules simplify the build process by automating the invocation of `cmake` with build options configured
from environment variables.

Variables can be set in the environment, on `make`'s command line, and in a `config.mk` file in the repository's root.

Create `config.mk` in the repository's root, and use it to specify the location of your build dependencies. 
The contents should look something like (replace with valid values):

```sh
CONNEXTDDS_DIR      ?= /path/to/rti_connext_dds
CONNEXTDDS_ARCH     ?= myOsAndCompiler
# Uncomment to enable security features
#OPENSSLHOME         ?= /path/to/openssl
#ENABLE_SSL          ?= ON
```

[Note: by using `?=` you will be able to override these values from the shell enviroment and/or `make`'s command line. Use `:=` if
 you want to force a value, and check this [guide](https://www.gnu.org/software/make/manual/html_node/Setting.html) for more information on `make`'s assignment operators.]


After creating `config.mk`, run `make` to perform the build and install resulting artefacts in a common location:

```sh
make
```

Build files will be generated in `<repo-root>/build`, and build artefacts will be installed under `<repo-root>/install`.

You can delete the build directory after the files have been installed.

### Build Options

The build process can be controlled using the following CMake variables:

| Variable | Default | Description |
|:--------:|:-------:|:-----------:|
| ENABLE_ALL          | `ON` | Build all plugins and examples |
| ENABLE_ALL_PLUGINS  | `ON` | Build all plugins |
| ENABLE_ALL_EXAMPLES | `ON` | Build all examples |
| ENABLE_ADAPTER_FILE | `ON` | Build plugin: File Adapter |
| ENABLE_ADAPTER_MQTT | `ON` | Build plugin: MQTT Adapter |
| ENABLE_PROCESSOR_FWD | `ON` | Build plugin: Forwarding Engine |
| ENABLE_TRANSFORMATION_JSON | `ON` | Build plugin: JSON Transformation |
| ENABLE_TRANSFORMATION_FIELD | `ON` | Build plugin: Field Transformation |
| ENABLE_EXAMPLE_MQTTSHAPES | `ON` | Build example: MQTT Shapes |
| DISABLE_LOG             | `OFF` | Disable all output of log messages to stdout |
| ENABLE_LOG              | `ON`* | Force output of log messages to stdout (*Enabled automatically for Debug builds only, unless `DISABLE_LOG` is used) |
| ENABLE_SSL              | `OFF` | Include support for security features (e.g. SSL/TLS). Requires OpenSSL |
| ENABLE_TRACE            | `OFF` | Enable trace level debug output |
| INSTALL_DEPS            | `ON` | Install external libraries (e.g. Connext DDS, OpenSSL) along with the ones generated by the repository |

### Build Artefacts

The build process will create the following directory structure at the selected `CMAKE_INSTALL_PREFIX`:

```sh
install/
├── doc
|   └── ... one directory per plugin ...
|       └── html
|           └── ... html documentation ...
├── include
│   ├── ... header files for external dependencies ...
│   └── rti
│       ├── adapt
│       │   └── ... header files for adapter plugins ...
│       ├── process
│       │   └── ... header files for processor plugins ...
│       └── transform
│           └── ... header files for transformation plugins ...
├── lib
|   └── ${CONNEXTDDS_ARCH}
│       ├── ... libraries from external dependencies ...
│       ├── ... plugin libraries
|       └── ... plugin binaries
└── resource
    └── ... one directory per plugin ...
        ├── example
        |   └── ... one directory per example ...
        |       ├── bin
        |       |   └── ... example binaries ...
        |       └── etc
        |           └── ... example configuration files ...
        └── idl
            └── ... type definitions for plugin
```

## Configuration

### Plugins Registration

Once the repository's libraries have been built and installed, you must
register the plugins in RTI Routing Service's XML configuration in order to use
them.

All plugins library must be available in RTI Routing Service's dynamic library
path.

If you installed the repository's artefacts to a common location `${INSTALL_DIR}`,
add `${INSTALL_DIR}/lib` to you

The following snippet can be added at the begininning of the `<dds>` element to
register all plugins contained in the repository:

```xml
<plugin_library name="RSPlugins">
    <adapter_plugin name="File">
        <dll>rtirsfileadapter</dll>
        <create_function>
            RTI_RS_FILE_AdapterPlugin_create
        </create_function>
    </adapter_plugin>
    <adapter_plugin name="Mqtt">
        <dll>rtirsmqttadapter</dll>
        <create_function>
            RTI_RS_MQTT_AdapterPlugin_create
        </create_function>
    </adapter_plugin>
    <processor_plugin name="FwdByName">
        <dll>rtirsfwdprocessor</dll>
        <create_function>
            RTI_PRCS_FWD_ByInputValueForwardingEnginePlugin_create
        </create_function>
    </processor_plugin>
    <processor_plugin name="FwdByValue">
        <dll>rtirsfwdprocessor</dll>
        <create_function>
            RTI_PRCS_FWD_ByInputValueForwardingEnginePlugin_create
        </create_function>
    </processor_plugin>
    <transformation_plugin name="FieldPrimitive">
        <dll>rtirsfieldtransf</dll>
        <create_function>
            RTI_TSFM_Field_PrimitiveTransformationPlugin_create
        </create_function>
    </transformation_plugin>
    <transformation_plugin name="JsonFlat">
        <dll>rtirsjsontransf</dll>
        <create_function>
            RTI_TSFM_Json_FlatTypeTransformationPlugin_create
        </create_function>
    </transformation_plugin>
</plugin_library>
```

### Plugins Configuration

Each plugin is configured using XML properties. This section summarizes
all properties accepted by each plugin.

#### Adapter: File

| Target | Property | Required | Default | Accepted Values |
|:------:|:--------:|:--------:|:-------:|:---------------:|
| `<input>` | `FileName` | Yes | - | A file path |
| `<input>` | `Loop` | No | `false` | A boolean value |
| `<input>` | `MaxSamplesSize` | No | 4096 | An integer value greater than 0 |
| `<input>` | `ReadPeriod` | No | 1000 (ms) | An integer value greater than 0 |
| `<input>` | `SamplesPerDisposedSample` | No | 0 | An integer value greater or equal to 0 |
| `<input>` | `SamplesPerRead` | No | 1 | A integer value greater than 0|
| `<input>` | `SamplesPerUnregisteredSample` | No | 0 | An integer value greater or equal to 0 |
| `<output>` | `FileName` | Yes | - | A file path |
| `<output>` | `Flush` | No | `false` | A boolean value |
| `<output>` | `WriteMode` | No | `keep` | `overwrite`, `append`, `keep` |

#### Adapter: MQTT

| Target | Property | Required | Default | Accepted Values |
|:------:|:--------:|:--------:|:-------:|:---------------:|
| `<connection>` | `client.id` | Yes | - |  A non-empty string |
| `<connection>` | `client.servers` | Yes | - | A list of MQTT Broker URIS, separated by semicolon. Each URI takes the form `<protocol>://<address>:<port>`, where `<protocol>` can be one of `tcp` or `ssl`. |
| `<connection>` | `client.protocol_version` | No | `default` | `default`, `3.1`, `3.1.1` |
| `<connection>` | `client.connection_timeout.sec` | No | 10 | An integer value greater or equal to 0 |
| `<connection>` | `client.connection_timeout.nanosec` | No | 0 | An integer value greater or equal to 0 |
| `<connection>` | `client.max_connection_retries` |  No | 10 | An integer value greater or equal to 0 |
| `<connection>` | `client.keep_alive_period.sec` | No | 10 | An integer value greater or equal to 0 |
| `<connection>` | `client.keep_alive_period.nanosec` | No | 0 | An integer value greater or equal to 0 |
| `<connection>` | `client.clean_session` | No | `false` | A boolean value |
| `<connection>` | `client.unsubscribe_on_disconnect` | No | `false` | A boolean value |
| `<connection>` | `client.max_reply_timeout.sec` | No | 10 | An integer value greater or equal to 0 |
| `<connection>` | `client.max_reply_timeout.nanosec` | No | 0 | An integer value greater or equal to 0 |
| `<connection>` | `client.reconnect` | No | `true` | A boolean value |
| `<connection>` | `client.max_unack_messages` | No | 10 | An integer value greater or equal to 0|
| `<connection>` | `client.persistence` | No | `no` | `no`, `yes` |
| `<connection>` | `client.persistence_storage` | No | - | A directory path |
| `<connection>` | `client.username` | No | - | A non-empty string |
| `<connection>` | `client.password` | No | - | A non-empty string |
| `<connection>` | `client.ssl.ca` | No | - | A file path |
| `<connection>` | `client.ssl.id` | No | - | A file path |
| `<connection>` | `client.ssl.key` | No | - | A file path |
| `<connection>` | `client.ssl.key_password` | No | - | A non-empty string |
| `<connection>` | `client.ssl.protocol_version` | No | `default` | `default`, `1.0`, `1.1`, `1.2` |
| `<connection>` | `client.ssl.verify_server_certificate` | No | `true` | A boolean value |
| `<connection>` | `client.ssl.cypher_suites` | No | `ALL` | A cypher suite identifier [accepted by OpenSSL](http://www.openssl.org/docs/apps/ciphers.html#CIPHER_LIST_FORMAT) |
| `<input>` | `subscription.topics` | Yes | - | A list of MQTT topic filters (which may contain [wildcards](http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Topic_wildcards)), separated by semicolon. |
| `<input>` | `subscription.max_qos` | No | `2` | `0`, `1`, `2` |
| `<input>` | `subscription.queue_size` | No | 0 (unbounded) | An integer value greater or equal to 0 |
| `<output>` | `publication.topic` | Yes* | - | An MQTT [topic name](http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Toc398718106) |
| `<output>` | `publication.qos` | No | `0` | `0`, `1`, `2` |
| `<output>` | `publication.retained` | No | `false` | A boolean value |
| `<output>` | `publication.use_message_info` | Yes* | `false` | A boolean value |
| `<output>` | `publication.max_wait_time.sec` | No | 10 | An integer value greater or equal to 0 |
| `<output>` | `publication.max_wait_time.nanosec` | No | 0 | An integer value greater or equal to 0 |

#### Processor: Forwarding Engine (By Input Name)

| Target | Property | Required | Default | Accepted Values |
|:------:|:--------:|:--------:|:-------:|:---------------:|
|`<processor>`| `forwarding_table` | Yes | - | A JSON array of entries with format `{ "input": "INPUT_NAME", "output": "OUTPUT_NAME" }` |

#### Processor: Forwarding Engine (By Input Value)

| Target | Property | Required | Default | Accepted Values |
|:------:|:--------:|:--------:|:-------:|:---------------:|
|`<processor>`| `forwarding_table` | Yes | - | A JSON array of entries with format `{ "input": "INPUT_VALUE", "output": "OUTPUT_NAME" }` |
|`<processor>`| `input_members` | Yes | - | A JSON array of entries with format `{ "input": "INPUT_NAME", "member": "INPUT_MEMBER" }` |

#### Transformation: JSON (Flat Type)

| Target | Property | Required | Default | Accepted Values |
|:------:|:--------:|:--------:|:-------:|:---------------:|
|`<transformation>`| `buffer_member` | Yes | - | An identifier for a member of a type (e.g. `"foo.bar"`) |
|`<transformation>` | `indent` | No | `false` | A boolean value |
|`<transformation>` | `serialized_size_min` | No | 255 | An integer value greater or equal to 0 |
|`<transformation>` | `serialized_size_max` | No | -1 | An integer value greater than 0, or -1 |
|`<transformation>` | `serialized_size_incr` | No | 255 | An integer value greater or equal to 0 |

#### Transformation: Field (Primitive)

| Target | Property | Required | Default | Accepted Values |
|:------:|:--------:|:--------:|:-------:|:---------------:|
|`<transformation>`| `buffer_member` | Yes | - | An identifier for a member of a type (e.g. `"foo.bar"`) |
|`<transformation>` | `field` | Yes | - | An identifier for a member of a type (e.g. `"foo.bar"`) |
|`<transformation>` | `field_type` | Yes | - | An IDL primitive type (e.g. `"unsigned long"`, `"uint64"`) |
|`<transformation>` | `max_serialized_size` | No | 255 | An integer value greater or equal to 0 |
|`<transformation>` | `serialization_format` | No | Depends on `field_type` | A format string accepted by `sprintf()` |
