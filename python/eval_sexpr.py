from fglib import *


class Ghost(Elt):
    pass

test = ['N', ['data', ['label', 1], ['radius', 10], ['blobbiness', 3.5], ['Distance', 5, 0.5], ['Straightness', 0, 0.10000000000000001]], ['N', ['data', ['label', 2], ['radius', 5], ['blobbiness', 3.5], ['Distance', 3, 0.5], ['Straightness', 0, 0.10000000000000001]], ['N', ['data', ['label', 3], ['radius', 2], ['blobbiness', 3.5], ['Distance', 2, 0.5], ['Straightness', 0, 0.10000000000000001]], ['N', ['data', ['label', 4], ['radius', 5], ['blobbiness', 10], ['Distance', 5, 0.5], ['Straightness', 0, 0.10000000000000001]]], ['N', ['data', ['label', 5], ['radius', 5], ['blobbiness', 10], ['Distance', 5, 0.5], ['Straightness', 0, 0.10000000000000001]]]]]]
#test = ['N', ['N',
#                     ['N', ['data', ['label', 1], ['radius', 1.2], ['blobbiness', -0.2],
#['Distance', 2, 0.1], ['Straightness', 0, 0.1]],
#                         ['N', ['data',['label', 1],  ['radius', 0.8], ['blobbiness', -0.1],
#['Distance', 3, 0.1], ['Straightness', 0, 0.1]],
#                             ['N', ['data', ['label', 1], ['radius', 0.6], ['blobbiness', -0.2],
#['Distance', 2, 0.1], ['Straightness', 0, 0.1]]]]]]]



test_simple = ['GN1',
                     ['N1', ['data', ['radius', 1.2], ['Distance', 2, 0.1]],
                         ['N2', ['data', ['radius', 0.8], ['Distance', 3, 0.1]],
]]]
                            

class Fail():
    pass
                         
cmd_dict = {
        'label': lambda latest, val, node_dict, node_stack: setEltAttr(latest, "label", val, node_dict),
        'pos': lambda latest, val, node_dict, node_stack: setEltAttr(latest, "pos", tuple(val), node_dict),
        'radius': lambda latest, val, node_dict, node_stack: setEltAttr(latest, "radius", val, node_dict),
        'blobbiness': lambda latest, val, node_dict, node_stack: setEltAttr(latest, "blobbiness", val, node_dict),
        'Distance': lambda latest, val, node_dict, node_stack: makeFactor(
            [node_dict[latest], node_stack[-1]],
            lambda x, y: make_distgauss(*val)(x.pos, y.pos)) if len(node_stack) >= 1 else Fail(),
        'Straightness': lambda latest, val, node_dict, node_stack: makeFactor([node_dict[latest], node_stack[-1], node_stack[-2]], 
            lambda x, y, z: make_straightgauss(*val)(x.pos, y.pos, z.pos)) if len(node_stack) >= 2 else Fail()
        }
mkParent = lambda latest, val, node_dict, node_stack: setEltAttr(latest, "parent", node_stack[-1], node_dict)

def setEltAttr(latest, name, val, node_dict):
    node_dict[latest].makeNewField(name, val)

def makeFactor(scope, fx): 
    factor = Factor(*scope)
    factor.set(fx)
    return factor

# check if data, then run commands from data;
# check if children, recurse for each child
# else if no children, stop
# 

isGN = lambda n: n.tile_obj.name.startswith('GN')

def evalFactorTree(ftree, node_stack, result_fg, node_dict):
    nodeName = ftree[0]
    latest = Elt(nodeName) if not nodeName.startswith('GN') else Ghost(nodeName)
    node_dict[latest] = latest
    node_dict[latest].tile_obj = Tile({})

    #if not node_dict.has_key(nodeName):
    #    node_dict[nodeName] = Elt(nodeName) if not nodeName.startswith('GN') else Ghost(nodeName)
    #    node_dict[nodeName].tile_obj = Tile({})

    new_node_stack = node_stack + [node_dict[latest]]

    data, children = partition(lambda elem: elem[0] == "data", ftree[1:])

    if len(data) > 0:
        data = data[0]
        data = map(lambda n_v: (n_v[0], tuple(n_v[1:]) if len(n_v) > 2 else n_v[1]),  data[1:])
        new_factors = map(lambda (name, val): cmd_dict[name](latest, val, node_dict, node_stack), data)
        if len(node_stack) >= 2:
            map(lambda (name, val): mkParent(latest, val, node_dict, node_stack), data)

        new_factors = filter(lambda x: type(x) == Factor, new_factors)
        result_fg += new_factors

    if len(children) == 0:
        return
    else:
        map(lambda child: evalFactorTree(child, new_node_stack, result_fg, node_dict), children)

def finalizeImage(node_dict):
    for (name, elt) in node_dict.items():
        if hasattr(elt.tile_obj, 'parent') and type(elt.tile_obj.parent) == Ghost:
            elt.tile_obj.parent = None

    return map(lambda (name, elt): elt, node_dict.items())

def finalizeNodes(node_dict):

    for (name, elt) in node_dict.items():
        if hasattr(elt.tile_obj, 'parent') and type(elt.tile_obj.parent) == Ghost:
            elt.tile_obj.parent = None

    return map(lambda (name, elt): elt.makeNewField('pos', (0,0)), node_dict.items())

def t():
    node_dict = {}
    factors = []
    evalFactorTree(test, [], factors, node_dict)
    print node_dict
    print finalizeNodes(node_dict)

