#!/bin/bash

update() {
  echo "Updating github.com/isazi/utils"
  cd "${SOURCE_ROOT}"
  cd utils
  git stash
  git checkout ${BRANCH}
  git pull
  echo

  echo "Updating github.com/isazi/OpenCL"
  cd "${SOURCE_ROOT}"
  cd OpenCL
  git stash
  git checkout ${BRANCH}
  git pull
  echo

  echo "Updating github.com/AA-ALERT/AstroData"
  cd "${SOURCE_ROOT}"
  cd AstroData
  git stash
  git checkout ${BRANCH}
  git pull
  echo

  echo "Updating github.com/AA-ALERT/Dedispersion"
  cd "${SOURCE_ROOT}"
  cd Dedispersion
  git stash
  git checkout ${BRANCH}
  git pull
  echo

  echo "Updating github.com/AA-ALERT/Integration"
  cd "${SOURCE_ROOT}"
  cd Integration
  git stash
  git checkout ${BRANCH}
  git pull
  echo

  echo "Updating github.com/AA-ALERT/SNR"
  cd "${SOURCE_ROOT}"
  cd SNR
  git stash
  git checkout ${BRANCH}
  git pull
  echo

  echo "Updating github.com/AA-ALERT/RFIm"
  cd "${SOURCE_ROOT}"
  cd RFIm
  git stash
  git checkout ${BRANCH}
  git pull
  echo

  echo "Updating github.com/AA-ALERT/AMBER"
  cd "${SOURCE_ROOT}"
  cd AMBER
  git stash
  git checkout ${BRANCH}
  git pull
  echo
}
