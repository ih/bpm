(import (rnrs)
        (church readable-scheme)
        (only (abstract) enumerate-tree)
        (unification-policies)
        (srfi :78)
        (xitomatl match)
        (sym))

;;;original unify tests
(define unify (get-unify original-unification-policy))

(check (unify '(node 25 3 'd) '(node 25 3 COLOR) '(COLOR)) => '((COLOR . 'd)))


;;;original anti-unify tests
(define anti-unify (get-anti-unify original-unification-policy))

(check (let ([none (reset-symbol-indizes!)])
           (anti-unify (enumerate-tree '(node 25 3 'd)) (enumerate-tree '(node 25 3 'a)) #t))
       =>
       (let ([none (reset-symbol-indizes!)]
             [var1 (sym (var-symbol))])
         `((,var1) (node 25 3 ',var1))))

;;;noisy-number anti-unify
;;(define anti-unify (get-anti-unify noisy-number-policy))
;;test match for non-numeric entries and displays part that is supposed to soft-match
(set! anti-unify (get-anti-unify noisy-number-policy))
;;(set! noisy-number-threshold 0)
(check (let* ([none (reset-symbol-indizes!)]
              [output (anti-unify (enumerate-tree '(node 25 3 'd)) (enumerate-tree '(node 24 100 'a)) #t)])
         (match output ((vars (x soft-match y z)) (begin (for-each display (list "soft-match value:" soft-match "\n"))
                                                            (list vars x y z)))))
       =>
       (let ([none (reset-symbol-indizes!)]
             [var1 (sym (var-symbol))]
             [var2 (sym (var-symbol))])
         `((,var2 ,var1) node  ,var1 ',var2)))

;;test for numeric entries are from the appropriate gaussian
;; (check (let ([gaussian (mean 25 24)]
;;              [output (anti-unify (enumerate-tree '(node 25 3 'd)) (enumerate-tree '(node 24 100 'a)) #t)]
;;              [pattern (second output)]
;;              [soft-match (match pattern (('node x _ _) x))])
;;          (drawn-from soft-match gaussian))
;;        =>
;;        #t)

;;;noisy-number unify
(set! unify (get-unify noisy-number-policy))
;;assumes N1 has a certain mean and variance
(check (unify '(node 25 3 'd) '(node 24 3 COLOR) '(COLOR)) => '((COLOR . 'd)))
(check (unify '(node 0 3 'd) '(node 24 3 COLOR) '(COLOR)) => #f)


(check-report)



