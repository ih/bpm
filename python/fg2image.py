import os, sys, pickle, random

from fg_interface import *

import os

if __name__ == "__main__":
    args=pickle.load(sys.stdin)


    for i in range(10):
        nodes, result_fg = mkFG(args)
        debug = mkDebugChannel('fg2image_debug')

        print >>debug, 'begin fg2image ====================='
        print >>debug, 'input', pformat(args)
        print >>debug, 'factors', pformat(result_fg)
        print >>debug, 'nodes', pformat(nodes)
        print >>debug, 'nodepos', pformat(map(lambda n: n.tile_obj.pos, nodes))

        nodes, score = sampleEltFG(nodes, result_fg, MH(10000))
        drawFG(nodes, map(lambda f: f.variables, result_fg))

        print >>debug, 'after sampling:'
        print >>debug, 'score:', score
        print >>debug, 'nodes', pformat(nodes)
        print >>debug, 'nodepos', pformat(map(lambda n: n.tile_obj.pos, nodes))
        print >>debug, 'end fg2image ====================='

        debug.close()


    pickle.dump(args,sys.stdout)
