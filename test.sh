#!/bin/bash

testing() {
  source ${SCENARIO}

  # Downsampling
  if [ ${DOWNSAMPLING} -gt 1 ]
  then
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
    DISPERSED_SAMPLES="`echo "if (${DISPERSED_SAMPLES} % ${DOWNSAMPLING}) (${DISPERSED_SAMPLES} + (${DISPERSE_SAMPLES} % ${DOWNSAMPLING})) else (${DISPERSED_SAMPLES})" | bc -q`"
    CONF="`cat ${CONFS}/downsampling.conf | grep ${DEVICE_NAME} | grep " ${DISPERSED_SAMPLES} "`"
    echo -n "Testing Downsampling: "
    ${INSTALL_ROOT}/bin/IntegrationTesting -in_place -before_dedispersion -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -integration ${DOWNSAMPLING} -beams ${BEAMS} -samples ${DISPERSED_SAMPLES} -channels ${CHANNELS} -random -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`" -int_type "`echo ${CONF} | awk -F' ' '{print $9}'`"
    SAMPLES="`echo "${SAMPLES} / ${DOWNSAMPLING}" | bc -q`"
  fi

  # Dedispersion
  if [ "${SUBBANDING}" = true ]
  then
    CONF="`cat ${CONFS}/dedispersion_stepone.conf | grep ${DEVICE_NAME}`"
    LOCAL=""
    if [ "`echo ${CONF} | awk -F' ' '{print $4}'`" = "1" ]
    then
      LOCAL="-local"
    fi
    echo -n "Testing Dedispersion (step one): "
    ${INSTALL_ROOT}/bin/DedispersionTesting -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -step_one -beams ${BEAMS} -samples ${SAMPLES} -sampling_time ${SAMPLING_TIME} -min_freq ${MIN_FREQ} -channels ${CHANNELS} -channel_bandwidth ${CHANNEL_BANDWIDTH} -zapped_channels ${CONFS}/zapped_channels.conf -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -subbanding_dm_first ${SUBBANDING_DM_FIRST} -subbanding_dm_step ${SUBBANDING_DM_STEP} -random ${LOCAL} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $6}'`" -threadsD1 "`echo ${CONF} | awk -F' ' '{print $7}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $9}'`" -itemsD1 "`echo ${CONF} | awk -F' ' '{print $10}'`" -unroll "`echo ${CONF} | awk -F' ' '{print $5}'`"
    CONF="`cat ${CONFS}/dedispersion_steptwo.conf | grep ${DEVICE_NAME}`"
    LOCAL=""
    if [ "`echo ${CONF} | awk -F' ' '{print $4}'`" = "1" ]
    then
      LOCAL="-local"
    fi
    echo -n "Testing Dedispersion (step two): "
    ${INSTALL_ROOT}/bin/DedispersionTesting -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -step_two -beams ${BEAMS} -synthesized_beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -sampling_time ${SAMPLING_TIME} -min_freq ${MIN_FREQ} -channels ${CHANNELS} -channel_bandwidth ${CHANNEL_BANDWIDTH} -subbands ${SUBBANDS} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -random ${LOCAL} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $6}'`" -threadsD1 "`echo ${CONF} | awk -F' ' '{print $7}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $9}'`" -itemsD1 "`echo ${CONF} | awk -F' ' '{print $10}'`" -unroll "`echo ${CONF} | awk -F' ' '{print $5}'`"
  else
    echo -n "Testing Dedispersion: "
    CONF="`cat ${CONFS}/dedispersion.conf | grep ${DEVICE_NAME}`"
    LOCAL=""
    if [ "`echo ${CONF} | awk -F' ' '{print $4}'`" = "1" ]
    then
      LOCAL="-local"
    fi
    ${INSTALL_ROOT}/bin/DedispersionTesting -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -single_two -beams ${BEAMS} -synthesized_beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -sampling_time ${SAMPLING_TIME} -min_freq ${MIN_FREQ} -channels ${CHANNELS} -channel_bandwidth ${CHANNEL_BANDWIDTH} -zapped_channels ${ZAPPED_CHANNELS} -dms ${DMS} -dm_first ${DM_FIRST} -dm_step ${DM_STEP} -random ${LOCAL} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $6}'`" -threadsD1 "`echo ${CONF} | awk -F' ' '{print $7}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $9}'`" -itemsD1 "`echo ${CONF} | awk -F' ' '{print $10}'`" -unroll "`echo ${CONF} | awk -F' ' '{print $5}'`"
  fi

  # SNR before downsampling
  if [ "${MOMAD}" = true ]
  then
    CONF="`cat ${CONFS}/max.conf | grep ${DEVICE_NAME} | grep " ${SAMPLES} "`"
    echo -n "Testing MAX for ${SAMPLES} samples: "
    if [ "${SUBBANDING}" = true ]
    then
      ${INSTALL_ROOT}/bin/SNRTesting -max -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
    else
      ${INSTALL_ROOT}/bin/SNRTesting -max -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -dms ${DMS} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
    fi
    CONF="`cat ${CONFS}/mom_stepone.conf | grep ${DEVICE_NAME} | grep " ${SAMPLES} "`"
    echo -n "Testing MedianOfMedians (step one) for ${SAMPLES} samples: "
    if [ "${SUBBANDING}" = true ]
    then
      ${INSTALL_ROOT}/bin/SNRTesting -median -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -median_step ${MEDIAN_STEP} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
    else
      ${INSTALL_ROOT}/bin/SNRTesting -median -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -dms ${DMS} -median_step ${MEDIAN_STEP} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
    fi
    MOM_STEPTWO_SAMPLES="`echo "${SAMPLES} / ${MEDIAN_STEP}" | bc -q`"
    CONF="`cat ${CONFS}/mom_steptwo.conf | grep ${DEVICE_NAME} | grep " ${MOM_STEPTWO_SAMPLES} "`"
    echo -n "Testing MedianOfMedians (step two) for ${MOM_STEPTWO_SAMPLES} samples: "
    if [ "${SUBBANDING}" = true ]
    then
      ${INSTALL_ROOT}/bin/SNRTesting -median -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${MOM_STEPTWO_SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -median_step ${MOM_STEPTWO_SAMPLES} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
    else
      ${INSTALL_ROOT}/bin/SNRTesting -median -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${MOM_STEPTWO_SAMPLES} -dms ${DMS} -median_step ${MOM_STEPTWO_SAMPLES} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
    fi
    CONF="`cat ${CONFS}/momad.conf | grep ${DEVICE_NAME} | grep " ${SAMPLES} "`"
    echo -n "Testing MOMAD for ${SAMPLES} samples: "
    if [ "${SUBBANDING}" = true ]
    then
      ${INSTALL_ROOT}/bin/SNRTesting -momad -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -median_step ${MEDIAN_STEP} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
    else
      ${INSTALL_ROOT}/bin/SNRTesting -momad -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -dms ${DMS} -median_step ${MEDIAN_STEP} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
    fi
  else
    CONF="`cat ${CONFS}/snr.conf | grep ${DEVICE_NAME} | grep " ${SAMPLES} "`"
    echo -n "Testing SNR for ${SAMPLES} samples: "
    if [ "${SUBBANDING}" = true ]
    then
      ${INSTALL_ROOT}/bin/SNRTesting -snr -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
    else
      ${INSTALL_ROOT}/bin/SNRTesting -snr -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -dms ${DMS} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
    fi
  fi

  # Integration steps
  for STEP in ${INTEGRATION_STEPS}
  do
    STEP_SAMPLES="`echo "${SAMPLES} / ${STEP}" | bc -q`"
    if [ "${SUBBANDING}" = true ]
    then
      # Integration
      CONF="`cat ${CONFS}/integration.conf | grep ${DEVICE_NAME} | grep " ${STEP} "`"
      echo -n "Testing Integration for step ${STEP}: "
      ${INSTALL_ROOT}/bin/IntegrationTesting -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -subband -integration ${STEP} -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -random -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`" -int_type "`echo ${CONF} | awk -F' ' '{print $9}'`"
    else
      # Integration
      CONF="`cat ${CONFS}/integration.conf | grep ${DEVICE_NAME} | grep " ${STEP} "`"
      echo -n "Testing Integration for step ${STEP}: "
      ${INSTALL_ROOT}/bin/IntegrationTesting -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -integration ${STEP} -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -dms ${DMS} -random -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`" -int_type "`echo ${CONF} | awk -F' ' '{print $9}'`"
    fi
    if [ "${MOMAD}" = true ]
    then
      CONF="`cat ${CONFS}/max.conf | grep ${DEVICE_NAME} | grep " ${STEP_SAMPLES} "`"
      echo -n "Testing MAX for ${STEP_SAMPLES} samples: "
      if [ "${SUBBANDING}" = true ]
      then
        ${INSTALL_ROOT}/bin/SNRTesting -max -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
      else
        ${INSTALL_ROOT}/bin/SNRTesting -max -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -dms ${DMS} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
      fi
      CONF="`cat ${CONFS}/mom_stepone.conf | grep ${DEVICE_NAME} | grep " ${STEP_SAMPLES} "`"
      echo -n "Testing MedianOfMedians (step one) for ${STEP_SAMPLES} samples: "
      if [ "${SUBBANDING}" = true ]
      then
        ${INSTALL_ROOT}/bin/SNRTesting -median -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -median_step ${MEDIAN_STEP} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
      else
        ${INSTALL_ROOT}/bin/SNRTesting -median -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -dms ${DMS} -median_step ${MEDIAN_STEP} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
      fi
      MOM_STEPTWO_SAMPLES="`echo "${STEP_SAMPLES} / ${MEDIAN_STEP}" | bc -q`"
      CONF="`cat ${CONFS}/mom_steptwo.conf | grep ${DEVICE_NAME} | grep " ${MOM_STEPTWO_SAMPLES} "`"
      echo -n "Testing MedianOfMedians (step two) for ${MOM_STEPTWO_SAMPLES} samples: "
      if [ "${SUBBANDING}" = true ]
      then
        ${INSTALL_ROOT}/bin/SNRTesting -median -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${MOM_STEPTWO_SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -median_step ${MOM_STEPTWO_SAMPLES} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
      else
        ${INSTALL_ROOT}/bin/SNRTesting -median -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${MOM_STEPTWO_SAMPLES} -dms ${DMS} -median_step ${MOM_STEPTWO_SAMPLES} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
      fi
      CONF="`cat ${CONFS}/momad.conf | grep ${DEVICE_NAME} | grep " ${STEP_SAMPLES} "`"
      echo -n "Testing MOMAD for ${STEP_SAMPLES} samples: "
      if [ "${SUBBANDING}" = true ]
      then
        ${INSTALL_ROOT}/bin/SNRTesting -momad -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -median_step ${MEDIAN_STEP} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
      else
        ${INSTALL_ROOT}/bin/SNRTesting -momad -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLESs} -dms ${DMS} -median_step ${MEDIAN_STEP} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
      fi
    else
      if [ "${SUBBANDING}" = true ]
      then
        # SNR after downsampling
        CONF="`cat ${CONFS}/snr.conf | grep ${DEVICE_NAME} | grep " ${STEP_SAMPLES} "`"
        echo -n "Testing SNR for ${STEP_SAMPLES} samples: "
        ${INSTALL_ROOT}/bin/SNRTesting -snr -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
      else
        # SNR after downsampling
        CONF="`cat ${CONFS}/snr.conf | grep ${DEVICE_NAME} | grep " ${STEP_SAMPLES} "`"
        echo -n "Testing SNR for `echo "${SAMPLES} / ${STEP}" | bc -q` samples: "
        ${INSTALL_ROOT}/bin/SNRTesting -snr -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -dms ${DMS} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
      fi
    fi
  done
}
