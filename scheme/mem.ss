;; memoization
(library (mem)
         (export mem)
         (import (except (rnrs) string-hash string-ci-hash)
                 (only (ikarus) set-car! set-cdr!)
                 (_srfi :1)
                 (_srfi :69)
                 (church readable-scheme)
                 (util))

         (define memtables '())

         (define (get/make-memtable f)
           (get/make-alist-entry memtables
                                 (lambda (k v) (set! memtables (pair (pair k v) memtables)))
                                 f
                                 (lambda () (make-hash-table equal?))))

         (define (mem f)
           (lambda args
             (let ([mt (get/make-memtable f)])
               (hash-table-ref mt
                               args
                               (lambda () (let ([val (apply f args)])
                                            (hash-table-set! mt args val)
                                            val))))))
)