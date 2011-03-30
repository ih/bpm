import os, sys, pickle, random
import test

from fg_interface import *

if __name__ == "__main__":
    args=pickle.load(sys.stdin)

    nodes, factors = mkFG(args)
    sample, score = sampleEltFG(nodes, result_fg, MH(2000))

    debug = mkDebugChannel('scoreImFg')
    print >>debug, 'score',score

    pickle.dump(score,sys.stdout)
