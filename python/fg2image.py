import os, sys, pickle, random

from fg_interface import *

import os

if __name__ == "__main__":
    args=pickle.load(sys.stdin)


    nodes, result_fg = mkFG(args)
    basename = 'fgfinal_0'
    intermediate = 'fgintermediate'

    for i in range(10):
        debug = mkDebugChannel('fg2image_debug')

        print >>debug, 'begin fg2image ====================='
        print >>debug, 'input', pformat(args)
        print >>debug, 'factors', pformat(result_fg)
        print >>debug, 'nodes', pformat(nodes)
        print >>debug, 'nodeasn', pformat(map(lambda n: n.tile_obj, nodes))

        nodes, score = sampleEltFG(nodes, result_fg, MH(10000))
        drawFG(nodes, map(lambda f: f.variables, result_fg), intermediate + "_%d" % i)

        print >>debug, 'after sampling:'
        print >>debug, 'score:', score
        print >>debug, 'nodes', pformat(nodes)
        print >>debug, 'nodepos', pformat(map(lambda n: n.tile_obj.pos, nodes))
        print >>debug, 'end fg2image ====================='

        debug.close()

    drawFG(nodes, map(lambda f: f.variables, result_fg), basename)

    pickle.dump(args,sys.stdout)
