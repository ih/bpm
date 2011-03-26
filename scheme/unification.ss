(library (unification)
         (export anti-unify unify var-symbol) 
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
         ;;returns a partial match of the expressions passed to it along with the variables used
         ;;e.g. (+ 2 (+ 3 4)) and (+ (* 3 5) (- 3 5)) => (+ V1 (V2 3 V3)) with variables (V1 V2 V3)
         ;;the reason for returning the variables is the output of this function is passed to make-abstraction, this also determines the order of the output
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

         
(define unify '())
         ;;noisy number related
;;;unification
         ;;it might be nice to memoize this, but right now if the sexprs passed to it have floating point numbers, this causes problems
         ;; takes a sexpr (s), a sexpr with variables (sv) and a proc name, e.g.
         ;; s = (foo (foo a b c) b c)
         ;; sv = (foo V b c)
         ;; name = P
         ;; first pass: (P (foo a b c))
         ;; second (operand) pass: (P (P a))
         ;; returns #f if abstraction cannot be applied, otherwise variable assignments
         ;; ! assumes that each variable occurs only once in sv [2]


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