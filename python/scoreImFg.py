import os, sys, pickle, random
import test

from fg_interface import *

def score_img(nodes, factors, imnodes):
    load_asn_from_nodes(nodes, imnodes)
    input_image = constructAssignments(nodes)
    score_of_input = logscore(factors, input_image)
    return score_of_input 

if __name__ == "__main__":
    args=pickle.load(sys.stdin)

    debug = mkDebugChannel('scoreImFg_debug')
    print >>debug, args
    imnodes, imfactors = mkImgFromFile(args[0])
    fg_nodes1, fg_factors1 = mkFG(args[1])
    sample1, score1 = scoreImg(nodes1, factors1)
    score_of_input1 = score_img(nodes1, factors1, imnodes)
    score_of_input1 -= score1 

    print >>debug, score_of_input1
    pickle.dump(score_of_input, sys.stdout)
    
    ## args = sys.argv
    ## imnodes, imfactors = mkImgFromFile(args[1])
    ## nodes1, factors1 = mkFGFromFile(args[2])
    ## nodes2, factors2 = mkFGFromFile(args[3])
    ## nodes3, factors3 = mkFGFromFile(args[4])


    ## sample1, score1 = scoreImg(nodes1, factors1)
    ## sample2, score2 = scoreImg(nodes2, factors2)
    ## sample3, score3 = scoreImg(nodes3, factors3)
    ## print 'normalization constant',score1
    ## print 'normalization constant',score2
    ## print 'normalization constant',score3

    ## score_of_input1 = score_img(nodes1, factors1, imnodes)
    ## score_of_input2 = score_img(nodes2, factors2, imnodes)
    ## score_of_input3 = score_img(nodes3, factors3, imnodes)

    ## score_of_input1 -= score1 
    ## score_of_input2 -= score2 
    ## score_of_input3 -= score3 
    ## print 'score_of_input1', score_of_input1
    ## print 'score_of_input2', score_of_input2
    ## print 'score_of_input3', score_of_input3

    #pickle.dump(score_of_input, sys.stdout)
