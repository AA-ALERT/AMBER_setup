# DAS5
module load hdf5_18
module load cuda80/toolkit
export HDF5_INCLUDE="-I/cm/shared/apps/hdf5/current/include/"
export HDF5_LDFLAGS="-L/cm/shared/apps/hdf5/current/lib/"
export HDF5_LIBS="-lhdf5 -lhdf5_cpp -lz"
