(library (churchpytest)
         (export len)
         (import (except (rnrs) string-hash string-ci-hash)
                 (church external py-pickle))
;;;assumes bher is being called from the bher root directory
         (define len
           (py-pickle-function "../python/churchpytest.py")))

         
