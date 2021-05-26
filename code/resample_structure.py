#!/usr/bin/env python

from nilearn.image import resample_to_img
from argparse import ArgumentParser

import nibabel as nib
import numpy as np
import os.path as op
import os



def main():
    parser = ArgumentParser()
    parser.add_argument("dwi_im")
    parser.add_argument("t1w_im")
    parser.add_argument("gla_im")

    results = parser.parse_args()

    # Load diffusion reference
    ref = nib.load(results.dwi_im)
    odir = op.dirname(results.dwi_im)

    # Resample T1w image
    t1w_2name = op.join(odir, op.basename(results.t1w_im))
    t1w_2 = resample_to_img(nib.load(results.t1w_im),
                            ref)
    nib.save(t1w_2, t1w_2name)

    # Resample parcellation
    gla_2name = op.join(odir, op.basename(results.gla_im))
    gla_2 = resample_to_img(nib.load(results.gla_im),
                            ref,
                            interpolation="nearest")
    nib.save(gla_2, gla_2name)

if __name__ == "__main__":
    main()

