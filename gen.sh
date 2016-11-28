export NEX=448
export NPROC=28
export model=s40rts
export ocean=.true.
export topog=.true.
export ellip=geo
export sediment=.true.

export wtime_spec="1:0:0"
export wtime_mesh="0:03:0"
export subdir="xinjiang"
export jname=gcmt_10

# source
export cmt=CMTSOLUTION_XJCh_GCMT
export station=STATIONS_XJCh

######################################
export nproc=$((${NPROC}*${NPROC}*6))
if [ $((${nproc}%24)) -gt 0 ]; then
    export nnode=$((${nproc}/24+1))
else
    export nnode=$((${nproc}/24))    
fi

export perfect_sphere=.false.
if [ ${ellip} == off ]; then
    perfect_sphere=.true.
fi

export ellip_par=.false.
if [ ${ellip} == full ]; then
    ellip_par=.true.
fi

mkdir ../SPECFEM_RUNS/${subdir}
mkdir ../SPECFEM_RUNS/${subdir}/${jname}
rsync -r --force --delete ../SPECFEM/ ../SPECFEM_RUNS/${subdir}/${jname}/

cp ../SPECFEM_RUNS/${subdir}/${jname}/DATA/${cmt} ../SPECFEM_RUNS/${subdir}/${jname}/DATA/CMTSOLUTION
cp ../SPECFEM_RUNS/${subdir}/${jname}/DATA/${station} ../SPECFEM_RUNS/${subdir}/${jname}/DATA/STATIONS

perl -pi -w -e "s/__NEX__/${NEX}/g;"                        ../SPECFEM_RUNS/${subdir}/${jname}/DATA/Par_file
perl -pi -w -e "s/__NPROC__/${NPROC}/g;"                    ../SPECFEM_RUNS/${subdir}/${jname}/DATA/Par_file
perl -pi -w -e "s/__MODEL__/${model}/g;"                    ../SPECFEM_RUNS/${subdir}/${jname}/DATA/Par_file
perl -pi -w -e "s/__OCEAN__/${ocean}/g;"                    ../SPECFEM_RUNS/${subdir}/${jname}/DATA/Par_file
perl -pi -w -e "s/__TOPOG__/${topog}/g;"                    ../SPECFEM_RUNS/${subdir}/${jname}/DATA/Par_file
perl -pi -w -e "s/__ELLIP__/${ellip_par}/g;"                ../SPECFEM_RUNS/${subdir}/${jname}/DATA/Par_file
perl -pi -w -e "s/__PERFECT_SPHERE__/${perfect_sphere}/g;"  ../SPECFEM_RUNS/${subdir}/${jname}/setup/constants.h.in
perl -pi -w -e "s/__DO_SEDIMENT__/${sediment}/g;"           ../SPECFEM_RUNS/${subdir}/${jname}/setup/constants.h.in

perl -pi -w -e "s/__NPROC__/${nproc}/g;"                    ../SPECFEM_RUNS/${subdir}/${jname}/mesh.bolt
perl -pi -w -e "s/__NNODE__/${nnode}/g;"                    ../SPECFEM_RUNS/${subdir}/${jname}/mesh.bolt
perl -pi -w -e "s/__JOBNAME__/${jname}/g;"                  ../SPECFEM_RUNS/${subdir}/${jname}/mesh.bolt
perl -pi -w -e "s/__SUBDIR__/${subdir}/g;"                  ../SPECFEM_RUNS/${subdir}/${jname}/mesh.bolt
perl -pi -w -e "s/__WALLTIME__/${wtime_mesh}/g;"            ../SPECFEM_RUNS/${subdir}/${jname}/mesh.bolt

perl -pi -w -e "s/__NPROC__/${nproc}/g;"                    ../SPECFEM_RUNS/${subdir}/${jname}/spec.bolt
perl -pi -w -e "s/__NNODE__/${nnode}/g;"                    ../SPECFEM_RUNS/${subdir}/${jname}/spec.bolt
perl -pi -w -e "s/__JOBNAME__/${jname}/g;"                  ../SPECFEM_RUNS/${subdir}/${jname}/spec.bolt
perl -pi -w -e "s/__SUBDIR__/${subdir}/g;"                  ../SPECFEM_RUNS/${subdir}/${jname}/spec.bolt
perl -pi -w -e "s/__WALLTIME__/${wtime_spec}/g;"            ../SPECFEM_RUNS/${subdir}/${jname}/spec.bolt

perl -pi -w -e "s/__JOBNAME__/${jname}/g;"                  ../SPECFEM_RUNS/${subdir}/${jname}/clear.bolt
perl -pi -w -e "s/__SUBDIR__/${subdir}/g;"                  ../SPECFEM_RUNS/${subdir}/${jname}/clear.bolt

cd ../SPECFEM_RUNS/${subdir}/${jname}
module swap PrgEnv-cray PrgEnv-gnu
module swap gcc gcc/6.1.0
./configure FC=ftn MPIFC=ftn CFLAGS="-Ofast -funroll-loops -DNDEBUG" FCFLAGS="-Ofast -funroll-loops -DNDEBUG" FLAGS_CHECK="-DFORCE_VECTORIZATION"
make meshfem3D -j16
make specfem3D -j16
qsub mesh.bolt


