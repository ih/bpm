from math import exp
from util_dist import Dist
from util_ext_frozendict import frozendict
from core_sampling_AIS import nextweight_log

def resampleParticles(particles, weights):
    frozenparticles = map(frozendict, particles)
    distribution = dict(zip(frozenparticles, weights))
    resampled = map(lambda p: Dist(distribution)(), frozenparticles)
    new_particles_weights = map(lambda p: (p, distribution[p]), resampled)
    new_particles, new_weights = zip(*new_particles_weights)
    new_particles = map(dict, new_particles)
    return new_particles, new_weights

# particle AIS
def AISp(fseq, Tseq, particles, resample_interval = 10):
    prev_weights = [0]*len(particles) 
    prev_particles = particles
    curr_weights = prev_weights
    curr_particles = []
    for i in range(1, len(fseq)):
        curr_particles = map(Tseq[i], prev_particles)
        pppw = zip(prev_particles, prev_weights)
        curr_weights = map(lambda (pp, pw): nextweight_log(pw, fseq[i], fseq[i-1], pp), pppw)

        if i % resample_interval == 0:
            curr_particles, curr_weights = resampleParticles(curr_particles, curr_weights)
        prev_weights = curr_weights
        prev_particles = curr_particles
    res_pppw = zip(curr_particles, map(exp, curr_weights))
    return res_pppw

