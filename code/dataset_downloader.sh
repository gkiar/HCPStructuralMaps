#!/usr/bin/env bash

# Activate virtualenv with AWS CLI installed
source ~/env/gp38/bin/activate

# Set some basic paths
base="s3://hcp-openaccess"

bval="T1w/Diffusion/bvals"
bvec="T1w/Diffusion/bvecs"
dwid="T1w/Diffusion/data.nii.gz"
t1wd="T1w/T1w_acpc_dc.nii.gz"
wmse="T1w/wmparc.nii.gz"

# For each subject of interest...
while read -r line;
do
  loc="dataset/sub-$line"

  mkdir -p ${loc}/ses-{test,retest}/{dwi,anat}

  echo $line

  # Create a few directories and download the data straight into a BIDS format
  aws s3 cp $base/HCP_1200/$line/$bval $loc/ses-test/dwi/sub-${line}_ses-test_dwi.bval
  aws s3 cp $base/HCP_1200/$line/$bvec $loc/ses-test/dwi/sub-${line}_ses-test_dwi.bvec
  aws s3 cp $base/HCP_1200/$line/$dwid $loc/ses-test/dwi/sub-${line}_ses-test_dwi.nii.gz
  aws s3 cp $base/HCP_1200/$line/$t1wd $loc/ses-test/anat/sub-${line}_ses-test_T1w.nii.gz
  aws s3 cp $base/HCP_1200/$line/$wmse $loc/ses-test/anat/sub-${line}_ses-test_T1w_WMseg.nii.gz

  aws s3 cp $base/HCP_Retest/$line/$bval $loc/ses-retest/dwi/sub-${line}_ses-retest_dwi.bval
  aws s3 cp $base/HCP_Retest/$line/$bvec $loc/ses-retest/dwi/sub-${line}_ses-retest_dwi.bvec
  aws s3 cp $base/HCP_Retest/$line/$dwid $loc/ses-retest/dwi/sub-${line}_ses-retest_dwi.nii.gz
  aws s3 cp $base/HCP_Retest/$line/$t1wd $loc/ses-retest/anat/sub-${line}_ses-retest_T1w.nii.gz
  aws s3 cp $base/HCP_Retest/$line/$wmse $loc/ses-retest/anat/sub-${line}_ses-retest_T1w_WMseg.nii.gz

done < sublist.txt
