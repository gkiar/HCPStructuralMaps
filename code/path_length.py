#!/usr/bin/env python

from argparse import ArgumentParser
from scipy import special

import matplotlib.pyplot as plt
import networkx as nx
import numpy as np

def summary(pl_adj, outf):
    locs = np.where(pl_adj>0)
    adj_stat = pl_adj[locs]
 
    maxe = int(special.comb(len(pl_adj), 2))
    print("Sparsity: {0:d}/{1:d} ({2:.2%})".format(int(len(adj_stat)/2),
                                                   maxe,
                                                   len(adj_stat)/2/maxe))
    print("Edge weights: [{0} ({1:.2f}) {2}]".format(np.min(adj_stat),
                                                     np.mean(adj_stat),
                                                     np.max(pl_adj)))

    # Plot the graph
    plt.imshow(pl_adj)
    plt.savefig(outf.replace('.mat', '.png'))

def dicts2mat(pls, adj):
    pl_a = np.zeros_like(adj)
    print(pl_a.shape)
    for n1 in pls.keys():
        for n2 in pls[n1].keys():
            pl_a[n1, n2] = pls[n1][n2]

    return pl_a + pl_a.T


def main():
    parser = ArgumentParser()
    parser.add_argument("graph")
    parser.add_argument("--mode", "-m", choices=['raw', 'log10', 'binary'],
                        default="log10")
    args = parser.parse_args()

    adj = np.loadtxt(args.graph)
    mode = args.mode

    outfname = args.graph.replace(".mat", "_pl-" + mode + ".mat")
    pl = nx.algorithms.shortest_paths.generic.shortest_path_length
    weight = 'weight'
    if mode == "log10":
        adj = np.log10(adj + 1)
    elif mode == "binary":
        adj = (adj > 0).astype(int)
        weight = None

    graph = nx.Graph(adj)
    assert(len(graph.nodes) == adj.shape[0])

    lengths = dict(pl(graph, weight=weight))
    pl_adj = dicts2mat(lengths, adj)

    summary(pl_adj, outfname)
    np.savetxt(outfname, pl_adj)


if __name__ == "__main__":
    main()

