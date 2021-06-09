#!/usr/bin/env bash

dset=$1
ident="*2016.mat"  # instruction for flaggin the graphs (e.g. *2016.mat)
modes="raw log10 binary"

for f in `find ${dset} -type f -name '*2016.mat'`
do
  for mode in ${modes}
  do
    echo $f
    python path_length.py $f -m ${mode}

  done
done
