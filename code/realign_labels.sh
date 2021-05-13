#!/usr/bin/env bash

# Activate virtual environment with AWS installed
source ~/env/gp38/bin/activate

# Accepts arg which points to the location of individual parcellations in MNINonLinear space
labdir=$1
# ... and another which points to the output location
outdir=$2

# For every whole-brain set of labels...
for f in `find ${labdir} -type f -name '*[0-9].G*.nii.gz'`
do

  # Remove the base path from f, so we can more easily parse it later
  f2=${f#"$labdir"}

  ses=`echo $f2 | cut -d '/' -f 1`
  if [[ $ses == "retest"  ]]
  then
    dset="HCP_Retest"
  else
    dset="HCP_1200"
  fi

  # Extract subject ID
  sub=`echo $f2 | cut -d '/' -f 2`

  echo $sub $ses $f2
  # Download the warp and T1w images for the participant
  # aws s3 cp s3://hcp-openaccess/$dset/$sub/MNINonLinear/xfms/standard2acpc_dc.nii.gz ${labdir}/$ses/$sub/MNINonLinear/
  # aws s3 cp s3://hcp-openaccess/$dset/$sub/T1w/T1w_acpc_dc_restore_brain.nii.gz ${labdir}/$ses/$sub/MNINonLinear/

  ofile=${outdir}/sub-$sub/ses-$ses/anat/sub-${sub}_ses-${ses}_T1w_Glasser2016.nii.gz
  if [ ! -e ${ofile} ]
  then
    # Create an output directory
    mkdir -p ${outdir}/sub-$sub/ses-$ses/anat/
    # Apply the warp to the labels with nearest-neighbour interpolation
    applywarp -i ${labdir}/$ses/$sub/MNINonLinear/${sub}.Glasser2016_0.7mm.nii.gz\
              -r ${labdir}/$ses/$sub/MNINonLinear/T1w_acpc_dc_restore_brain.nii.gz\
              -w ${labdir}/$ses/$sub/MNINonLinear/standard2acpc_dc.nii.gz\
              -o ${ofile}\
              --interp=nn

  fi

done
