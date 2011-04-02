from eval_sexpr import *
from fglib import *
from fg_sampling import *

from drawing import *
from draw_leaf import *

from pprint import pformat

proposal = lambda asn: gaussPerturbProposalByNameAll(asn, 'pos', 0.3)
proposal2 = lambda asn: gaussPerturbProposalByName(asn, 'pos', 0.3, rndSelect(asn.keys()))

MH = lambda nIter: lambda scorefx, asn: MH_n_iter(scorefx, asn, proposal2, nIter)

def getUnusedFileName(basename, ext):
    counter = 0
    while os.path.exists('%s_%d.%s' % (basename, counter, ext)):
        counter +=1
    return '%s_%d.%s' % (basename, counter, ext)

def drawFG(nodes, edges, basename='fgdrawing'):
    fname = getUnusedFileName(basename, 'svg')

    exclude = filter(lambda n: type(n) == Ghost, nodes)

    final_nodes = filter(lambda n: n not in exclude, nodes)
    final_edges = filter(lambda ns: reduce(lambda x, y: x and y, map(lambda n: n not in exclude, ns)), edges)

    drawGraph(final_nodes, final_edges, 0.2, 'black').SVG().save(fname)

    #drawBlobSpec(final_nodes, basename)

    drawAll(final_nodes, "shape"+fname, 0.5)

def mkFG(sexpr):
    nodes = {}
    result_fg = []

    evalFactorTree(sexpr, [], result_fg, nodes)

    nodes = finalizeNodes(nodes)

    return nodes, result_fg

def mkDebugChannel(name):
    return open(getUnusedFileName(name, 'txt'), 'w')


def drawBlobSpec(nodes, basename, exclude=[]):

    fh = open(getUnusedFileName(basename, 'pos'), 'w')
    for n in nodes:
        fh.write("%s: %f %f\n" % (n.name, n.tile_obj.pos[0], n.tile_obj.pos[1]))
    fh.close()

    fh = open(getUnusedFileName(basename, 'radblob'), 'w')
    for n in nodes:
        fh.write("%s: %f %f\n" % (n.name, n.tile_obj.radius, n.tile_obj.blobbiness))
    fh.close()


