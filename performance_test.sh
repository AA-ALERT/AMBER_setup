#!/bin/bash

# Source root
SOURCE_ROOT=${HOME}

# OpenCL settings
OPENCL_PLATFORM="0"
OPENCL_DEVICE="0"
DEVICE_NAME="GenericDevice"

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

# Test
mkdir -p ${SOURCE_ROOT}/results
OUTFILE="`date +%d%m%Y_%H%M`"
${SOURCE_ROOT}/TransientSearch/bin/TransientSearch -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -device_name ${DEVICE_NAME} -padding_file ${PADDING} -zapped_channels ${ZAPPED_CHANNELS} -integration_steps ${INTEGRATION_STEPS} -integration_file ${INTEGRATION} -snr_file ${SNR} -subband_dedispersion -dedispersion_step_one_file ${DEDISPERSION_STEPONE} -dedispersion_step_two_file ${DEDISPERSION_STEPTWO} -input_bits ${INPUT_BITS} -output ${SOURCE_ROOT}/results/${OUTFILE} -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -subbanding_dm_first ${SUBBANDING_DM_FIRST} -subbanding_dm_step ${SUBBANDING_DM_STEP} -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -threshold 16 -random -width 50 -dm 100 -beams ${BEAMS} -synthesized_beams ${SYNTHESIZED_BEAMS} -batches 120 -channels ${CHANNELS} -min_freq ${MIN_FREQ} -channel_bandwidth ${CHANNEL_BANDWIDTH} -samples ${SAMPLES} -compact_results
SCORE="`echo "1.0 / `cat ${SOURCE_ROOT}/results/${OUTFILE}.stats | sed -n '4'p` | bc -ql`"
rm -rf ${SOURCE_ROOT}/results

echo "Performance score: ${SCORE}"

exit 0
