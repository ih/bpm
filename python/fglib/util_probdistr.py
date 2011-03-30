import util_functional as fp

def normalize(d):
	total = sum(d.values())
	return dict(map(lambda (k, v): (k, v / total), d.items()))

def project(d, pred):
	return normalize(dict(filter(lambda (k, v): pred(k), d.items())))

def agg_distr(*ds):
	return normalize(fp.combine(*ds))

def agg_distrs(ds):
	return normalize(fp.combine(*ds))
