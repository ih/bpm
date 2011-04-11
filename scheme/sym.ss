;; unique readable symbols. this is used to enumerate lists and to
;; generate readable variable names.
(library (sym)
         (export sym reset-symbol-indizes! set-symbol-index! raise-tagged! max-index tag-match? find-tagged-symbols)
         (import (except (rnrs) string-hash string-ci-hash)
                 (only (ikarus) set-car! set-cdr!)
                 (_srfi :1)
                 (_srfi :69)
                 (only (srfi :13) string-drop string-take string-length)
                 (church readable-scheme)
                 (util))

         (define symbol-indizes '())

         (define (reset-symbol-indizes!) (set! symbol-indizes '()))

         (define (get-symbol-index-container tag)
           (get/make-alist-entry symbol-indizes
                                 (lambda (k v) (set! symbol-indizes (pair (pair k v) symbol-indizes)))
                                 tag
                                 (lambda () (list 0))))

         (define (get-symbol-index tag)
           (first (get-symbol-index-container tag)))

         (define (set-symbol-index! tag new-index)
           (let ([tag-index-container (get-symbol-index-container tag)])
             (set-car! tag-index-container new-index)))

         (define (inc-symbol-index! tag)
           (let ([tag-index-container (get-symbol-index-container tag)])
             (set-car! tag-index-container (+ (first tag-index-container) 1))))

         (define (sym tag)
           (inc-symbol-index! tag)
           (string->symbol (string-append (symbol->string tag)
                                          (number->string (get-symbol-index tag)))))

         
         (define (raise-tagged! tag tagged-symbols)
           (if (null? tagged-symbols)
               #f
               (let ([largest-index (max-index tag tagged-symbols)])
                 (set-symbol-index! tag largest-index))))
         (define (max-index tag tagged-symbols)
           ;;get-index is implemented as get-symbol-index in the sym library
           (define (get-index tagged-symbol) 
             (string->number (string-drop (symbol->string tagged-symbol) (length (string->list (symbol->string tag))))))
           (apply max (map get-index tagged-symbols)))

         ;;assumes tag is actually in symbol-indizes, better to explicitly check
         (define (tag-match? tag expr)
             (if (symbol? expr)
                 (let* ([tag-string (symbol->string tag)]
                        [tag-length (string-length tag-string)]
                        [expr-string (symbol->string expr)])
                   (if (< (string-length expr-string) tag-length)
                       #f
                       (equal? (string-take expr-string tag-length) tag-string)))
                 #f))

         (define (find-tagged-symbols expr tag)
           (filter (curry tag-match? tag) (primitives expr))))

