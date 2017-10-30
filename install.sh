#!/bin/bash

echo "Installing github.com/isazi/utils"
cd "${SOURCE_ROOT}"
git clone https://github.com/isazi/utils.git
cd utils && ${MAKE} install
echo

echo "Installing github.com/isazi/OpenCL"
cd "${SOURCE_ROOT}"
git clone https://github.com/isazi/OpenCL.git
cd OpenCL && ${MAKE} install
echo

echo "Installing github.com/AA-ALERT/AstroData"
cd "${SOURCE_ROOT}"
git clone https://github.com/AA-ALERT/AstroData.git
cd AstroData && ${MAKE} install
echo

echo "Installing github.com/AA-ALERT/Dedispersion"
cd "${SOURCE_ROOT}"
git clone https://github.com/AA-ALERT/Dedispersion.git
cd Dedispersion && ${MAKE} install
echo

echo "Installing github.com/AA-ALERT/Integration"
cd "${SOURCE_ROOT}"
git clone https://github.com/AA-ALERT/Integration.git
cd Integration && ${MAKE} install
echo

echo "Installing github.com/AA-ALERT/SNR"
cd "${SOURCE_ROOT}"
git clone https://github.com/AA-ALERT/SNR.git
cd SNR && ${MAKE} install
echo

echo "Installing github.com/AA-ALERT/AMBER"
cd "${SOURCE_ROOT}"
git clone https://github.com/AA-ALERT/AMBER.git
cd AMBER && ${MAKE} install
echo
