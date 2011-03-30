# Taken from http://code.activestate.com/recipes/414283-frozen-dictionaries/

## {{{ http://code.activestate.com/recipes/414283/ (r1)

class hashabledict(dict):
    def __hash__(self):
        return hash(tuple(sorted(self.items())))

class frozendict(dict):
    def _blocked_attribute(obj):
        raise AttributeError, "A frozendict cannot be modified."
    _blocked_attribute = property(_blocked_attribute)

    __delitem__ = __setitem__ = clear = _blocked_attribute
    pop = popitem = setdefault = update = _blocked_attribute

    def __new__(cls, *args):
        new = dict.__new__(cls)
        dict.__init__(new, *args)
        return new

    def __init__(self, *args):
        pass

    def __hash__(self):
        try:
            return self._cached_hash
        except AttributeError:
            h = self._cached_hash = hash(tuple(sorted(self.items())))
            return h

    def __repr__(self):
        return "frozendict(%s)" % dict.__repr__(self)
## end of http://code.activestate.com/recipes/414283/ }}}

