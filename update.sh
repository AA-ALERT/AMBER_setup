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

  echo "Updating github.com/TRASAL/AstroData"
  cd "${SOURCE_ROOT}"
  cd AstroData
  git stash
  git checkout ${BRANCH}
  git pull
  echo

  echo "Updating github.com/TRASAL/Dedispersion"
  cd "${SOURCE_ROOT}"
  cd Dedispersion
  git stash
  git checkout ${BRANCH}
  git pull
  echo

  echo "Updating github.com/TRASAL/Integration"
  cd "${SOURCE_ROOT}"
  cd Integration
  git stash
  git checkout ${BRANCH}
  git pull
  echo

  echo "Updating github.com/TRASAL/SNR"
  cd "${SOURCE_ROOT}"
  cd SNR
  git stash
  git checkout ${BRANCH}
  git pull
  echo

  echo "Updating github.com/TRASAL/RFIm"
  cd "${SOURCE_ROOT}"
  cd RFIm
  git stash
  git checkout ${BRANCH}
  git pull
  echo

  echo "Updating github.com/TRASAL/AMBER"
  cd "${SOURCE_ROOT}"
  cd AMBER
  git stash
  git checkout ${BRANCH}
  git pull
  echo
}
