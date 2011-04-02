from fglib import *
from svgfig import *

def find_chain_from_leaf(leaf_node, dict_num_children):
    def loop(leaf_node, dict_num_children, res):
        if dict_num_children[leaf_node] > 1 or leaf_node.getField("parent") == None:
            return res + [leaf_node]
        return loop(leaf_node.getField("parent"), dict_num_children, res + [leaf_node]) 
    return loop(leaf_node, dict_num_children, [])

def chains(ns):
    dict_num_children = dict(map(lambda n: (n, 0), ns))
    for n in ns:
        if n.getField("parent") != None:
            dict_num_children[n.getField("parent")] += 1 

    leaf_nodes = filter(lambda n: dict_num_children[n] == 0, ns)

    res = []
    for n in leaf_nodes:
        res += [find_chain_from_leaf(n, dict_num_children)]

    return res



def bbox(ns):
    lx, ly = zip(*(map(lambda n: n.getField("pos"), ns)))
    minx, maxx, miny, maxy = min(lx), max(lx), min(ly), max(ly)
    canvasW, canvasH = maxx-minx, maxy-miny
    unit = max(canvasW, canvasH)
    return window(minx-10, minx+unit+10, unit+miny+10, miny-10)

def drawSkeletonToLeafShape(ns_pos, leaf_width = 2.0):

    if len(ns_pos) == 2:
        ns_pos = [ns_pos[0], vec.interp(ns_pos[0], ns_pos[1], 0.5), ns_pos[1]]

    normal_vec = map(lambda i: signed_curve_normal(ns_pos[i-1], ns_pos[i], ns_pos[i+1]),range(1, len(ns_pos)-1))
    normal_vec_flip = map(lambda v: vec.scale(v, -1), normal_vec)

    normal_vec = [(0, 0)] + normal_vec + [(0, 0)]
    normal_vec_flip = [(0, 0)] + normal_vec_flip + [(0, 0)]

    scaling_vec = map(lambda t: leaf_width*(0.5-2*(0.5 - t)**2), vec.interp_range(0, 1, len(normal_vec)))
    nodes_norm = zip(ns_pos, normal_vec, scaling_vec)
    nodes_norm_flip = zip(ns_pos, normal_vec_flip, scaling_vec)
    normal_pt = map(lambda (n, v, s): vec.add(n, vec.scale(v, s)), (nodes_norm))
    normal_pt_flip = map(lambda (n, v, s): vec.add(n, vec.scale(v, s)), (nodes_norm_flip))

    t = []

    #t = t + [Poly(ns_pos, mode = "smooth")]
    t = t + [Poly(normal_pt, mode = "smooth")]
    t = t + [Poly(normal_pt_flip, mode = "smooth")]

    return t

def draw(t, trans, filename):
    Fig(Fig(*t), trans=trans).SVG().save(filename)




def makeChainSets(nodes):
    def loop(nodes, res):
        if len(nodes) < 2:
            return res
        else:
            leaf_chains = chains(nodes)

            leaf_chain_pos = []
            for leaf_chain in leaf_chains:
                leaf_chain_pos += [map(lambda n: n.getField("pos"), leaf_chain)]

            leaf_nodes = concat(map(lambda chain: chain[:-1], leaf_chains))
            remaining_nodes = filter(lambda n: n not in leaf_nodes, nodes)
            return loop(remaining_nodes, res + [leaf_chain_pos])

    return loop(nodes, [])

def drawLeafChainLists(chain_lists, leaf_width = 2.0):
    t = []
    for chain_list in chain_lists:
        for leaf_chain_pos in chain_list:
            t = t + drawSkeletonToLeafShape(leaf_chain_pos, leaf_width = leaf_width)
    return t

def drawTrunk(chains):
    t = [Poly(chain, mode="line") for chain in chains]
    return t

def drawAll(nodes, filename, leaf_width = 2.0):
    trans = bbox(nodes)
    chain_lists = makeChainSets(nodes)
    t = []
    if len(chain_lists) == 1:
        t = t + drawLeafChainLists(chain_lists, leaf_width = leaf_width)
    else:
        t = t + drawLeafChainLists(chain_lists[:-1], leaf_width = leaf_width)
        t = t + drawTrunk(chain_lists[-1])
    draw(t, trans, filename)
