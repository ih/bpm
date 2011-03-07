(library (python-fg-lib)
         (export fg->image)
         (import (except (rnrs) string-hash string-ci-hash)
                 (church external py-pickle))

         (define fg-dir "/home/ih/factor-graphics/")

         (define fg->image
           (py-pickle-function (string-append fg-dir "python/fg2image.py")))

         )
