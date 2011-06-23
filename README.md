You need to have ikarus, bher, and [scheme-tools](https://github.com/stuhlmueller/scheme-tools) set up on your system. <code>[bpm-dir]</code> is the absolute path for the bayesian program merging directory e.g. <code>/home/ih/bpm/</code> (it is important to have the trailing '/'). <code>[bher dir]</code> is the absolute path for the bher directory, e.g., <code>/home/ih/bher-read-only/</code>. 

# Installation

1. Apply modifications to Bher:

    1. Change into the factor-graphics directory: <code>cd [bpm-dir]</code>

    2. Run <code>python configure.py "[bher-dir]" "[bpm-dir]"</code>


2. Adjust path variables: Add <code>PATH=$PATH:[bher dir]:.</code> and <code>IKARUS_LIBRARY_PATH=[bpm-dir]/scheme:[scheme-tools dir]:[bher dir]:.</code> to your .bashrc file.

# Testing

To see if everything works you can do the following

    cd [bpm-dir]/church/tests
    bher beam-learning-tests.church

Due to path issues, you currently have to run bher from the directory containing the church file being run if it uses eval.

