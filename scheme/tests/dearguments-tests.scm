(import (dearguments)
        (srfi :78)
        (program)
        (church readable-scheme))

;;;global test variables
(define recursive-program (sexpr->program '(let () (define F1 (lambda (V1) (node V1))) (F1 (F1 1)))))
(define noisy-number-program (sexpr->program '(let () (define F1 (lambda (V1) (node V1))) (node (F1 1) (F1 1.1)))))
(define same-variable-program (sexpr->program `(let () (define F1 (lambda (V1) ((lambda (V2) (node V1 V2)) (make-mixture-sexpr '(1 2))))) (node (F1 1) (F1 2)))))

;;;uniform-draw test
(define uniform-draw-deargument (make-deargument-transformation uniform-replacement))
(let* ([correct-abstraction (make-named-abstraction 'F1 '((lambda (V1) (node V1)) ((uniform-draw (list (lambda () (F1)) (lambda () 1))))) '())]
       [correct-program (make-program (list correct-abstraction) '(F1))])
 (check (uniform-draw-deargument recursive-program) => correct-program))

;;;noisy-number test
(define noisy-number-deargument (make-deargument-transformation noisy-number-replacement))
(let* ([correct-abstraction (make-named-abstraction 'F1 '((lambda (V1) (node V1)) (gaussian 1.05 0.05)) '())]
       [correct-program (make-program (list correct-abstraction) '(node (F1) (F1)))])
  (check (noisy-number-deargument noisy-number-program) => correct-program))

;;;same-variable test
(define same-variable-deargument (make-deargument-transformation same-variable-replacement))
(let* ([correct-abstraction (make-named-abstraction 'F1 `((lambda (V1) ((lambda (V2) (node V1 V2)) V1)) ,(make-mixture-sexpr '(1 2))) '())]
       [correct-program (make-program (list correct-abstraction) '(node (F1) (F1)))])
  (check (same-variable-deargument same-variable-deargument) => correct-program))