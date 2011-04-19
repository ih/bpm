import os, sys, pickle, random
import test

from fg_interface import *

if __name__ == "__main__":
    args=pickle.load(sys.stdin)

    imnodes, imfactors = mkFG(args[0])
    nodes, factors = mkFG(args[1])

    sample, score = scoreImg(imnodes, nodes, factors)

    debug = mkDebugChannel('scoreImFg')
    print >>debug, 'score',score

    pickle.dump(score,sys.stdout)
