(import (abstract)
        (church readable-scheme))

(define simple-cacti '(lambda ()
                        (lazy-list->all-list ((uniform-draw
                                               (list
                                                (lambda ()
                                                  (N (data (color 70) (size 1))
                                                     (N (data (color 37) (size 0.3))
                                                        (N (data (color 213) (size 0.3)))
                                                        (N (data (color 207) (size 0.3)))
                                                        (N (data (color 211) (size 0.3))))))
                                                (lambda ()
                                                  (N (data (color 43) (size 1))
                                                     (N (data (color 47) (size 0.1))
                                                        (N (data (color 33) (size 0.3))
                                                           (N (data (color 220) (size 0.3)))
                                                           (N (data (color 224) (size 0.3)))
                                                           (N (data (color 207) (size 0.3)))))))))))))

(define compressed (compressions simple-cacti))
(pretty-print compressed)
