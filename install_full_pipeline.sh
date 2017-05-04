#!/bin/bash

if [ -z "${SOURCE_ROOT}" ]; then
  echo "Please set SOURCE_ROOT first"
  exit
fi

# by default, use parallel make to speed things up
MAKE="make -j"
mkdir -p "${SOURCE_ROOT}"

# save directory path to this repo
cd `dirname $0`
ARTSHARDWARE=`pwd`

# Not necessary for hardware test
cd "${SOURCE_ROOT}"
if false ; then
  echo "PSRDada"
  tar -xvf "${ARTSHARDWARE}/optional/psrdada.tar.gz"
  cd psrdada
  $MAKE
  export PSRDADA="${SOURCE_ROOT}/psrdada"

  echo "Ringbuffer"
  cd "${SOURCE_ROOT}"
  git clone -b sc4 https://github.com/AA-ALERT/ringbuffer.git
  cd ringbuffer && $MAKE
else
  echo "Skipping PSRDada and fill ringbuffer"
fi

echo "Utils"
cd "${SOURCE_ROOT}"
git clone            https://github.com/isazi/utils.git
cd utils && $MAKE all

echo "OpenCL"
cd "${SOURCE_ROOT}"
git clone            https://github.com/isazi/OpenCL.git
cd OpenCL && $MAKE all

echo "AstroData"
cd "${SOURCE_ROOT}"
git clone            https://github.com/isazi/AstroData.git
cd AstroData && $MAKE all

echo "Dedispersion"
cd "${SOURCE_ROOT}"
git clone            https://github.com/isazi/Dedispersion.git
cd Dedispersion && $MAKE all

echo "Integration"
cd "${SOURCE_ROOT}"
git clone            https://github.com/isazi/Integration.git
cd Integration && $MAKE all

echo "SNR"
cd "${SOURCE_ROOT}"
git clone            https://github.com/isazi/SNR.git
cd SNR && $MAKE all

echo "TransientSearch"
cd "${SOURCE_ROOT}"
git clone            https://github.com/isazi/TransientSearch.git
cd TransientSearch && $MAKE all
