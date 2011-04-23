import os, sys, pickle, random
import test

from fg_interface import *

from utils import *

fsts = lambda xs: map(lambda (x, y): x, xs)

Node = Term('Node', ['label', 'radius', 'blobbiness', "Distance", 'Straightness', 'children'])

get_ints = lambda xs: map(int, xs)
get_floats = lambda xs: map(float, xs)

get_one_int = lambda xs: get_ints(xs)[0]
get_one_float = lambda xs: get_floats(xs)[0]

parses = {
        'label' : get_one_int,
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
            parsed_data['radius'],
            parsed_data['blobbiness'],
            parsed_data['Distance'],
            parsed_data['Straightness'],
            parsed_data.get('children', []))

    return node

if __name__ == "__main__":
    args=pickle.load(sys.stdin)

    debug = mkDebugChannel('image2fg_debug')

    #filename = sys.argv[1]

    filename = args
    #print >>debug, filename
    nodes = map(parse_img_line, open(filename).readlines())

    mklist = lambda *a: list(a)

    def mk_sexpr(node):
        return mklist('N', ['data', mklist('label', node.label), ['radius', node.radius], ['blobbiness', node.blobbiness], mklist('Distance', *node.Distance), mklist('Straightness', *node.Straightness)], *map(mk_sexpr, map(lambda i: nodes[i], node.children)))

    output = mk_sexpr(nodes[0])
    #output = ['N', ['data', ['label', 1], ['radius', 10.0], ['blobbiness', 3.5], ['Distance', 5.0, 0.5], ['Straightness', 0.0, 0.10000000000000001]], ['N', ['data', ['label', 2], ['radius', 5.0], ['blobbiness', 3.5], ['Distance', 3.0, 0.5], ['Straightness', 0.0, 0.10000000000000001]]]]
   
    print >>debug, output
    pickle.dump(output,sys.stdout)

