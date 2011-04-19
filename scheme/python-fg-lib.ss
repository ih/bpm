(library (python-fg-lib)
         (export fg->image fg->img-score) 
         (import (except (rnrs) string-hash string-ci-hash)
                 (church external py-pickle))

         (define fg-dir "/home/ih/factor-graphics/")

         (define fg->image
           (py-pickle-function (string-append fg-dir "python/fg2image.py")))

         (define fg->img-score
           (py-pickle-function (string-append fg-dir "python/scoreImFg.py")))

         ;;not exporting until issues w/ py-pickle have been worked out, see a temporary definition in factor-graph.scm
         (define image->factor-graph
           (py-pickle-function (string-append fg-dir "python/im2fg.py"))))

