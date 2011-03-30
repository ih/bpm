from math import log
from util_probdistr import project

log2 = lambda x : log(x, 2)

def kl_div(p, q):
	return sum(map(lambda k: 0 if p[k] == 0 else p[k] * log(p[k] / q[k]), p.keys()))

def kl_div_proj(p, q):
	return (kl_div(p_in_q(p, q), q), p_notin_q(p, q))

# In the case where q[k] == 0 but p[k] != 0,
# we preprocess p so that the KL divergence analysis is on the keys that they do have in common,
# and also output the keys we deleted. 

def p_in_q(p, q):
	return project(p, lambda k: q.get(k, 0) != 0)

def p_notin_q(p, q):
	return project(p, lambda k: q.get(k, 0) == 0)

test1 = { 0 : 0.5, 1 : 0.5 }
test2 = { 0 : 0.3, 1 : 0.7 }

test3 = { 0 : 0,   1: 1.0 }

def hist_intersect(p, q):
	return (sum(map(lambda k: min(p[k], q.get(k, 0)), p.keys())) + sum(map(lambda k: min(q[k], p.get(k, 0)), q.keys()))) * 0.5
