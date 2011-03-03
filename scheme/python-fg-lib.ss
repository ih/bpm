(library (python-fg-lib)
         (export fg->image)
         (import (except (rnrs) string-hash string-ci-hash)
                 (church external py-pickle))

         (define fg->image
           (py-pickle-function "../python/fg2image.py"))

         )
