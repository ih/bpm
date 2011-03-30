from itertools import product
from util_dist import *
from util_functional import *
from core_scoring import *

def marginalizeZ(scorefx, factors, y, z_var_prime, domain):
    if len(factors) == 0:
        return 1.0
    score_sum = 0
    for value in domain:
        z_asn = {z_var_prime:value}
        new_asn = combine(y, z_asn)
        score_sum += exp(scorefx(new_asn))
    return -9000 if score_sum == 0 else log(score_sum)

def extract_asnonly(asn, vars):
    return tuple(map(lambda v: asn[v], vars))

def ASRweight(scorefx, domain, phi2, y_hat, zvar, yvars, visited_dict):
    orig_weight = marginalizeZ(scorefx, phi2, y_hat, zvar, domain)
    y_asn = extract_asnonly(y_hat, yvars)
    if y_asn in visited_dict[zvar].keys():
        orig_weight = orig_weight * visited_dict[zvar][y_asn]
    return orig_weight

def ASRweightStandard(scorefx, domain, phi2, y_hat, zvar):
    orig_weight = marginalizeZ(scorefx, phi2, y_hat, zvar, domain)
    return orig_weight

def ASR(factor_gen, domain, visited_dict, proposal_fx):
    (phi1, phi2, z, y, C_star, scorefx) = factor_gen.next()
    y_hat = {}
    old_accept = True
    if len(phi1) == 0: # for FG's with pairwise factors
        y_hat = dict(map(lambda y_var: (y_var, rndSelect(domain)), y))
    else:
        old_accept, y_hat = ASR(factor_gen, domain, visited_dict, proposal_fx)
    if not old_accept:
        return old_accept, y_hat
    z_hat = proposal_fx(scorefx, domain, phi2, y_hat, z, y, visited_dict)
    y_z_hat = combine(y_hat, z_hat) 
    visited_y = extract_asnonly(y_hat, y)
    weight = ASRweightStandard(scorefx, domain, phi2, y_hat, z)
    if visited_dict[z].has_key(visited_y):
        weight = C_star
    accept = flip(exp(float(weight) - float(C_star))) and old_accept
    
    visited_dict[y[0]] = visited_dict.get(y[0], {})
    visited_dict[y[0]][visited_y] = float(weight) -float(C_star)
    #visited_dict[z] = visited_dict.get(z, {})
    #visited_dict[z][visited_y] = float(weight)/float(C_star)
    #print "weight, accept, C_star", weight, accept, C_star
    #print "y_z_hat"
    #print y_z_hat
    return accept, y_z_hat

def runASR(factor_gen, domain, proposal_fx, visited_dict):
    accept, asn_next = ASR(factor_gen(), domain, visited_dict, proposal_fx)
    reject_count = 0
    while not accept:
        reject_count += 1
        accept, asn_next = ASR(factor_gen(), domain, visited_dict, proposal_fx)

    print "rejected %d------------------" % reject_count
    return asn_next

def ASR_sample(factor_gen, domain, proposal_fx, visited_dict):
    return runASR(factor_gen, domain, proposal_fx, visited_dict)

def decompose(factors, var):
    phi1 = filter(lambda f: var not in f.variables, factors)
    phi2 = filter(lambda f: var in f.variables, factors)
    return phi1, phi2, var


def calculateC(scorefx, phi2, var, domain):
    if len(phi2) == 0:
        return 1.0
    all_var = set(concat(map(lambda f: f.variables, phi2)))
    #print "all_var"
    #print all_var
    y = all_var - set([var])
    all_asn_y = list(product(*[domain]*len(y)))
    #print "all_asn_y"
    #print all_asn_y
    #print "y"
    #print y
    #print "list(y)"
    #print list(y)
    C =  max(map(lambda y_asn: marginalizeZ(scorefx, phi2, dict(zip(list(y), y_asn)), var, domain), all_asn_y))
    #print "C"
    #print C
    return C


def gen_factor_seq(domain, hard_factors, soft_factors, vars, results = []):
    if len(hard_factors + soft_factors) == 0:
        return results
    else:

        phi1hard, phi2hard, var = decompose(hard_factors, vars[0])
        phi1soft, phi2soft, var = decompose(soft_factors, vars[0])

        phi1 = phi1hard + phi1soft
        phi2 = phi2hard + phi2soft

        scorefx = mkHardSoftScoreLog(phi2hard, phi2soft)
        
        C_star = calculateC(scorefx, phi2, var, domain)
        return gen_factor_seq(domain, phi1hard, phi1soft, vars[1:], results + [(phi1, phi2, var, vars[1:], C_star, scorefx)])

def Gibbs_proposal_reweight(scorefx, domain, factors, y_asn, var_to_change, yvars, visited_dict):
    if len(factors) == 0:
        return {var_to_change: rndSelect(domain)}

    y_asn_only = extract_asnonly(y_asn, yvars)

    gibbs_kernel = {}
    for i in domain:
        z_asn = {var_to_change: i}
        y_z_asn = combine(y_asn, z_asn)
        orig_weight = scorefx(y_z_asn)

        y_z_asn_only = tuple([i] + list(y_asn_only)) 
        #if len(visited_dict[var_to_change].keys()) > 0 and len(visited_dict[var_to_change].keys()[0]) != len(y_z_asn_only):
        #    print "mismatch"
        #else:
        #    print "match"
        if y_z_asn_only in visited_dict[var_to_change].keys():
            orig_weight = orig_weight + visited_dict[var_to_change][y_z_asn_only]
            #if visited_dict[var_to_change][y_z_asn_only] < 0.01:
            #    print "changing gibbs---------"
        gibbs_kernel[i] = exp(orig_weight)
    
    return {var_to_change: Dist(gibbs_kernel)()}

def Gibbs_proposal(scorefx, domain, factors, y_asn, var_to_change, yvars, visited_dict):
    if len(factors) == 0:
        return {var_to_change: rndSelect(domain)}

    gibbs_kernel = {}
    for i in domain:
        z_asn = {var_to_change: i}
        y_z_asn = combine(y_asn, z_asn)
        gibbs_kernel[i] = scorefx(y_z_asn)
    
    return {var_to_change: Dist(gibbs_kernel)()}

def easyASR(elt_grid, hard_factors, soft_factors, domain):
    var_seq = concat(elt_grid)
    factor_seq = gen_factor_seq(domain, hard_factors, soft_factors, var_seq)
    factor_generator = lambda: (f for f in factor_seq)

    visited_dict = dict(map(lambda v: (v, {}), var_seq))
    next_sample = ASR_sample(factor_generator, domain, Gibbs_proposal_reweight, visited_dict)
    return (next_sample, mkHardSoftScoreLog(hard_factors, soft_factors)(next_sample))
    #for i in range(numSyn):
    #    res += (next_sample, prodscore(factors, next_sample))
    #    update_elt_grid_by_dict_asn(elt_grid, next_sample)
    #return res

if __name__ == "__main__":

    #testSat()     
    test()



