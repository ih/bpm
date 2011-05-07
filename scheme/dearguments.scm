(library (dearguments)
         (export make-dearguments-transformation has-arguments? find-variable-instances remove-abstraction-variable remove-ith-argument remove-application-argument abstraction-deargumentations uniform-replacement noisy-number-replacement noisy-number-simple-replacement same-variable-replacement deargument simple-noisy-number-dearguments uniform-draw-dearguments noisy-number-dearguments same-variable-dearguments NO-REPLACEMENT find-matching-variable)
         (import (except (rnrs) string-hash string-ci-hash remove)
                 (program)
                 (except (_srfi :1) remove)
                 (only (srfi :1) remove)
                 (util)
                 (church readable-scheme))
         (define NO-REPLACEMENT 'no-replacement)
         ;;program transformations
         (define noisy-number-dearguments (make-dearguments-transformation noisy-number-replacement))
         (define same-variable-dearguments (make-dearguments-transformation same-variable-replacement))
         (define uniform-draw-dearguments (make-dearguments-transformation uniform-replacement))
         (define simple-noisy-number-dearguments (make-dearguments-transformation noisy-number-simple-replacement))
         ;;replacement functions
         (define (uniform-replacement program abstraction variable variable-instances)
           (let* ([db (pretty-print (list "before" variable-instances (map has-variable? variable-instances)))]
                  [valid-variable-instances (remove has-variable? variable-instances)]
                  [db (pretty-print (list "after" valid-variable-instances))])
             (if (null? valid-variable-instances)
                 NO-REPLACEMENT
                 `((uniform-draw (list ,@(map thunkify valid-variable-instances)))))))

         (define (noisy-number-replacement program abstraction variable variable-instances)
           (if (all (map number? variable-instances))
               (let*
                   ([instances-mean (my-mean variable-instances)])
                 instances-mean)
               NO-REPLACEMENT))

         (define (same-variable-replacement program abstraction variable variable-instances)
           (let* ([possible-match-variables (delete variable (abstraction->vars abstraction))])
             (find-matching-variable program abstraction variable-instances possible-match-variables)))

         (define (find-matching-variable program abstraction variable-instances possible-match-variables)
           (if (null? possible-match-variables)
               NO-REPLACEMENT
               (let* ([hypothesis-variable (first possible-match-variables)]
                      [hypothesis-instances (find-variable-instances program abstraction hypothesis-variable)])
                 (if (equal? hypothesis-instances variable-instances)
                     hypothesis-variable
                     (find-matching-variable program abstraction variable-instances (rest possible-match-variables))))))
         
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
                    [prog-size (program-size (program->sexpr program))]
                    [valid-deargumented-programs
                     (if (not (null? nofilter))
                         deargumented-programs
                         (filter (lambda (ip) (<= (program-size (program->sexpr ip))
                                                  (+ prog-size 1)))
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
                 (let* ([program-with-new-abstraction (program->replace-abstraction program new-abstraction)]
                        [new-program (remove-application-argument program-with-new-abstraction abstraction variable)])
                   new-program))))

         ;;creates a "mixture" distribution over instances of the variable being removed
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
         (define (remove-application-argument program abstraction variable)
           (define (abstraction-application? sexpr)
              (if (non-empty-list? sexpr)
                  (equal? (first sexpr) (abstraction->name abstraction))
                  #f))
           (define (change-application variable-position application)
              (remove-ith-argument variable-position application))
           (let* ([variable-position (abstraction->variable-position abstraction variable)]
                  [program-sexpr (program->sexpr program)]
                  [changed-sexpr (sexp-search abstraction-application? (curry change-application variable-position) program-sexpr)]
                  [new-program (sexpr->program changed-sexpr)])
             new-program))

         ;;assumes abstractions and only abstractions have name of the form '[FUNC-SYMBOL][Number]
         (define (application? sexpr)
           (if (non-empty-list? sexpr)
               (func? (first sexpr)))))

