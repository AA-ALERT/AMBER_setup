#!/bin/bash

install() {
  echo "Installing github.com/isazi/utils"
  cd "${SOURCE_ROOT}"
  git clone -b ${BRANCH} -q https://github.com/isazi/utils.git
  cd utils
  mkdir build
  cd build
  cmake ${CMAKE_BUILD_ARGUMENTS} ..
  ${MAKE} install
  echo

  echo "Installing github.com/isazi/OpenCL"
  cd "${SOURCE_ROOT}"
  git clone -b ${BRANCH} -q https://github.com/isazi/OpenCL.git
  cd OpenCL
  mkdir build
  cd build
  cmake ${CMAKE_BUILD_ARGUMENTS} ..
  ${MAKE} install
  echo

  echo "Installing github.com/TRASAL/AstroData"
  cd "${SOURCE_ROOT}"
  git clone -b ${BRANCH} -q https://github.com/TRASAL/AstroData.git
  cd AstroData
  mkdir build
  cd build
  cmake ${CMAKE_BUILD_ARGUMENTS} ..
  ${MAKE} install
  echo

  echo "Installing github.com/TRASAL/Dedispersion"
  cd "${SOURCE_ROOT}"
  git clone -b ${BRANCH} -q https://github.com/TRASAL/Dedispersion.git
  cd Dedispersion
  mkdir build
  cd build
  cmake ${CMAKE_BUILD_ARGUMENTS} ..
  ${MAKE} install
  echo

  echo "Installing github.com/TRASAL/Integration"
  cd "${SOURCE_ROOT}"
  git clone -b ${BRANCH} -q https://github.com/TRASAL/Integration.git
  cd Integration
  mkdir build
  cd build
  cmake ${CMAKE_BUILD_ARGUMENTS} ..
  ${MAKE} install
  echo

  echo "Installing github.com/TRASAL/SNR"
  cd "${SOURCE_ROOT}"
  git clone -b ${BRANCH} -q https://github.com/TRASAL/SNR.git
  cd SNR
  mkdir build
  cd build
  cmake ${CMAKE_BUILD_ARGUMENTS} ..
  ${MAKE} install
  echo

  echo "Installing github.com/TRASAL/RFIm"
  cd "${SOURCE_ROOT}"
  git clone -b ${BRANCH} -q https://github.com/TRASAL/RFIm.git
  cd RFIm
  mkdir build
  cd build
  cmake ${CMAKE_BUILD_ARGUMENTS} ..
  ${MAKE} install
  echo

  echo "Installing github.com/TRASAL/AMBER"
  cd "${SOURCE_ROOT}"
  git clone -b ${BRANCH} -q https://github.com/TRASAL/AMBER.git
  cd AMBER
  mkdir build
  cd build
  cmake ${CMAKE_BUILD_ARGUMENTS} ..
  ${MAKE} install
  echo
}
