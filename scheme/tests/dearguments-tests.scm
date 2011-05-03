(import (dearguments)
        (srfi :78)
        (program)
        (util)
        (church readable-scheme))

;;;global test variables


(define same-variable-program (sexpr->program `(let () (define F1 (lambda (V1) ((lambda (V2) (node V1 V2)) (make-mixture-sexpr '(1 2))))) (node (F1 1) (F1 2)))))

;;;uniform-draw variables
(define uniform-target-abstraction (make-named-abstraction 'F1 '(node V1) '(V1)))
(define uniform-program (make-program (list uniform-target-abstraction) '(F1 (F1 1))))
(define uniform-correct-abstraction (make-named-abstraction 'F1 '((lambda (V1) (node V1)) ((uniform-draw (list (lambda () (F1)) (lambda () 1))))) '()))
(define uniform-correct-program (make-program (list uniform-correct-abstraction) '(F1)))


;;;uniform-replacement test
(check (uniform-replacement (find-variable-instances uniform-program uniform-target-abstraction 'V1)) => '((uniform-draw (list (lambda () (F1 1)) (lambda () 1)))))
;;;remove-abstraction-variable
(let ([abstraction (make-named-abstraction 'F1 '((lambda (V1) (node V1)) ((uniform-draw (list (lambda () (F1 1)) (lambda () 1))))) '())])
 (check (remove-abstraction-variable uniform-replacement uniform-program uniform-target-abstraction 'V1) => abstraction))
;;;deargument test
(check (deargument uniform-replacement uniform-program uniform-target-abstraction 'V1) => uniform-correct-program)

(define uniform-draw-dearguments (make-dearguments-transformation uniform-replacement))
(check (uniform-draw-dearguments uniform-program #t) => (list uniform-correct-program))

;;;noisy-number variables
(define noisy-number-target-abstraction (make-named-abstraction 'F1 '(node V1) '(V1 V2)))
(define noisy-number-program (make-program (list noisy-number-target-abstraction) '(node (F1 1 2) (F1 1.1 2))))

(define noisy-node-program (make-program (list (make-named-abstraction 'F1 '(data (label V1) (radius V2) (blobbiness V3) (Distance V4 0.5) (Straightness 0 0.1)) '(V1 V2 V3 V4))) '(lambda () ((uniform-draw (list (lambda () (N (F1 1 10 3.5 5) (N (F1 2 5 3.5 3) (N (F1 3 2 3.5 2) (N (F1 4 5 10 5)) (N (F1 5 5 10 5))))))))))))
;;;noisy-number-replacement
(check (noisy-number-replacement (find-variable-instances noisy-number-program noisy-number-target-abstraction 'V1)) => `(gaussian ,(my-mean (list 1 1.1)) ,(my-variance (list 1 1.1))))

;;;noisy-number test
(define noisy-number-dearguments (make-dearguments-transformation noisy-number-replacement))
(let* ([correct-abstraction (make-named-abstraction 'F1 `((lambda (V1) (node V1)) (gaussian ,(my-mean (list 1 1.1)) ,(my-variance (list 1 1.1)))) '())]
       [correct-program (make-program (list correct-abstraction) '(node (F1) (F1)))])
  (check (noisy-number-dearguments noisy-number-program #t) => (list correct-program)))



;; ;;;same-variable test
;; (define same-variable-dearguments (make-dearguments-transformation same-variable-replacement))
;; (let* ([correct-abstraction (make-named-abstraction 'F1 `((lambda (V1) ((lambda (V2) (node V1 V2)) V1)) ,(uniform-replacement '(1 2))) '())]
;;        [correct-program (make-program (list correct-abstraction) '(node (F1) (F1)))])
;;   (check (same-variable-deargument same-variable-deargument) => (list correct-program)))
(check-report)
(exit)