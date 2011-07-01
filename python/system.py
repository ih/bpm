import os, sys, pickle

if __name__ == "__main__":
    print 'system running?'
    os.system(pickle.load(sys.stdin))
