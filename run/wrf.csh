#!/bin/tcsh
### Job Name
#PBS -N mpi_job
### Project code
#PBS -A UCDV0024
#PBS -l walltime=06:00:00
#PBS -q regular
### Merge output and error files
#PBS -j oe
#PBS -k eod
### Select 2 nodes with 36 CPUs each for a total of 72 MPI processes
#PBS -l select=1:ncpus=36:mpiprocs=36
### Send email on abort, begin and end
#PBS -m abe
### Specify mail recipient
#PBS -M azqhu@ucdavis.edu 

setenv TMPDIR /glade/scratch/$USER/temp
mkdir -p $TMPDIR

### Run the executable
mpiexec_mpt ./wrf.exe
