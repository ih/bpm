(library (program)
         (export func-symbol var-symbol size var? func? make-abstraction make-named-abstraction abstraction->name abstraction->vars abstraction->pattern abstraction->define abstraction->variable-position make-program program->abstractions program->replace-abstraction capture-free-variables program->sexpr sexpr->program pretty-print-program program->body program->abstraction-applications define->abstraction)
         (import (except (rnrs) string-hash string-ci-hash)
                 (church readable-scheme)
                 (sym)
                 (_srfi :1)
                 (_srfi :69)
                 (util))

         ;;var-symbol and func-symbol are functions that return symbols so that they can be used in bher
         ;;think about moving these to a constants file since they're now separated due to unification-policies
         (define (func-symbol) 'F)
         (define (var-symbol) 'V)

         ;;language specific functions ;use reg-exps
         ;;temp fix b/c problems access to srfi 13
         (define (var? expr)
           (if (symbol? expr)
               (let* ([var-string (symbol->string (var-symbol))]
                      [string-expr (symbol->string expr)])
                 ;; (string-prefix? var-pattern string-expr))))
                 (equal? (substring string-expr 0 1) var-string))
               #f))

         (define (func? expr)
           (if (symbol? expr)
               (let* ([func-string (symbol->string (func-symbol))]
                      [string-expr (symbol->string expr)])
                 ;; (string-prefix? var-pattern string-expr))))
                 (equal? (substring string-expr 0 1) func-string))
               #f))

         ;;compute the size of a program
         (define (size expr)
           (if (list? expr)
               (cond [(tagged-list? expr 'begin) (size (rest expr))] ;; ignore 'begin symbol
                     [(tagged-list? expr 'define) (size (cddr expr))] ;; ignore 'define symbol + args
                     [else (apply + (map size expr))])
               1))

;;; data abstraction for abstraction 
         (define (make-abstraction pattern variables)
           (make-named-abstraction (sym (func-symbol)) pattern variables))
         (define (make-named-abstraction name pattern variables)
           (list 'abstraction name variables pattern))

         (define abstraction->name second)
         (define abstraction->vars third)
         (define abstraction->pattern fourth)

         ;; make a define statement out of an abstraction, format is (define name (lambda (vars) body))
         (define (abstraction->define abstraction)
           (let ((name (abstraction->name abstraction))
                 (variables (abstraction->vars abstraction))
                 (pattern (abstraction->pattern abstraction)))
             (list 'define name (list 'lambda variables pattern))))

         (define (abstraction->variable-position abstraction variable)
           (list-index (lambda (x) (equal? variable x)) (abstraction->vars abstraction)))

                  ;;searches through the body of the abstraction  and returns a list of free variables
         (define (get-free-vars abstraction)
           (let* ([pattern (abstraction->pattern abstraction)]
                  [non-free (abstraction->vars abstraction)]
                  [free '()]
                  [free-var? (lambda (x) (and (var? x) (not (member x non-free))))]
                  [add-to-free! (lambda (x) (set! free (pair x free)))])
             (sexp-search free-var? add-to-free! pattern)
             free))

;;free variables can occur when the pattern for an abstraction contains variables that were part of the matched expressions e.g. if the expression was (+ v1 v1 a) (+ v1 v1 b) then the pattern would be (+ v1 v1 v2)
         ;;we "capture" the variables by adding them to the function definition
         ;;an alternative approach would be to have nested abstractions
         
         (define (capture-free-variables abstraction)
           (let* ([free-vars (get-free-vars abstraction)])
             (if (null? free-vars)
                 abstraction
                 (let* ([new-vars (append free-vars (abstraction->vars abstraction))] 
                        [old-pattern (abstraction->pattern abstraction)]
                        ;;add new-pattern with new variable names for captured-vars to prevent isomorphic abstractions
                        [old-name (abstraction->name abstraction)]
                        [no-free-abstraction (make-named-abstraction old-name old-pattern new-vars)])
                   no-free-abstraction))))
         
;;;data abstraction for programs
         (define (make-program abstractions body)
           (list 'program abstractions body))
         (define program->abstractions second)
         (define program->body third)

         ;;it might also be possible to search over program->sexpr, but then we'd need a more complicated predicate to avoid the definition of the target-abstraction
         (define (program->abstraction-applications program target-abstraction)
           (define (target-abstraction-application? sexpr)
             (if (non-empty-list? sexpr)
                 (if (equal? (first sexpr) (abstraction->name target-abstraction))
                     #t
                     #f)
                 #f))
           (let* ([abstraction-patterns (map abstraction->pattern (program->abstractions program))]
                  [possible-locations (pair (program->body program) abstraction-patterns)])
             (deep-find-all target-abstraction-application? possible-locations)))

         ;;assumes the new-abstraction has the same name as the abstraction it is replacing in program
         ;;assumes a particular abstraction is only defined once in the program
         (define (program->replace-abstraction program new-abstraction)
           (define (replace-abstraction abstractions new-abstraction)
             (if (null? abstractions)
                 '()
                 (let* ([current-abstraction (first abstractions)])
                   (if (equal? (abstraction->name current-abstraction) (abstraction->name new-abstraction))
                       (pair new-abstraction (rest abstractions))
                       (pair current-abstraction (replace-abstraction (rest abstractions) new-abstraction))))))
           (let* ([abstractions (program->abstractions program)]
                  [new-abstractions (replace-abstraction abstractions new-abstraction)])
             (make-program new-abstractions (program->body program))))

         (define (program->sexpr program)
           `(let ()  
              ,@(map abstraction->define (program->abstractions program))
              ,(program->body program)))

         ;;assumes format of (let () definitions body); if format fails to hold then program is an empty set of abstractions and the sexpr as the body
         (define (sexpr->program sexpr)
           (define (abstraction-sexpr? x)
             (if (and (not (null? x)) (list? x))
                 (equal? (first x) 'define)
                 #f))
           (let*-values ([(no-scope-sexpr) (remove-scope sexpr)]
                         [(abstractions body) (span abstraction-sexpr? no-scope-sexpr)])
             (make-program (map define->abstraction abstractions) (first body))))

         (define (remove-scope sexpr)
           (define (scope? x)
             (or (equal? 'let x) (null? x)))
           (let*-values ([(scope program) (span scope? sexpr)])
             program))

         (define (pretty-print-program program)
           (let ([sexpr (program->sexpr program)])
             (pretty-print sexpr)
             (for-each display (list "size: " (size sexpr) "\n\n"))))

         ;;define is of the form (define name (lambda (vars) body))
         (define (define->abstraction definition)
           (let* ([name (second definition)]
                  [vars (second (third definition))]
                  [body (third (third definition))])
             (make-named-abstraction name body vars)))

                  ;;used to ensure all function and variable names are in consecutive order; important for when trying to generate a program from a grammar that matches a compressed program
         (define (normalize-names expr)
           (define ht (make-hash-table eqv?))
           (define (traverse action expr)
             (if (or (primitive? expr) (null? expr))
                 (if (or (func? expr) (var? expr))
                     (action expr)
                     expr)
                 (map (curry traverse action) expr)))
           ;;build table
           (define (add-to-table expr)
             (if (func? expr)
                 (hash-table-set! ht expr (sym (func-symbol)))
                 (hash-table-set! ht expr (sym (var-symbol)))))
           (define (relabel expr)
             (hash-table-ref ht expr))
           (reset-symbol-indizes!)
           (let* ([signatures (sexpr->signatures expr)])
             (traverse add-to-table signatures))
           (traverse relabel expr))
         (define (sexpr->signatures sexpr)
           (let* ([program (sexpr->program sexpr)]
                  [defs (program->abstractions program)]
                  [names (map abstraction->name defs)]
                  [vars (map abstraction->vars defs)])
             (map pair names vars))))