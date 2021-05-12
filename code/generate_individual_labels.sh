#!/usr/bin/env bash

# Applies the Glasser parcellation to HCP subject data

# Accepts two arguments: base directories for HCP data and for supplemental data
hcp_base_dir=$1
data_base_dir=$2

label_L=${data_base_dir}/resources/Glasser2016_parcellation/HCP_MMP_P210.L.CorticalAreas_dil_Colors.32k_fs_LR.label.gii
label_R=${data_base_dir}/resources/Glasser2016_parcellation/HCP_MMP_P210.R.CorticalAreas_dil_Colors.32k_fs_LR.label.gii
template=${data_base_dir}/resources/Glasser2016_parcellation/MNI152_T1_0.7mm.nii.gz

dataset_names="test retest"
subjects=`cat ${data_base_dir}/data/hcp_trt/subjects_hcptrt_30subs.list`

# For each of the test and retest datasets...
for a in ${dataset_names}; do

  hcp_dir=${hcp_base_dir}/${a}
  data_dir=${data_base_dir}/data/hcp_trt/${a}

  # For each subject in the desired list of subjects...
  for s in $subjects; do
    echo $s

    # Create an output directory
    mkdir -p ${data_dir}/${s}/MNINonLinear/
    
    # Apply the Left- and Right-hemisphere labels to the subject's data
    wb_command -label-to-volume-mapping ${label_L} \
               ${hcp_dir}/${s}/fsaverage_LR32k/${s}.L.midthickness_MSMAll.32k_fs_LR.surf.gii \
               ${template} \
               ${data_dir}/${s}/MNINonLinear/${s}.L.Glasser2016_0.7mm.nii.gz \
               -ribbon-constrained \
               ${hcp_dir}/${s}/fsaverage_LR32k/${s}.L.white_MSMAll.32k_fs_LR.surf.gii \
               ${hcp_dir}/${s}/fsaverage_LR32k/${s}.L.pial_MSMAll.32k_fs_LR.surf.gii 

    wb_command -label-to-volume-mapping ${label_R} \
               ${hcp_dir}/${s}/fsaverage_LR32k/${s}.R.midthickness_MSMAll.32k_fs_LR.surf.gii \
               ${template} ${data_dir}/${s}/MNINonLinear/${s}.R.Glasser2016_0.7mm.nii.gz \
               -ribbon-constrained ${hcp_dir}/${s}/fsaverage_LR32k/${s}.R.white_MSMAll.32k_fs_LR.surf.gii \
               ${hcp_dir}/${s}/fsaverage_LR32k/${s}.R.pial_MSMAll.32k_fs_LR.surf.gii

    # Binarize the right mask
    fslmaths ${data_dir}/${s}/MNINonLinear/${s}.R.Glasser2016_0.7mm.nii.gz \
             -bin ${data_dir}/${s}/MNINonLinear/tmp_R_mask.nii.gz

    # Add 180 to regions in the right side
    fslmaths ${data_dir}/${s}/MNINonLinear/${s}.R.Glasser2016_0.7mm.nii.gz \
             -add 180 \
             -mas ${data_dir}/${s}/MNINonLinear/tmp_R_mask.nii.gz \
             ${data_dir}/${s}/MNINonLinear/tmp_R.nii.gz

    # Add the left and right labels together
    fslmaths ${data_dir}/${s}/MNINonLinear/${s}.L.Glasser2016_0.7mm.nii.gz\
             -add ${data_dir}/${s}/MNINonLinear/tmp_R.nii.gz \
             ${data_dir}/${s}/MNINonLinear/${s}.Glasser2016_0.7mm.nii.gz 

    rm ${data_dir}/${s}/MNINonLinear/tmp_*.nii.gz
  done
done
