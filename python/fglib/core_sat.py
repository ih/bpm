from constraint import *
from core_factor import *
from util_functional import concat

def getSatisfying_Disj(fs, domain):
    print 'call getSatisfying_Disj'
    canonical_vars = []
    for f in fs:
        canonical_vars.append((f, tuple(set(f.variables))))
    canonical_vars = dict(canonical_vars)
    scope_to_fs = {}
    for f in fs:
        scope_to_fs[canonical_vars[f]] = scope_to_fs.get(canonical_vars[f], [])
        scope_to_fs[canonical_vars[f]].append(f.func)
    new_scope_to_fs = {}
    scope_to_fs = dict(map(lambda (k, v): (k, lambda *a: 1 if reduce(lambda x, y: x  or y, map(lambda f: f(*a), v)) else 0), scope_to_fs.items()))

    new_scope_to_fs = scope_to_fs
    new_fg = []
    for (k, v) in new_scope_to_fs.items():
        factor = Factor(*list(k))
        factor.set(v)
        new_fg.append(factor)

    return getSatisfying(new_fg, domain)

def getSatisfying(fs, domain):
    problem = Problem()
    all_variables = set(concat(map(lambda f: f.variables, fs)))
    map(lambda v: problem.addVariable(v, domain), all_variables)
    map(lambda f: problem.addConstraint(lambda *a: f(*a) > 0, f.variables), fs)
    useEverything = lambda *tiles: len(set(map(lambda tile: tile.tid, tiles))) == len(domain)
    problem.addConstraint(useEverything, all_variables)
    return problem.getSolutionIter()

