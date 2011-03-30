import util_vector as vec
from math import *

DIST_MEAN = 6
DIST_VAR = 0.5
ORIENT_MEAN = 0
ORIENT_VAR = 1
POS_STRAIGHT_MEAN = 0.0
POS_STRAIGHT_VAR = 0.3
NEG_STRAIGHT_MEAN = 0.0
NEG_STRAIGHT_VAR = 0.3

def ccw(x, y, z):
    x = (x[0], x[1], 0)
    y = (y[0], y[1], 0)
    z = (z[0], z[1], 0)
    vec12 = vec.sub(y, x)
    vec32 = vec.sub(z, x)
    if vec.length(vec12) > 0 and vec.length(vec32) > 0:
        vec12 = vec.norm(vec12)
        vec32 = vec.norm(vec32)
        sign = -1 if vec.cross(vec12, vec32)[2] > 0 else 1
        return sign * vec.length(vec.cross(vec12, vec32))
    else:
        return 0


def gaussPDFRN(pos, meanvec, var):
    return exp(-0.5* ((vec.dist(pos, meanvec))**2) / var )

def make_vectoreqgauss(means, var):
    return lambda x: gaussPDFRN(x, means, var)

def sigmoid(t):
    return 1.0 / (1.0 + exp(-t))

def soft_geq(x):
    return lambda t: sigmoid(t - x)

def soft_leq(x):
    return lambda t: sigmoid(-t + x)

def make_gauss_mix(list_of_gauss):
    print list_of_gauss
    return lambda *args: sum(map(lambda fx: fx(*args), list_of_gauss))

def make_dotgauss(mean, var):
    def dotgauss_local(x, y):
        return gaussPDF(vec.dot(x, y), mean, var)
    return dotgauss_local

def make_gauss_spacing(mean, var):
    def call(dists):
        pairs = zip(dists, dists[1:])
        diffs = map(lambda (x, y): vec.dist(x, y), pairs)
        return gaussPDF(sum(diffs), mean, var)
    return call

def make_gauss_spacing_gt(mean, var):
    def call(dists):
        pairs = zip(dists, dists[1:])
        diffs = map(lambda (x, y): vec.dist(x, y), pairs)
        return gaussPDF(sum(diffs), 0, var) * soft_geq(mean)(sum(dists) / float(len(dists)))
    return call
def make_gauss_equal_spacing(var):
    return make_gauss_spacing(0, var)

def make_eqgauss(mean, var):
    return lambda x: make_distgauss(0, var)(x, mean)

def make_positiongauss(mean, var):
    def posgauss_local(pos):
        return gaussPDFR2(pos, (mean, mean), var)
    return posgauss_local

def make_distgauss(mean, var):
    def distgauss_local(x1, x2):
        return gaussPDF(vec.dist(x1, x2), mean, var)
    return distgauss_local

def make_straightgauss(mean, var):
    def straigtgauss_local(xy1, xy2, xy3):
        return gaussPDF(signed_straightness(xy1, xy2, xy3), mean, var)
    return straigtgauss_local

def make_unsigned_straightgauss(mean, var):
    def straigtgauss_local(xy1, xy2, xy3):
        return gaussPDF(straightness(xy1, xy2, xy3), mean, var)
    return straigtgauss_local

def gaussPDFR2(pos, meanvec, var):
    return exp(-0.5* ((vec.dist(pos, meanvec))**2) / var )

def gaussPDF(x, mean, var):
    return 1/sqrt(2*pi*(var)) * exp(-((x-mean)**2)/(2.0*var))

def distgauss(x1, x2):
    return gaussPDF(vec.dist(x1, x2), DIST_MEAN, DIST_VAR)

def orientgauss(x1, x2):
    return gaussPDF(vec.sub(x1, x2), ORIENT_MEAN, ORIENT_VAR)

def straigtgauss(xy1, xy2, xy3):
    return gaussPDF(straightness(xy1, xy2, xy3), POS_STRAIGHT_MEAN, POS_STRAIGHT_VAR)

def neg_signed_straigtgauss(xy1, xy2, xy3):
    return gaussPDF(signed_straightness(xy1, xy2, xy3), NEG_STRAIGHT_MEAN, NEG_STRAIGHT_VAR)

def pos_signed_straigtgauss(xy1, xy2, xy3):
    return gaussPDF(signed_straightness(xy1, xy2, xy3), POS_STRAIGHT_MEAN, POS_STRAIGHT_VAR)

def straightness(xy1, xy2, xy3):
    vec12 = vec.norm((xy2[0] - xy1[0], xy2[1] - xy1[1]))
    vec32 = vec.norm((xy2[0] - xy3[0], xy2[1] - xy3[1]))
    return vec.length(vec.add(vec12, vec32))

def signed_straightness(xy1, xy2, xy3):
    vec12 = (xy2[0] - xy1[0], xy2[1] - xy1[1], 0)
    vec32 = (xy2[0] - xy3[0], xy2[1] - xy3[1], 0)
    if vec.length(vec12) > 0 and vec.length(vec32) > 0:
        vec12 = vec.norm(vec12)
        vec32 = vec.norm(vec32)
        sign = 1 if vec.cross(vec12, vec32)[2] > 0 else -1
        return sign * vec.length(vec.add(vec12, vec32))
    else:
        return 0


def distgauss_grad((x1, y1), (x2, y2)):
    dFdx1 =    (((x1-x2)**2 + (y1-y2)**2)**(-0.5))*(x1-x2) if x1 != x2 or y1 != y2 else 0
    dFdy1 =    (((x1-x2)**2 + (y1-y2)**2)**(-0.5))*(y1-y2) if x1 != x2 or y1 != y2 else 0
    dFdx2 = -(((x1-x2)**2 + (y1-y2)**2)**(-0.5))*(x1-x2) if x1 != x2 or y1 != y2 else 0
    dFdy2 = -(((x1-x2)**2 + (y1-y2)**2)**(-0.5))*(x1-x2) if x1 != x2 or y1 != y2 else 0
    dist = vec.dist((x1, y1), (x2, y2))
    FM = (dist - DIST_MEAN)
    dUdx1 = distgauss((x1, y1), (x2, y2)) * (FM/DIST_VAR) * dFdx1 
    dUdy1 = distgauss((x1, y1), (x2, y2)) * (FM/DIST_VAR) * dFdy1 
    dUdx2 = distgauss((x1, y1), (x2, y2)) * (FM/DIST_VAR) * dFdx2 
    dUdy2 = distgauss((x1, y1), (x2, y2)) * (FM/DIST_VAR) * dFdy2 
    return ((dUdx1, dUdy1), (dUdx2, dUdy2))

def approx_signed_straigtness_grad((x1, y1), (x2, y2), (x3, y3)):
    offset = 0.2
    straightness_old = signed_straightness((x1, y1), (x2, y2), (x3, y3))
    dSdx1 = (signed_straightness((x1+offset, y1), (x2, y2), (x3, y3))-straightness_old)/offset
    dSdy1 = (signed_straightness((x1, y1+offset), (x2, y2), (x3, y3))-straightness_old)/offset
    dSdx2 = (signed_straightness((x1, y1), (x2+offset, y2), (x3, y3))-straightness_old)/offset
    dSdy2 = (signed_straightness((x1, y1), (x2, y2+offset), (x3, y3))-straightness_old)/offset
    dSdx3 = (signed_straightness((x1, y1), (x2, y2), (x3+offset, y3))-straightness_old)/offset
    dSdy3 = (signed_straightness((x1, y1), (x2, y2), (x3, y3+offset))-straightness_old)/offset
    return ((dSdx1, dSdy1), (dSdx2, dSdy2), (dSdx3, dSdy3))

def make_distgauss_grad(mean, var):
    def distgauss_grad((x1, y1), (x2, y2)):
        dFdx1 =    (((x1-x2)**2 + (y1-y2)**2)**(-0.5))*(x1-x2) if x1 != x2 or y1 != y2 else 0
        dFdy1 =    (((x1-x2)**2 + (y1-y2)**2)**(-0.5))*(y1-y2) if x1 != x2 or y1 != y2 else 0
        dFdx2 = -(((x1-x2)**2 + (y1-y2)**2)**(-0.5))*(x1-x2) if x1 != x2 or y1 != y2 else 0
        dFdy2 = -(((x1-x2)**2 + (y1-y2)**2)**(-0.5))*(x1-x2) if x1 != x2 or y1 != y2 else 0
        dist = vec.dist((x1, y1), (x2, y2))
        FM = (dist - mean)
        dUdx1 = distgauss((x1, y1), (x2, y2)) * (FM/var) * dFdx1 
        dUdy1 = distgauss((x1, y1), (x2, y2)) * (FM/var) * dFdy1 
        dUdx2 = distgauss((x1, y1), (x2, y2)) * (FM/var) * dFdx2 
        dUdy2 = distgauss((x1, y1), (x2, y2)) * (FM/var) * dFdy2 
        return ((dUdx1, dUdy1), (dUdx2, dUdy2))
    return distgauss_grad

def make_straightgauss_grad(mean, var):
    signed_straigtgauss = make_straightgauss(mean, var)
    def signed_straigtgauss_grad((x1, y1), (x2, y2), (x3, y3)):
        straightness_old = signed_straightness((x1, y1), (x2, y2), (x3, y3))
        FM = straightness_old - mean
        ((dFdx1, dFdy1), (dFdx2, dFdy2), (dFdx3, dFdy3)) = approx_signed_straigtness_grad((x1, y1), (x2, y2), (x3, y3))
        dUdx1 =    signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/var) * dFdx1 
        dUdy1 =    signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/var) * dFdy1 
        dUdx2 =    signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/var) * dFdx2 
        dUdy2 =    signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/var) * dFdy2 
        dUdx3 =    signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/var) * dFdx3 
        dUdy3 =    signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/var) * dFdy3 
        return ((dUdx1, dUdy1), (dUdx2, dUdy2), (dUdx3, dUdy3))
    return signed_straigtgauss_grad

def neg_signed_straigtgauss_grad((x1, y1), (x2, y2), (x3, y3)):
    straightness_old = signed_straightness((x1, y1), (x2, y2), (x3, y3))
    FM = straightness_old - NEG_STRAIGHT_MEAN
    ((dFdx1, dFdy1), (dFdx2, dFdy2), (dFdx3, dFdy3)) = approx_signed_straigtness_grad((x1, y1), (x2, y2), (x3, y3))
    dUdx1 =    neg_signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/NEG_STRAIGHT_VAR) * dFdx1 
    dUdy1 =    neg_signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/NEG_STRAIGHT_VAR) * dFdy1 
    dUdx2 =    neg_signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/NEG_STRAIGHT_VAR) * dFdx2 
    dUdy2 =    neg_signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/NEG_STRAIGHT_VAR) * dFdy2 
    dUdx3 =    neg_signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/NEG_STRAIGHT_VAR) * dFdx3 
    dUdy3 =    neg_signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/NEG_STRAIGHT_VAR) * dFdy3 
    return ((dUdx1, dUdy1), (dUdx2, dUdy2), (dUdx3, dUdy3))


def pos_signed_straigtgauss_grad((x1, y1), (x2, y2), (x3, y3)):
    straightness_old = signed_straightness((x1, y1), (x2, y2), (x3, y3))
    FM = straightness_old - POS_STRAIGHT_MEAN
    ((dFdx1, dFdy1), (dFdx2, dFdy2), (dFdx3, dFdy3)) = approx_signed_straigtness_grad((x1, y1), (x2, y2), (x3, y3))
    dUdx1 =    pos_signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/POS_STRAIGHT_VAR) * dFdx1 
    dUdy1 =    pos_signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/POS_STRAIGHT_VAR) * dFdy1 
    dUdx2 =    pos_signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/POS_STRAIGHT_VAR) * dFdx2 
    dUdy2 =    pos_signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/POS_STRAIGHT_VAR) * dFdy2 
    dUdx3 =    pos_signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/POS_STRAIGHT_VAR) * dFdx3 
    dUdy3 =    pos_signed_straigtgauss((x1, y1), (x2, y2), (x3, y3)) * (FM/POS_STRAIGHT_VAR) * dFdy3 
    return ((dUdx1, dUdy1), (dUdx2, dUdy2), (dUdx3, dUdy3))
