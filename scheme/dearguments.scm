(library (dearguments)
         (export dearguments has-arguments? find-variable-instances thunkify make-mixture-sexpr remove-abstraction-variable remove-ith-argument remove-application-argument abstraction-deargumentations)
         (import (except (rnrs) string-hash string-ci-hash)
                 (program)
                 (_srfi :1)
                 (util))
         ;;creates a program transformation that removes a variable from the abstraction and replaces it with the output of replacement-function
         ;;replacement-function takes in the instances for a particular variable and returns an expression that the variable gets set to 
         (define (make-dearguments-transformation replacement-function)
           ;;a transformation is performed for each variable of each abstraction 
           (lambda (program . nofilter)
             (let* ([abstractions-with-variables (filter has-arguments? (program->abstractions program))]
                    [deargumented-programs (concatenate (map (curry abstraction-deargumentations replacement-function program) abstractions-with-variables))]
                    [program-size (size (program->sexpr program))]
                    [valid-deargumented-programs
                     (if (not (null? nofilter))
                         deargumented-programs
                         (filter (lambda (ip) (<= (size (program->sexpr ip))
                                                  (+ program-size 1)))
                                 deargumented-programs))])
               valid-deargumented-programs)))

         (define (has-arguments? abstraction)
           (not (null? (abstraction->vars abstraction))))

         ;;return a program transformation is returned for each variable in abstraction
         (define (abstraction-deargumentations replacement-function program abstraction)
           (map (curry deargument replacement-function program abstraction) (abstraction->vars abstraction)))

         ;;rewrite the abstraction to have the variable in the abstraction be a mixture of the values its taken on in the program
         ;;rewrite applications of the abstraction function in the program to not have the variable
         (define (deargument replacement-function program abstraction variable)
           (let* ([new-abstraction (remove-abstraction-variable replacement-function program abstraction variable)]
                  [program-with-new-abstraction (program->replace-abstraction program new-abstraction)]
                  [new-program (remove-application-argument program-with-new-abstraction abstraction variable)])
             new-program))

         ;;creates a "mixture" distribution over instances of the variable being removed
         (define (remove-abstraction-variable replacement-function program abstraction variable)
           (let* ([variable-instances (find-variable-instances program abstraction variable)]
                  [variable-definition (replacement-function variable-instances)]
                  [new-pattern `((lambda (,variable) ,(abstraction->pattern abstraction)) variable-definition)]
                  [new-variables (delete variable (abstraction->vars abstraction))])
             (make-named-abstraction (abstraction->name abstraction) new-pattern new-variables)))

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

         (define (make-mixture-sexpr mixture-elements)
           `((uniform-draw (list ,@(map thunkify mixture-elements)))))

         (define (thunkify sexpr) `(lambda () ,sexpr))


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

