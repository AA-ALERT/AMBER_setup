
![AMBER](https://raw.githubusercontent.com/AA-ALERT/AMBER/master/doc/Amber-Logo-h200.png)

# AMBER Setup and Management Scripts

This repository contains a set of scripts to perform basic maintenance operation on an installation of [AMBER](https://github.com/AA-ALERT/AMBER), a many-core accelerated and fully auto-tuned FRB pipeline.
The operations currently supported are:

- **Download** and install the complete pipeline
- **Update** the AMBER source code
- **Compile** and install AMBER
- **Tune** the pipeline modules and generate configuration files
- **Test** generated configuration files

# User's Guide

## Prerequisites

To compile and install AMBER and its modules, it is necessary to have a system with [CMake](https://cmake.org/) and other standard Unix development tools available. So far AMBER and this installer have been tested on Linux using [GCC](https://gcc.gnu.org/) as a compiler.

Before running this script it is necessary to set two environmental variables: `SOURCE_ROOT` and `INSTALL_ROOT`.
`SOURCE_ROOT` specifies where the source code of AMBER all its dependencies are saved; `INSTALL_ROOT` specifies where the libraries, includes, and executables are saved.
```bash
# Example
export SOURCE_ROOT=${HOME}/src/AMBER/src
export BUILD_ROOT=${HOME}/src/AMBER/build
```
If the directories do not exist, they will be created by the script.

In order to compile and run, AMBER needs a working [OpenCL](https://www.khronos.org/opencl/) environment; OpenCL is a necessary dependency for the pipeline.

If the environmental variable `DEBUG` is set, generated executables and libraries will have compiler optimizations disabled, and contain all debug symbols.
If the environmental variable `OPENMP` is set, [OpenMP](http://www.openmp.org/) is used to parallelize some of the CPU workload.
```bash
# Example
export DEBUG=1
export OPENMP=1
```

There are also two optional dependencies: [PSRDADA](http://psrdada.sourceforge.net/) and [HDF5](https://support.hdfgroup.org/HDF5/).
PSRDADA support is necessary to read time series from a PSRDADA ringbuffer.
```bash
# Example
export PSRDADA=1
```
HDF5 is used to support the file format used by LOFAR observations.
```bash
# Example
export LOFAR=1
```

## Download and Install AMBER

To compile and install AMBER, run the `amber.sh` script.
The script takes two command line parameters: the first parameter is the mode, in this case `install`, and the second parameter is the development branch to use.
The second parameter is optional, and if not provided the master branch is used.
```bash
# Example
# Compile and install the master branch of AMBER
amber.sh install
```

## Update AMBER

To update the source code of an existing AMBER installation, run the `amber.sh` script and specify `update` as first parameter on the command line.
The second parameter is optional, and if not provided the master branch is used.
```bash
# Example
# Update and install the master branch of AMBER
amber.sh update
```
Please **be aware** that all local changes to the code are lost when updating.

## Compile AMBER

Sometimes it may be necessary to recompile and install the pipeline, but without updating the source code from GitHub, for example to enable the `DEBUG` mode, or use different compiler optimizations.
To recompile the pipeline, run the `amber.sh` script and specify `compile` as the only command line parameter.
```bash
# Example
# Compile AMBER
amber.sh compile
```

## Post Install

After installing AMBER, it is useful to modify the `PATH` and `LD_LIBRARY_PATH` variables to reflect the installation paths.
```bash
# Example
export LD_LIBRARY_PATH=${INSTALL_ROOT}/lib:${LD_LIBRARY_PATH}
export PATH=${INSTALL_ROOT}/bin:${PATH}
```

## Tune AMBER

AMBER is composed by various modules that need to be tuned, and has multiple configuration files that need to be generated.
To tune the pipeline and generate the configuration file, run the `amber.sh` script.
The script takes three command line parameters: the first parameter is the mode, in this case `tune`, the second parameter is the path of a file containing the description of the scenario in which AMBER will be run, and the third is the path where to save the configuration files.
```bash
# Example
# Tune AMBER using the example scenario description
amber.sh tune examples/scenario.sh ${INSTALL_ROOT}/confs
```
Please **be aware** that the script will delete previously generated configuration files in the same directory.

## Test AMBER

After tuning AMBER, or after editing some manually generated configuration files, it is also possible to test that these configuration files are correct.
To test a set of configuration files run the `amber.sh` script.
The script takes three command line parameters: the first parameter is the mode, in this case `test`, the second parameter is the path of a file containing the description of the scenario in which AMBER will run, and the third is the path where the configuration files are stored.
```bash
# Example
# Test the previously tuned AMBER configuration files
amber.sh test examples/scenario.sh ${INSTALL_ROOT}/confs
```

# Demo

[![asciicast](https://asciinema.org/a/ORS45Opq7ZjsNsMmBsm5RjPDd.png)](https://asciinema.org/a/ORS45Opq7ZjsNsMmBsm5RjPDd)
