features = {
		'f2h0' : lambda x, y: (x, y) == (0,0),
		'f2h1' : lambda x, y: (x, y) == (0,1),
		'f2h2' : lambda x, y: (x, y) == (1,0),
		'f2h3' : lambda x, y: (x, y) == (1,1),
		'eq' : lambda x, y: x == y,
		'f1s0' : lambda x: x == 0,
		'f1s1' : lambda x: x == 1
}

def makef_single(domain):
    #return dict(map(lambda tid: ('f1s_%d'%tid, lambda x: x.tid == tid), domain))
    return dict(map(lambda tile: ('f1s_%d'%tile.tid, lambda x: x.tid == tile.tid), domain))

def makef_pairwise(domain):
    pair_entries = [(i, j) for i in domain for j in domain]
    #return dict(map(lambda (xid, yid): ('f2pw_%d_%d'% (xid, yid), lambda x, y: (x.tid, y.tid) == (xid, yid)), pair_entries))
    return dict(map(lambda (xt, yt): ('f2pw_%d_%d'% (xt.tid, yt.tid), lambda x, y: (x.tid, y.tid) == (xt.tid, yt.tid)), pair_entries))

key_map = {
        'B#' : 0,
        'C' : 0,
        'C#' : 1,
        'Db' : 1,
        'D' : 2,
        'D#' : 3,
        'Eb': 3,
        'E' : 4,
        'Fb' : 4,
        'E#' : 5,
        'F' : 5,
        'F#' : 6,
        'Gb' : 6,
        'G' : 7,
        'G#' : 8,
        'Ab' : 8,
        'A' : 9,
        'A#' : 10,
        'Bb' : 10,
        'B' : 11,
        }

def lookup(name):
    if not features.has_key(name):
        if name.startswith('f2pw'):
            ft, xid, yid = name.split('_')
            xid, yid = int(xid), int(yid)
            return lambda x, y: (x.tid, y.tid) == (xid, yid)
        elif name.startswith('f1s'):
            ft, xid = name.split('_')
            xid = int(xid)
            return lambda x : x.tid == xid
        elif name.startswith('m'):
            '''m_u_C_2'''
            ft, direction, anchor, hstep = name.split('_')
            anchor = key_map[anchor]
            return lambda x, y: (x.tid, y.tid) == (anchor, ((anchor + int(hstep)) if direction == 'u' else (anchor - int(hstep))) % 12)
        else:
            raise
    else:
        return features[name]


