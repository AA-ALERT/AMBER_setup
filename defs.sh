#!/bin/bash

# CPU core used to run the pipeline (important for affinity to OpenCL device)
CPU="1"

# OpenCL configuration
## Device settings
OPENCL_PLATFORM="0"
OPENCL_DEVICE="0"
## Name of OpenCL device (used for configuration files)
DEVICE_NAME="GenericDevice"
## Size of the cache line of OpenCL device (in bytes)
DEVICE_PADDING="128"
## Number of OpenCL work-items running simultaneously
DEVICE_THREADS="32"

# Tuning
ITERATIONS="10"
## Constraints
MIN_THREADS="8"
MAX_THREADS="1024"
MAX_ITEMS="255"
## Dedispersion constraints
LOCAL="-local"
MAX_ITEMS_DIM0="64"
MAX_ITEMS_DIM1="32"
MAX_UNROLL="32"
MAX_DIM0="1024"
MAX_DIM1="128"

# Do not modify below this line

# Configuration files (do not modify)
PADDING="${SOURCE_ROOT}/confs/padding.inc"
ZAPPED_CHANNELS="${SOURCE_ROOT}/confs/zapped_channels.inc"
DEDISPERSION_STEPONE="${SOURCE_ROOT}/confs/dedispersion_stepone.inc"
DEDISPERSION_STEPTWO="${SOURCE_ROOT}/confs/dedispersion_steptwo.inc"
INTEGRATION_STEPS="${SOURCE_ROOT}/confs/integration_steps.inc"
INTEGRATION="${SOURCE_ROOT}/confs/integration.inc"
SNR="${SOURCE_ROOT}/confs/snr.inc"

# Test parameters (do not modify)
INPUT_BITS="8"
SUBBANDS="32"
SUBBANDING_DMS="128"
SUBBANDING_DM_FIRST="0.0"
SUBBANDING_DM_STEP="1.2"
DMS="32"
DM_FIRST="0.0"
DM_STEP="0.0375"
BEAMS="12"
SYNTHESIZED_BEAMS="12"
BATCHES="120"
CHANNELS="1536"
MIN_FREQ="1425.0"
CHANNEL_BANDWIDTH="0.1953125"
SAMPLES="25000"
DOWNSAMPLING="5 10 50 100 250 500"

