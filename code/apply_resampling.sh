#!/bin/bash

dset=$1

source ~/env/gp38/bin/activate

tmpl_dwi="dwi_model-DKI_FA.nii.gz"
tmpl_t1w="T1w.nii.gz"
tmpl_gla="T1w_Glasser2016.nii.gz"

for sub in `ls $dset`
do
  for ses in `ls $dset/$sub`
  do
    d=${1}/${sub}/${ses}/dwi/${sub}_${ses}_${tmpl_dwi}
    t=${1}/${sub}/${ses}/anat/${sub}_${ses}_${tmpl_t1w}
    g=${1}/${sub}/${ses}/anat/${sub}_${ses}_${tmpl_gla}
    echo python resample_structure.py $d $t $g
  done
done
