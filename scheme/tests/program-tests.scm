(import (program)
        (srfi :78)
        (sym))
;;;size test
(let* ([program (sexpr->program '(let ()
                                   (define F8
                                     (lambda (V25) (list a (list a (list V25) (list V25)))))
                                   (define F8
                                     (lambda (V25) (list a (list a (list V25) (list V25)))))
                                   (uniform-draw (F8 b) (F8 c) (F8 d))))])
    (check (program-size program) => 23))

;;;make-named-abstraction test
(check (make-named-abstraction 'F1 '(+ V1 V2) '(V1 V2)) => '(abstraction F1 (V1 V2) (+ V1 V2)))

;;;program->abstraction-applications tests
(let* ([program (sexpr->program '(let ()
                                   (define F8
                                     (lambda (V25) (list 'a (list 'a (list V25) (list V25)))))
                                   (uniform-draw (F8 'b) (F8 'c) (F8 'd))))]
       [abstraction (define->abstraction '(define F8
                                            (lambda (V25) (list 'a (list 'a (list V25) (list V25))))))])
  (check (program->abstraction-applications program abstraction) => '((F8 'b) (F8 'c) (F8 'd))))

;;;program->replace-abstraction program new-abstraction
(let* ([program (sexpr->program '(let () (define F1 (lambda (V1) (node V1))) (F1 (F1 1))))]
       [new-abstraction (make-named-abstraction 'F1 '(let ([V1 ((uniform-draw (list (lambda () (F1 1)) (lambda () 1))))]) (node V1)) '())])
  (check (program->replace-abstraction program new-abstraction) => (make-program (list new-abstraction) '(F1 (F1 1)))))

;;;set-indices-floor tests
(let* ([expr '(+ (+ V1 V1) (+ V1 F3))]
       [none (set-indices-floor! expr)])
  (check (list (sym 'F) (sym 'V)) => '(F4 V2)))
;;;program+ tests
(check (make-program+ 'a 0 0 0 #t) => '(program+ a 0 0 0 #t))
(check (program+->program (make-program+ 'a 0 0 0 #t)) => 'a)
;;;has-variable
(check (has-variable? '(F1 (+ 2 V1))) => #t)
(check (has-variable? '(F1 (+ 2 3))) => #f)

;;;program->abstraction-pattern
(let* ([abstraction1 (make-named-abstraction 'F1 '((lambda (V1) (node (F2 V1 0.1) V2)) -7.315789473684211) '(V2))]
       [abstraction2 (make-named-abstraction 'F2 '(data (color (gaussian V3 25)) (size V4)) '(V3 V4))]
       [abstraction3 (make-named-abstraction 'F3 '(F1 (F1 (F1 (F1 (F1 (node (F2 V5 0.3) (node (F2 V6 0.3)) (node (F2 V7 0.3)))))))) '(V5 V6 V7))]
       [program (make-program (list abstraction1 abstraction2 abstraction3) '(lambda () ((uniform-draw (list (lambda () (node (F2 5e1 1) (F1 (F1 (F1 (F1 (F1 (F1 (F1 (F1 (F1 (F3 222.0 272.0 268.0)))))))))) (F3 168.0 126.0 145.0))))))))])
  (check (program->abstraction-pattern program 'F2) => '(data (color (gaussian V3 25)) (size V4))))


(check-report)
(exit)