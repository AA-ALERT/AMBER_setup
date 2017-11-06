#!/bin/bash

# Example tuning scenario

# System
## CPU core used to run the pipeline; important for affinity to OpenCL device
CPU="1"
## OpenCL platform ID
OPENCL_PLATFORM="0"
## OpenCL device ID
OPENCL_DEVICE="0"
## Name of OpenCL device, used for configuration files
DEVICE_NAME="GenericDevice"
## Size, in bytes, of the OpenCL device's cache line
DEVICE_PADDING="128"
## Number of OpenCL work-items running simultaneously
DEVICE_THREADS="32"

# Tuning
## Number of iterations for each kernel run
ITERATIONS="10"
## Minimum number of work-items
MIN_THREADS="8"
## Maximum number of work-items
MAX_THREADS="1024"
## Maximum number of variables
MAX_ITEMS="255"
## Maximum unrolling
MAX_UNROLL="32"
## Maximum number of work-items in OpenCL dimension 0; dedispersion specific
MAX_DIM0="1024"
## Maximum number of work-items in OpenCL dimension 1; dedispersion specific
MAX_DIM1="128"
## Maximum number of variables in OpenCL dimension 0; dedispersion specific
MAX_ITEMS_DIM0="64"
## Maximum number of variables in OpenCL dimension 1; dedispersion specific
MAX_ITEMS_DIM1="32"
## Switch to use the subbanding mode; dedispersion specific
SUBBANDING=true

# Scenario
## Number of channels
CHANNELS="1536"
## Frequency of the lowest channel, in MHz
MIN_FREQ="1425.0"
## Bandwidth of a channel, in MHz
CHANNEL_BANDWIDTH="0.1953125"
## Number of samples per batch
SAMPLES="25000"
# Sampling time, in seconds
SAMPLING_TIME="0.00004096"
## Number of subbands
SUBBANDS="32"
## Number of DMs to dedisperse in step one; subbanding mode only
SUBBANDING_DMS="128"
## First DM in step one; subbanding mode only
SUBBANDING_DM_FIRST="0.0"
## DM step in step one; subbanding mode only
SUBBANDING_DM_STEP="1.2"
## Number of DMs to dedisperse in either the single step or subbanding step two
DMS="32"
## First DM in either the single step or subbanding step two
DM_FIRST="0.0"
## DM step in either the single step or subbanding step two
DM_STEP="0.0375"
## Number of input beams
BEAMS="12"
## Number of synthesized output beams
SYNTHESIZED_BEAMS="12"
## Downsampling factors
INTEGRATION_STEPS="5 10 50 100 250 500"
