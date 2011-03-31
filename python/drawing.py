from math import pi
from math import atan

from svgfig import *

from fglib import vec
from fglib.util_functional import *

def radial(fig, n):
    return Fig(*map(lambda i: Fig(fig, trans=rotate(360 / float(n) * i, 0, 0)), range(n)))

def perturbFig(fig, px, py):
    return Fig(fig, trans = lambda x, y: (x + px, y + py))

def rotateFigOrient(fig, (x, y)):
    xx, yy = vec.norm((x, y))
    return Fig(fig, trans=rotate(180.0 * atan(yy / xx), 0, 0))

def drawRect(x1, y1, x2, y2):
    return Fig(Rect(x1, y1, x2, y2))

FM = lambda f, xs: Fig(*map(f, xs))

# rows: list of row widths, relative
# cols: list of col heights, relative

def drawGridLines(xstart, ystart, width, height, rows, cols):
    rows_n = map(lambda x: -x, list(vec.scale(tuple(normalize(rows)) , height)))
    cols_n = list(vec.scale(tuple(normalize(cols)) , width))

    ys = scanl(lambda x, y: x + y, [0.0] + rows_n)
    xs = scanl(lambda x, y: x + y, [0.0] + cols_n)

    coords = map(lambda (y1, y2): map(lambda (x1, x2): ((x1, y1), (x2, y2)), zip(xs, xs[1:])), zip(ys, ys[1:]))
    return Fig(FM(lambda (y1, y2): FM(lambda (x1, x2): drawRect(x1, y1, x2, y2), zip(xs, xs[1:])), zip(ys, ys[1:])), trans=lambda x, y: (x + xstart, y + ystart)), coords

def drawElem(xx, yy, theta, size):
   t= Fig(
          Fig(Rect(0, 0, size, size), 
            #trans=lambda x, y: (x-xx, y-yy)),
            trans=rotate(theta*180/pi, 0, 0)),
            trans=lambda x, y: (x+xx, y+yy))
   return Fig(t, trans="x, 10-y")

def drawCircle(xx, yy, size, color = 'black'):
  return Fig(Ellipse(xx, yy, size, 0, size, fill = color))

def drawGrid(grid, cell_w, cell_h):
    xpos = map(lambda i: (i+1)*cell_w, range(len(grid[0])))
    ypos = map(lambda i: (i+1)*cell_h, range(len(grid)))
    print xpos
    print ypos
    grid_ypos = zip(grid, ypos)
    return Fig(*map(lambda (figrow, yoffset): Fig(*map(lambda (onefig, xoffset): Fig( onefig, trans = lambda x, y: (x+xoffset, y+yoffset)), zip(figrow, xpos))), grid_ypos))

#def scaleFig(s):
#    return lambda fig: Fig(fig, trans = lambda x, y: (x*s, y*s))

def scaleFig(fig, s):
    return Fig(fig, trans = lambda x, y: (x*s, y*s))

def distributeX(x1, y1, x2, y2, xs, figs, y_off, x_off):
    scaled = vec.scale(tuple(xs), (x2 - x1) / (xs[-1]))
    return FM(lambda (sx, f): Fig(f, trans = lambda x, y: (x + x1 + sx + x_off, y + y1 + y_off)) , zip(scaled, figs))

def drawGraph(ns, es, size=1.0, color='black', excluded=[]):

    lx, ly = zip(*(map(lambda n: n.getPos(), ns)))
    minx, maxx, miny, maxy = min(lx), max(lx), min(ly), max(ly)
    canvasW, canvasH = maxx-minx, maxy-miny
    unit = max(canvasW, canvasH)

    t = map(lambda n: drawCircle(n.getPos()[0], n.getPos()[1], n.tile_obj.radius, color), ns)

    list_pos = map(lambda ns: map(lambda n: n.getPos(), ns), es)

    t = t + [Poly(l_pos, mode = "lines") for l_pos in list_pos]

    return Fig(Fig(*t), trans=window(minx-10, minx+unit+10, unit+miny+10, miny-10))
