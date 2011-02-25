#!r6rs
;;TO DO
;;-adjust tree-apply-proc to not be dependent on * as a masking character
;;-use data abstraction for location in tree-apply-proc
(library (util)
         (export all-equal? all-assoc curry all max-take sexp-replace sexp-search get/make-alist-entry rest pair random-from-range depth tree-apply-proc primitive?)
         (import (except (rnrs) string-hash string-ci-hash)
                 (only (ikarus) set-car! set-cdr!)
                 (_srfi :1)
                 (_srfi :69)
                 (scheme-tools repl)
                 (church readable-scheme))

         (define (all-equal? lst)
           (all (map (lambda (itm) (equal? (first lst) itm)) (rest lst))))

         (define (all-assoc alist key)
           (filter (lambda (entry) (equal? (first entry) key)) alist))

         (define (curry fun . const-args)
           (lambda args
             (apply fun (append const-args args))))

         (define (all lst)
           (if (null? lst)
               #t
               (and (first lst)
                    (all (rest lst)))))

         (define (max-take lst n)
           (if (<= (length lst) n)
               lst
               (take lst n)))
         ;;if abstract.ss stops working replace sexp-replace in abstract.ss w/ a function leaf replace (sexp-replace before it was modified to the current version)
         (define (sexp-replace old new sexp)
           (if (equal? old sexp)
               new
               (if (list? sexp)
                   (map (curry sexp-replace old new) sexp)
                   sexp)))
               

         (define (sexp-search pred? func sexp)
           (if (list? sexp)
               (map (curry sexp-search pred? func) sexp)
               (if (pred? sexp) (func sexp) sexp)))

                  ;; look up value for key in alist; if not found,
         ;; set (default-thunk) as value and return it
         (define (get/make-alist-entry alist alist-set! key default-thunk)
           (let ([binding (assq key alist)])
             (if binding
                 (rest binding)
                 (let* ([default-val (default-thunk)])
                   (alist-set! key default-val)
                   default-val))))

         (define (random-from-range a b)
           (+ (random-integer (+ (- b a) 1)) a))

         (define (primitive? expr)
           (or (symbol? expr) (boolean? expr) (number? expr)))

           

         (define (depth tree)
           (if (or (not (list? tree)) (null? tree))
               0
               (+ 1 (apply max (map depth tree)))))

         ;;this function copies a tree, but applies proc to the tree at the passed in location.  
         (define (tree-apply-proc proc location tree)
           (define (build-mask location number-of-branches)
             (define (substitute indx value lst)
               (if (= indx 0)
                   (pair value (rest lst))
                   (pair (first lst) (substitute (- indx 1) value (rest lst)))))
             (let ([mask (make-list number-of-branches '*)]
                   [index (- (first location) 1)])
               (if (= (length location) 1)
                   (substitute index '() mask)
                   (substitute index (rest location) mask))))
           
           (cond [(null? tree) tree]
                 [(null? location) (proc tree)]
                 [(eq? location '*) tree]
                 [else
                  (let ([location-mask (build-mask location (length (rest tree)))])
                    (pair (first tree) (map (curry tree-apply-proc proc) location-mask (rest tree))))])))

