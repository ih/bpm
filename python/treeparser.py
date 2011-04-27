class parseable_string(str):
    def __new__(cls, value, *args, **keywargs):
        return str.__new__(cls, value)
    def __init__(self, *args, **kwargs):
        self.pos = 0
        return str.__init__(self, *args, **kwargs)
    def last(self):
        if self.pos > 0:
            self.pos -= 1
        return self.cur()
    def next(self):
        if self.pos < len(self):
            self.pos += 1
        return self.cur()
    def cur(self):
        if self.pos < len(self):
            return self[self.pos]
        else:
            return None

def parse(t):
    if t.cur() == "(":
        out = []
        while t.next() != ")":
            cur_parse = parse(t)
            if cur_parse:
                out.append(cur_parse)
        return tuple(out)
    elif t.cur() == " ":
        return None
    else:
        cur = t.cur()
        next = "$"
        while next and next not in " ()":
            if next != "$":
                cur += next
            next = t.next()
        t.last()
        return cur

def treedepth(tree):
    node, subtrees = tree[0], tree[1:]
    if subtrees:
        return 1 + max([treedepth(subtree) for subtree in subtrees])
    else:
        return 1

def treeparser(s):
    return parse(parseable_string(s))

if __name__ == "__main__":
    print treeparser("(a-x (b (c)) (b (c) (d (e)) (e (b) (c))))")