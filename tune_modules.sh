#!/bin/bash

if [ -z "${SOURCE_ROOT}" ]; then
  echo "Please set SOURCE_ROOT first"
  exit
fi

source defs.sh

# Tune and generate configuration files
mkdir -p ${SOURCE_ROOT}/confs
echo "${DEVICE_NAME} ${DEVICE_PADDING}" >> ${PADDING}
touch ${ZAPPED_CHANNELS}
echo -n "${DEVICE_NAME} " >> ${DEDISPERSION_STEPONE}
${SOURCE_ROOT}/Dedispersion/bin/DedispersionTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_columns ${MAX_DIM0} -max_rows ${MAX_DIM1} -max_items ${MAX_ITEMS} -max_sample_items ${MAX_ITEMS_DIM0} -max_dm_items ${MAX_ITEMS_DIM1} -max_unroll ${MAX_UNROLL} -step_one ${LOCAL} -beams ${BEAMS} -samples ${SAMPLES} -min_freq ${MIN_FREQ} -channels ${CHANNELS} -channel_bandwidth ${CHANNEL_BANDWIDTH} -input_bits ${INPUT_BITS} -zapped_channels ${ZAPPED_CHANNELS} -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -subbanding_dm_first ${SUBBANDING_DM_FIRST} -subbanding_dm_step ${SUBBANDING_DM_STEP} -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -best >> ${DEDISPERSION_STEPONE}
echo -n "${DEVICE_NAME} " >> ${DEDISPERSION_STEPTWO}
${SOURCE_ROOT}/Dedispersion/bin/DedispersionTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_columns ${MAX_DIM0} -max_rows ${MAX_DIM1} -max_items ${MAX_ITEMS} -max_sample_items ${MAX_ITEMS_DIM0} -max_dm_items ${MAX_ITEMS_DIM1} -max_unroll ${MAX_UNROLL} -step_two ${LOCAL} -beams ${BEAMS} -samples ${SAMPLES} -min_freq ${MIN_FREQ} -channels ${CHANNELS} -channel_bandwidth ${CHANNEL_BANDWIDTH} -synthesized_beams ${SYNTHESIZED_BEAMS} -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -best >> ${DEDISPERSION_STEPTWO}
echo -n "${DEVICE_NAME} " >> ${SNR}
${SOURCE_ROOT}/SNR/bin/SNRTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -best >> ${SNR}
echo ${DOWNSAMPLING} >> ${INTEGRATION_STEPS}
for STEP in ${DOWNSAMPLING}
do
  echo -n "${DEVICE_NAME} " >> ${INTEGRATION}
  ${SOURCE_ROOT}/Integration/bin/IntegrationTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -integration ${STEP} -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -best >> ${INTEGRATION}
  echo -n "${DEVICE_NAME} " >> ${SNR}
  ${SOURCE_ROOT}/SNR/bin/SNRTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples `echo "${SAMPLES} / ${STEP}" | bc -q` -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -best >> ${SNR}
done

exit 0
