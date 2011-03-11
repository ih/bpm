import os, sys, pickle, random

if __name__ == "__main__":
    args=pickle.load(sys.stdin)
    output=random.random()
    pickle.dump(output,sys.stdout)
