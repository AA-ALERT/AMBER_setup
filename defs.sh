#!/bin/bash

# Source root
SOURCE_ROOT=${HOME}

# Device settings
OPENCL_PLATFORM="0"
OPENCL_DEVICE="0"
DEVICE_NAME="GenericDevice"
## Padding (in bytes)
DEVICE_PADDING="128"
DEVICE_THREADS="32"
CPU="1"

# Tuning
ITERATIONS="10"

# Constraints
MIN_THREADS="8"
MAX_THREADS="1024"
MAX_ITEMS="255"

# Dedispersion constraints
LOCAL="-local"
MAX_ITEMS_DIM0="64"
MAX_ITEMS_DIM1="32"
MAX_UNROLL="32"
MAX_DIM0="1024"
MAX_DIM1="128"

# Configuration files (no need to modify)
PADDING="${SOURCE_ROOT}/confs/padding.inc"
ZAPPED_CHANNELS="${SOURCE_ROOT}/confs/zapped_channels.inc"
DEDISPERSION_STEPONE="${SOURCE_ROOT}/confs/dedispersion_stepone.inc"
DEDISPERSION_STEPTWO="${SOURCE_ROOT}/confs/dedispersion_steptwo.inc"
INTEGRATION_STEPS="${SOURCE_ROOT}/confs/integration_steps.inc"
INTEGRATION="${SOURCE_ROOT}/confs/integration.inc"
SNR="${SOURCE_ROOT}/confs/snr.inc"

# Test parameters (no need to modify)
INPUT_BITS="8"
SUBBANDS="32"
SUBBANDING_DMS="128"
SUBBANDING_DM_FIRST="0.0"
SUBBANDING_DM_STEP="1.2"
DMS="32"
DM_FIRST="0.0"
DM_STEP="0.0375"
BEAMS="12"
SYNTHESIZED_BEAMS="15"
BATCHES="120"
CHANNELS="1536"
MIN_FREQ="1425.0"
CHANNEL_BANDWIDTH="0.1953125"
SAMPLES="25000"

