(import (inverse-inline)
        (sym)
        (program)
        (srfi :78))

;;;possible-abstractions tests
;;basic test
(let* ([none (reset-symbol-indizes!)]
       [expr '(+ (+ 2 2) (- 2 5))]
       [abstraction1 (make-named-abstraction 'F1 '(+ V1 V2) '(V1 V2))]
       [abstraction2 (make-named-abstraction 'F1 '(V1 V2 V3) '(V1 V2 V3))]
       [abstraction3 (make-named-abstraction 'F1 '(V1 2 V2) '(V1 V2))])
  (check (possible-abstractions expr) => (list abstraction1 abstraction2 abstraction3)))
;;expr has free variables

(let* ([none (reset-symbol-indizes!)]
       [abstraction1 (make-named-abstraction 'F4 '(+ V2 V3) '(V2 V3))])
  (check (possible-abstractions '(+ (+ V1 V1) (+ V1 F3))) => (list abstraction1)))

;;non match
(let* ([none (reset-symbol-indizes!)]
       [abstraction1 (make-named-abstraction 'F1 '(+ V2 V3) '(V2 V3))])
  (check (possible-abstractions '(+ (+ V1 3) (- 2))) => (list abstraction1)))

;;;replace-matches test  !remember variable order has an effect on the application of functions
(let* ([abstraction (make-named-abstraction 'F1 '(+ V2 V3) '(V2 V3))])
  (check (replace-matches '(+ (+ 2 2) (- 2 5)) abstraction) => '(F1 (F1 2 2) (- 2 5))))
;;;compressions tests
(let* ([program (make-program '() '(+ (+ 2 2) (- 2 5)))]
       [abstraction1 (make-named-abstraction 'F1 '(+ V1 V2) '(V1 V2))]
       [abstraction2 (make-named-abstraction 'F1 '(V1 V2 V3) '(V1 V2 V3))]
       [abstraction3 (make-named-abstraction 'F1 '(V1 2 V2) '(V1 V2))]
       [compressed1 (make-program (list abstraction1) '(F1 (F1 2 2) (- 2 5)))]
       [compressed3 (make-program (list abstraction3) '(+ (F1 + 2) (F1 - 5)))]
       [compressed2 (make-program (list abstraction2) '(F1 + (F1 + 2 2) (F1 - 2 5)))])
  (check (compressions program #t) => (list compressed1 compressed2 compressed3)))

(let ([program (make-program '() '(lambda ()
                                    ((uniform-draw (list
                                                    (lambda () (node (data (color (gaussian -36.0 . (25))) (size 0.3)) (node (data (color (gaussian 102.0 . (25))) (size 0.3))) (node (data (color (gaussian 1e2 . (25))) (size 0.3))) (node (data (color (gaussian 39.0 . (25))) (size 0.3)))))
                                                    (lambda () (node (data (color (gaussian 1.0 . (25))) (size 0.3)) (node (data (color (gaussian 7e1 . (25))) (size 0.3))) (node (data (color (gaussian 138.0 . (25))) (size 0.3))) (node (data (color (gaussian 75.0 . (25))) (size 0.3)))))
                                                    (lambda () (node (data (color (gaussian -42.0 . (25))) (size 0.3)) (node (data (color (gaussian 76.0 . (25))) (size 0.3))) (node (data (color (gaussian 126.0 . (25))) (size 0.3))) (node (data (color (gaussian 93.0 . (25))) (size 0.3)))))
                                                    (lambda () (node (data (color (gaussian -7.0 . (25))) (size 0.3)) (node (data (color (gaussian 240.0 . (25))) (size 0.3))) (node (data (color (gaussian 229.0 . (25))) (size 0.3))) (node (data (color (gaussian 186.0 . (25))) (size 0.3)))))
                                                    (lambda () (node (data (color (gaussian 12.0 . (25))) (size 0.3)) (node (data (color (gaussian 207.0 . (25))) (size 0.3))) (node (data (color (gaussian 215.0 . (25))) (size 0.3))) (node (data (color (gaussian 265.0 . (25))) (size 0.3)))))
                                                    (lambda () (node (data (color (gaussian -19.0 . (25))) (size 0.3)) (node (data (color (gaussian 105.0 . (25))) (size 0.3))) (node (data (color (gaussian 74.0 . (25))) (size 0.3))) (node (data (color (gaussian 110.0 . (25))) (size 0.3)))))
                                                    (lambda () (node (data (color (gaussian -19.0 . (25))) (size 0.3)) (node (data (color (gaussian 105.0 . (25))) (size 0.3))) (node (data (color (gaussian 74.0 . (25))) (size 0.3))) (node (data (color (gaussian 110.0 . (25))) (size 0.3)))))
                                                    (lambda () (node (data (color (gaussian -19.0 . (25))) (size 0.3)) (node (data (color (gaussian 105.0 . (25))) (size 0.3))) (node (data (color (gaussian 74.0 . (25))) (size 0.3))) (node (data (color (gaussian 110.0 . (25))) (size 0.3)))))
                                                    (lambda () (node (data (color (gaussian -19.0 . (25))) (size 0.3)) (node (data (color (gaussian 105.0 . (25))) (size 0.3))) (node (data (color (gaussian 74.0 . (25))) (size 0.3))) (node (data (color (gaussian 110.0 . (25))) (size 0.3)))))
                                                    )))))])
  (pretty-print (length (compressions program #t))))
(check-report)
(exit)