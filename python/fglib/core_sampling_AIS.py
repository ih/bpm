from math import *

def nextweight_log(weight_prev, fx_curr, fx_prev, asn_prev):
    return weight_prev + (fx_curr(asn_prev) - fx_prev(asn_prev))
    
def AIS(fseq, Tseq, initialState, skip = 1):
    prev_weight = 0 # log 1
    prev_state = initialState
    curr_weight = prev_weight
    for i in range(1, len(fseq)):
        curr_state = Tseq[i](prev_state)
        curr_weight = nextweight_log(prev_weight, fseq[i], fseq[i-1], prev_state)
        prev_weight = curr_weight
        prev_state = curr_state
    return curr_state, curr_weight


