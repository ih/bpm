import os, sys, pickle, random
import test

from fg_interface import *

if __name__ == "__main__":
    args=pickle.load(sys.stdin)

    debug = mkDebugChannel('image2fg_debug')

    filename = args
    print >>debug, filename
    output = fg_parse(filename, exclude=['pos'])
    print >>debug, output
    pickle.dump(output, sys.stdout)
