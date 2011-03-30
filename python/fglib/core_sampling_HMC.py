from math import *
from random import uniform
from random import randint
import util_vector as vec
from random import gauss
from util_functional import *
from core_scoring import *


#
#   Hamiltonian Monte Carlo (HMC) sampling algorithm.
#  
#   fs: asn -> float. It is a function returning logscore of the assignment.
#   starting_state: asn
#   proposal_fx: asn -> asn. It generates candidate assignments
#
#   HMC performs sampling over variables represenring a single "continuous" type. 
#   For example, the state variable is a dictionary {N1: (x1, y1), N2: (x2, y2)...}
#

#
# This is a convenient function to get gradients specified in factor graphs.
#
def gradient_fromfactors(factors, x):
    dUdx = {}
    def setdU(k, v):
        dUdx[k] = v
    bound = map(lambda f: (f, map(lambda v: x[v], f.variables)), factors)
    gradient_results = map(lambda (f, a): (f, f.grad(*a)), bound) #(f, {f.variables[0]:(...)})
    map(lambda (f, grad): (f, map(lambda (var, g): setdU(var, vec.add(dUdx.get(var, (0, 0)), g)), grad.items())), gradient_results) #FIXME
    return dUdx

def leapfrog(gradient_fx, x, u, epsilon):
    dU = gradient_fx(x)
    u_new = dict(map(lambda (k, v): (k, vec.sub(v, vec.scale(dU[k], epsilon*0.5))), u.items()))
    x = dict(map(lambda (k, v): (k, vec.add(x[k], vec.scale(v, epsilon))), u_new.items()))
    dU = gradient_fx(x)
    u_new = dict(map(lambda (k, v): (k, vec.sub(v, vec.scale(dU[k], epsilon*0.5))), u.items()))
    return x, u_new

def Ham(fs, x, u):
    return -fs(x) + 0.5*vec.dot(tuple(snds(u.items())), tuple(snds(u.items())))


def HMC_gen(fs, starting_state, proposal_fx, gradient_fx, leapfrogIter = 100, leapfrogEpsilon = 0.05):
    xcurr = starting_state
    while True:
        ucurr = proposal_fx(xcurr)
        xst, ust = xcurr, ucurr
        for j in range(leapfrogIter):
            xst, ust = leapfrog(gradient_fx, xst, ust, leapfrogEpsilon)
        if uniform(0, 1) < min(1, exp(Ham(fs, xcurr, ucurr) - Ham(fs, xst, ust))):
            xcurr = xst
            currscore = fs(xcurr)
            print "currscore", currscore
        yield xcurr, currscore


def HMC_n_iter(fs, starting_state, proposal_fx, gradient_fx, leapfrogIter = 100, leapfrogEpsilon = 0.05, nIter = 100):
    return zip(range(nIter), HMC_gen(fs, starting_state, proposal_fx, gradient_fx, leapfrogIter, leapfrogEpsilon))[-1][1]


def HMC_one_iter(fs, starting_state, proposal_fx, gradient_fx, leapfrogIter = 100, leapfrogEpsilon = 0.05):
    return HMC_n_iter(fs, starting_state, proposal_fx, gradient_fx, leapfrogIter, leapfrogEpsilon, nIter = 1)

