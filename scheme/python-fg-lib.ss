(library (python-fg-lib)
         (export draw-trees system)
         (import (except (rnrs) string-hash string-ci-hash)
                 (scheme-tools py-pickle)
                 (util)
                 ;(church external py-pickle)
                 )
         (define py-dir "/home/ih/bpm/python/")
         (define system
           (py-pickle-script (string-append py-dir "system.py")))
         (define draw-trees
           (py-pickle-script (string-append py-dir "treedraw.py"))))
