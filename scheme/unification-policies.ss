(library (unification-policies)
         (export original-unification-policy get-anti-unify get-unify var-symbol noisy-number-policy noisy-number-threshold)
         (import (rnrs)
                 (_srfi :1)
                 (church readable-scheme)
                 (church external math-env)
                 (mem)
                 (util)
                 (sym))

         (define get-anti-unify first)
         (define get-unify rest)
         (define build-unification-policy pair)


         (define (var-symbol) 'V)

         ;; data structures & associated functions
         (define etree->id first)
         (define etree->tree cdr) ;; non-recursive

         ;; returns #f if trees cannot be unified,
         ;; otherwise tree with variable in places where they differ
         ;; returns for (the enumerated version of) trees
         ;; (z (a (x (i (j)) (h (m)))) (c) (d (f) (i)))
         ;; (z (a (x (k (l)) (h (m)))) (c) (d (h (f)) (i)))
         ;; this:
         ;; (z (a (x (* (*)) (h (m)))) (c) (d * (i)))
         ;; (f (f (f c)))
         ;; (f (f c))
         ;; returns:
         ;; (if (flip) var2 (var1 (rec
         (define original-anti-unify
           (mem (lambda (et1 et2 ignore-id-matches)
                  (begin 
                    (define variables '())
                    (define (add-variable!)
                      (set! variables (pair (sym (var-symbol)) variables))
                      (first variables))
                    (define (build-pattern et1 et2 ignore-id-matches)
                      (cond [(and (primitive? et1) (primitive? et2)) (if (eq? et1 et2) et1 (add-variable!))]
                            [(or (primitive? et1) (primitive? et2)) (add-variable!)]
                            [(and ignore-id-matches (eqv? (etree->id et1) (etree->id et2))) #f]
                            [(not (eqv? (length et1) (length et2))) (add-variable!)]
                            [else
                             (let ([unified-tree (map (lambda (t1 t2) (build-pattern t1 t2 ignore-id-matches))
                                                      (etree->tree et1)
                                                      (etree->tree et2))])
                               (if (any false? unified-tree)
                                   #f
                                   unified-tree))]))
                    (let ([pattern (build-pattern et1 et2 ignore-id-matches)])
                      (list variables pattern))))))

         ;; takes a sexpr (s), a sexpr with variables (sv) and a proc name, e.g.
         ;; s = (foo (foo a b c) b c)
         ;; sv = (foo V b c)
         ;; name = P
         ;; first pass: (P (foo a b c))
         ;; second (operand) pass: (P (P a))
         ;; returns #f if abstraction cannot be applied, otherwise variable assignments
         ;; ! assumes that each variable occurs only once in sv [2]
         (define original-unify
           (mem (lambda (s sv vars)
                  (begin
                    (define (variable? obj)
                      (member obj vars))
                    (cond [(variable? sv) (list (pair sv s))]
                          [(and (primitive? s) (primitive? sv)) (if (eq? s sv) '() #f)]
                          [(or (primitive? s) (primitive? sv)) #f]
                          [(not (eqv? (length s) (length sv))) #f]
                          [else
                           (let ([assignments (map (lambda (si sj) (original-unify si sj vars)) s sv)])
                             (if (any false? assignments)
                                 #f
                                 (check/remove-repeated (apply append assignments))))])))))

         ;;returns false if any repeated variable in pattern doesn't have the same value or any of the assignments are false, returns a set of unique variable assignments
         (define (check/remove-repeated unified-vars)
           (let* ([repeated-vars (filter more-than-one (map (curry all-assoc unified-vars) (map first unified-vars)))])
             (if (and (all (map all-equal? repeated-vars)) (not (any false? unified-vars)))
                 (delete-duplicates unified-vars)
                 #f)))

         (define (more-than-one lst)
           (> (length lst) 1))
         
         (define original-unification-policy (build-unification-policy original-anti-unify original-unify))


         ;;noisy-number anti-unify
         (define noisy-number-anti-unify
           (mem (lambda (et1 et2 ignore-id-matches)
                  (begin 
                    (define variables '())
                    (define (add-variable!)
                      (set! variables (pair (sym (var-symbol)) variables))
                      (first variables))
                    (define (build-pattern et1 et2 ignore-id-matches)
                      (cond [(and (number? et1) (number? et2)) (if (close? et1 et2) (make-noisy-number et1 et2) (add-variable!))]
                            [(and (primitive? et1) (primitive? et2)) (if (eq? et1 et2) et1 (add-variable!))]
                            [(or (primitive? et1) (primitive? et2)) (add-variable!)]
                            [(and ignore-id-matches (eqv? (etree->id et1) (etree->id et2))) #f]
                            [(not (eqv? (length et1) (length et2))) (add-variable!)]
                            [else
                             (let ([unified-tree (map (lambda (t1 t2) (build-pattern t1 t2 ignore-id-matches))
                                                      (etree->tree et1)
                                                      (etree->tree et2))])
                               (if (any false? unified-tree)
                                   #f
                                   unified-tree))]))
                    (let ([pattern (build-pattern et1 et2 ignore-id-matches)])
                      (list variables pattern))))))
         (define noisy-number-threshold 3)
         (define (close? a b)
           (< (abs (- b a)) noisy-number-threshold))

         (define variance 1)
         (define (make-noisy-number et1 et2)
           (let ([mean (/ (+ et1 et2) 2)])
             (sample-gaussian mean variance)))
         
         ;;noisy-number unify
         (define noisy-number-unify
           (mem (lambda (s sv vars)
                  (begin
                    (define (variable? obj)
                      (member obj vars))
                    (cond [(variable? sv) (list (pair sv s))]
                          [(and (number? s) (number? sv)) (if (close? s sv) '() #f)]
                          [(and (primitive? s) (primitive? sv)) (if (eq? s sv) '() #f)]
                          [(or (primitive? s) (primitive? sv)) #f]
                          [(not (eqv? (length s) (length sv))) #f]
                          [else
                           (let ([assignments (map (lambda (si sj) (noisy-number-unify si sj vars)) s sv)])
                             (if (any false? assignments)
                                 #f
                                 (check/remove-repeated (apply append assignments))))])))))


         (define noisy-number-policy (build-unification-policy noisy-number-anti-unify noisy-number-unify))         
         )


