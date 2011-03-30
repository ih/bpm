from math import log
from math import exp

def apply_template_constraint(fs, predicate, theta = 1):
    map(lambda f: f.setConstraints(predicate, theta), fs)


def apply_template(fs, factorfx):
    map(lambda f: f.set(factorfx), fs)


def gen_feat(predicate, theta = 1):
    def feat(*asn):
        return theta if predicate(*asn) else 0
    return feat

def gen_feat_exp(predicate, theta = 1):
    def feat(*asn):
        return exp(theta) if predicate(*asn) else 1
    return feat

def mkDisj(fs):
    canonical_vars = []
    for f in fs:
        canonical_vars.append((f, tuple(set(f.variables))))
    canonical_vars = dict(canonical_vars)
    scope_to_fs = {}
    for f in fs:
        scope_to_fs[canonical_vars[f]] = scope_to_fs.get(canonical_vars[f], [])
        scope_to_fs[canonical_vars[f]].append(f.func)
    new_scope_to_fs = {}
    scope_to_fs = dict(map(lambda (k, v): (k, lambda *a: sum(map(lambda f: f(*a), v))), scope_to_fs.items()))

    new_scope_to_fs = scope_to_fs
    new_fg = []
    for (k, v) in new_scope_to_fs.items():
        factor = Factor(*list(k))
        factor.set(v)
        new_fg.append(factor)
    return new_fg    

class Factor(object):
  def __init__(self, *variables): 
    self.variables = variables 
    self.name = None
  def __repr__(self):
    return "Factor scope: %s" % map(lambda v: v.__repr__(), self.variables)
  def __call__(self, *assignments):
    return self.func(*assignments)
  def set(self, func):
    self.func = func
    return self
  def setWeighted(self, func, theta = 1.0):
    self.func = lambda *asn: theta * func(*asn)
    return self
  def setGrad(self, func):
    self._grad = func
    return self
  def setName(self, name):
    self.name = name
    return self
  def setConstraints(self, predicate, theta = 1):
    self.set(gen_feat(predicate, theta))
    return self
  def setSoftConstraints(self, predicate, theta = 1):
    self.set(gen_feat_exp(predicate, theta))
    return self
  def grad(self, *assignments):
    return dict(zip(self.variables, self._grad(*assignments)))
  def score(self, asn):
    bound = map(lambda v: asn[v], self.variables)
    try:
        return self.func(*bound)
    except ValueError:
        return -9000
  def logscore(self, asn):
    bound = map(lambda v: asn[v], self.variables)
    try:
        return log(self.func(*bound))
    except ValueError:
        return -9000
