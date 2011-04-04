(import (internalize-arguments)
        (srfi :78)
        (abstract)
        (church readable-scheme))

;;;has-arguments?
(check (has-arguments? (make-named-abstraction 'F1 '(node V1) '(V1))) => #t)
;;;find-variable-instances
(let* ([program (sexpr->program '(let () (define F1 (lambda (V1) (node V1))) (F1 (F1 1))))]
       [abstraction (make-named-abstraction 'F1 '(node V1) '(V1))])
  (check (find-variable-instances program abstraction 'V1) => '((F1 1) 1)))
;;;thunkify
(check (thunkify '(F1 1)) => '(lambda () (F1 1)))
;;;make-mixture-sexpr
(check (make-mixture-sexpr '((F1 1) 1)) => '((uniform-draw  (list (lambda () (F1 1)) (lambda () 1)))))

(check (eval (make-mixture-sexpr '(1)) (interaction-environment)) => 1)
;;;remove-abstraction-variable
(let* ([program (sexpr->program '(let () (define F1 (lambda (V1) (node V1))) (F1 (F1 1))))]
       [abstraction (make-named-abstraction 'F1 '(node V1) '(V1))])
    (check (remove-abstraction-variable program abstraction 'V1) => (make-named-abstraction 'F1 '(let ([V1 ((uniform-draw (list (lambda () (F1 1)) (lambda () 1))))]) (node V1)) '())))
;;;remove-ith-argument tests
(check (remove-ith-argument 1 '(F1 3 4 5)) => '(F1 3 5))
(check (remove-ith-argument 0 '(F1 3)) => '(F1))

;;;change-applications
(let* ([new-abstraction (make-named-abstraction 'F1 '(let ([V1 ((uniform-draw (list (lambda () (F1 1)) (lambda () 1))))]) (node V1)) '())]
       [program (make-program (list new-abstraction) '(F1 (F1 1)))]
       [old-abstraction (make-named-abstraction 'F1 '(node V1) '(V1))])
  (check (remove-application-argument program old-abstraction 'V1) => (sexpr->program '(let () (define F1 (lambda () (let ([V1 ((uniform-draw (list (lambda () (F1)) (lambda () 1))))]) (node V1)))) (F1))))
  ;; ;;;internalize-argument
  ;; (let* ([program (sexpr->program '(let () (define F1 (lambda (V1) (node V1))) (F1 (F1 1))))]
  ;;        [abstraction (make-named-abstraction 'F1 '(node V1) '(V1))])
  ;;   (check (internalize-argument program abstraction 'V1) => (sexpr->program '(let () (define (F1) (let ([V1 ((uniform-draw (list (lambda () (F1)) (lambda () 1))))]) (list V1)) ) (F1)))))

  ;; ;;;abstraction-internalizations
  ;; (let* ([program (sexpr->program '(let () (define F1 (lambda (V1) (node V1))) (F1 (F1 1))))]
  ;;        [abstraction (make-named-abstraction 'F1 '(node V1) '(V1))])
  ;;  (check (abstraction-internalizations program abstraction) => '((let () (define (F1) (let ([x ((uniform-draw (list (lambda () 1) (lambda () (F1)))))]) (list x)) ) (F1)))))

  ;; ;;;internalize-arguments
  ;; (check (internalize-arguments (sexpr->program '(let () (define F1 (lambda (V1) (node V1))) (F1 (F1 1)))))
  ;;        =>
  ;;        '((let () (define (F1) (let ([x ((uniform-draw (list (lambda () 1) (lambda () (F1)))))]) (list x)) ) (F1))))

  (check-report))
(exit)