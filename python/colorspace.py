#!/usr/bin/python
from colormath.color_objects import *
from math import sin, cos, pi

def rgb_to_hex(rgb):
    return '#%02x%02x%02x' % rgb

def get_colors(num_colors=7, lightness=80, saturation=60, shift=0):
    l = lightness
    r = saturation
    center = (0, 0)
    colors = []
    step_size = 360/(num_colors+1)
    angles = range(0, 360, step_size)[:-1]
    angles = [angle+shift*step_size for angle in angles]
    for angle in angles:
        y = r*sin((angle/360.0)*2*pi)
        x = r*cos((angle/360.0)*2*pi)
        lab = LabColor(l, x, y)
        rgb = lab.convert_to("rgb", target_rgb='sRGB')
        rgb_tuple = (rgb.rgb_r, rgb.rgb_g, rgb.rgb_b)
        colors.append(rgb_tuple)
        # print('(%d, %d, %d)' % rgb_tuple)
        # print "<div style='width: 50px; height: 50px; background-color: %s'></div><br>" % rgb_to_hex(rgb_tuple)
    return colors

def get_hex_colors(*args, **kwargs):
    return [rgb_to_hex(c) for c in get_colors(*args, **kwargs)]

if __name__ == '__main__':
    get_colors()
