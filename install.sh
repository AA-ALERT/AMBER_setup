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

  echo "Installing github.com/AA-ALERT/AstroData"
  cd "${SOURCE_ROOT}"
  git clone -b ${BRANCH} -q https://github.com/AA-ALERT/AstroData.git
  cd AstroData
  mkdir build
  cd build
  cmake ${CMAKE_BUILD_ARGUMENTS} ..
  ${MAKE} install
  echo

  echo "Installing github.com/AA-ALERT/Dedispersion"
  cd "${SOURCE_ROOT}"
  git clone -b ${BRANCH} -q https://github.com/AA-ALERT/Dedispersion.git
  cd Dedispersion
  mkdir build
  cd build
  cmake ${CMAKE_BUILD_ARGUMENTS} ..
  ${MAKE} install
  echo

  echo "Installing github.com/AA-ALERT/Integration"
  cd "${SOURCE_ROOT}"
  git clone -b ${BRANCH} -q https://github.com/AA-ALERT/Integration.git
  cd Integration
  mkdir build
  cd build
  cmake ${CMAKE_BUILD_ARGUMENTS} ..
  ${MAKE} install
  echo

  echo "Installing github.com/AA-ALERT/SNR"
  cd "${SOURCE_ROOT}"
  git clone -b ${BRANCH} -q https://github.com/AA-ALERT/SNR.git
  cd SNR
  mkdir build
  cd build
  cmake ${CMAKE_BUILD_ARGUMENTS} ..
  ${MAKE} install
  echo

  echo "Installing github.com/AA-ALERT/AMBER"
  cd "${SOURCE_ROOT}"
  git clone -b ${BRANCH} -q https://github.com/AA-ALERT/AMBER.git
  cd AMBER
  mkdir build
  cd build
  cmake ${CMAKE_BUILD_ARGUMENTS} ..
  ${MAKE} install
  echo
}
