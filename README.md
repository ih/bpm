You need to have ikarus, bher, and [scheme-tools](https://github.com/stuhlmueller/scheme-tools) set up on your system. <code>[fg-dir]</code> is the absolute path for the factor-graphics directory e.g. <code>/home/ih/factor-graphics/</code> (it is important to have the trailing '/'). <code>[bher dir]</code> is the absolute path for the bher directory, e.g., <code>/home/ih/bher-read-only/</code>. 

# Installation

1. Apply modifications to Bher:

    1. Change into the factor-graphics directory: <code>cd [fg-dir]</code>

    2. Run <code>python configure.py "[bher-dir]" "[fg-dir]"</code>


2. Adjust path variables: Add <code>PATH=$PATH:[bher dir]:.</code> and <code>IKARUS_LIBRARY_PATH=[fg-dir]/scheme:[scheme-tools dir]:[bher dir]:.</code> to your .bashrc file.

# Testing

To see if everything works you can do the following

    cd [fg-dir]/church/tests
    bher factor-graph-tests.church
    bher beam-learning-tests.church

Due to path issues, you currently have to run bher from the directory containing the church file being run if it uses eval.

