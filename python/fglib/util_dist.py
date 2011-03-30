from random import uniform
from random import sample
from random import gauss

rndSelect = lambda xs: sample(xs, 1)[0]

def gauss_perturb_truncate1d(ms, vs, ls, rs):
    while True:
        res = gauss_perturb(ms, vs)
        if res > ls and res < rs:
            return res

def gauss_perturb_truncate(ms, vs, ls, rs):
    while True:
        res = gauss_perturb(ms, vs)
        if reduce(lambda x, y: x and y, map(lambda (x, l): x > l, zip(res, ls))) and reduce(lambda x, y: x and y, map(lambda (x, r): x < r, zip(res, rs))):
            return res

def gauss_perturb(ms, vs):

    if type(ms) != tuple and type(ms) != list:
        return gauss(ms, vs)
    else:
        if type(vs) != tuple and type(vs) != list:
            return tuple(map(lambda m: gauss(m, vs), ms))
        else:
            return tuple(map(lambda (m, v): gauss(m, v), zip(ms, vs)))

def mean_var(data):
    meanData = sum(data)/ len(data)
    varData = sum(map(lambda s: (s-meanData)**2, data))/(len(data))
    return meanData, varData

def flip(prob):
    return True if uniform(0, 1) < prob else False

def norm_dict(d):
    total = float(sum(d.values()))
    if total == 0.0:
        total = float(len(d.values()))
        return dict(map(lambda (k, v): (k, 1.0 / total), d.items()))
    else:
        return dict(map(lambda (k, v): (k, v / total), d.items()))

class Dist(object):
		def __init__(self, data, conditional=False):
			self.cond = conditional
			self.data = norm_dict(data)
		def __call__(self, *args):
			return self.sample(*args)
		def sample(self,*args):
			t = uniform(0,1)
			probs = [v for (k, v) in self.data.items()]
			vals = [k for (k, v) in self.data.items()]
			ind = 0

			for i in range(len(probs)):
				if i is not 0:
					probs[i] = probs[i] + probs[i - 1]
			for i in range(len(probs)):
				if t < probs[i]:
					ind = i
					break				
			return vals[ind]
		def __repr__(self):
			return "Dist %s" % self.data if not self.cond else "CPT %s" % self.data

