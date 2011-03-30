def fsts(xs):
	return map(lambda (x, y): x, xs)

def snds(xs):
	return map(lambda (x, y): y, xs)
def concat(xs):
	return reduce(lambda x, y: x + y, xs, [])

swap = lambda (x, y): (y, x)

def unconcat(l, n):
	return [l[i:i+n] for i in range(0, len(l), n)]

combine = lambda *ds : reduce(lambda x, y: dict(x.items() + y.items()), ds)

zipWith = lambda f, xs: map(lambda args: f(*args), zip(*xs))

partition = lambda pred, xs: (filter(pred, xs), filter(lambda x: not pred(x), xs))

nub = lambda xs: list(set(xs))

nubLL = lambda xss: map(list, list(set(map(tuple, xss))))

def accum_dict(xs, ys, binop = lambda x, y: x + y):
	res = {}
	for (k, v) in xs.items():
		res[k] = binop(xs[k], ys[k])
	return res

# For dependent type programming
def can_int(x):
	try:
		res = int(x)
		return True
	except ValueError:
		return False

prefixes = lambda xs: map(lambda i: xs[:i+1], range(len(xs)))

scanl = lambda f, xs: map(lambda xs: reduce(f, xs), prefixes(xs))

def normalize(xs):
    T = float(sum(xs))
    return map(lambda x: x / T, xs)

mapd = lambda f, d: dict(map(f, d.items()))

ngram = lambda n: lambda xs: zip(*map(lambda i: xs[i:], range(n)))
circular_ngram = lambda n: lambda xs: zip(*map(lambda i: xs[i:] + xs[0:i], range(n)))

compose = lambda f, g: lambda *a: f(g(*a))
