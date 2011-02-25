;; unique readable symbols. this is used to enumerate lists and to
;; generate readable variable names.
(library (sym)
         (export sym reset-symbol-indizes! set-symbol-index!)
         (import (except (rnrs) string-hash string-ci-hash)
                 (only (ikarus) set-car! set-cdr!)
                 (_srfi :1)
                 (_srfi :69)
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

)

