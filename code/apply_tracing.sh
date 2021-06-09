#!/bin/bash

dset=$1

source ~/env/gp38/bin/activate

tmpl_sln="dwi_space-RASMM_model-DKI_desc-det-reco80-clean_tractography.trk"
tmpl_t1w="T1w.nii.gz"
tmpl_gla="T1w_Glasser2016.nii.gz"

for sub in `ls $dset`
do
  for ses in `ls $dset/$sub`
  do
    echo ${sub}_${ses}
    t=${1}/${sub}/${ses}/dwi/${sub}_${ses}_${tmpl_t1w}
    g=${1}/${sub}/${ses}/dwi/${sub}_${ses}_${tmpl_gla}
    s=${1}/${sub}/${ses}/dwi/${sub}_${ses}_${tmpl_sln}
    python trace_and_print_tracts.py $t $g $s
  done
done
