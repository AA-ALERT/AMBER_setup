#!/bin/bash

# Source root
SOURCE_ROOT=${HOME}

# OpenCL and tuning settings
OPENCL_PLATFORM="0"
OPENCL_DEVICE="0"
DEVICE_NAME="GenericDevice"
ITERATIONS="10"

# Padding (in bytes)
DEVICE_PADDING="128"
DEVICE_THREADS="32"

# Constraints
MIN_THREADS="8"
MAX_THREADS="1024"
MAX_ITEMS="255"

# Dedispersion
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

# Tune and generate configuration files
mkdir -p ${SOURCE_ROOT}/confs
echo "${DEVICE_NAME} ${DEVICE_PADDING}" >> ${PADDING}
touch ${ZAPPED_CHANNELS}
echo -n "${DEVICE_NAME} " >> ${DEDISPERSION_STEPONE}
${SOURCE_ROOT}/Dedispersion/bin/DedispersionTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_columns ${MAX_DIM0} -max_rows ${MAX_DIM1} -max_items ${MAX_ITEMS} -max_sample_items ${MAX_ITEMS_DIM0} -max_dm_items ${MAX_ITEMS_DIM1} -max_unroll ${MAX_UNROLL} -step_one ${LOCAL} -beams ${BEAMS} -samples ${SAMPLES} -min_freq ${MIN_FREQ} -channels ${CHANNELS} -channel_bandwidth ${CHANNEL_BANDWIDTH} -input_bits ${INPUT_BITS} -zapped_channels ${ZAPPED_CHANNELS} -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -subbanding_dm_first ${SUBBANDING_DM_FIRST} -subbanding_dm_step ${SUBBANDING_DM_STEP} -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -best >> ${DEDISPERSION_STEPONE}
echo -n "${DEVICE_NAME} " >> ${DEDISPERSION_STEPTWO}
${SOURCE_ROOT}/Dedispersion/bin/DedispersionTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_columns ${MAX_DIM0} -max_rows ${MAX_DIM1} -max_items ${MAX_ITEMS} -max_sample_items ${MAX_ITEMS_DIM0} -max_dm_items ${MAX_ITEMS_DIM1} -max_unroll ${MAX_UNROLL} -step_two ${LOCAL} -beams ${BEAMS} -samples ${SAMPLES} -min_freq ${MIN_FREQ} -channels ${CHANNELS} -channel_bandwidth ${CHANNEL_BANDWIDTH} -synthesized_beams ${SYNTHESIZED_BEAMS} -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -best >> ${DEDISPERSION_STEPTWO}

exit 0
