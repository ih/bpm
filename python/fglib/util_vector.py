from math import *

def interp(x, y, t):
    return add(scale(x, t), scale(y, 1 - t))

def eq(x, y):
	if type(x) == float:
		return True if abs(x - y) < 1e-10 else False
	else:
		return reduce(lambda x, y: x and y, map(lambda (x, y): eq(x, y), zip(x, y)))

def colinear(coord1, coord2):
	if eq(abs(dot(norm(coord1), norm(coord2))), 1.0):
		return True
	else:
		return False

def angle(v1, v2):
    d = dot(v1, v2)
    if d == 0:
        return pi / 2.0
    f = length(v1) * length(v2)
    if f == 0:
        return 0.0
    c = d / f

    return acos(c)

def polar((x, y), ref=(0,0)):

    x, y = (x - ref[0], y - ref[1])
    
    if y == 0:
        return (abs(x), 0) if x >= 0 else (abs(x), pi)

    if x == 0:
        return (abs(y), pi / 2) if y >= 0 else (abs(y), 3 * pi / 2)

    s = sin(y)
    c = cos(x)

    r = length((x, y))

    t = atan(y / x)

    if t < 0:
        t = t + 2 * pi

    if x > 0:
        return (r, t)
    elif x < 0 and y >= 0:
        return (r, t + pi)
    elif x < 0 and y < 0:
        return (r, t - pi)
    else:
        raise


def dot(coord1, coord2):
  if type(coord1) == tuple:
    return sum(map(lambda (c1, c2): dot(c1, c2), zip(coord1, coord2)))
  else:
    return coord1*coord2

def length(coord):
  if type(coord) == tuple:
    return sqrt(sum(map(lambda x: x**2, coord)))
  else:
    return abs(coord)

def norm(coord):
  L = length(coord) 
  if L == 0:
      return coord
  if type(coord) == tuple:
    return tuple(map(lambda x: x/L, coord))
  else:
    return 1.0

def dist(x1, x2):
  return length(sub(x2, x1))

def cabs(coord):
  if type(coord) == tuple:
    return tuple(map(lambda x: abs(x), coord))
  else:
    return abs(coord)

def neg(coord):
  if type(coord) == tuple:
    return tuple(map(lambda x: -x, coord))
  else:
    return -coord

def scale(coord, s):
  if type(coord) == tuple:
    return tuple(map(lambda x: s*x, coord))
  else:
    return s*coord

def sub(coord1, coord2):
  return add(coord1, neg(coord2))

def add(coord1, coord2):
  if type(coord1) == tuple:
    return tuple(map(lambda (c1, c2): c1+c2, zip(coord1, coord2)))
  else:
    return coord1+coord2

def cross((x1, y1, z1), (x2, y2, z2)):
  return (y1*z2 - y2*z1, x1*z2 - x2*z1, x1*y2 - x2*y1)

interp_range = lambda min, max, n: map(lambda i: min + (float(i) / (n - 1)) * float(max - min), range(n))

