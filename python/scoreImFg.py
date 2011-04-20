import os, sys, pickle, random
import test

from fg_interface import *

if __name__ == "__main__":
    args=pickle.load(sys.stdin)

    debug = mkDebugChannel('scoreImFg_debug')
    print >>debug, args

    #imnodes, imfactors = mkFG(args[0])
    nodes, factors = mkFG(args)
    imnodes = nodes

    input_image = constructAssignments(imnodes)
    score_of_input = logscore(factors, input_image)

    sample, score = scoreImg(nodes, factors)
    print >>debug, 'normalization constant',score
    score_of_input -= score 

    debug = mkDebugChannel('scoreImFg')
    print >>debug, 'score_of_input', score_of_input

    pickle.dump(score_of_input, sys.stdout)
