#!/usr/bin/env bash

# Activate virtualenv with AWS CLI installed
source ~/env/gp38/bin/activate

# Set some basic paths
base="s3://hcp-openaccess/HCP_Retest/"

bval="T1w/Diffusion/bvals"
bvec="T1w/Diffusion/bvecs"
dwid="T1w/Diffusion/data.nii.gz"
t1wd="T1w/T1w_acpc_dc.nii.gz"
wmse="T1w/wmparc.nii.gz"

# For each subject of interest...
while read -r line;
do
  loc="dataset/sub-$line"

  # Create a few directories and download the data straight into a BIDS format
  mkdir -p ${loc}/{dwi,anat}
  aws s3 cp $base$line/$bval $loc/dwi/sub-${line}_dwi.bval
  aws s3 cp $base$line/$bvec $loc/dwi/sub-${line}_dwi.bvec
  aws s3 cp $base$line/$dwid $loc/dwi/sub-${line}_dwi.nii.gz
  aws s3 cp $base$line/$t1wd $loc/anat/sub-${line}_T1w.nii.gz
  aws s3 cp $base$line/$wmse $loc/anat/sub-${line}_T1w_WMseg.nii.gz

  echo $line

done < sublist.txt
