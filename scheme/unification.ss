(library (unification)
         (export anti-unify unify var-symbol unenumerate-expr set-policy!) 
         (import (rnrs)
                 (_srfi :1)
                 (noisy-number)
                 (church readable-scheme)
                 (mem)
                 (util)
                 (sym))
         (define eexpr->id first)

         (define eexpr->expr cdr) ;; non-recursive

         (define (unenumerate-expr t)
           (if (primitive? t)
               t
               (map unenumerate-expr (rest t))))


         
         (define (var-symbol) 'V)

         (define policy 'noisy-number)
         (define (set-policy! new-policy)
           (set! policy new-policy))
;;;anti-unification
         ;;it might be nice to memoize this, but right now if the sexprs passed to it have floating point numbers, this causes problems
         (define anti-unify
           (lambda (et1 et2 ignore-id-matches)
             (begin

               (define variables '())

               (define (mismatch-policy!)
                 (cond [(eq? policy 'original) original-policy]
                       [(eq? policy 'noisy-number) noisy-number-policy]
                       [(eq? policy 'no-var) no-var-policy]
                       [else (error "no such matching policy for anti-unification!")]))

               (define (original-policy et1 et2)
                 (add-variable!))

               (define (noisy-number-policy et1 et2)
                 (if (and (number? et1) (number? et2))
                     (if (close? et1 et2) (make-noisy-number et1 et2) (add-variable!))
                     (add-variable!)))

               ;;eventually change this to probabilistically return et1 or et2, returns et1 now for testing purposes
               (define (no-var-policy et1 et2)
                 (unenumerate-expr et1))
               
               (define (add-variable!)
                 (set! variables (pair (sym (var-symbol)) variables))
                 (first variables))
               
               (define (build-pattern et1 et2 ignore-id-matches)
                 (cond [(and (primitive? et1) (primitive? et2)) (if (equal? et1 et2) et1 ((mismatch-policy!) et1 et2))]
                       [(or (primitive? et1) (primitive? et2)) ((mismatch-policy!) et1 et2)]
                       [(and ignore-id-matches (eqv? (eexpr->id et1) (eexpr->id et2))) #f]
                       [(not (eqv? (length et1) (length et2))) ((mismatch-policy!) et1 et2)]
                       [else
                        (let ([unified-expr (map (lambda (t1 t2) (build-pattern t1 t2 ignore-id-matches))
                                                 (eexpr->expr et1)
                                                 (eexpr->expr et2))])
                          (if (any false? unified-expr)
                              #f
                              unified-expr))]))
               (let ([pattern (build-pattern et1 et2 ignore-id-matches)])
                 (list pattern variables)))))

         

         ;;noisy number related
;;;unification
         ;;it might be nice to memoize this, but right now if the sexprs passed to it have floating point numbers, this causes problems
         (define unify
           (lambda (s sv vars)
             (begin
               (define (variable? obj)
                 (member obj vars))
               (define (match-policy?)
                 (cond [(eq? policy 'original) original-policy]
                       [(eq? policy 'noisy-number) noisy-number-policy]
                       [(eq? policy 'no-var) original-policy]
                       [else (error "no such matching policy for unification!")]))

               (define original-policy eq?)

               (define (noisy-number-policy s sv)
                 (if (and (number? s) (number? sv))
                     (if (close? s sv) '() #f)
                     (eq? s sv)))
               
               (cond [(variable? sv) (list (pair sv s))]
                     [(and (primitive? s) (primitive? sv)) (if ((match-policy?) s sv) '() #f)]
                     [(or (primitive? s) (primitive? sv)) #f]
                     [(not (eqv? (length s) (length sv))) #f]
                     [else
                      (let ([assignments (map (lambda (si sj) (unify si sj vars)) s sv)])
                        (if (any false? assignments)
                            #f
                            (check/remove-repeated (apply append assignments))))]))))

         (define (check/remove-repeated unified-vars)
           (let* ([repeated-vars (filter more-than-one (map (curry all-assoc unified-vars) (map first unified-vars)))])
             (if (and (all (map all-equal? repeated-vars)) (not (any false? unified-vars)))
                 (delete-duplicates unified-vars)
                 #f)))

         (define (more-than-one lst)
           (> (length lst) 1))


         
         )