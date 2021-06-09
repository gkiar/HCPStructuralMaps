#!/usr/bin/env python

from argparse import ArgumentParser

from dipy.io.streamline import load_tractogram
from dipy.viz import actor, window, colormap
from dipy.tracking import utils

from scipy import special
import nibabel as nib
import numpy as np
import os.path as op

import matplotlib
try:
    matplotlib.use('TkAgg')
except:
    pass
import matplotlib.pyplot as plt


def view_tracts(imdat, labdat, streamlines, outfname, interactive=False):
    color = colormap.line_colors(streamlines)
    sl_actor = actor.line(streamlines, color)

    label_actor = actor.contour_from_roi(labdat, color=(0.8,0.8,0.2),
                                         opacity=0.1)

    vol_actor = actor.slicer(imdat)

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
        window.record(r, n_frames=1, out_path=outfname,
                      size=(800, 800))

def trace_streamlines(streamlines, labels, outfname, report=True,
                      interactive=False):
    # Trace with an identity affine, since the data are all aligned
    affine = np.eye(4)
    graph = utils.connectivity_matrix(streamlines, affine, labels,
                                      return_mapping=False, symmetric=True)

    # Remove 0 (background) connections
    graph = graph[1:, 1:]
    np.savetxt(outfname, graph)

    # If we want to report statistics...
    if report:
        locs = np.where(graph>0)
        g_stat = graph[locs]

        maxe = int(special.comb(len(graph), 2))
        print("Sparsity: {0:d}/{1:d} ({2:.2%})".format(int(len(g_stat)/2),
                                                       maxe,
                                                       len(g_stat)/2/maxe))
        print("Edge weights: [{0} ({1:.2f}) {2}]".format(np.min(g_stat),
                                                         np.mean(g_stat),
                                                         np.max(graph)))
    
    # Plot the graph after log-transforming weights
    plt.imshow(np.log10(graph + 1))
    if interactive:
        plt.ion()
        plt.show(block=True)
        plt.ioff()
    plt.savefig(outfname.replace('.mat', '.png'))


def main():
    parser = ArgumentParser()
    parser.add_argument("image",
                        help="Participant's T1w image in DWI space.")
    parser.add_argument("labels",
                        help="Parcellation in DWI space.")
    parser.add_argument("tractogram",
                        help="Tractogram in native (DWI) space.")
    parser.add_argument("--interactive", "-i", action="store_true",
                        help="Toggles interactivity for viewing tracts.")
    args = parser.parse_args()

    # Load image...
    ref = nib.load(args.image)
    rdat = ref.get_fdata()
    # ... and parcellation images
    lab = nib.load(args.labels)
    ldat = lab.get_fdata().astype(int)

    # Transform tracts into voxel coordinates so they can be traced
    tr = load_tractogram(args.tractogram, ref)
    tr.to_vox()
    sl = np.array(tr.streamlines, dtype=object)

    # Create QC figure for the tracts
    tractfig = op.splitext(args.tractogram)[0] + ".png"
    view_tracts(rdat, ldat, sl, tractfig, args.interactive)

    # Create the connectomes
    ose = op.splitext
    graph = args.tractogram.split("dwi_")[0] + "dwi_graph-" +\
            ose(ose(args.labels.split("T1w_")[1])[0])[0] + ".mat"
    trace_streamlines(sl, ldat, graph, interactive=args.interactive)


if __name__ == "__main__":
    main()

