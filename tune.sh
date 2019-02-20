#!/bin/bash

tune() {
  source ${SCENARIO}

  if [ -d ${CONFS} ]
  then
    FILES="padding.conf zapped_channels.conf integration_steps.conf integration.conf snr.conf"
    if [ "${RFIM_TDSC_STEPS}" != "" ]
    then
      FILES="${FILES} tdsc.conf"
    fi
    if [ ${DOWNSAMPLING} -gt 1 ]
    then
      FILES="${FILES} downsampling.conf"
    fi
    if [ "${SUBBANDING}" = true ]
    then
      FILES="${FILES} dedispersion_stepone.conf dedispersion_steptwo.conf"
    else
      FILES="${FILES} dedispersion.conf"
    fi
    if [ "${SNR}" = "SNR" ]
    then
      FILES="${FILES} snr.conf"
    elif [ "${SNR}" = "MOMAD" ]
    then
      FILES="${FILES} max.conf mom_stepone.conf mom_steptwo.conf momad.conf"
    elif [ "${SNR}" = "MOMSIGMACUT" ]
    then
      FILES="${FILES} max_std.conf mom_stepone.conf mom_steptwo.conf"
    fi
    for file in ${FILES}
    do
      if [ -f ${CONFS}/${file} ]
      then
        rm ${CONFS}/${file}
      fi
    done
  else
    mkdir -p ${CONFS}
  fi

  # Compute the number of dispersed samples
  if [ "${SUBBANDING}" = true ]
  then
    # Subbanding mode
    SHIFT_ONE="`echo "(4148.808 * ((1.0 / (${MIN_FREQ} * ${MIN_FREQ})) - (1.0 / ((${MIN_FREQ} + ((${CHANNELS} - 1) * ${CHANNEL_BANDWIDTH})) * (${MIN_FREQ} + ((${CHANNELS} - 1) * ${CHANNEL_BANDWIDTH}))))) * (${SAMPLES})) / (${SAMPLES} * ${SAMPLING_TIME})" | bc -ql`"
    SHIFT_TWO="`echo "(4148.808 * ((1.0 / ((${MIN_FREQ} + ((${CHANNELS} / ${SUBBANDS} / 2.0) * ${CHANNEL_BANDWIDTH})) * (${MIN_FREQ} + ((${CHANNELS} / ${SUBBANDS} / 2.0) * ${CHANNEL_BANDWIDTH})))) - (1.0 / ((${MIN_FREQ} + ((${CHANNELS} - (${CHANNELS} / ${SUBBANDS} / 2.0)) * ${CHANNEL_BANDWIDTH})) * (${MIN_FREQ} + ((${CHANNELS} - (${CHANNELS} / ${SUBBANDS} / 2.0)) * ${CHANNEL_BANDWIDTH}))))) * (${SAMPLES})) / (${SAMPLES} * ${SAMPLING_TIME})" | bc -ql`"
    DISPERSED_SAMPLES="`echo "(${SAMPLES} + (${SHIFT_TWO} * (${DM_FIRST} + ((${DMS} - 1) * ${DM_STEP}))))" | bc -q`"
    DISPERSED_SAMPLES="`echo "if (${DISPERSED_SAMPLES} % 1) (${DISPERSED_SAMPLES} / 1 + 1) else (${DISPERSED_SAMPLES} / 1)" | bc -q`"
    DISPERSED_SAMPLES="`echo "${DISPERSED_SAMPLES} + (${SHIFT_ONE} * (${SUBBANDING_DM_FIRST} + ((${SUBBANDING_DMS} - 1) * ${SUBBANDING_DM_STEP})))" | bc -q`"
    DISPERSED_SAMPLES="`echo "if (${DISPERSED_SAMPLES} % 1) (${DISPERSED_SAMPLES} / 1 + 1) else (${DISPERSED_SAMPLES} / 1)" | bc -q`"
  else
    # Standard mode
    SHIFT="`echo "(4148.808 * ((1.0 / (${MIN_FREQ} * ${MIN_FREQ})) - (1.0 / ((${MIN_FREQ} + ((${CHANNELS} - 1) * ${CHANNEL_BANDWIDTH})) * (${MIN_FREQ} + ((${CHANNELS} - 1) * ${CHANNEL_BANDWIDTH}))))) * (${SAMPLES})) / (${SAMPLES} * ${SAMPING_TIME})" | bc -ql`"
    DISPERSED_SAMPLES="`echo "${SAMPLES} + (${SHIFT} * (${DM_FIRST} + ((${DMS} - 1) * ${DM_STEP})))" | bc -q`"
    DISPERSED_SAMPLES="`echo "if (${DISPERSED_SAMPLES} % 1) (${DISPERSED_SAMPLES} / 1 + 1) else (${DISPERSED_SAMPLES} / 1)" | bc -q`"
  fi
  if [ ${DOWNSAMPLING} -gt 1 ]
  then
    DISPERSED_SAMPLES="`echo "if (${DISPERSED_SAMPLES} % ${DOWNSAMPLING}) (${DISPERSED_SAMPLES} + (${DOWNSAMPLING} - (${DISPERSED_SAMPLES} % ${DOWNSAMPLING}))) else (${DISPERSED_SAMPLES})" | bc -q`"
  fi

  # Padding
  echo "Generating padding.conf file"
  echo "${DEVICE_NAME} ${DEVICE_PADDING}" >> ${CONFS}/padding.conf

  # Zapped channels
  echo "Generating zapped_channels.conf file"
  echo ${ZAPPED_CHANNELS} >> ${CONFS}/zapped_channels.conf

  # RFI mitigation
  # Time domain sigma cut
  if [ "${RFIM_TDSC_STEPS}" != "" ]
  then
    echo "Generating tdsc_steps.conf file"
    echo ${RFIM_TDSC_STEPS} >> ${CONFS}/tdsc_steps.conf
    for SIGMA in ${RFIM_TDSC_STEPS}
    do
      echo "Tuning TimeDomainSigmaCut (RFIm) for ${SIGMA} sigma"
      echo -n "${DEVICE_NAME} " >> ${CONFS}/tdsc.conf
      if [ "${SUBBANDING}" = true ]
      then
        taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/RFImTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -time_domain_sigma_cut -subbanding -frequency_time -replace_mean -beams ${BEAMS} -channels ${CHANNELS} -samples ${DISPERSED_SAMPLES} -sigma ${SIGMA} -best 2>/dev/null 1>> ${CONFS}/tdsc.conf
      else
        taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/RFImTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -time_domain_sigma_cut -frequency_time -replace_mean -beams ${BEAMS} -channels ${CHANNELS} -samples ${DISPERSED_SAMPLES} -sigma ${SIGMA} -best 2>/dev/null 1>> ${CONFS}/tdsc.conf
      fi
    done
  fi

  # Downsampling
  if [ ${DOWNSAMPLING} -gt 1 ]
  then
    echo "Tuning Downsampling"
    echo -n "${DEVICE_NAME} " >> ${CONFS}/downsampling.conf
    if [ "${SUBBANDING}" = true ]
    then
      taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/IntegrationTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -in_place -before_dedispersion -subband -integration ${DOWNSAMPLING} -beams ${BEAMS} -samples ${DISPERSED_SAMPLES} -channels ${CHANNELS} -best 2>/dev/null 1>> ${CONFS}/downsampling.conf
    else
      taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/IntegrationTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -in_place -before_dedispersion -integration ${DOWNSAMPLING} -beams ${BEAMS} -samples ${DISPERSED_SAMPLES} -channels ${CHANNELS} -best 2>/dev/null 1>> ${CONFS}/downsampling.conf
    fi
    SAMPLES="`echo "${SAMPLES} / ${DOWNSAMPLING}" | bc -q`"
  fi

  # Dedispersion
  if [ "${SUBBANDING}" = true ]
  then
    # Subbanding mode
    echo "Tuning Dedispersion (step one)"
    echo -n "${DEVICE_NAME} " >> ${CONFS}/dedispersion_stepone.conf
    taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/DedispersionTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_columns ${MAX_DIM0} -max_rows ${MAX_DIM1} -max_items ${MAX_ITEMS} -max_sample_items ${MAX_ITEMS_DIM0} -max_dm_items ${MAX_ITEMS_DIM1} -max_unroll ${MAX_UNROLL} -step_one -beams ${BEAMS} -samples ${SAMPLES} -sampling_time ${SAMPLING_TIME} -min_freq ${MIN_FREQ} -channels ${CHANNELS} -channel_bandwidth ${CHANNEL_BANDWIDTH} -zapped_channels ${CONFS}/zapped_channels.conf -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -subbanding_dm_first ${SUBBANDING_DM_FIRST} -subbanding_dm_step ${SUBBANDING_DM_STEP} -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -best 2>/dev/null 1>> ${CONFS}/dedispersion_stepone.conf
    echo "Tuning Dedispersion (step two)"
    echo -n "${DEVICE_NAME} " >> ${CONFS}/dedispersion_steptwo.conf
    taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/DedispersionTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_columns ${MAX_DIM0} -max_rows ${MAX_DIM1} -max_items ${MAX_ITEMS} -max_sample_items ${MAX_ITEMS_DIM0} -max_dm_items ${MAX_ITEMS_DIM1} -max_unroll ${MAX_UNROLL} -step_two -beams ${BEAMS} -samples ${SAMPLES} -sampling_time ${SAMPLING_TIME} -min_freq ${MIN_FREQ} -channels ${CHANNELS} -channel_bandwidth ${CHANNEL_BANDWIDTH} -synthesized_beams ${SYNTHESIZED_BEAMS} -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -best 2>/dev/null 1>> ${CONFS}/dedispersion_steptwo.conf
  else
    # Standard mode
    echo "Tuning Dedispersion"
    echo -n "${DEVICE_NAME} " >> ${CONFS}/dedispersion.conf
    taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/DedispersionTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_columns ${MAX_DIM0} -max_rows ${MAX_DIM1} -max_items ${MAX_ITEMS} -max_sample_items ${MAX_ITEMS_DIM0} -max_dm_items ${MAX_ITEMS_DIM1} -max_unroll ${MAX_UNROLL} -single_step -beams ${BEAMS} -synthesized_beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -sampling_time ${SAMPLING_TIME} -min_freq ${MIN_FREQ} -channels ${CHANNELS} -channel_bandwidth ${CHANNEL_BANDWIDTH} -zapped_channels ${CONFS}/zapped_channels.conf -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -best 2>/dev/null 1>> ${CONFS}/dedispersion.conf
  fi

  # SNR before downsampling
  if [ "${SNR}" = "SNR" ]
  then
    # Standard SNR
    echo "Tuning SNR for ${SAMPLES} samples"
    echo -n "${DEVICE_NAME} " >> ${CONFS}/snr.conf
    if [ "${SUBBANDING}" = true ]
    then
      taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -snr -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/snr.conf
    else
      taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -snr -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/snr.conf
    fi
  elif [ "${SNR}" = "MOMAD" ]
  then
    # MOMAD specific
    echo "Tuning MAX for ${SAMPLES} samples"
    echo -n "${DEVICE_NAME} " >> ${CONFS}/max.conf
    if [ "${SUBBANDING}" = true ]
    then
      taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -max -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/max.conf
    else
      taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -max -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/max.conf
    fi
    echo "Tuning MOMAD for ${SAMPLES} samples"
    echo -n "${DEVICE_NAME} " >> ${CONFS}/momad.conf
    if [ "${SUBBANDING}" = true ]
    then
      taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -momad -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -median_step ${MEDIAN_STEP} -best 2>/dev/null 1>> ${CONFS}/momad.conf
    else
      taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -momad -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -dms ${DMS} -median_step ${MEDIAN_STEP} -best 2>/dev/null 1>> ${CONFS}/momad.conf
    fi
  elif [ "${SNR}" = "MOMSIGMACUT" ]
  then
    # MOMSIGMACUT specific
    echo "Tuning MaxStdSigmaCut for ${SAMPLES} samples"
    echo -n "${DEVICE_NAME} " >> ${CONFS}/max_std.conf
    if [ "${SUBBANDING}" = true ]
    then
      taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -max_std -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -nsigma ${NSIGMA} -best 2>/dev/null 1>> ${CONFS}/max_std.conf
    else
      taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -max_std -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -dms ${DMS} -nsigma ${NSIGMA} -best 2>/dev/null 1>> ${CONFS}/max_std.conf
    fi
  fi
  if [ "${SNR}" = "MOMAD" -o "${SNR}" = "MOMSIGMACUT" ]
  then
    # MOMAD and MOMSIGMACUT
    echo "Tuning MedianOfMedians (step one) for ${SAMPLES} samples"
    echo -n "${DEVICE_NAME} " >> ${CONFS}/mom_stepone.conf
    if [ "${SUBBANDING}" = true ]
    then
      taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -median -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -median_step ${MEDIAN_STEP} -best 2>/dev/null 1>> ${CONFS}/mom_stepone.conf
    else
      taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -median -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -dms ${DMS} -median_step ${MEDIAN_STEP} -best 2>/dev/null 1>> ${CONFS}/mom_stepone.conf
    fi
    MOM_STEPTWO_SAMPLES="`echo "${SAMPLES} / ${MEDIAN_STEP}" | bc -q`"
    echo "Tuning MedianOfMedians (step two) for ${MOM_STEPTWO_SAMPLES} samples"
    echo -n "${DEVICE_NAME} " >> ${CONFS}/mom_steptwo.conf
    if [ "${SUBBANDING}" = true ]
    then
      taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -median -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${MOM_STEPTWO_SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -median_step ${MOM_STEPTWO_SAMPLES} -best 2>/dev/null 1>> ${CONFS}/mom_steptwo.conf
    else
      taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -median -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${MOM_STEPTWO_SAMPLES} -dms ${DMS} -median_step ${MOM_STEPTWO_SAMPLES} -best 2>/dev/null 1>> ${CONFS}/mom_steptwo.conf
    fi
  fi

  # Integration steps
  echo "Generating integration_steps.conf file"
  echo ${INTEGRATION_STEPS} >> ${CONFS}/integration_steps.conf
  for STEP in ${INTEGRATION_STEPS}
  do
    STEP_SAMPLES="`echo "${SAMPLES} / ${STEP}" | bc -q`"
    MOM_STEPTWO_SAMPLES="`echo "${STEP_SAMPLES} / ${MEDIAN_STEP}" | bc -q`"
    echo -n "${DEVICE_NAME} " >> ${CONFS}/integration.conf
    if [ "${SUBBANDING}" = true ]
    then
      # Integration
      echo "Tuning Integration for step ${STEP}"
      taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/IntegrationTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -integration ${STEP} -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/integration.conf
    else
      # Integration
      echo "Tuning Integration for step ${STEP}"
      taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/IntegrationTuning -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -integration ${STEP} -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/integration.conf
    fi
    # SNR after downsampling
    if [ "${SNR}" = "SNR" ] 
    then
      # Standard SNR
      echo "Tuning SNR for ${STEP_SAMPLES} samples"
      echo -n "${DEVICE_NAME} " >> ${CONFS}/snr.conf
      if [ "${SUBBANDING}" = true ]
      then
        taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -snr -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/snr.conf
      else
        taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -snr -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/snr.conf
      fi
    elif [ "${SNR}" = "MOMAD" ]
    then
      # MOMAD specific
      echo "Tuning MAX for ${STEP_SAMPLES} samples"
      echo -n "${DEVICE_NAME} " >> ${CONFS}/max.conf
      if [ "${SUBBANDING}" = true ]
      then
        taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -max -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/max.conf
      else
        taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -snr -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -dms ${DMS} -best 2>/dev/null 1>> ${CONFS}/max.conf
      fi
      echo "Tuning MOMAD for ${STEP_SAMPLES} samples"
      echo -n "${DEVICE_NAME} " >> ${CONFS}/momad.conf
      if [ "${SUBBANDING}" = true ]
      then
        taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -momad -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -median_step ${MEDIAN_STEP} -best 2>/dev/null 1>> ${CONFS}/momad.conf
      else
        taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -momad -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -dms ${DMS} -median_step ${MEDIAN_STEP} -best 2>/dev/null 1>> ${CONFS}/momad.conf
      fi
    elif [ "${SNR}" = "MOMSIGMACUT" ]
    then
      # MOMSIGMACUT specific
      echo "Tuning MaxStdSigmaCut for ${STEP_SAMPLES} samples"
      echo -n "${DEVICE_NAME} " >> ${CONFS}/max_std.conf
      if [ "${SUBBANDING}" = true ]
      then
        taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -max_std -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -nsigma ${NSIGMA} -best 2>/dev/null 1>> ${CONFS}/max_std.conf
      else
        taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -max_std -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -dms ${DMS} -nsigma ${NSIGMA} -best 2>/dev/null 1>> ${CONFS}/max_std.conf
      fi
    fi
    if [ "${SNR}" = "MOMAD" -o "${SNR}" = "MOMSIGMACUT" ]
    then
      # MOMAD and MOMSIGMACUT
      echo "Tuning MedianOfMedians (step one) for ${STEP_SAMPLES} samples"
      echo -n "${DEVICE_NAME} " >> ${CONFS}/mom_stepone.conf
      if [ "${SUBBANDING}" = true ]
      then
        taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -median -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -median_step ${MEDIAN_STEP} -best 2>/dev/null 1>> ${CONFS}/mom_stepone.conf
      else
        taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -median -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -dms ${DMS} -median_step ${MEDIAN_STEP} -best 2>/dev/null 1>> ${CONFS}/mom_stepone.conf
      fi
      echo "Tuning MedianOfMedians (step two) for ${MOM_STEPTWO_SAMPLES} samples"
      echo -n "${DEVICE_NAME} " >> ${CONFS}/mom_steptwo.conf
      if [ "${SUBBANDING}" = true ]
      then
        taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -median -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${MOM_STEPTWO_SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -median_step ${MOM_STEPTWO_SAMPLES} -best 2>/dev/null 1>> ${CONFS}/mom_steptwo.conf
      else
        taskset -c ${CPU_CORE} ${INSTALL_ROOT}/bin/SNRTuning -median -iterations ${ITERATIONS} -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -vector ${DEVICE_THREADS} -min_threads ${MIN_THREADS} -max_threads ${MAX_THREADS} -max_items ${MAX_ITEMS} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${MOM_STEPTWO_SAMPLES} -dms ${DMS} -median_step ${MOM_STEPTWO_SAMPLES} -best 2>/dev/null 1>> ${CONFS}/mom_steptwo.conf
      fi
    fi
  done
}
