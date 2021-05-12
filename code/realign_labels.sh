#!/usr/bin/env bash

# Activate virtual environment with AWS installed
source ~/env/gp/bin/activate

# Accepts arg which points to the location of individual parcellations in MNINonLinear space
labdir=$1
# ... and another which points to the output location
outdir=$2

# For every whole-brain set of labels...
for f in `find ${labdir} -type f -name '*[0-9].G*.nii.gz'`
do

  # Extract subject ID
  sub=`echo $f | cut -d '/' -f 3`
  echo $sub

  # Download the warp and T1w images for the participant
  aws s3 cp s3://hcp-openaccess/HCP_Retest/$sub/MNINonLinear/xfms/standard2acpc_dc.nii.gz ./test/$sub/MNINonLinear/
  aws s3 cp s3://hcp-openaccess/HCP_Retest/$sub/T1w/T1w_acpc_dc_restore_brain.nii.gz ./test/$sub/MNINonLinear/

  # Create an output directory
  mkdir -p ${outdir}/sub-$sub/anat/
  # Apply the warp to the labels with nearest-neighbour interpolation
  applywarp -i ${labdir}/$sub/MNINonLinear/${sub}.Glasser2016_0.7mm.nii.gz\
            -r ${labdir}/$sub/MNINonLinear/T1w_acpc_dc_restore_brain.nii.gz\
            -w ${labdir}/$sub/MNINonLinear/standard2acpc_dc.nii.gz\
            -o ${ourdir}/sub-$sub/anat/${sub}-T1w_Glasser2016.nii.gz\
            --interp=nn

done
