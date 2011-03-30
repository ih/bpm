from util_dist import rndSelect
from pprint import pformat

class Element(object):
  def __init__(self, name): 
    self.name = name 
  def __repr__(self):
    return "%s pos: %s" % (self.name, self.pos)
  def setPos(self, pos):
    self.pos = pos
  def getPos(self):
    return self.pos
  def setTheta(self, pos):
    self.theta = theta
  def getTheta(self):
    return self.theta

class Tile(object):
    def __init__(self, data):
        if type(data) == dict:
            for (k, v) in data.items():
                setattr(self, k, v)
        elif type(data) == Tile:
            attr_dict = data.__dict__
            for (k, v) in attr_dict.items():
                setattr(self, k, v)
    def __repr__(self):
        return "Tile\n%s" % pformat(self.__dict__)
    def makeNewField(self, k, v):
        setattr(self, k, v)
        return self
    def copyWithUpdate(self, k, v):
        res = Tile(self)
        return res.updateField(k, v)
    def updateField(self, k, v):
        if not hasattr(self, k):
            setattr(self, k, v)
        else:
            self.__dict__[k] = v
        return self
    def getField(self, k):
        return self.__dict__[k]
    #def __eq__(self, other):
     #   print type(other)
     #   res = True
     #   for (k, v) in self.__dict__.items():
     #       res = res and v == other.__dict__[k]
     #   return res

class Elt(object):
    def __init__(self, name):
        self.name = name
        self.tid = 'N/A'
    def __repr__(self):
        return "%s" % self.name
        #return "%s : %s" % (self.name, self.tile_obj)
    def setID(self, tid):
        self.tid = int(tid)
    def setTile(self, tile_obj):
        self.tile_obj = tile_obj
    def setTileAttr(self, tile_attr_dict):
        self.tile_obj = Tile(tile_attr_dict)
        return self
    def makeNewField(self, k, v):
        self.tile_obj.makeNewField(k, v)
        return self
    def setPos(self, pos):
        return self.tile_obj.updateField("pos", pos) 
    def getPos(self):
        return self.tile_obj.pos
    def getField(self, k):
        return self.tile_obj.getField(k)
    def setField(self, k, v):
        self.tile_obj.updateField(k, v)
        return self

def projectAsnByField(asn, name):
    return dict(map(lambda (k, v): (k, v.__dict__[name]), asn.items()))

def updateAsnByField(dst_asn, name, src_asn):
    return dict(map(lambda (k, v): (k, v.copyWithUpdate(name, src_asn[k])), dst_asn.items()))

def constructAssignments(ns):
    return dict(map(lambda n: (n, n.tile_obj), ns))

def updateNodes(asn):
    map(lambda (n, v): n.setTile(v), asn.items())

def randomizeAsn(ns, name, fx):
    map(lambda n: n.setField(name, fx()), ns)
