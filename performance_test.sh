#!/bin/bash

source ${SOURCE_ROOT}/artshardware/defs.sh

# Test
mkdir -p ${SOURCE_ROOT}/results
OUTFILE="`date +%d%m%Y_%H%M`"
tasket -c ${CPU} ${SOURCE_ROOT}/TransientSearch/bin/TransientSearch -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -device_name ${DEVICE_NAME} -padding_file ${PADDING} -zapped_channels ${ZAPPED_CHANNELS} -integration_steps ${INTEGRATION_STEPS} -integration_file ${INTEGRATION} -snr_file ${SNR} -subband_dedispersion -dedispersion_step_one_file ${DEDISPERSION_STEPONE} -dedispersion_step_two_file ${DEDISPERSION_STEPTWO} -input_bits ${INPUT_BITS} -output ${SOURCE_ROOT}/results/${OUTFILE} -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -subbanding_dm_first ${SUBBANDING_DM_FIRST} -subbanding_dm_step ${SUBBANDING_DM_STEP} -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -threshold 16 -random -width 50 -dm 100 -beams ${BEAMS} -synthesized_beams ${SYNTHESIZED_BEAMS} -batches 120 -channels ${CHANNELS} -min_freq ${MIN_FREQ} -channel_bandwidth ${CHANNEL_BANDWIDTH} -samples ${SAMPLES} -compact_results
SCORE="`echo "1.0 / `cat ${SOURCE_ROOT}/results/${OUTFILE}.stats | sed -n '4'p` | bc -ql`"
rm -rf ${SOURCE_ROOT}/results

echo "Performance score: ${SCORE}"

exit 0
