import Image as img
from PIL.ImageOps import invert

import ImageFilter

import pymorph as morph
import numpy as np

import sys
import os

if __name__ == '__main__':

    dirname = sys.argv[1]
    if not os.path.exists(dirname + '/output'):
        os.mkdir(dirname + '/output')

    def run_one(fname, outname):
        N = 1

        im = img.open(fname)
        #im = im.filter(ImageFilter.BLUR)
        im = im.resize((600, 600), img.ANTIALIAS)
        im = im.convert('L')
        im = invert(im)


        x = np.asarray(im)
        y = x 

        size = 3

        for i in range(N):
            y = morph.dilate(y, morph.sedisk(size))
            y = morph.close(y, morph.sedisk(size))

        jm = img.fromarray(y)
        jm = invert(jm)

        jm = jm.resize((400, 400), img.ANTIALIAS)

        jm.save(outname)

    for file in os.listdir(dirname):
        if file.endswith('.png'):
            run_one(dirname + '/' + file, dirname + '/output/' + file)

