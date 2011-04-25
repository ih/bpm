(library (python-fg-lib)
         (export fg->image fg->img-score)
         (import (except (rnrs) string-hash string-ci-hash)
                 (church external py-pickle))

         (define fg-dir "/Users/yitingy/Graphics/factor-graphics/")

         (define fg->image
           (py-pickle-function (string-append fg-dir "python/fg2image.py")))

         (define fg->img-score
           (py-pickle-function (string-append fg-dir "python/scoreImFg.py")))

         )
