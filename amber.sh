#!/bin/bash

MAKE="make -j"

# Check that the necessary environmental variables are set
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

# Set CMake build arguments
CMAKE_BUILD_ARGUMENTS="-DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT}"
if [ -z ${DEBUG} ]
then
  CMAKE_BUILD_ARGUMENTS="${CMAKE_BUILD_ARGUMENTS} -DCMAKE_BUILD_TYPE=Release"
else
  CMAKE_BUILD_ARGUMENTS="${CMAKE_BUILD_ARGUMENTS} -DCMAKE_BUILD_TYPE=Debug"
fi

# Set AMBER include and library path
OLD_CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}
export CPLUS_INCLUDE_PATH="${INSTALL_ROOT}/include:${CPLUS_INCLUDE_PATH}"
OLD_LIBRARY_PATH=${LIBRARY_PATH}
export LIBRARY_PATH="${INSTALL_ROOT}/lib64:${LIBRARY_PATH}"

# Save script directory
DIR=`realpath ${0}`
DIR=`dirname ${DIR}`

# Import modules
source ${DIR}/install.sh
source ${DIR}/update.sh
source ${DIR}/tune.sh
source ${DIR}/compile.sh
source ${DIR}/test.sh

# Usage function
usage () {
  echo "Usage: ${0} <install | update | compile | tune | test> <branch | scenario> <configuration_path>"
  echo
  echo -e "\tinstall <branch>: install the specified branch of AMBER."
  echo -e "\t\tbranch: development branch to install. The default is master."
  echo
  echo -e "\tupdate <branch>: update an already existing installation of AMBER. The default branch is master."
  echo -e "\t\tbranch: development branch to update. The default is master."
  echo
  echo -e "\tcompile: recompiles and install the current branch of AMBER."
  echo
  echo -e "\ttune scenario configuration_path: tune the AMBER modules and save the generated configuration files."
  echo -e "\t\tscenario: script containing tuning and observational parameters and constraints."
  echo -e "\t\tconfiguration_path: directory where to save the generated configuration files."
  echo
  echo -e "\ttest scenario configuration_path: test tuned AMBER configurations."
  echo -e "\t\tscenario: script containing observational parameters."
  echo -e "\t\tconfiguration_path: directory containing the generated configuration files."
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
    install
  elif [ ${COMMAND} = "update" ]
  then
    if [ -n ${2} ]
    then
      BRANCH=${2}
    else
      BRANCH="master"
    fi
    update
  elif [ ${COMMAND} = "tune" ]
  then
    SCENARIO=${2}
    CONFS=${3}
    if [ -z ${SCENARIO} -o -z ${CONFS} ]
    then
      usage
      exit 1
    fi
    tune
  elif [ ${COMMAND} = "compile" ]
  then
    compile
  elif [ ${COMMAND} = "test" ]
  then
    SCENARIO=${2}
    CONFS=${3}
    if [ -z ${SCENARIO} -o -z ${CONFS} ]
    then
      usage
      exit 1
    fi
    testing
  else
    usage
    exit 1
  fi
fi

# Restore variables that were exported outside the scope of this script
export CPLUS_INCLUDE_PATH=${OLD_CPLUS_INCLUDE_PATH}
export LIBRARY_PATH=${OLD_LIBRARY_PATH}

exit 0
