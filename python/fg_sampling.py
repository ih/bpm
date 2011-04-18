from fglib import *


def fix_argument(var_free, index_free, index_fixed, value): 
    res = [0]*(len(index_free) + len(index_fixed))
    for i in range(len(index_free)):
        res[index_free[i]] = var_free[i]
    for i in range(len(index_fixed)):
        res[index_fixed[i]] = value

    return res

def fix_factor(factor, var_to_fix, value):
    var_index = zip(factor.variables, range(len(factor.variables)))
    var_index_to_fix, var_index_free = partition(lambda v_idx: v_idx[0] == var_to_fix, var_index)

    var_free, index_free = [], []
    if(len(var_index_free) > 0):
        var_free, index_free = zip(*var_index_free)
    var_fixed, index_fixed = zip(*var_index_to_fix)
    
    newfactor = Factor(*var_free)
    newfactor.set(lambda *v_free: factor.func(*fix_argument(v_free, index_free, index_fixed, value)))

    return newfactor

def condFG(fg, fixed_asn):
    newfg = fg

    for (var, v) in fixed_asn.items():
        print "(fixvar, fixv)", var, v
        touched_f, untouched_f = partition(lambda f: var in f.variables, newfg)
        new_factors = map(lambda f: fix_factor(f, var, v), touched_f)
        newfg = new_factors + untouched_f

    return newfg

def sampleEltFG(nodes, factors, mcmc, fixed_asn={}):

    updateNodes(fixed_asn)

    free_nodes = filter(lambda n: n not in fixed_asn.keys(), nodes)

    cond_fg = condFG(factors, fixed_asn)

    asn = constructAssignments(free_nodes)

    sample, score = mcmc(lambda asn: logscore(cond_fg, asn), asn)

    updateNodes(sample)
    
    return nodes, score

def runAIS(init_asn,
        samples,
        f0,
        fn,
        lower_beta, 
        upper_beta, 
        trans_iter, 
        proposal_fx,
        trans_kernel):

    betas = []
    betas += map(lambda t: (t)*.05, map(lambda i: i/float(lower_beta), range(lower_beta+1)))
    betas += map(lambda t:    (1-t**2)*0.05+(t**2)*1.0, map(lambda i: i/float(upper_beta), range(upper_beta+1)))

    fseq = make_distribution_seq_log(f0, fn, betas)
    Tseq = map(lambda fi: lambda asn: trans_kernel(fi, asn, proposal_fx, trans_iter), fseq)

    sample_scores = []
    for i in range(samples):
        sample_score = AIS(fseq, Tseq, init_asn)
        print sample_score
        sample_scores += [sample_score]
    return sample_scores

