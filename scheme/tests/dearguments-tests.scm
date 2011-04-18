(import (dearguments)
        (srfi :78)
        (program)
        (church readable-scheme))

;;;global test variables

(define noisy-number-program (sexpr->program '(let () (define F1 (lambda (V1) (node V1))) (node (F1 1) (F1 1.1)))))
(define same-variable-program (sexpr->program `(let () (define F1 (lambda (V1) ((lambda (V2) (node V1 V2)) (make-mixture-sexpr '(1 2))))) (node (F1 1) (F1 2)))))

;;;uniform-draw variables
(define uniform-target-abstraction (make-named-abstraction 'F1 '(node V1) '(V1)))
(define uniform-program (make-program (list uniform-target-abstraction) '(F1 (F1 1))))
(define uniform-correct-abstraction (make-named-abstraction 'F1 '((lambda (V1) (node V1)) ((uniform-draw (list (lambda () (F1)) (lambda () 1))))) '()))
(define uniform-correct-program (make-program (list correct-abstraction) '(F1)))


;;;remove-abstraction-variable
(check (remove-abstraction-variable uniform-replacement uniform-program uniform-target-abstraction 'V1) => uniform-correct-abstraction)
;;;deargument test
(check (deargument uniform-replacement uniform-program uniform-target-abstraction 'V1) => uniform-correct-program)

(define uniform-draw-dearguments (make-dearguments-transformation uniform-replacement))
(check (uniform-draw-dearguments uniform-program) => (list uniform-correct-program))

;;;noisy-number test
(define noisy-number-dearguments (make-dearguments-transformation noisy-number-replacement))
(let* ([correct-abstraction (make-named-abstraction 'F1 '((lambda (V1) (node V1)) (gaussian 1.05 0.05)) '())]
       [correct-program (make-program (list correct-abstraction) '(node (F1) (F1)))])
  (check (noisy-number-deargument noisy-number-program) => (list correct-program)))

;;;same-variable test
(define same-variable-dearguments (make-dearguments-transformation same-variable-replacement))
(let* ([correct-abstraction (make-named-abstraction 'F1 `((lambda (V1) ((lambda (V2) (node V1 V2)) V1)) ,(make-mixture-sexpr '(1 2))) '())]
       [correct-program (make-program (list correct-abstraction) '(node (F1) (F1)))])
  (check (same-variable-deargument same-variable-deargument) => (list correct-program)))