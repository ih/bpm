from eval_sexpr import *
from fglib import *
from fg_sampling import *

from drawing import *

from pprint import pformat

proposal = lambda asn: gaussPerturbProposalByNameAll(asn, 'pos', 0.3)
proposal2 = lambda asn: gaussPerturbProposalByName(asn, 'pos', 0.3, rndSelect(asn.keys()))

MH = lambda nIter: lambda scorefx, asn: MH_n_iter(scorefx, asn, proposal2, nIter)

def getUnusedFileName(basename, ext):
    counter = 0
    while os.path.exists('%s_%d.%s' % (basename, counter, ext)):
        counter +=1
    return '%s_%d.%s' % (basename, counter, ext)

def drawFG(nodes, edges, basename='fg_drawing'):
    fname = getUnusedFileName('fg_drawing', 'svg')
    drawGraph(nodes, edges, 0.2, 'black').SVG().save(fname)

def mkFG(sexpr):
    nodes = {}
    result_fg = []

    evalFactorTree(sexpr, [], result_fg, nodes)

    nodes = finalizeNodes(nodes)

    return nodes, result_fg

def mkDebugChannel(name):
    return open(getUnusedFileName(name, 'txt'), 'w')

