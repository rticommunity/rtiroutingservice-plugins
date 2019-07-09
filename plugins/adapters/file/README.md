# RTI Routing Service File Adapter Plugin

This repository contains an example Adapter Plugin for RTI Routing Service that can
be used to read and write data from files.

The **StreamReader** for the File adapter reads the data from file specified in the routing service configuration for the adapter. Each line results on a single sample which is read, parsed, and stored into a DynamicData which is then given to the Routing Service.

The **StreamWriter** for the File adapter receives a DynamicData and writes it into a file specified in the routing service configuration for the adapter. Each sample is wtitten to a line.

The adapter is written in a generic manner such that it can operate on any data type. It gets the type information from the **DynamicData** and uses the introspection API to determine field names and types.

The data-types can be either discovered from the other side or the route, or else configured on the Routing Service XML configuration.

The file format uses is a set of comma-separated,  name=value pairs. Where each name=value pair represents a field as in:
```
color=RED,x=10,y=20,shapesize=30
```

You can modify the **LineConversion.c** to use a different file format.

## Cloning

This adapter is provided as part of the `rtiroutingservice-plugins` repository.

To clone this repository, along with all required dependencies:

```sh
git clone --recurse-submodules https://bitbucket.rti.com/scm/~asorbini/rtiroutingservice-plugins.git
```

## Building

Follow building instructions for `rtiroutingservice-plugins` and make sure to
enable CMake option `ENABLE_ADAPTER_FILE` (enabled by default), e.g.:

```sh
mkdir build
cd build
cmake /path/to/rtiroutingservice-plugins \
      -DCONNEXTDDS_DIR=/path/to/rti_connext_dds \
      -DCONNEXTDDS_ARCH=targetCompilerAndOs \
      -DENABLE_ADAPTER_FILE=ON
```
