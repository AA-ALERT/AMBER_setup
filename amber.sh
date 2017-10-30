#!/bin/bash

# By default, use parallel make to speed things up
MAKE="make -j"

if [ -z "${SOURCE_ROOT}" ]
then
  echo "Please set SOURCE_ROOT first; SOURCE_ROOT is the directory where source code will be kept."
  exit
fi

if [ -z "${INSTALL_ROOT}" ]
then
  echo "Please set INSTALL_ROOT first; INSTALL_ROOT is the directory where the software will be installed."
  exit
fi

# Save script directory
DIR=`realpath ${0}`
DIR=`dirname ${DIR}`

# Usage function
usage () {
  echo "Usage: ${0} <install | update>"
}

# Create directories
mkdir -p "${SOURCE_ROOT}"
mkdir -p "${INSTALL_ROOT}"

# Process command line
if [ ${#} -lt 2 ]
then
  usage
fi

if [ "${1}" = "install" ]
then
  source ${DIR}/install.sh
elif [ "${1}" = "update" ]
then
  source ${DIR}/update.sh
else
  usage
fi

exit
