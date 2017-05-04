# DAS5
module load hdf5_18
module load cuda80/toolkit
export HDF5_INCLUDE="-I${HDF5INCLUDE}"
export HDF5_LDFLAGS="-L${HDF5DIR}"
export HDF5_LIBS="-lhdf5 -lhdf5_cpp -lz"
