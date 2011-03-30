from core_sampling_AIS import *
from core_sampling_MH import *

def make_distribution_seq_log(f0, fn, betas):
    return map(lambda b: lambda asn: (f0(asn)*(1.0-b))+(fn(asn)*(b)), betas)

def acceptance(prob):
    try:
        print prob
        if uniform(0, 1) < min(1, exp(prob)):
            return True
        else:
            return False
    except OverflowError:
        return True

def TT_1_iter(ais_fx, curr_state):
    candidate, candidate_weight = ais_fx(curr_state)
    if acceptance(candidate_weight):
        return candidate, candidate_weight
    else:
        return curr_state, candidate_weight
    
def TT(f0, ffg1, dict_asn, proposal_fx, lower_beta, upper_beta, numIter, numIterTT = 100):
    betas = []
    betas += map(lambda t: (t)*.05, map(lambda i: i/float(lower_beta), range(lower_beta+1)))
    betas += map(lambda t:    (1-t**2)*0.05+(t**2)*1.0, map(lambda i: i/float(upper_beta), range(upper_beta+1)))

    finalbetas = list(reversed(betas)) + betas

    fseq = make_distribution_seq_log(f0, ffg1, finalbetas)
    Tseq = map(lambda fi: lambda asn: MH_n_iter(fi, asn, proposal_fx, numIter)[0], fseq)

    ais_fx = lambda state: AIS(fseq, Tseq, state)
    weight = 0.0
    for i in range(numIterTT):
        dict_asn, weight = TT_1_iter(ais_fx, dict_asn)
    return dict_asn, ffg1(dict_asn)

