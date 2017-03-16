# Performance test suite for the ARTS hardware tender

This test suite consists of an auto-tuning (ie. self-optimizing) OpenCL program used for astrophysics research (specifically, for the detection of 'Fast Radio Bursts').
It is one of the programs that will be run on the final hardware.

The test contains three steps:

1. installation of the software
2. running the auto-tuning (can last from 5 to 24 hours)
3. measuring final performance (takes several minutes per run)

Help or questions available via leeuwen@astron.nl

# Installation

## Install dependencies from repositories

This installation guide has been written for `CentOS7`, starting from a clean install.
Extra package are available via the epel repository; enable it via:
```
sudo yum install epel-release
```

Then install the following packages with dependencies:
```
sudo yum group install "Development Tools"
sudo yum install git wget ed
sudo yum install hdf5-devel
```

## Install OpenCL

Headers should be in standard paths, location of the libraries can be set via the OPENCL_LIB variable

## Install full pipeline

Set the evironment variable SOURCE_ROOT as the install location for the pipeline and run the installation script:
```
export SOURCE_ROOT=${HOME}/pipeline
./install_full_pipeline.sh
```

## Install full pipeline on the DAS cluster

For users having access to the DAS5 cluster, specific configuration can be set via the das5_config.sh script

# Autotuning

Check the definitions in the defs.sh file. Modify OpenCL device parameters and CPU identifier (the pipeline is pinned to the specified CPU to optimize memory transfers).
Then run the tuning script:
```
export SOURCE_ROOT=${HOME}/pipeline
./tune_modules.sh
```

This script will run for a possibly long period (upto 24 hours).
It will result in a number of configuration files that will be automatically stored at the apropriate locations.

Note that by default the testsuite runs in single precission.
Half precission is also acceptable, but will require some code modifications. Please contact us for details.

# Performance testing

Finally, the performance test can be run using:
```
export SOURCE_ROOT=${HOME}/pipeline
./performance_test.sh
```

It will report a number (roughly inverse running time excluding initialization), that should be multiplied by the number of GPUs in the full system to obtain the performance score for this tender:
```
performance score = (number of GPUs) x (output of the performance test)
```
Please do not round the performance score, and report it with full precision.
It is allowed to run the test multiple times and report the average score.
