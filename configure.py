import sys, fileinput

#code from http://stackoverflow.com/questions/39086/search-and-replace-a-line-in-a-file-in-python
def replaceAll(file,searchExp,replaceExp):
    for line in fileinput.input(file, inplace=1):
        if searchExp in line:
                line = line.replace(searchExp,replaceExp)
        sys.stdout.write(line)

def modifyBher():
    #this is needed b/c include-paths in bher will become absolute paths
    replaceAll(bherDir+"bher", "cd '%(bher_path)s' && ", "")

def modifyDesugar():
    replaceAll(bherDir+"church/desugar.ss", '"./church/"', '"'+bherDir+'church/" "'+fgDir+'church/"')

def modifyHeader():
    replaceAll(bherDir+"church/header.ss", "*lazy* false", "*lazy* true")
    replaceAll(bherDir+"church/header.ss", "'(rnrs)", "'(rnrs) '(abstract) '(program) '(factor-graph) '(lazy) '(util) '(sym) '(python-fg-lib)")

def modifyCompiler():
    replaceAll(bherDir+"church/compiler.ss", "*lazy* false", "*lazy* true")
    replaceAll(bherDir+"church/compiler.ss", '(load "mcmc-preamble.church")', '(load "mcmc-preamble.church") (load "factor-graph.church") (load "beam-learning.church")')

def modifyHeaderIkarus():
    replaceAll(bherDir+"scheme-compilers/header-ikarus.sc", "(rnrs eval)", "(rnrs eval) (lazy) (abstract) (program) (factor-graph) (util) (sym) (testing) (python-fg-lib)")    

def modifyPythonFgLib():
    replaceAll(fgDir+"scheme/python-fg-lib.ss", "/home/ih/factor-graphics/", fgDir)
    
if __name__ == "__main__":
    bherDir = sys.argv[1]
    fgDir = sys.argv[2]

    modifyBher()
    modifyDesugar()
    modifyHeader()
    modifyCompiler()
    modifyHeaderIkarus()
    modifyPythonFgLib()



    
