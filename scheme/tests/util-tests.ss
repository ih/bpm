(import (util)
        (srfi :78)
        (srfi :1)
        (program))
;;;primitives test
(let* ([expr '(F1 (V1 V23) F5 V2)])
  (check (primitives expr) => '(F1 V1 V23 F5 V2)))
;;;all-subexprs
(let* ([expr '(F1 (V1 V23) F5 V2)])
  (check (all-subexprs expr) => '((F1 (V1 V23) F5 V2) F1 (V1 V23) F5 V2 V1 V23)))

;;;deep-find test
(check (deep-find number? '(a (a (b c 5)))) => 5)
(check (deep-find number? '(a (a (b c q)))) => #f)
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

;;;transform-sexp
;; (let ([sexprs '((F8 (F8 'b)) (F8 'b) (F8 'c) (F8 'd))])
;;   (check (transform-sexp rule-application? (lambda (x) (list (first x))) sexprs) => '((F8) (F8) (F8) (F8))))

;;;lambda-apply
(let* ([args '((2 3) (4 6))])
  (check (map-apply + args) => '(5 10)))

;;;all-subexprs tests
(let ([expr '((+ (+ 2 2) (- 2 5)))])
  (check (all-subexprs expr) => '(((+ (+ 2 2) (- 2 5))) (+ (+ 2 2) (- 2 5)) (+ 2 2) (- 2 5))))

;;;unique-commutative-pairs tests
(let* ([subexprs '((+ (+ 2 2) (- 2 5)) (+ 2 2) (+ 2 2) (+ 2 2) (- 2 5))]
       [pair1 '((+ (+ 2 2) (- 2 5)) (+ 2 2))]
       [pair2 '((+ (+ 2 2) (- 2 5)) (- 2 5))]
       [pair3 '((+ 2 2) (+ 2 2))]
       [pair4 '((+ 2 2) (- 2 5))])
  (check (unique-commutative-pairs subexprs list) => (list pair1 pair2 pair3 pair4)))

;;null subexpression test
(check (unique-commutative-pairs '(() 3) list) => (list '(() 3)))


(check-report)
(exit)
