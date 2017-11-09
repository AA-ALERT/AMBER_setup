#!/bin/bash

echo "Compiling github.com/isazi/utils"
cd "${SOURCE_ROOT}"
cd utils
${MAKE} clean
${MAKE} install
echo

echo "Compiling github.com/isazi/OpenCL"
cd "${SOURCE_ROOT}"
cd OpenCL
${MAKE} clean
${MAKE} install
echo

echo "Compiling github.com/AA-ALERT/AstroData"
cd "${SOURCE_ROOT}"
cd AstroData
${MAKE} clean
${MAKE} install
echo

echo "Compiling github.com/AA-ALERT/Dedispersion"
cd "${SOURCE_ROOT}"
cd Dedispersion
${MAKE} clean
${MAKE} install
echo

echo "Compiling github.com/AA-ALERT/Integration"
cd "${SOURCE_ROOT}"
cd Integration
${MAKE} clean
${MAKE} install
echo

echo "Compiling github.com/AA-ALERT/SNR"
cd "${SOURCE_ROOT}"
cd SNR
${MAKE} clean
${MAKE} install
echo

echo "Compiling github.com/AA-ALERT/AMBER"
cd "${SOURCE_ROOT}"
cd AMBER
${MAKE} clean
${MAKE} install
echo
