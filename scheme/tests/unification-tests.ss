(import (rnrs)
        (church readable-scheme)
        (unification)
        (srfi :78)
        (xitomatl match)
        (sym))

;;;continued from abstract-tests.ss example of compressing '(+ (+ 2 2) (- 2 5))
(let* ([subexpr1 '(+ (+ 2 2) (- 2 5))]
       [subexpr2 '(+ 2 2)])
  (check (anti-unify subexpr1 subexpr2) => '((+ V1 V2) (V1 V2))))

(let* ([subexpr1 '(+ 2 2)]
       [subexpr2 '(+ 2 2)])
  (check (anti-unify subexpr1 subexpr2) => '((+ 2 2) ())))

(reset-symbol-indizes!)
(let* ([subexpr1 '(+ (+ 2 2) (- 2 5))]
       [subexpr2 '(- 2 2)])
  (check (anti-unify subexpr1 subexpr2) => '((V1 V2 V3) (V1 V2 V3))))

;;unify tests 
(check (unify '(+ (+ 2 2) (- 2 5)) '(+ V1 V2) '(V1 V2)) => '((V1 . (+ 2 2)) (V2 . (- 2 5))))
(check (unify '(- (+ 2 2) (- 2 5)) '(+ V1 V2) '(V1 V2)) => #f)
(check (unify '(+ 2 2) '(+ V1 V1) '(V1)) => '((V1 . 2)))

(check-report)



