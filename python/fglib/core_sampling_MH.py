from math import exp
from random import uniform

#
#   Metropolis-Hastings sampling algorithm.
#  
#   fs: asn -> float. It is a function returning logscore of the assignment.
#   starting_state: asn
#   proposal_fx: asn -> asn. It generates candidate assignments
#

#   This is the most general MH. This is a generator.

def MH_gen(fs, starting_state, proposal_fx):
    xcurr = starting_state
    xst = xcurr
    while True:
        xst = proposal_fx(xcurr)
        currscore = fs(xcurr)
        stscore = fs(xst)
        try:
            if uniform(0, 1) < min(1, exp(stscore - currscore)):
                xcurr = xst
                currscore = stscore
            else:
                yield xcurr, currscore
        except OverflowError:
                yield xst, stscore
        yield xcurr, currscore

#   This is for running MH for nIter iterations.

def MH_n_iter(fs, starting_state, proposal_fx, nIter):
    return zip(range(nIter), MH_gen(fs, starting_state, proposal_fx))[-1][1]

#   This is for running MH for one iteration.

def MH_one_iter(fs, starting_state, proposal_fx):
    return MH_n_iter(fs, starting_state, proposal_fx, 1)
