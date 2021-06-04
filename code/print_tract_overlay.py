#!/usr/bin/env python

from argparse import ArgumentParser

from dipy.io.streamline import load_tractogram
from dipy.viz import actor, window, colormap
from dipy.tracking import utils

import nibabel as nib
import numpy as np

def main():
    parser = ArgumentParser()
    parser.add_argument("image")
    parser.add_argument("labels")
    parser.add_argument("tractogram")
    parser.add_argument("output")
    parser.add_argument("--interactive", "-i", action="store_true",
                        default=False)

    args = parser.parse_args()

    ref = nib.load(args.image)
    rdat = ref.get_fdata()
    lab = nib.load(args.labels)
    ldat = lab.get_fdata()

    tr = load_tractogram(args.tractogram, ref)
    tr.to_vox()
    sl = np.array(tr.streamlines, dtype=object)

    interactive = args.interactive

    # Make display objects
    color = colormap.line_colors(sl)
    sl_actor = actor.line(sl, color)

    label_actor = actor.contour_from_roi(ldat, color=(0.8,0.8,0.2),
                                         opacity=0.1)

    vol_actor = actor.slicer(rdat)

    vol_actor.display(x=40)
    vol_actor2 = vol_actor.copy()
    vol_actor2.display(z=35)

    # Add display objects to canvas
    r = window.Scene()
    r.add(vol_actor)
    r.add(vol_actor2)
    r.add(sl_actor)
    r.add(label_actor)

    r.set_camera(position=[0.2, 0.6, 0],
                 focal_point=[0, 0, 0],
                 view_up=[0, 0, 1])

    if interactive:
        window.show(r)
    else:
        # Save figures
        window.record(r, n_frames=1, out_path=args.output,
                      size=(800, 800))


if __name__ == "__main__":
    main()

