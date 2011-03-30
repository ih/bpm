from fglib import *


test = ['GN2', ['GN1',
                     ['N3', ['data', ['radius', 1.2], ['blobbiness', -0.2],
['Distance', 2, 0.1], ['Straightness', 0, 0.1]],
                         ['N2', ['data', ['radius', 0.8], ['blobbiness', -0.1],
['Distance', 3, 0.1], ['Straightness', 0, 0.1]],
                             ['N1', ['data', ['radius', 0.6], ['blobbiness', -0.2],
['Distance', 2, 0.1], ['Straightness', 0, 0.1]]]]]]]



test_simple = ['GN1',
                     ['N1', ['data', ['radius', 1.2], ['Distance', 2, 0.1]],
                         ['N2', ['data', ['radius', 0.8], ['Distance', 3, 0.1]],
]]]
                             
                         
cmd_dict = {
        'pos': lambda nodeName, val, node_dict, node_stack: setEltAttr(nodeName, "pos", tuple(val), node_dict),
        'radius': lambda nodeName, val, node_dict, node_stack: setEltAttr(nodeName, "radius", val, node_dict),
        'blobbiness': lambda nodeName, val, node_dict, node_stack: setEltAttr(nodeName, "blobbiness", val, node_dict),
        'Distance': lambda nodeName, val, node_dict, node_stack: makeFactor(
            [node_dict[nodeName], node_stack[-1]],
            lambda x, y: make_distgauss(*val)(x.pos, y.pos)),
        'Straightness': lambda nodeName, val, node_dict, node_stack: makeFactor([node_dict[nodeName], node_stack[-1], node_stack[-2]], 
            lambda x, y, z: make_straightgauss(*val)(x.pos, y.pos, z.pos))
        }


def setEltAttr(nodeName, name, val, node_dict):
    node_dict[nodeName].makeNewField(name, val)

def makeFactor(scope, fx): 
    factor = Factor(*scope)
    factor.set(fx)
    return factor

# check if data, then run commands from data;
# check if children, recurse for each child
# else if no children, stop
# 
def evalFactorTree(ftree, node_stack, result_fg, node_dict):
    nodeName = ftree[0]
    if not node_dict.has_key(nodeName):
        node_dict[nodeName] = Elt(nodeName)
        node_dict[nodeName].tile_obj = Tile({})

    new_node_stack = node_stack + [node_dict[nodeName]]

    data, children = partition(lambda elem: elem[0] == "data", ftree[1:])

    if len(data) > 0:
        data = data[0]
        data = map(lambda n_v: (n_v[0], tuple(n_v[1:]) if len(n_v) > 2 else n_v[1]),  data[1:])
        new_factors = map(lambda (name, val): cmd_dict[name](nodeName, val, node_dict, node_stack), data)
        new_factors = filter(lambda x: type(x) == Factor, new_factors)
        result_fg += new_factors

    if len(children) == 0:
        return
    else:
        map(lambda child: evalFactorTree(child, new_node_stack, result_fg, node_dict), children)

def finalizeNodes(node_dict):
    return map(lambda (name, elt): elt.makeNewField('pos', (0,0)), node_dict.items())

#result_factor_graph = [] 
#nodes = {}
#evalFactorTree(test, [], result_factor_graph, nodes)

