#!/bin/bash

install() {
  echo "Installing github.com/isazi/utils"
  cd "${SOURCE_ROOT}"
  git clone https://github.com/isazi/utils.git
  cd utils
  git checkout ${BRANCH}
  ${MAKE} install
  echo

  echo "Installing github.com/isazi/OpenCL"
  cd "${SOURCE_ROOT}"
  git clone https://github.com/isazi/OpenCL.git
  cd OpenCL
  git checkout ${BRANCH}
  ${MAKE} install
  echo

  echo "Installing github.com/AA-ALERT/AstroData"
  cd "${SOURCE_ROOT}"
  git clone https://github.com/AA-ALERT/AstroData.git
  cd AstroData
  git checkout ${BRANCH}
  ${MAKE} install
  echo

  echo "Installing github.com/AA-ALERT/Dedispersion"
  cd "${SOURCE_ROOT}"
  git clone https://github.com/AA-ALERT/Dedispersion.git
  cd Dedispersion
  git checkout ${BRANCH}
  ${MAKE} install
  echo

  echo "Installing github.com/AA-ALERT/Integration"
  cd "${SOURCE_ROOT}"
  git clone https://github.com/AA-ALERT/Integration.git
  cd Integration
  git checkout ${BRANCH}
  ${MAKE} install
  echo

  echo "Installing github.com/AA-ALERT/SNR"
  cd "${SOURCE_ROOT}"
  git clone https://github.com/AA-ALERT/SNR.git
  cd SNR
  git checkout ${BRANCH}
  ${MAKE} install
  echo

  echo "Installing github.com/AA-ALERT/AMBER"
  cd "${SOURCE_ROOT}"
  git clone https://github.com/AA-ALERT/AMBER.git
  cd AMBER
  git checkout ${BRANCH}
  ${MAKE} install
  echo
}
