export SOURCE_ROOT=$HOME/pipeline
mkdir -p "${SOURCE_ROOT}"

# by default, use parallel make to speed things up
MAKE="make -j4"

# Machine specific settings
# DAS5
module load hdf5_18
export HDF5_INCLUDE="-I/cm/shared/apps/hdf5/current/include/"
export HDF5_LDFLAGS="-L/cm/shared/apps/hdf5/current/lib/"
export HDF5_LIBS="-lhdf5 -lhdf5_cpp -lz"

# manually copy psrdada if available. Not necessary for hardware test
cd "${SOURCE_ROOT}"
if [ -f ~/psrdada.tar.gz ]; then
  echo "PSRDada"
  tar -xvf ~/psrdada.tar.gz
  cd psrdada
  $MAKE
  export PSRDADA="${SOURCE_ROOT}/psrdada"
else
  echo "Skipping PSRDada"
fi

module load cuda80/toolkit

# fillringbuffer code
echo "Ringbuffer"
cd "${SOURCE_ROOT}"
git clone -b sc4 https://github.com/AA-ALERT/ringbuffer.git

echo "Utils"
cd "${SOURCE_ROOT}"
git clone            https://github.com/isazi/utils.git
cd utils && $MAKE all

echo "OpenCL"
cd "${SOURCE_ROOT}"
git clone            https://github.com/isazi/OpenCL.git
cd OpenCL && $MAKE all

echo "AstroData"
cd "${SOURCE_ROOT}"
git clone            https://github.com/isazi/AstroData.git
cd AstroData && $MAKE all

echo "Dedispersion"
cd "${SOURCE_ROOT}"
git clone            https://github.com/isazi/Dedispersion.git
cd Dedispersion && $MAKE all

echo "Integration"
cd "${SOURCE_ROOT}"
git clone            https://github.com/isazi/Integration.git
cd Integration && $MAKE all

echo "SNR"
cd "${SOURCE_ROOT}"
git clone            https://github.com/isazi/SNR.git
cd SNR && $MAKE all

echo "TransientSearch"
cd "${SOURCE_ROOT}"
git clone            https://github.com/isazi/TransientSearch.git
cd TransientSearch && $MAKE all
