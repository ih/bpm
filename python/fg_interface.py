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

def mkImgFromFile(filename):
    sexpr = fg_parse(filename)
    nodes = {}
    result_fg = []

    evalFactorTree(sexpr, [], result_fg, nodes)

    nodes = finalizeImage(nodes)

    return nodes, result_fg

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

from utils import *

def fg_parse(filename):

    fsts = lambda xs: map(lambda (x, y): x, xs)

    Node = Term('Node', ['label', 'pos', 'radius', 'blobbiness', "Distance", 'Straightness', 'children'])

    get_ints = lambda xs: map(int, xs)
    get_floats = lambda xs: map(float, xs)

    get_one_int = lambda xs: get_ints(xs)[0]
    get_one_float = lambda xs: get_floats(xs)[0]

    parses = {
            'label' : get_one_int,
            'pos' : get_floats,
            'radius': get_one_float,
            'blobbiness': get_one_float,
            'Distance': get_floats,
            'Straightness': get_floats,
            'children': get_ints
            }

    def parse_img_line(line):
        split = filter(lambda s: s != '', line.strip().split(' '))

        split2 = map(lambda s: parses.has_key(s), split)

        true_index = filter(lambda i: split2[i] == True, range(len(split2)))

        parse_ranges = map(lambda (i, j): (i + 1, j), zip(true_index, true_index[1:] + [len(split2)]))

        assoc_name_range = map(lambda (ti, (j, k)): (split[ti], split[j : k]), zip(true_index, parse_ranges))

        parsed_data = dict(map(lambda (name, data): (name, parses[name](data)), assoc_name_range))

        node = Node(
                parsed_data['label'],
                parsed_data.get('pos', (0,0)),
                parsed_data['radius'],
                parsed_data['blobbiness'],
                parsed_data['Distance'],
                parsed_data['Straightness'],
                parsed_data.get('children', []))

        return node

    nodes = map(parse_img_line, open(filename).readlines())

    mklist = lambda *a: list(a)

    def mk_sexpr(node):
        return mklist('N', 
                ['data', 
                    mklist('label', node.label), 
                    mklist('pos', *node.pos), 
                    ['radius', node.radius], 
                    ['blobbiness', node.blobbiness], 
                    mklist('Distance', *node.Distance), 
                    mklist('Straightness', *node.Straightness)], 
                *map(mk_sexpr, map(lambda i: filter(lambda n: n.label == i, nodes)[0], node.children)))

    output = mk_sexpr(nodes[0])
    return output

mkFGFromFile = lambda filename : mkFG(fg_parse(filename))
