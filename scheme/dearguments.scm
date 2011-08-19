(library (dearguments)
         (export make-dearguments-transformation has-arguments? find-variable-instances remove-abstraction-variable remove-ith-argument remove-application-argument abstraction-deargumentations uniform-replacement noisy-number-replacement noisy-number-simple-replacement same-variable-replacement deargument simple-noisy-number-dearguments uniform-draw-dearguments noisy-number-dearguments same-variable-dearguments NO-REPLACEMENT find-matching-variable recursion-dearguments recursion-replacement terminates?)
         (import (except (rnrs) string-hash string-ci-hash remove)
                 (program)
                 (except (_srfi :1) remove)
                 (only (srfi :1) remove)
                 (util)
                 (srfi :69)
                 (church readable-scheme))
         (define NO-REPLACEMENT 'no-replacement)
         ;;program transformations
         (define noisy-number-dearguments (make-dearguments-transformation noisy-number-replacement))
         (define same-variable-dearguments (make-dearguments-transformation same-variable-replacement))
         (define recursion-dearguments (make-dearguments-transformation recursion-replacement))
         (define uniform-draw-dearguments (make-dearguments-transformation uniform-replacement))
         (define simple-noisy-number-dearguments (make-dearguments-transformation noisy-number-simple-replacement))
         ;;replacement functions
         (define (uniform-replacement program abstraction variable variable-instances)
           (let* (;[db (pretty-print (list "before" variable-instances (map has-variable? variable-instances)))]
                  [valid-variable-instances (remove has-variable? variable-instances)]
                  ;[db (pretty-print (list "after" valid-variable-instances))]
                  )
             (if (null? valid-variable-instances)
                 NO-REPLACEMENT
                 `((uniform-draw (list ,@(map thunkify valid-variable-instances)))))))
         ;;make stronger check for whether a variable-instance is a recursive call (e.g. a different function that only calls the current function)
         ;;flip version only works when data is a single line i.e. a function that only takes one argument and repeatedly calls itself
         (define (recursion-replacement program abstraction variable variable-instances)
           (let* ([valid-variable-instances (remove has-variable? variable-instances)]
                  [recursive-calls (filter (curry abstraction-application? abstraction) valid-variable-instances)]
                  [non-recursive-calls (remove (curry abstraction-application? abstraction) valid-variable-instances)]
                  [terminates (terminates? program (abstraction->name abstraction) non-recursive-calls)]) 
             (if (or (null? valid-variable-instances) (null? recursive-calls) (not terminates))
                 NO-REPLACEMENT
                 (let* ([prob-of-recursion (/ (length recursive-calls) (length valid-variable-instances))])
                   `(if (flip ,prob-of-recursion) ,(first recursive-calls) (uniform-choice  ,@non-recursive-calls))))))

         (define (terminates? program init-abstraction-name non-recursive-calls)
           (define abstraction-statuses (make-hash-table eq?))

           (define (initialize-statuses)
             (let ([abstraction-names (map abstraction->name (program->abstractions program))])
              (begin
                (map (curry hash-table-set! abstraction-statuses) abstraction-names (make-list (length abstraction-names) 'unchecked))
                (hash-table-set! abstraction-statuses init-abstraction-name 'checking))))

           (define (status? name)
             (hash-table-ref abstraction-statuses name))

           (define (set-status! name new-status)
             (hash-table-set! abstraction-statuses name new-status))
           
           (define (terminating-abstraction? abstraction-name)
               (cond [(eq? (status? abstraction-name) 'terminates) #t]
                     [(eq? (status? abstraction-name) 'checking) #f]
                     [(eq? (status? abstraction-name) 'unchecked)
                      (begin
                        (set-status! abstraction-name 'checking)
                        (if (base-case? (program->abstraction-pattern program abstraction-name))
                            (begin
                              (set-status! abstraction-name 'terminates)
                              #t)
                            #f))]))
           
           (define (base-case? sexpr)
             (cond [(branching? sexpr) (list-or (map base-case?  (get-branches sexpr)))]
                   [(application? sexpr) (if (any-abstraction-application? sexpr)
                                             (and (terminating-abstraction? (operator sexpr)) (all (map base-case? (operands sexpr))))
                                             (all (map base-case? (operands sexpr))))]
                   [else #t]))
           (begin
             ;(display-all "\nterminates?" init-abstraction-name " " non-recursive-calls "\n")
             (initialize-statuses)
             (list-or (map base-case? non-recursive-calls))))


         (define application? pair?)
         
         (define operator first)

         (define operands rest)

         (define (branching? sexpr)
           (or (if? sexpr) (uniform-draw? sexpr)))
         
         (define (if? sexpr)
           (tagged-list? sexpr 'if))

         (define (uniform-draw? sexpr)
           (tagged-list? sexpr 'uniform-draw))
         
         (define (get-branches sexpr)
           (define dethunkify third) 
           (cond [(if? sexpr) (list (third sexpr) (fourth sexpr))]
                 [(uniform-draw? sexpr) (map dethunkify (rest (second sexpr)))]
                 [else (error "not a branching expression" sexpr)]))

         (define (noisy-number-replacement program abstraction variable variable-instances)
           (if (all (map number? variable-instances))
               (my-mean variable-instances)
               NO-REPLACEMENT))

         (define (same-variable-replacement program abstraction variable variable-instances)
           (let* ([possible-match-variables (delete variable (abstraction->vars abstraction))])
             (find-matching-variable program abstraction variable-instances possible-match-variables)))

         (define (find-matching-variable program abstraction variable-instances possible-match-variables)
           ;based on http://community.schemewiki.org/?sicp-ex-2.54
           (define (my-equal? a b) 
             (if (and (pair? a) (pair? b)) 
                 (and (my-equal? (car a) (car b)) (my-equal? (cdr a) (cdr b))) 
                 (if (and (number? a) (number? b))
                     #t
                     (eq? a b)))) 
           (if (null? possible-match-variables)
               NO-REPLACEMENT
               (let* ([hypothesis-variable (uniform-draw possible-match-variables)]
                      [hypothesis-instances (find-variable-instances program abstraction hypothesis-variable)])
                 (if (my-equal? hypothesis-instances variable-instances)
                     hypothesis-variable
                     (find-matching-variable program abstraction variable-instances (delete hypothesis-variable possible-match-variables))))))
         
         ;; (define (noisy-number-replacement variable-instances)
         ;;   (define (close? a b)
         ;;     (< (abs (- a b)) .2))
         ;;   (if (all (map number? variable-instances))
         ;;       (let* ([instances-mean (my-mean variable-instances)]
         ;;              [instances-variance (my-variance variable-instances)] 
         ;;              [instance-close-to-mean (map (curry close? instances-mean) variable-instances)])
         ;;         (if (all instance-close-to-mean)
         ;;             `(gaussian ,instances-mean ,instances-variance)
         ;;             (uniform-replacement variable-instances)))
         ;;       (uniform-replacement variable-instances)))

         (define (noisy-number-simple-replacement variable-instances)
           (define (close? a b)
             (< (abs (- a b)) .2))
           (if (all (map number? variable-instances))
               (let* ([instances-mean (my-mean variable-instances)]
                      [instance-close-to-mean (map (curry close? instances-mean) variable-instances)])
                 (if (all instance-close-to-mean)
                     (first variable-instances)
                     (uniform-replacement variable-instances)))
               (uniform-replacement variable-instances)))


         ;;creates a program transformation that removes a variable from the abstraction and replaces it with the output of replacement-function
         ;;replacement-function takes in the instances for a particular variable and returns an expression that the variable gets set to 
         (define (make-dearguments-transformation replacement-function)
           ;;a transformation is performed for each variable of each abstraction 
           (lambda (program . nofilter)
             (let* ([abstractions-with-variables (filter has-arguments? (program->abstractions program))]
                    [deargumented-programs (delete '() (concatenate (map (curry abstraction-deargumentations replacement-function program) abstractions-with-variables)))] ;;any deargument attempts where the replacement-function couldn't be applied will return '()
                    ;;[db (for-each display (list "\nstart-program" program "\ndeargumented-programs" deargumented-programs))]
                    [prog-size (program-size program)]
                    [valid-deargumented-programs
                     (if (not (null? nofilter))
                         deargumented-programs
                         (filter (lambda (ip) (< (program-size ip)
                                                 prog-size))
                                 deargumented-programs))])
               valid-deargumented-programs)))

         (define (has-arguments? abstraction)
           (not (null? (abstraction->vars abstraction))))

         ;;return a program transformation is returned for each variable in abstraction
         (define (abstraction-deargumentations replacement-function program abstraction)
           (map (curry deargument replacement-function program abstraction) (abstraction->vars abstraction)))

         ;;rewrite the abstraction to have the variable in the abstraction be a mixture of the values its taken on in the program
         ;;rewrite applications of the abstraction function in the program to not have the variable
         ;;returns '() if replacement-function cannot be applied
         (define (deargument replacement-function program abstraction variable)
           (let* ([new-abstraction (remove-abstraction-variable replacement-function program abstraction variable)])
             (if (null? new-abstraction)
                 '()
                 (let* ([program-with-new-abstraction (update-abstraction program new-abstraction)]
                        [new-program (remove-application-argument program-with-new-abstraction abstraction variable)])
                   new-program))))


         (define (remove-abstraction-variable replacement-function program abstraction variable)
           (let* ([variable-instances (find-variable-instances program abstraction variable)]
                  [variable-definition (replacement-function program abstraction variable variable-instances)])
             (if (equal? variable-definition NO-REPLACEMENT)
                 '()
                 (let* ([new-pattern `((lambda (,variable) ,(abstraction->pattern abstraction)) ,variable-definition)]
                        [new-variables (delete variable (abstraction->vars abstraction))])
                   (make-named-abstraction (abstraction->name abstraction) new-pattern new-variables)))))

         (define (find-variable-instances program abstraction variable)
           (let* ([abstraction-applications (program->abstraction-applications program abstraction)]
                  [variable-position (abstraction->variable-position abstraction variable)]
                  [variable-instances (map (curry ith-argument variable-position) abstraction-applications)])
             variable-instances))

         ;;i+1 because the first element is the function name
         (define (ith-argument i function-application)
           (list-ref function-application (+ i 1)))

         (define (remove-ith-argument i function-application)
           (append (take function-application (+ i 1)) (drop function-application (+ i 2))))


         


         ;;rewrite applications of abstraction in program to not have the variable argument
         ;;abstraction is the old abstraction and program contains the new abstraction
         (define (remove-application-argument program abstraction variable)
           (define (abstraction-application? sexpr)
              (if (non-empty-list? sexpr)
                  (equal? (first sexpr) (abstraction->name abstraction))
                  #f))
           (define (change-application variable-position application)
             (define (change-recursive-arguments argument) ;;in case one of the arguments is an application of the abstraction currently being deargumented
               (if (abstraction-application? argument)
                   (change-application variable-position argument)
                   argument))
             (let* ([ith-removed (remove-ith-argument variable-position application)])
               (map change-recursive-arguments ith-removed)))
           (let* ([variable-position (abstraction->variable-position abstraction variable)]
                  [program-sexpr (program->sexpr program)]
                  [changed-sexpr (transform-sexp abstraction-application? (curry change-application variable-position) program-sexpr)]
                  [new-program (sexpr->program changed-sexpr)])
             new-program))

         ;;assumes abstractions and only abstractions have name of the form '[FUNC-SYMBOL][Number]
         )

