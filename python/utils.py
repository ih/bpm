# Create a class with the corresponding datafields that is a subclass of base.

def Term(name, single_names=[], list_name=None, base=object):
    if list_name != None:
        def constructor(self, *args):
            if len(args) >= 1 and not type(args[0]) == type(self):
                self.__dict__[list_name] = []
                for i in range(len(single_names)):
                    self.__dict__[single_names[i]] = args[i]
                for i in range(len(single_names), len(args)):
                    self.__dict__[list_name] += [args[i]]
            elif len(args) == 1:
                data = args[0]
                attr_dict = data.__dict__
                for (k, v) in attr_dict.items():
                    setattr(self, k, v)
    else:
        def constructor(self, *args):
            if len(args) >=1 and not type(args[0]) == type(self):
                for i in range(len(single_names)):
                    self.__dict__[single_names[i]] = args[i]
            elif len(args) == 1:
                data = args[0]
                attr_dict = data.__dict__
                for (k, v) in attr_dict.items():
                    setattr(self, k, v)

    return type(name, (base,), {'__init__' : constructor})


# Derive a class RT from another class T where:

# a. objects of RT have an object of T as an assignment (tile_obj)

# b. RT's datafields actually reference the assignment (tile_obj)'s datafields

# c. Use the same constructor for R[T] as with T

def RV(base=object):
    name = 'R[%s]' % (base.__name__)
    def constructor(self, *args):
        self.tile_obj = base(*args)
    def ga(self, item):
        try:
            return self.tile_obj.__dict__[item]
        except KeyError:
            raise AttributeError
    def setTile(self, value):
        self.tile_obj = value
    def setField(self, name, val):
        self.tile_obj.__dict__[name] = val
    def getField(self, name):
        return self.tile_obj.__dict__[name]
    return type(name, (base,), 
            {
                '__init__' : constructor,
                '__getattr__' : ga,
                'setTile' : setTile,
                'setField' : setField,
                'getField' : getField
                })

# TODO:

# a. Dynamically modify fields as with Elt
# b. Provide printing functions
# c. Compatibility with existing factor functions?
