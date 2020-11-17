#!/bin/bash

compile() {
  echo "Compiling github.com/isazi/utils"
  cd "${SOURCE_ROOT}"
  cd utils/build
  ${MAKE} clean
  ${MAKE} install
  echo

  echo "Compiling github.com/isazi/OpenCL"
  cd "${SOURCE_ROOT}"
  cd OpenCL/build
  ${MAKE} clean
  ${MAKE} install
  echo

  echo "Compiling github.com/TRASAL/AstroData"
  cd "${SOURCE_ROOT}"
  cd AstroData/build
  ${MAKE} clean
  ${MAKE} install
  echo

  echo "Compiling github.com/TRASAL/Dedispersion"
  cd "${SOURCE_ROOT}"
  cd Dedispersion/build
  ${MAKE} clean
  ${MAKE} install
  echo

  echo "Compiling github.com/TRASAL/Integration"
  cd "${SOURCE_ROOT}"
  cd Integration/build
  ${MAKE} clean
  ${MAKE} install
  echo

  echo "Compiling github.com/TRASAL/SNR"
  cd "${SOURCE_ROOT}"
  cd SNR/build
  ${MAKE} clean
  ${MAKE} install
  echo

  echo "Compiling github.com/TRASAL/RFIm"
  cd "${SOURCE_ROOT}"
  cd RFIm/build
  ${MAKE} clean
  ${MAKE} install
  echo

  echo "Compiling github.com/TRASAL/AMBER"
  cd "${SOURCE_ROOT}"
  cd AMBER/build
  ${MAKE} clean
  ${MAKE} install
  echo
}
