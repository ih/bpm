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



(check-report)
(exit)