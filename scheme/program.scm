(library (program)
         (export func-symbol var-symbol size var? func? make-abstraction make-named-abstraction abstraction->name abstraction->vars abstraction->pattern abstraction->define abstraction->variable-position)
         (import (except (rnrs) string-hash string-ci-hash)
                 (church readable-scheme)
                 (sym)
                 (_srfi :1))

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

         )