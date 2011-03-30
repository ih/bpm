from builtin_element import *

def sampleEltFG(nodes, factors, mcmc, fixed_asn={}):
    updateNodes(fixed_asn)
    asn = constructAssignments(nodes)
