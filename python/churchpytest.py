import os, sys, pickle

if __name__ == "__main__":
    args=pickle.load(sys.stdin)
    x=len(args)
    pickle.dump(x,sys.stdout)
