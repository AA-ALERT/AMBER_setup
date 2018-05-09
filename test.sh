#!/bin/bash

testing() {
  source ${SCENARIO}

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
  CONF="`cat ${CONFS}/snr.conf | grep ${DEVICE_NAME} | grep " ${SAMPLES} "`"
  echo -n "Testing SNR for ${SAMPLES} samples: "
  if [ "${SUBBANDING}" = true ]
  then
    ${INSTALL_ROOT}/bin/SNRTesting -snr -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
  else
    ${INSTALL_ROOT}/bin/SNRTesting -snr -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -dms ${DMS} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
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
      ${INSTALL_ROOT}/bin/IntegrationTesting -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -subband -integration ${STEP} -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -random -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
      # SNR after downsampling
      CONF="`cat ${CONFS}/snr.conf | grep ${DEVICE_NAME} | grep " ${STEP_SAMPLES} "`"
      echo -n "Testing SNR for ${STEP_SAMPLES} samples: "
      ${INSTALL_ROOT}/bin/SNRTesting -snr -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -subband -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -subbanding_dms ${SUBBANDING_DMS} -dms ${DMS} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
    else
      # Integration
      CONF="`cat ${CONFS}/integration.conf | grep ${DEVICE_NAME} | grep " ${STEP} "`"
      echo -n "Testing Integration for step ${STEP}: "
      ${INSTALL_ROOT}/bin/IntegrationTesting -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -integration ${STEP} -beams ${SYNTHESIZED_BEAMS} -samples ${SAMPLES} -dms ${DMS} -random -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
      # SNR after downsampling
      CONF="`cat ${CONFS}/snr.conf | grep ${DEVICE_NAME} | grep " ${STEP_SAMPLES} "`"
      echo -n "Testing SNR for `echo "${SAMPLES} / ${STEP}" | bc -q` samples: "
      ${INSTALL_ROOT}/bin/SNRTesting -snr -opencl_platform ${OPENCL_PLATFORM} -opencl_device ${OPENCL_DEVICE} -padding ${DEVICE_PADDING} -dms_samples -beams ${SYNTHESIZED_BEAMS} -samples ${STEP_SAMPLES} -dms ${DMS} -threadsD0 "`echo ${CONF} | awk -F' ' '{print $5}'`" -itemsD0 "`echo ${CONF} | awk -F' ' '{print $8}'`"
    fi
  done
}
