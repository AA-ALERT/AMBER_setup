#!/bin/bash

MODULES="utils OpenCL AstroData Dedispersion Integration SNR TransientSearch"

for module in ${MODULES}
do
  echo "Updating ${module}"
  cd ${SOURCE_ROOT}/${module}
  git pull
  $MAKE all
done

exit

echo "Updating github.com/isazi/utils"
cd "${SOURCE_ROOT}/utils"
git pull && ${MAKE} install
echo

echo "Updating github.com/isazi/OpenCL"
cd "${SOURCE_ROOT}/OpenCL"
git pull && ${MAKE} install
echo

echo "Updating github.com/AA-ALERT/AstroData"
cd "${SOURCE_ROOT}/AstroData"
git pull && ${MAKE} install
echo

echo "Updating github.com/AA-ALERT/Dedispersion"
cd "${SOURCE_ROOT}/Dedispersion"
git pull && ${MAKE} install
echo

echo "Updating github.com/AA-ALERT/Integration"
cd "${SOURCE_ROOT}/Integration"
git pull && ${MAKE} install
echo

echo "Updating github.com/AA-ALERT/SNR"
cd "${SOURCE_ROOT}/SNR"
git pull && ${MAKE} install
echo

echo "Updating github.com/AA-ALERT/AMBER"
cd "${SOURCE_ROOT}/AMBER"
git pull && ${MAKE} install
echo
