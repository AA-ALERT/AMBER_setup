#!/bin/bash

if [ -z "${SOURCE_ROOT}" ]; then
  echo "Please set SOURCE_ROOT first."
  exit
fi

MAKE="make -j"

MODULES="utils OpenCL AstroData Dedispersion Integration SNR TransientSearch"

for module in ${MODULES}
do
  cd ${SOURCE_ROOT}/${module}
  git pull
  $MAKE all
done

exit

