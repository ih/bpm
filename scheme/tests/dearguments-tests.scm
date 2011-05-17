(import (dearguments)
        (srfi :78)
        (program)
        (util)
        (only (srfi :1) remove)
        (church readable-scheme))

;;;global test variables


(define same-variable-program (sexpr->program `(let () (define F1 (lambda (V1) ((lambda (V2) (node V1 V2)) (make-mixture-sexpr '(1 2))))) (node (F1 1) (F1 2)))))



;;;uniform-draw variables
;; (define uniform-target-abstraction (make-named-abstraction 'F1 '(node V1) '(V1)))
;; (define uniform-program (make-program (list uniform-target-abstraction) '(F1 (F1 1))))
;; (define uniform-correct-abstraction (make-named-abstraction 'F1 '((lambda (V1) (node V1)) ((uniform-draw (list (lambda () (F1)) (lambda () 1))))) '()))
;; (define uniform-correct-program (make-program (list uniform-correct-abstraction) '(F1)))


;;;uniform-replacement test
;; (check (uniform-replacement uniform-program uniform-target-abstraction 'V1 (find-variable-instances uniform-program uniform-target-abstraction 'V1)) => '((uniform-draw (list (lambda () (F1 1)) (lambda () 1)))))

;; ;don't draw over expressions that have variables, since these variables are in the scope of other functions
;; (let* ([abstraction1 (make-named-abstraction 'F1 '(node V1) '(V1))]
;;        [abstraction2 (make-named-abstraction 'F2 '(F1 V2) '(V2))]
;;        [program (make-program (list abstraction1 abstraction2) '(list (F1 2) (F2 4)))])
;;   (check (uniform-replacement uniform-program uniform-target-abstraction 'V1 (find-variable-instances program abstraction1 'V1)) => '((uniform-draw (list (lambda () 2))))))

;; ;case when there is no replacment
;; (let* ([abstraction1 (make-named-abstraction 'F1 '(node V1) '(V1))]
;;        [abstraction2 (make-named-abstraction 'F2 '(F1 V2) '(V2))]
;;        [program (make-program (list abstraction1 abstraction2) '(list (F2 4)))])
;;   (check (uniform-replacement uniform-program uniform-target-abstraction 'V1 (find-variable-instances program abstraction1 'V1)) => NO-REPLACEMENT))
;; ;;;remove-abstraction-variable
;; (let ([abstraction (make-named-abstraction 'F1 '((lambda (V1) (node V1)) ((uniform-draw (list (lambda () (F1 1)) (lambda () 1))))) '())])
;;  (check (remove-abstraction-variable uniform-replacement uniform-program uniform-target-abstraction 'V1) => abstraction))
;; ;;;deargument test
;; (check (deargument uniform-replacement uniform-program uniform-target-abstraction 'V1) => uniform-correct-program)
;; (check (remove even? '(0 7 8 8 43 -4)) => '(7 43))
;; (define uniform-draw-dearguments (make-dearguments-transformation uniform-replacement))
;; (check (uniform-draw-dearguments uniform-program #t) => (list uniform-correct-program))

;; ;;test for NO-REPLACMENT CASE
;; (let* ([abstraction1 (make-named-abstraction 'F1 '(node V1) '(V1))]
;;        [abstraction2 (make-named-abstraction 'F2 '(F1 V2) '(V2))]
;;        [program (make-program (list abstraction1 abstraction2) '(list (F2 4)))]
;;        [correct-program (sexpr->program '(let () (define F1 (lambda (V1) (node V1)))
;;                                               (define F2
;;                                                 (lambda ()
;;                                                   ((lambda (V2) (F1 V2))
;;                                                    ((uniform-draw (list (lambda () 4)))))))
;;                                               (list (F2))))])
;;   (check (uniform-draw-dearguments program #t) => (list correct-program)))


;;;noisy-number variables
(define noisy-number-target-abstraction (make-named-abstraction 'F1 '(node V1) '(V1 V2)))
(define noisy-number-program (make-program (list noisy-number-target-abstraction) '(node (F1 1 2) (F1 1.1 2))))

;;(define noisy-node-program (make-program (list (make-named-abstraction 'F1 '(data (label V1) (radius V2) (blobbiness V3) (Distance V4 0.5) (Straightness 0 0.1)) '(V1 V2 V3 V4))) '(lambda () ((uniform-draw (list (lambda () (N (F1 1 10 3.5 5) (N (F1 2 5 3.5 3) (N (F1 3 2 3.5 2) (N (F1 4 5 10 5)) (N (F1 5 5 10 5))))))))))))
;;;noisy-number-replacement
;; (check (noisy-number-replacement noisy-number-program noisy-number-target-abstraction 'V1 (find-variable-instances noisy-number-program noisy-number-target-abstraction 'V1)) => `(gaussian ,(my-mean (list 1 1.1)) ,(my-variance (list 1 1.1))))

;;;noisy-number test
;; (define noisy-number-dearguments (make-dearguments-transformation noisy-number-replacement))
;; (let* ([correct-abstraction (make-named-abstraction 'F1 `((lambda (V1) (node V1)) (gaussian ,(my-mean (list 1 1.1)) ,(my-variance (list 1 1.1)))) '())]
;;        [correct-program (make-program (list correct-abstraction) '(node (F1) (F1)))])
;;   (check (noisy-number-dearguments noisy-number-program #t) => (list correct-program)))



;;;same-variable test
;; (define same-var-test-abstraction (make-named-abstraction 'F1 '(node V1 V2 V3) '(V1 V2 V3)))
;; (define same-var-test-program (make-program (list same-var-test-abstraction) '(node (F1 1 1 3) (F1 2 2 1))))
;; (define correct-abstractionV1 (make-named-abstraction 'F1 '((lambda (V1) (node V1 V2 V3)) V2) '(V2 V3)))
;;;find-matching-variable
;; (check (find-matching-variable same-var-test-program same-var-test-abstraction (find-variable-instances same-var-test-program same-var-test-abstraction 'V3) '(V2 V1)) => NO-REPLACEMENT)

;; (check (find-matching-variable same-var-test-program same-var-test-abstraction (find-variable-instances same-var-test-program same-var-test-abstraction 'V1) '(V2 V3)) => 'V2)
;;;same-variable-replacement
;; (check (same-variable-replacement same-var-test-program same-var-test-abstraction 'V1 (find-variable-instances same-var-test-program same-var-test-abstraction 'V1)) => 'V2)
;;;deargument test
;; (define same-variable-dearguments (make-dearguments-transformation same-variable-replacement))
;; (let* ([correct-program (make-program (list correct-abstractionV1) '(node (F1 1 3) (F1 2 1)))]
;;        [correct-abstraction2 (make-named-abstraction 'F1 '((lambda (V2) (node V1 V2 V3)) V1) '(V1 V3))]
;;        [correct-program2 (make-program (list correct-abstraction2) '(node (F1 1 3) (F1 2 1)))])
;;   (check (same-variable-dearguments same-var-test-program) => (list correct-program correct-program2)))

;;;remove-application-argument test
;; (let* ([newf1 (make-named-abstraction 'F1 '((lambda (V1) (+ V1 V2)) 2) '(V2))]
;;        [oldf1 (make-named-abstraction 'F1 '(+ V1 V2)  '(V1 V2))]
;;        [prog (make-program (list newf1) '(F1 2 (F1 2 (F1 2 3))))])
;;   (check (remove-application-argument prog oldf1 'V1) => (make-program (list newf1) '(F1 (F1 (F1 3))))))
;; ;;;recursion dearguments test
;; (define recursive-target-abstraction (make-named-abstraction 'F1 '(node V1) '(V1)))
;; (define recursive-program (make-program (list recursive-target-abstraction) '(F1 (F1 (F1 1)))))
;; (define non-recursive-program (make-program (list recursive-target-abstraction) '(F1 1)))
;; (define recursive-correct-abstraction (make-named-abstraction 'F1 `((lambda (V1) (node V1)) ((multinomial (list (lambda () (F1)) (lambda () 1)) (list ,(/ 2 3) ,(/ 1 3))))) '()))
;; (define recursive-correct-program (make-program (list recursive-correct-abstraction) '(F1)))

;; (check (recursion-dearguments recursive-program #t) => (list recursive-correct-program))
;; (check (recursion-dearguments non-recursive-program #t) => '())

;;;terminates?

;;recursion halts
(let* ([abstraction1 (make-named-abstraction 'F1 '((lambda (V1) (node (F2 V1 0.1) V2)) -7.315789473684211) '(V2))]
       [abstraction2 (make-named-abstraction 'F2 '(data (color (gaussian V3 25)) (size V4)) '(V3 V4))]
       [abstraction3 (make-named-abstraction 'F3 '(F1 (F1 (F1 (F1 (F1 (node (F2 V5 0.3) (node (F2 V6 0.3)) (node (F2 V7 0.3)))))))) '(V5 V6 V7))]
       [program (make-program (list abstraction1 abstraction2 abstraction3) '(lambda () ((uniform-draw (list (lambda () (node (F2 5e1 1) (F1 (F1 (F1 (F1 (F1 (F1 (F1 (F1 (F1 (F3 222.0 272.0 268.0)))))))))) (F3 168.0 126.0 145.0))))))))])
  (check (recursion-dearguments program) => '()))


(check-report)
(exit)

