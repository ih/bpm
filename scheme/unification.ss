(library (unification)
         (export anti-unify unify) 
         (import (rnrs)
                 (_srfi :1)
                 (noisy-number)
                 (program)
                 (church readable-scheme)
                 (mem)
                 (util)
                 (sym))
         
         

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
                 (list pattern (reverse variables)))))) ;;reversing variables is more for readability/testing, can remove for efficiency

         

;;          noisy number related
;; unification
;;          it might be nice to memoize this, but right now if the sexprs passed to it have floating point numbers, this causes problems
;;          takes a sexpr (s), a sexpr with variables (sv) and a proc name, e.g.
;;          s = (foo (foo a b c) b c)
;;          sv = (foo V b c)
;;          name = P
;;          first pass: (P (foo a b c))
;;          second (operand) pass: (P (P a))
;;          returns #f if abstraction cannot be applied, otherwise variable assignments

         ;;;one way to speed up unification is to stop as soon as a #f is returned
         (define unify
           (lambda (s sv vars)
             (begin
               (define (variable? obj)
                 (member obj vars))

               ;;deals with a variable that occurs multiple times in sv
               (define (check/remove-repeated unified-vars)
                 (let* ([repeated-vars (filter more-than-one (map (curry all-assoc unified-vars) (map first unified-vars)))])
                   (if (and (all (map all-equal? repeated-vars)) (not (any false? unified-vars)))
                       (delete-duplicates unified-vars)
                       #f)))
               
               (cond [(variable? sv) (if (eq? s 'lambda) #f (list (pair sv s)))]
                     [(and (primitive? s) (primitive? sv)) (if (eqv? s sv) '() #f)]
                     [(or (primitive? s) (primitive? sv)) #f]
                     [(not (eqv? (length s) (length sv))) #f]
                     [else
                      (let ([assignments (map (lambda (si sj) (unify si sj vars)) s sv)])
                        (if (any false? assignments)
                            #f
                            (check/remove-repeated (apply append assignments))))])))))