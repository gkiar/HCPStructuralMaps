#!/bin/bash

source ~/env/gp/bin/activate

bp1="s3://profile-hcp-west/hcp_reliability/multi_shell/hcp_"
bp2="_reco80_azure/sub-"
bp3="/ses-01/"
dset="1200 retest"

od="/data/HCP_TRT_dwi/"

set -f noglob

ex1='--exclude *'
inc='--include *clean_tractography.trk --include *DWI_to_MNI_xfm.nii.gz --include *DKI_FA.nii.gz'
ex2='--exclude *bundles*'

while read -r line;
do
  sub=$line

  for ds in $dset;
  do

    if [[ $ds == "1200" ]]
    then
      ses="test"
    else
      ses="retest"
    fi

    op=${od}sub-$sub/ses-$ses/dwi/
    mkdir -p $op

    cmd="""aws --profile afq s3 cp \
               --recursive \
               ${ex1} \
               ${inc} \
               ${ex2} \
               ${bp1}${ds}${bp2}${sub}${bp3} \
               ${op}"""
    echo $cmd
    $cmd 
  done

done < sublist.txt
