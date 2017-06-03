#!/bin/bash

if [ -z "${SOURCE_ROOT}" ]; then
  echo "Please set SOURCE_ROOT first"
  exit
fi

source defs.sh

# Beam factor
if [ "${SYNTHESIZED_BEAMS}" -eq "12" ]
then
  FACTOR="1.0"
elif [ "${SYNTHESIZED_BEAMS}" -eq "11" ]
then
  FACTOR="0.625"
elif [ "${SYNTHESIZED_BEAMS}" -eq "10" ]
then
  FACTOR="0.555"
elif [ "${SYNTHESIZED_BEAMS}" -eq "9" ]
then
  FACTOR="0.476"
fi
# Test
mkdir -p ${SOURCE_ROOT}/results
OUTFILE="`date +%d%m%Y_%H%M`"
taskset -c ${CPU} ${SOURCE_ROOT}/TransientSearch/bin/TransientSearch -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -device_name ${DEVICE_NAME} -padding_file ${PADDING} -zapped_channels ${ZAPPED_CHANNELS} -integration_steps ${INTEGRATION_STEPS} -integration_file ${INTEGRATION} -snr_file ${SNR} -subband_dedispersion -dedispersion_step_one_file ${DEDISPERSION_STEPONE} -dedispersion_step_two_file ${DEDISPERSION_STEPTWO} -input_bits ${INPUT_BITS} -output ${SOURCE_ROOT}/results/${OUTFILE} -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -subbanding_dm_first ${SUBBANDING_DM_FIRST} -subbanding_dm_step ${SUBBANDING_DM_STEP} -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -threshold 16 -random -width 50 -dm 100 -beams ${BEAMS} -synthesized_beams ${SYNTHESIZED_BEAMS} -batches 120 -channels ${CHANNELS} -min_freq ${MIN_FREQ} -channel_bandwidth ${CHANNEL_BANDWIDTH} -samples ${SAMPLES} -sampling_time ${SAMPLING_TIME} -compact_results
SEARCH_TIME=`cat ${SOURCE_ROOT}/results/${OUTFILE}.stats | sed -n '4'p`
SCORE=`echo "${FACTOR} / ${SEARCH_TIME}" | bc -ql`
rm -rf ${SOURCE_ROOT}/results

echo "Performance score: ${SCORE}"

exit 0
