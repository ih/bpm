from math import log
from math import exp
from util_functional import concat


def logscore(fs, asn):
    bound = map(lambda f: (f, map(lambda v: asn[v], f.variables)), fs)
    try:
        return reduce(lambda x, y: x+y ,map(lambda (f, a): log(f(*a)), bound), 0.0)
    except ValueError:
        return -9000

def prodscore(fs, asn):
    bound = map(lambda f: (f, map(lambda v: asn[v], f.variables)), fs)
    try:
        return reduce(lambda x, y: x*y ,map(lambda (f, a): f(*a), bound), 1.0)
    except ValueError:
        return -9000

def prodscore_exp(fs, asn):
    bound = map(lambda f: (f, map(lambda v: asn[v], f.variables)), fs)
    try:
        return reduce(lambda x, y: x*y ,map(lambda (f, a): exp(f(*a)), bound))
    except ValueError:
        return -9000

def sumscore(fs, asn):
    bound = map(lambda f: (f, map(lambda v: asn[v], f.variables)), fs)
    try:
        return reduce(lambda x, y: x+y ,map(lambda (f, a): f(*a), bound))
    except ValueError:
        return -9000

def mkHardSoftScore(hardfs, softfs):
    return lambda asn: prodscore(hardfs, asn) * exp(sumscore(softfs, asn))

UNSAT = -9000

def mkHardSoftScoreLog(hardfs, softfs):
    def score(asn):
        hard_score = prodscore(hardfs, asn)
        return UNSAT if 0 == hard_score else log(hard_score) + sumscore(softfs, asn)
    return score

def empiric_expect(repeated_features, asn):
    bound = map(lambda f: (f, map(lambda v: asn[v], f.variables)), repeated_features)
    try:
        return reduce(lambda x, y: x+y ,map(lambda (f, a): 1.0 if f(*a) > 0 else 0.0, bound)) / float(len(repeated_features))
    except ValueError:
        return -9000

def multi_empiric_expect(asn_feature_list):
    total = 0
    totallentgh = 0
    for (asn, repeated_features) in asn_feature_list:
        bound = map(lambda f: (f, map(lambda v: asn[v], f.variables)), repeated_features)
        total += reduce(lambda x, y: x+y ,map(lambda (f, a): 1.0 if f(*a) > 0 else 0.0, bound))
        totallentgh += len(repeated_features)
    return total / float(totallentgh)

def feature_response(repeated_features, asn):
    bound = map(lambda f: (f, map(lambda v: asn[v], f.variables)), repeated_features)
    try:
        return reduce(lambda x, y: x+y ,map(lambda (f, a): f(*a), bound)) / float(len(repeated_features))
    except ValueError:
        return -9000

