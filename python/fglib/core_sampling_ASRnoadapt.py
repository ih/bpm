from itertools import product
from util_dist import *
from util_functional import *
from core_scoring import *

def marginalizeZ(factors, y, z_var_prime, domain):
    if len(factors) == 0:
        return 1.0
    score_sum = 0
    for value in domain:
        z_asn = {z_var_prime:value}
        #print "y"
        #print y
        #print "z_asn"
        #print z_asn
        new_asn = combine(y, z_asn)
        #print "new_asn"
        #print new_asn
        score_sum += prodscore(factors, new_asn)
    return score_sum

def ASRweight(domain, phi2, y_hat, zvar):
    return marginalizeZ(phi2, y_hat, zvar, domain)

def ASR(factor_gen, domain, visited_dict, proposal_fx):
    (phi1, phi2, z, y, C_star) = factor_gen.next()
    y_hat = {}
    old_accept = True
    if len(phi1) == 0: # for FG's with pairwise factors
        y_hat = dict(map(lambda y_var: (y_var, rndSelect(domain)), y))
    else:
        old_accept, y_hat = ASR(factor_gen, domain, visited_dict, proposal_fx)
    z_hat = proposal_fx(domain, phi2, y_hat, z, visited_dict)
    y_z_hat = combine(y_hat, z_hat) 
    weight = ASRweight(domain, phi2, y_hat, z)
    accept = flip(float(weight)/ float(C_star)) and old_accept
    #print "weight, accept, C_star", weight, accept, C_star
    #print "y_z_hat"
    #print y_z_hat
    return accept, y_z_hat

def runASR(factor_gen, domain, proposal_fx):
    visited_dict = {}
    accept, asn_next = ASR(factor_gen(), domain, visited_dict, proposal_fx)
    while not accept:
        print "rejected------------------"
        accept, asn_next = ASR(factor_gen(), domain, visited_dict, proposal_fx)
    return asn_next

def sample(factor_gen, domain, proposal_fx):
    return runASR(factor_gen, domain, proposal_fx)

def decompose(factors, var):
    phi1 = filter(lambda f: var not in f.variables, factors)
    phi2 = filter(lambda f: var in f.variables, factors)
    return phi1, phi2, var


def calculateC(phi2, var, domain):
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
    return max(map(lambda y_asn: marginalizeZ(phi2, dict(zip(list(y), y_asn)), var, domain), all_asn_y))


def gen_factor_seq(domain, factors, vars, results = []):
    if len(factors) == 0:
        return results
    else:
        phi1, phi2, var = decompose(factors, vars[0])
        #print "phi2"
        #print phi2
        #print "phi1"
        #print phi1
        #print "var"
        #print var
        C_star = calculateC(phi2, var, domain)
        return gen_factor_seq(domain, phi1, vars[1:], results + [(phi1, phi2, var, vars[1:], C_star)])

def Gibbs_proposal(domain, factors, y_asn, var_to_change, visited_dict):
    #print "Entering Gibbs"
    #print "-----------", var_to_change
    #print "factors", factors
    if len(factors) == 0:
        return {var_to_change: rndSelect(domain)}

    gibbs_kernel = {}
    for i in domain:
        z_asn = {var_to_change: i}
        y_z_asn = combine(y_asn, z_asn)
        gibbs_kernel[i] = prodscore(factors, y_z_asn)
    
    #print Dist(gibbs_kernel)()
    #print Dist(gibbs_kernel)()
    #print Dist(gibbs_kernel)()
    #print Dist(gibbs_kernel)()
    #print Dist(gibbs_kernel)()
    #print gibbs_kernel
    return {var_to_change: Dist(gibbs_kernel)()}
