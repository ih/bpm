(library (churchpytest)
         (export len)
         (import (except (rnrs) string-hash string-ci-hash)
                 (church external py-pickle))

         (define len
           (py-pickle-function "./churchpytest.py")))

         )
