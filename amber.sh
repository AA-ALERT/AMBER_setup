#!/bin/bash

MAKE="make"

if [ -z "${SOURCE_ROOT}" ]
then
  echo "Please set SOURCE_ROOT first; SOURCE_ROOT is the directory where source code will be kept."
  exit 1
fi

if [ -z "${INSTALL_ROOT}" ]
then
  echo "Please set INSTALL_ROOT first; INSTALL_ROOT is the directory where the software will be installed."
  exit 1
fi

# Save script directory
DIR=`realpath ${0}`
DIR=`dirname ${DIR}`

# Usage function
usage () {
  echo "Usage: ${0} <install | update | tune> <branch | scenario> <configuration_path>"
  echo -e "\tinstall <branch>: install the specified branch of AMBER."
  echo -e "\t\tbranch: development branch to install. The default is master."
  echo -e "\tupdate <branch>: update an already existing installation of AMBER. The default branch is master."
  echo -e "\t\tbranch: development branch to update. The default is master."
  echo -e "\ttune scenario configuration_path: tune the AMBER modules and save the generated configuration files."
  echo -e "\t\tscenario: script containing tuning parameters and constraints."
  echo -e "\t\tconfiguration_path: directory where to save the generated configuration files."
}

# Create directories
mkdir -p "${SOURCE_ROOT}"
mkdir -p "${INSTALL_ROOT}"

# Process command line
if [ ${#} -lt 1 -o ${#} -gt 3 ]
then
  usage
  exit 1
else
  COMMAND=${1}
  if [ ${COMMAND} = "install" ]
  then
    if [ -n ${2} ]
    then
      BRANCH=${2}
    else
      BRANCH="master"
    fi
    source ${DIR}/install.sh
  elif [ ${COMMAND} = "update" ]
  then
    if [ -n ${2} ]
    then
      BRANCH=${2}
    else
      BRANCH="master"
    fi
    source ${DIR}/update.sh
  elif [ ${COMMAND} = "tune" ]
  then
    SCENARIO=${2}
    CONFS=${3}
    if [ -z ${SCENARIO} -o -z ${CONFS} ]
    then
      usage
      exit 1
    fi
    source ${DIR}/tune.sh
  else
    usage
    exit 1
  fi
fi

exit 0
