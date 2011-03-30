from util_dist import *
from builtin_element import *
from util_functional import *

def uniformProposal(xcurr):
    return dict(map(lambda (n, asn): (n, (uniform(0, 10), uniform(0, 10))), xcurr.items()))

def sampleMultiVarGaussian(mean, var):
    return tuple(map(lambda (mm, vv): gauss(mm, vv), zip(mean, var)))

def selectProposalByName(xcurr, field, items, target):
    return mapd(lambda (n, t): (n, t.copyWithUpdate(field, rndSelect(items))) if n == target else (n, t), xcurr)

def gaussPerturbProposal(xcurr, var=0.1):
    return dict(map(lambda (n, (x, y)): (n, gauss_perturb((x, y), var)), xcurr.items()))

def gaussPerturbProposalByNameAll(xcurr, name, var): # Uses Tile objects
    return dict(map(lambda (n, tile): (n, tile.copyWithUpdate(name, gauss_perturb(tile.getField(name), var))), xcurr.items()))


def gaussPerturbProposalByName(xcurr, name, var, target): # Uses Tile objects 
    return dict(map(lambda (n, tile): (n, tile.copyWithUpdate(name, gauss_perturb(tile.getField(name), var))) if n == target else (n, tile), xcurr.items()))


def gaussPerturbProposalByNameAllTrunc1D(xcurr, name, var, left, right): # Uses Tile objects
    return dict(map(lambda (n, tile): (n, tile.copyWithUpdate(name, gauss_perturb_truncate1d(tile.getField(name), var, left, right))), xcurr.items()))

def gaussPerturbProposalByNameTrunc1D(xcurr, name, var, target, left, right): # Uses Tile objects 
    return dict(map(lambda (n, tile): (n, tile.copyWithUpdate(name, gauss_perturb_truncate1d(tile.getField(name), var, left, right))) if n == target else (n, tile), xcurr.items()))

def gaussPerturbProposalByNameTrunc(xcurr, name, var, target, left, right): # Uses Tile objects 
    return dict(map(lambda (n, tile): (n, tile.copyWithUpdate(name, gauss_perturb_truncate(tile.getField(name), var, left, right))) if n == target else (n, tile), xcurr.items()))

def multi_update_tile(t, field_vars):
    res = t
    for (f, v) in field_vars:
        res = res.copyWithUpdate(f, v)
    return res

def multiGaussPerturbByNameAll(xcurr, field_vars):
    field_vals = lambda t: map(lambda (f, var): (f, gauss_perturb(t.getField(f), var)), field_vars)
    return mapd(lambda (n, tile): (n, multi_update_tile(tile, field_vals(tile))), xcurr)

def multiGaussPerturbByName(xcurr, field_vars, target):
    field_vals = lambda t: map(lambda (f, var): (f, gauss_perturb(t.getField(f), var)), field_vars)
    return mapd(lambda (n, tile): (n, multi_update_tile(tile, field_vals(tile))) if n == target else (n, tile), xcurr)

def multiGaussPerturbByNameTrunc1D(xcurr, field_vars, target, left, right):
    field_vals = lambda t: map(lambda (f, var): (f, gauss_perturb_truncate1d(t.getField(f), var, left, right)), field_vars)
    return mapd(lambda (n, tile): (n, multi_update_tile(tile, field_vals(tile))) if n == target else (n, tile), xcurr)

def multiGaussPerturbByNameAllTrunc1D(xcurr, field_vars, target, left, right):
    field_vals = lambda t: map(lambda (f, var): (f, gauss_perturb_truncate1d(t.getField(f), var, left, right)), field_vars)
    return mapd(lambda (n, tile): (n, multi_update_tile(tile, field_vals(tile))), xcurr)
