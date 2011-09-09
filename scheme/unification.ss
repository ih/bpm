(library (unification)
         (export anti-unify unify) 
         (import (rnrs)
                 (_srfi :1)
                 (noisy-number)
                 (program)
                 (church readable-scheme)
                 (mem)
                 (util)
                 (sym)
                 (delimcc-simple-ikarus))

         ;;;anti-unification
         ;;it might be nice to memoize this, but right now if the sexprs passed to it have floating point numbers, this causes problems
         ;;returns a partial match of the expressions passed to it along with the variables used
         ;;e.g. (+ 2 (+ 3 4)) and (+ (* 3 5) (- 3 5)) => (+ V1 (V2 3 V3)) with variables (V1 V2 V3)
         ;;the reason for returning the variables is the output of this function is passed to make-abstraction, this also determines the order of the output
         (define anti-unify
           (lambda (expr1 expr2)
             (begin
               (define variables '())

               (define (add-var! acc)
                 (set! variables (pair (sym (var-symbol)) variables))
                 (lambda (x) (acc (first variables))))

               (define (continue-with acc x)
                 (lambda (y) (acc x)))

               (define (id x) x)

               (define (loop acc expr1 expr2)
                 (cond [(and (primitive? expr1) (primitive? expr2))
                        (if (equal? expr1 expr2)
                          (continue-with acc expr1)
                          (add-var! acc))]
                       [(or (primitive? expr1) (primitive? expr2))
                        (add-var! acc)]
                       [(not (eqv? (length expr1) (length expr2)))
                        (add-var! acc)]
                       [else (loop (lambda (y) 
                                     (acc (cons ((loop id (car expr1) (car expr2)) y) 
                                                y)))
                                            (cdr expr1) 
                                            (cdr expr2))]))

               ;; (define (add-variable!)
               ;;   (begin
               ;;     (set! variables (pair (sym (var-symbol)) variables))
               ;;     (first variables)))

               ;; (define (build-pattern expr1 expr2)
               ;;   (cond [(and (primitive? expr1) (primitive? expr2)) (if (equal? expr1 expr2) expr1 (add-variable!))]
               ;;         [(or (primitive? expr1) (primitive? expr2)) (add-variable!)]
               ;;         [(not (eqv? (length expr1) (length expr2))) (add-variable!)]
               ;;         [else
               ;;           (let ([unified-expr (map (lambda (subexpr1 subexpr2) (build-pattern subexpr1 subexpr2))
               ;;                                    expr1 expr2)])
               ;;             unified-expr)]))
               ;; (let ([pattern (build-pattern expr1 expr2)])

               (let ([pattern ((loop id expr1 expr2) '())])
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

         ;; one way to speed up unification is to stop as soon as a #f is returned
         ;; we stop early by using delimited control operations
         ;;
         ;; think of
         ;; (reset <code that calls (shift k #f)>) as
         ;; (try <code that calls (throw Done)> (catch Done #f))
         
         (define (unify s sv vars)
           (define (early-fail)
             (shift k #f))


           (define (map-early-fail-2 f xs ys)
             (cond [(or (null? xs) (null? ys)) '()]
                   [else (let* ([fx (f (car xs) (car ys))])
                            (cond [(eq? #f fx) (shift k #f)]
                                  [else (cons fx (map-early-fail-2 f (cdr xs) (cdr ys)))]))]))
             
          (define (map-early-fail f xs) 
            (cond [(null? xs) '()]
                  [else (let* ([fx (f (car xs))])
                          (cond [(eq? #f fx) (shift k #f)]
                                [else (cons fx (map-early-fail f (cdr xs)))]))]))

           (define (loop s sv)
             (begin
               (define (variable? obj)
                 (member obj vars))

               ;;deals with a variable that occurs multiple times in sv
               (define (check/remove-repeated unified-vars)
                 (let* ([repeated-vars (filter more-than-one (map (curry all-assoc unified-vars) (map first unified-vars)))])
                   (begin (map-early-fail all-equal? repeated-vars)
                          (map-early-fail (lambda (x) (cond [(false? x) #f]
                                                            [else #t])) unified-vars)
                          (delete-duplicates unified-vars))))

               (cond [(variable? sv) (if (eq? s 'lambda) (early-fail) (list (pair sv s)))]
                     [(and (primitive? s) (primitive? sv)) (if (eqv? s sv) '() (early-fail))]
                     [(or (primitive? s) (primitive? sv)) (early-fail)]
                     [(not (eqv? (length s) (length sv))) (early-fail)]
                     [else
                       (let ([assignments (map-early-fail-2 (lambda (si sj) (loop si sj)) s sv)])
                           (check/remove-repeated (apply append assignments)))])))
           (reset (loop s sv)))



         )
