(import (util)
        (srfi :78)
        (srfi :1)
        (abstraction-grammar))
;;;primitives test
(let* ([expr '(F1 (V1 V23) F5 V2)])
  (check (primitives expr) => '(F1 V1 V23 F5 V2)))
;;;all-subexprs
(let* ([expr '(F1 (V1 V23) F5 V2)])
  (check (all-subexprs expr) => '((F1 (V1 V23) F5 V2) F1 (V1 V23) F5 V2 V1 V23)))
;;;deep-find-all tests
(let* ([sexpr '(let ()
                 (define F8
                   (lambda (V25) (list 'a (list 'a (list V25) (list V25)))))
                 (uniform-draw (F8 (F8 'b)) (F8 'c) (F8 'd)))]
       [pred (lambda (sexpr)
               (if (non-empty-list? sexpr)
                 (if (equal? (first sexpr) 'F8)
                     #t
                     #f)
                 #f))])
  (check (deep-find-all pred sexpr) => '((F8 (F8 'b)) (F8 'b) (F8 'c) (F8 'd))))

;;;sexp-search

(let ([sexprs '((F8 (F8 'b)) (F8 'b) (F8 'c) (F8 'd))])
  (check (sexp-search rule-application? (lambda (x) (list (first x))) sexprs) => '((F8) (F8) (F8) (F8))))

;;;lambda-apply
(let* ([args '((2 3) (4 6))])
  (check (map-apply + args) => '(5 10)))

(check-report)