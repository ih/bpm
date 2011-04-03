(library (internalize-arguments)
         (export internalize-arguments has-arguments? find-variable-instances thunkify make-mixture-sexpr remove-abstraction-variable)
         (import (except (rnrs) string-hash string-ci-hash)
                 (abstract)
                 (_srfi :1)
                 (util))

         ;;a transformation is performed for each variable of each abstraction 
         (define (internalize-arguments program . nofilter)
           (let* ([abstractions-with-variables (filter has-arguments? (program->abstractions program))])
             (append (map (curry abstraction-internalizations program) abstractions-with-variables))))

         (define (has-arguments? abstraction)
           (not (null? (abstraction->vars abstraction))))

         (define (abstraction-internalizations program abstraction)
           (map (curry internalize-argument program abstraction) (abstraction->vars abstraction)))

         (define (internalize-argument program abstraction variable)
           (let* ([new-abstraction (remove-abstraction-variable program abstraction variable)]
                  [new-program (change-applications program new-abstraction variable)])
             new-program))

         ;;creates a "mixture" distribution over instances of the variable being removed
         (define (remove-abstraction-variable program abstraction variable)
           (let* ([mixture-elements (find-variable-instances program abstraction variable)]
                  [mixture-sexpr (make-mixture-sexpr mixture-elements)]
                  [new-pattern `(let ([,variable ,mixture-sexpr]) ,(abstraction->pattern abstraction))]
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

         (define (make-mixture-sexpr mixture-elements)
           `((uniform-draw (list ,@(map thunkify mixture-elements)))))

         (define (thunkify sexpr) `(lambda () ,sexpr))

         (define change-applications 1))

