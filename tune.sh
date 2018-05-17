#!/bin/bash

tune() {
  source ${SCENARIO}

  if [ -d ${CONFS} ]
  then
    for file in padding.conf zapped_channels.conf dedispersion_stepone.conf dedispersion_steptwo.conf dedispersion.conf snr.conf integration_steps.conf integration.conf
    do
      if [ -f ${CONFS}/${file} ]
      then
        rm ${CONFS}/${file}
      fi
    done
  else
    mkdir -p ${CONFS}
  fi

  # Padding
  echo "Generating padding.conf file"
  echo "${DEVICE_NAME} ${DEVICE_PADDING}" >> ${CONFS}/padding.conf

  # Zapped channels
  echo "Generating zapped_channels.conf file"
  echo ${ZAPPED_CHANNELS} >> ${CONFS}/zapped_channels.conf

  # Dedispersion
  if [ "${SUBBANDING}" = true ]
  then
    echo "Tuning Dedispersion (step one)"
    echo -n "${DEVICE_NAME} " >> ${CONFS}/dedispersion_stepone.conf
    ${INSTALL_ROOT}/bin/DedispersionTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_columns ${MAX_DIM0} -max_rows ${MAX_DIM1} -max_items ${MAX_ITEMS} -max_sample_items ${MAX_ITEMS_DIM0} -max_dm_items ${MAX_ITEMS_DIM1} -max_unroll ${MAX_UNROLL} -step_one -beams ${BEAMS} -samples ${SAMPLES} -sampling_time ${SAMPLING_TIME} -min_freq ${MIN_FREQ} -channels ${CHANNELS} -channel_bandwidth ${CHANNEL_BANDWIDTH} -zapped_channels ${CONFS}/zapped_channels.conf -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -subbanding_dm_first ${SUBBANDING_DM_FIRST} -subbanding_dm_step ${SUBBANDING_DM_STEP} -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -best 2>/dev/null 1>> ${CONFS}/dedispersion_stepone.conf
    echo "Tuning Dedispersion (step two)"
    echo -n "${DEVICE_NAME} " >> ${CONFS}/dedispersion_steptwo.conf
    ${INSTALL_ROOT}/bin/DedispersionTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_columns ${MAX_DIM0} -max_rows ${MAX_DIM1} -max_items ${MAX_ITEMS} -max_sample_items ${MAX_ITEMS_DIM0} -max_dm_items ${MAX_ITEMS_DIM1} -max_unroll ${MAX_UNROLL} -step_two -beams ${BEAMS} -samples ${SAMPLES} -sampling_time ${SAMPLING_TIME} -min_freq ${MIN_FREQ} -channels ${CHANNELS} -channel_bandwidth ${CHANNEL_BANDWIDTH} -synthesized_beams ${SYNTHESIZED_BEAMS} -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -best 2>/dev/null 1>> ${CONFS}/dedispersion_steptwo.conf
  else
    echo "Tuning Dedispersion"
    echo -n "${DEVICE_NAME} " >> ${CONFS}/dedispersion.conf
    ${INSTALL_ROOT}/bin/DedispersionTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_columns ${MAX_DIM0} -max_rows ${MAX_DIM1} -max_items ${MAX_ITEMS} -max_sample_items ${MAX_ITEMS_DIM0} -max_dm_items ${MAX_ITEMS_DIM1} -max_unroll ${MAX_UNROLL} -single_step -beams ${BEAMS} -synthesized_beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -sampling_time ${SAMPLING_TIME} -min_freq ${MIN_FREQ} -channels ${CHANNELS} -channel_bandwidth ${CHANNEL_BANDWIDTH} -zapped_channels ${CONFS}/zapped_channels.conf -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -best 2>/dev/null 1>> ${CONFS}/dedispersion.conf
  fi

  # SNR before downsampling
  echo "Tuning SNR for ${SAMPLES} samples"
  echo -n "${DEVICE_NAME} " >> ${CONFS}/snr.conf
  if [ "${SUBBANDING}" = true ]
  then
    ${INSTALL_ROOT}/bin/ -snr -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/snr.conf
  else
    ${INSTALL_ROOT}/bin/SNRTuning -snr -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/snr.conf
  fi

  # Integration steps
  echo "Generating integration_steps.conf file"
  echo ${INTEGRATION_STEPS} >> ${CONFS}/integration_steps.conf
  for STEP in ${INTEGRATION_STEPS}
  do
    STEP_SAMPLES="`echo "${SAMPLES} / ${STEP}" | bc -q`"
    echo -n "${DEVICE_NAME} " >> ${CONFS}/integration.conf
    echo -n "${DEVICE_NAME} " >> ${CONFS}/snr.conf
    if [ "${SUBBANDING}" = true ]
    then
      # Integration
      echo "Tuning Integration for step ${STEP}"
      ${INSTALL_ROOT}/bin/IntegrationTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -integration ${STEP} -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/integration.conf
      # SNR after downsampling
      echo "Tuning SNR for ${STEP_SAMPLES} samples"
      ${INSTALL_ROOT}/bin/SNRTuning -snr -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/snr.conf
    else
      # Integration
      echo "Tuning Integration for step ${STEP}"
      ${INSTALL_ROOT}/bin/IntegrationTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -integration ${STEP} -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/integration.conf
      # SNR after downsampling
      echo "Tuning SNR for ${STEP_SAMPLES} samples"
      ${INSTALL_ROOT}/bin/SNRTuning -snr -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/snr.conf
    fi
  done
}
