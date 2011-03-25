(library (unification)
         (export anti-unify var-symbol) 
         (import (rnrs)
                 (_srfi :1)
                 (noisy-number)
                 (church readable-scheme)
                 (mem)
                 (util)
                 (sym))
         
         (define (var-symbol) 'V)

;;;anti-unification
         ;;it might be nice to memoize this, but right now if the sexprs passed to it have floating point numbers, this causes problems
         (define anti-unify
           (lambda (expr1 expr2)
             (begin
               (define variables '())

               (define (add-variable!)
                 (set! variables (pair (sym (var-symbol)) variables))
                 (first variables))
               
               (define (build-pattern expr1 expr2)
                 (cond [(and (primitive? expr1) (primitive? expr2)) (if (equal? expr1 expr2) expr1 (add-variable!))]
                       [(or (primitive? expr1) (primitive? expr2)) (add-variable!)]
                       [(not (eqv? (length expr1) (length expr2))) (add-variable!)]
                       [else
                        (let ([unified-expr (map (lambda (subexpr1 subexpr2) (build-pattern subexpr1 subexpr2))
                                                 expr1 expr2)])
                          unified-expr)]))
               (let ([pattern (build-pattern expr1 expr2)])
                 (list pattern variables)))))

         

         ;;noisy number related
;;;unification
         ;;it might be nice to memoize this, but right now if the sexprs passed to it have floating point numbers, this causes problems
         ;; (define unify
         ;;   (lambda (s sv vars)
         ;;     (begin
         ;;       (define (variable? obj)
         ;;         (member obj vars))
         ;;       (define (match-policy?)
         ;;         (cond [(eq? policy 'original) original-policy]
         ;;               [(eq? policy 'noisy-number) noisy-number-policy]
         ;;               [(eq? policy 'no-var) original-policy]
         ;;               [else (error "no such matching policy for unification!")]))

         ;;       (define original-policy eq?)

         ;;       (define (noisy-number-policy s sv)
         ;;         (if (and (number? s) (number? sv))
         ;;             (if (close? s sv) '() #f)
         ;;             (eq? s sv)))
               
         ;;       (cond [(variable? sv) (list (pair sv s))]
         ;;             [(and (primitive? s) (primitive? sv)) (if ((match-policy?) s sv) '() #f)]
         ;;             [(or (primitive? s) (primitive? sv)) #f]
         ;;             [(not (eqv? (length s) (length sv))) #f]
         ;;             [else
         ;;              (let ([assignments (map (lambda (si sj) (unify si sj vars)) s sv)])
         ;;                (if (any false? assignments)
         ;;                    #f
         ;;                    (check/remove-repeated (apply append assignments))))]))))

         ;; (define (check/remove-repeated unified-vars)
         ;;   (let* ([repeated-vars (filter more-than-one (map (curry all-assoc unified-vars) (map first unified-vars)))])
         ;;     (if (and (all (map all-equal? repeated-vars)) (not (any false? unified-vars)))
         ;;         (delete-duplicates unified-vars)
         ;;         #f)))

         


         
         )