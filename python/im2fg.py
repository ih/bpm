import os, sys, pickle, random
import test

from fg_interface import *

fsts = lambda xs: map(lambda (x, y): x, xs)

class Node(object):
    def __init__(self, name):
        self.name = name
        self.children = []
    def __repr__(self):
        return 'Node'

def parse_img_line(line):
    split = filter(lambda s: s != '', line.strip().split(' '))
    return split

if __name__ == "__main__":
    #args=pickle.load(sys.stdin)

    filename = sys.argv[1]

    print map(parse_img_line, open(filename).readlines())
    sys.exit()

    raw1 = [filter(lambda s: s != '', s.strip('\n').split(' ')) for s in open(filename).readlines() if s != '']

    print raw1

    raw2 = map(lambda xs: (Node(xs[0]), map(int, xs[1:])), raw1)

    print raw2

    for (n, cs) in raw2:
        n.children = map(lambda i: raw2[i - 1][0], cs)

    raw3 = fsts(raw2) 

    print raw3

    mklist = lambda *a: a

    def mk_sexpr(node):
        return mklist(node, *map(mk_sexpr, node.children))

    print mk_sexpr(raw3[0])


    pickle.dump(filename,sys.stdout)

