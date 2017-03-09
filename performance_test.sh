echo "Running demo"

./bin/TransientSearch -opencl_platform 0 -opencl_device 0 -device_name TitanX_Pascal -padding_file confs/padding.inc -zapped_channels confs/empty.inc -integration_steps confs/integration_stepsDEMO.inc -integration_file confs/integrationDEMO.inc -snr_file confs/snrDEMO.inc -subband_dedispersion -dedispersion_step_one_file confs/dedispersionOneDEMO.inc -dedispersion_step_two_file confs/dedispersionTwoDEMO.inc -input_bits 8 -output /var/scratch/alessio/BusyWeekDEMO/demo01 -subbands 32 -subbanding_dms 32 -subbanding_dm_first 0 -subbanding_dm_step 6.4 -dms 32 -dm_first 0.0 -dm_step 0.2 -threshold 16 -random -width 32 -dm 100 -beams 1 -synthesized_beams 1 -batches 120 -channels 512 -min_freq 1492 -channel_bandwidth 0.5859 -samples 8192

exit 0
