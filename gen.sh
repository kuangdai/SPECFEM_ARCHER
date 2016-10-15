export T0=10

export NEX=448
export NPROC=28
export model=1D_transversely_isotropic_prem
export ocean=.false.
export topog=.false.
export ellip=geo

export wtime_spec="1:0:0"
export wtime_mesh="0:03:0"
export subdir="ellip"
export jname=pr2_10_geo

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

perl -pi -w -e "s/__t0__/${T0}/g;"                          ../SPECFEM_RUNS/${subdir}/${jname}/DATA/CMTSOLUTION
perl -pi -w -e "s/__NEX__/${NEX}/g;"                        ../SPECFEM_RUNS/${subdir}/${jname}/DATA/Par_file
perl -pi -w -e "s/__NPROC__/${NPROC}/g;"                    ../SPECFEM_RUNS/${subdir}/${jname}/DATA/Par_file
perl -pi -w -e "s/__MODEL__/${model}/g;"                    ../SPECFEM_RUNS/${subdir}/${jname}/DATA/Par_file
perl -pi -w -e "s/__OCEAN__/${ocean}/g;"                    ../SPECFEM_RUNS/${subdir}/${jname}/DATA/Par_file
perl -pi -w -e "s/__TOPOG__/${topog}/g;"                    ../SPECFEM_RUNS/${subdir}/${jname}/DATA/Par_file
perl -pi -w -e "s/__ELLIP__/${ellip_par}/g;"                ../SPECFEM_RUNS/${subdir}/${jname}/DATA/Par_file
perl -pi -w -e "s/__PERFECT_SPHERE__/${perfect_sphere}/g;"  ../SPECFEM_RUNS/${subdir}/${jname}/setup/constants.h.in

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


cd ../SPECFEM_RUNS/${subdir}/${jname}
./configure FC=ftn MPIFC=ftn CFLAGS="-O3" FCFLAGS="-O3"
make meshfem3D -j16
make specfem3D -j16
qsub mesh.bolt


