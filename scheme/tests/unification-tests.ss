(import (rnrs)
        (church readable-scheme)
        (unification)
        (srfi :78)
        (only (abstract) enumerate-tree)
        (xitomatl match)
        (sym))

;;;original policy tests
;;anti-unify tests
(set-policy! 'original)
(check (let ([none (reset-symbol-indizes!)])
           (anti-unify (enumerate-tree '(node 25 3 'd)) (enumerate-tree '(node 25 3 'a)) #t))
       =>
       (let ([none (reset-symbol-indizes!)]
             [var1 (sym (var-symbol))])
         `((,var1) (node 25 3 ',var1))))

;;unify tests
(check (unify '(node 25 3 'd) '(node 25 3 COLOR) '(COLOR)) => '((COLOR . 'd)))

;;;noisy-number anti-unify
(set-policy! 'noisy-number)
;;test match for non-numeric entries and displays part that is supposed to soft-match
(check (let* ([none (reset-symbol-indizes!)]
              [output (anti-unify (enumerate-tree '(node 25 3 'd)) (enumerate-tree '(node 24 100 'a)) #t)])
         (match output ((vars (x soft-match y z)) (begin (for-each display (list "soft-match value:" soft-match "\n"))
                                                            (list vars x y z)))))
       =>
       (let ([none (reset-symbol-indizes!)]
             [var1 (sym (var-symbol))]
             [var2 (sym (var-symbol))])
         `((,var2 ,var1) node  ,var1 ',var2)))

;;;noisy-number unify
;;assumes N1 has a certain mean and variance
(check (unify '(node 25 3 'd) '(node 24 3 COLOR) '(COLOR)) => '((COLOR . 'd)))
(check (unify '(node 0 3 'd) '(node 24 3 COLOR) '(COLOR)) => #f)

;;;no-var anti-unify
(set-policy! 'no-var)

(check (anti-unify (enumerate-tree '(node 25 3 'd)) (enumerate-tree '(node 25 3 'a)) #t)
       =>
       '(() (node 25 3 'd)))

(check (anti-unify (enumerate-tree '(node 25 3 'd (node 11 95 'c))) (enumerate-tree '(node 25 3 'a)) #t)
       =>
       '(() (node 25 3 'd (node 11 95 'c))))


(check (unify '(node 25 3 'd) '(node 25 3 COLOR) '(COLOR)) => '((COLOR . 'd)))

;;;floating point test
(set-policy! 'original)
(check (let ([none (reset-symbol-indizes!)])
           (anti-unify (enumerate-tree '(n 25.0)) (enumerate-tree '(n 25.0)) #t))
       =>
       (let ([none (reset-symbol-indizes!)]
             [var1 (sym (var-symbol))])
         '(() (n 25.0))))





(check-report)



