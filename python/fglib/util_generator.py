from util_functional import *

def gen_range(n, gen, *args):
    return snds(zip(range(n), gen(*args)))
