(import (rnrs)
        (church readable-scheme)
        (only (abstract) enumerate-tree)
        (unification-policies)
        (srfi :78)
        (sym))

;;;unify tests
(define unify (get-unify original-unification-policy))

(check (unify '(node 25 3 'd) '(node 25 3 COLOR) '(COLOR)) => '((COLOR . 'd)))


;;;anti-unify tests
(define anti-unify (get-anti-unify original-unification-policy))

(check (let ([none (reset-symbol-indizes!)])
           (anti-unify (enumerate-tree '(node 25 3 'd)) (enumerate-tree '(node 25 3 'a)) #t))
       =>
       (let ([none (reset-symbol-indizes!)]
             [var1 (sym (var-symbol))])
         `((,var1) (node 25 3 ',var1))))

(check-report)



