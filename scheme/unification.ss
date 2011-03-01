(library (unification)
         (export anti-unify var-symbol unenumerate-tree set-policy!) 
         (import (rnrs)
                 (_srfi :1)
                 (church readable-scheme)
                 (church external math-env)
                 (mem)
                 (util)
                 (sym))
         (define etree->id first)

         (define etree->tree cdr) ;; non-recursive

         (define (unenumerate-tree t)
           (if (primitive? t)
               t
               (map unenumerate-tree (rest t))))


         
         (define (var-symbol) 'V)

         (define policy 'original)
         (define (set-policy! new-policy)
           (set! policy new-policy))
         
         (define anti-unify
           (mem (lambda (et1 et2 ignore-id-matches)
                  (begin

                    (define variables '())

                    (define (mismatch-policy! et1 et2)
                      (cond [(eq? policy 'original) (add-variable!)]
                            [(eq? policy 'noisy-number)
                             (if (and (number? et1) (number? et2))
                                 (if (close? et1 et2) (make-noisy-number et1 et2) (add-variable!))
                                 (add-variable!))]
                            [else (error "no such matching policy for anti-unification!")]))

                    (define (add-variable!)
                      (set! variables (pair (sym (var-symbol)) variables))
                      (first variables))
                    
                    (define (build-pattern et1 et2 ignore-id-matches)
                      (cond [(and (primitive? et1) (primitive? et2)) (if (eq? et1 et2) et1 (mismatch-policy! et1 et2))]
                            [(or (primitive? et1) (primitive? et2)) (mismatch-policy! et1 et2)]
                            [(and ignore-id-matches (eqv? (etree->id et1) (etree->id et2))) #f]
                            [(not (eqv? (length et1) (length et2))) (mismatch-policy! et1 et2)]
                            [else
                             (let ([unified-tree (map (lambda (t1 t2) (build-pattern t1 t2 ignore-id-matches))
                                                      (etree->tree et1)
                                                      (etree->tree et2))])
                               (if (any false? unified-tree)
                                   #f
                                   unified-tree))]))
                    (let ([db (pretty-print policy)]
                          [pattern (build-pattern et1 et2 ignore-id-matches)])
                      (list variables pattern))))))
         

         ;;noisy number related
         (define noisy-number-threshold 3)
         (define (close? a b)
           (< (abs (- b a)) noisy-number-threshold))
         (define variance 1)
         (define (make-noisy-number et1 et2)
           (let ([mean (/ (+ et1 et2) 2)])
             (sample-gaussian mean variance)))


         )