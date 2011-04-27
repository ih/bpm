(import (python-fg-lib)
        (church readable-scheme))

(define tree  '((data (100) (2))
                ((data (200) (.5)))
                ((data (20) (.5)))))

(define ots (list '(a (b (c (c)) (b)) (d (e))) '(a (b) (c) (d)) '(c (d (e (b (c (a))))))))

(draw-trees (pair "./test.png" (list tree)))