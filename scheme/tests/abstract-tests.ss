#!r6rs
;;TODO:
;;- figure out a good way to test a library w/o exporting all the functions
(import (abstract)
        (program)
        (srfi :78)
        (srfi :69)
        (sym)
        (util)
        (unification))
;;;test definitions
(define (test-beam-search-compressions sexpr)
  (for-each display (list "original expr:\n" sexpr "\n"
                          "size: " (size sexpr)
                          "\n\n"
                          "compressed exprs:\n"))
  (map pretty-print-program
       (sort-by-size
        (unique-programs
         (beam-search-compressions 10 (make-program '() sexpr))))))

(define (test-compressions name compressing-function sexpr)
  (for-each display (list name
                          "\noriginal expr:\n" sexpr "\n"
                          "size: " (size sexpr)
                          "\n\n"
                          "compressed exprs:\n"))
  (map pretty-print-program
       (sort-by-size
        (unique-programs
         (compressing-function (make-program '() sexpr))))))



;;;find-*-symbols test
(let* ([expr '(F1 (V1 V23) F5 V2)])
  (check (find-tagged-symbols expr (func-symbol)) => '(F1 F5)))

(let* ([expr '(F1 (V1 V23) F5 V2)])
  (check (find-tagged-symbols expr (var-symbol)) => '(V1 V23 V2)))
;;;set-indices-floor tests
(let* ([expr '(+ (+ V1 V1) (+ V1 F3))]
       [none (set-indices-floor! expr)])
  (check (list (sym 'F) (sym 'V)) => '(F4 V2)))


;;;internalize-arguments test
;; (let* ([correct-abstraction (make-named-abstraction 'F1 '(let ([V1 ((uniform-draw (list (lambda () (F1)) (lambda () 1))))]) (node V1)) '())]
;;          [correct-program (make-program (list correct-abstraction) '(F1))])
;;     (check (internalize-arguments (sexpr->program '(let () (define F1 (lambda (V1) (node V1))) (F1 (F1 1)))))
;;           =>
;;           (list correct-program)))

;; (let* ([correct-abstraction (make-named-abstraction 'F1 '(let ([V1 ((uniform-draw (list (lambda () (F1)) (lambda () 1))))]) (node V1)) '())]
;;          [correct-program (make-program (list correct-abstraction) '(F1))])
;;     (check (internalize-arguments (make-program '() '(node (node 1))))
;;           =>
;;           '()))

;;;similarity-replacement test
;; (define alphabet (alist->hash-table '((a . 1) (b . 2) (c . 3) (d . 4) (e . 5))))
;; (define (alphabet-distance c1 c2)
;;   (let ([c1 (hash-table-ref alphabet c1)]
;;         [c2 (hash-table-ref alphabet c2)])
;;     (abs (- c1 c2))))
;; (define (threshold c1 c2)
;;   (< (alphabet-distance c1 c2) 2))
;; (define (alphabet? expr)
;;   (member expr (hash-table-keys alphabet)))
;; (define (make-replacement c1 c2)
;;   (list 'uniform-draw (list 'list c1 c2)))


;; (let* ([similarity-replacement (make-similarity-transform alphabet-distance threshold alphabet? make-replacement)]
;;        [program (make-program '() '(node a (node b (node c) (node a))))])
;;   (check (similarity-replacement node a)))
(check-report)
;; (define (test-unify)
;;   (let* ([sexpr '(a b c d)]
;;          [pattern '(A b c A)] 
;;          [variables '(A B)]) 
;;     (pretty-print (unify sexpr pattern variables))))

;; ;;((A . a)) correct output?!
;; (define (test-self-matching)
;;   (let* ([test-tree '(((u) b y (a (b (c d e)) f g) x (a c))
;;                       ((i) b z (a (b (c d e)) f g) x (a d)) f)]
;;          [enum-test-tree (enumerate-tree test-tree)])
;;     (for-each display
;;               (list "test-tree: " test-tree "\n"
;;                     "enumerated test-tree: " enum-test-tree "\n\n"))
;;     (map pretty-print-match
;;          (filter (lambda (m) (third m))
;;                  (self-matches enum-test-tree)))))

;; (define (test-match-replacement)
;;   (let* ([test-tree '(e f ((d (a b c)) b c) g h (e f (q q)))]
;;          [abstraction (make-abstraction '(X b Y) '(X Y))]
;;          [abstraction2 (make-abstraction '(e f Z) '(Z))])
;;     (pretty-print (replace-matches test-tree abstraction))
;;     (pretty-print (replace-matches test-tree abstraction2))))


;;;displays all the compressions created by compressing function, compressing-function takes a program and returns a list of compressions


;;(test-compressions "simple compression" compressions '((node '(a 20)) (node '(a 20)) (node '(a 20)) (node '(a 20))))

;;(test-beam-search-compressions '((a (a (b) (b))) (a (a (c) (c))) (a (a (d) (d)))))

;; (test-compressions "floating point test" compressions
;;                    '(n .3))


;; (test-compressions "new node" compressions
;;                    '(N3 ((radius 0.6) (blobbiness -0.2) (Distance 2 0.1) (Straightness 0 0.1))))

;; (test-beam-search-compressions '(list 'n1 (list 1.2 -.2 (list 2 .1) (list 0 0.1)) 
;;   (list 'n1 (list .8 -.1 (list 3 .1) (list 0 .1))
;;     (list 'n1 (list .6 -.2 (list 2 .1) (list 0 .1))
;;           (list 'n1 (list .6 -.2 (list 2 .1) (list 0 .1)))))))

;; (test-beam-search-compressions '(((1.2) (-0.2) (2 0.1) (0 0.1))
;;                                              (((0.8) (-0.1) (3 0.1) (0 0.1))
;;                                               (((0.6) (-0.2) (2 0.1) (0 0.1))))))
;; (test-beam-search-compressions '(uniform-draw (list a (list a (list b) (list b)))
;;  (list a (list a (list c) (list c)))
;;  (list a (list a (list d) (list d)))))

;; (test-beam-search-compressions '((list 'a (list 'a (list 'b) (list 'b)))
;;  (list 'a (list 'a (list 'c) (list 'c)))
;;  (list 'a (list 'a (list 'd) (list 'd)))))
;; (test-compressions "new node" compressions
;;                    '(GN2 
;;                      (GN1
;;                       (N1 ((radius 1.2) (blobbiness -0.2) (Distance 2 0.1) (Straightness 0 0.1))
;;                           (N2 ((radius 0.8) (blobbiness -0.1) (Distance 3 0.1) (Straightness 0 0.1))
;;                               (N3 ((radius 0.6) (blobbiness -0.2) (Distance 2 0.1) (Straightness 0 0.1))))))))

;;(test-beam-search-compressions '(list (list a (list a)) (list a (list a (list a (list a)))) (list a (list a (list a)))))
;;(test-beam-search-compressions '((list a (list b (list d) (list d))) (list a (list b (list c) (list c)))))

;; (test-compressions "recursion" compressions '(uniform-draw (list (list a (list a)) (list a (list a (list a (list a)))) (list a (list a (list a))) (list a) (list a (list a (list a (list a (list a (list a)))))))))

;;(test-compressions "simple compression" compressions '((node (a 20)) (node (a 20)) (node (a 20)) (node (a 20))))
;; (test-compressions "compressions" compressions '((f (f (f (f x)))) (f (f (f (f x)))) (f (f (f (f x)))) (g (f (f (f x))))))
;; (test-compressions "all-compressions" all-compressions '((f (f (f (f x)))) (f (f (f (f x)))) (f (f (f (f x)))) (g (f (f (f x))))))

;; (define (test-redundant-variables)
;;   (let* ([tabs (make-abstraction '(+ A B C D) '(A B C D))]
;;          [test-trees '((+ a b b a) (+ q d d q) (+ f m m f))])
;;     ;;         [test-trees '((+ 2 3 3 2) (+ 4 5 5 4) (+ 6 1 1 6))])
;;     (map (lambda (x) (replace-matches x tabs)) test-trees)
;;     (pretty-print test-trees)    
;;     (pretty-print tabs)
;;     (pretty-print (remove-redundant-variables tabs))))


;; ;; the expression should have a pattern with repeated variables
;; (define (test-repeated-variable-pattern)
;;   (let* ([expr '(+ (+ a b a) (+ c d c))]
;;          [et (enumerate-tree expr)])
;;     (pretty-print (self-matches et))))

;; (define (test-capture-vars)
;;   (pretty-print (capture-vars (make-abstraction '(v1 v2 (f a v3)) '(v3)))))

;; ;; (test-capture-vars)


;; (define (test-instantiate-pattern)
;;   (let ([abstraction (make-named-abstraction 'F '(+ a a (+ b c)) '(a c))]
;;         [sexpr '(F 3 4)])
;; ;;    (pretty-print (replace-var (abstraction->pattern abstraction) '(a 3)))))
;;     (pretty-print (instantiate-pattern sexpr abstraction))))

;; (define (test-inline)
;;   (let* ([a1 (make-named-abstraction 'F '(+ a (G 99 100) (+ b c)) '(a c))]
;;          [a2 (make-named-abstraction 'G '(* (F 2 1) (+ q q) c a) '(a c))]
;;          [body '(+ (F 3 4) (* (G (F 20 30) 8) (G 9 10)))]
;;          [program (make-program (list a1 a2) body)])
;;     (pretty-print (inline program .5))))

        
;; ;;(test-inline)
;; ;;(recursive? '(f (f x)))
;;;compression test for sexpr without comrpessions
;;(test-beam-search-compressions '('a))

;;(beam-compression '('a) 2)
;;(test-beam-search-compressions '((f (f (f (f x)))) (f (f (f (f x)))) (f (f (f (f x)))) (g (f (f (f x))))))
;;(display (beam-compression '((f (f (f (f x)))) (f (f (f (f x)))) (f (f (f (f x)))) (g (f (f (f x))))) 2))
;; ;; (test-repeated-variable-pattern)
;; ;; (test-beam-search-compressions '((f (f (f (f (f (f (f (f (f (f (f (f x))))))))))))))
;; ;;(test-beam-search-compressions '((h (m (h (m (h (m (h (m (c))))))))) (h (m (h (m (h (m (c))))))) (h (m (h (m (c))))) (h (m (c))) (f (f (f (f (f (f (f (f (f (f (f (f x))))))))))))))
;; ;; (test-beam-search-compressions '(f (a x) (f (a x) (f (a x) b (a x)) (a x)) (a x)))
;; ;; (test-beam-search-compressions '(f (a b (x y (u k l)))
;; ;;                       (a b c)
;; ;;                       (a b (z d (u k l)))
;; ;;                       (a b c)))
;; ;; (test-beam-search-compressions '(a (a (foo bar) b) (a (bar foo) b) (a (bzar fzoo) b)))
;; ;;(test-beam-search-compressions '(f (a x) (f (a x) (f (a x) b (a x)) (a x)) (a x)))
;; ;; (test-beam-search-compressions '(k (h (g (f (a b (x y (u k l)))
;; ;;                               (a b c)
;; ;;                               (a b (z d (u k l)))
;; ;;                               (a b c))
;; ;;                            (f (a b (x y (u k l)))
;; ;;                               (a b c)
;; ;;                               (a b (z d (u k l)))
;; ;;                               (a b c)))
;; ;;                         (g (f (a b (x y (u k l)))
;; ;;                               (a b c)
;; ;;                               (a b (z d (u k l)))
;; ;;                               (a b c))
;; ;;                            (f (a b (x y (u k l)))
;; ;;                               (a b c)
;; ;;                               (a b (z d (u k l)))
;; ;;                               (a b c))))
;; ;;                      (h (g (f (a b (x y (u k l)))
;; ;;                               (a b c)
;; ;;                               (a b (z d (u k l)))
;; ;;                               (a b c))
;; ;;                            (f (a b (x y (u k l)))
;; ;;                               (a b c)
;; ;;                               (a b (z d (u k l)))
;; ;;                               (a b c)))
;; ;;                         (g (f (a b (x y (u k l)))
;; ;;                               (a b c)
;; ;;                               (a b (z d (u k l)))
;; ;;                               (a b c))
;; ;;                            (f (a b (x y (u k l)))
;; ;;                               (a b c)
;; ;;                               (a b (z d (u k l)))
;; ;;                               (a b c))))))

;; ;;(test-beam-search-compressions '((f (f (f (f x)))) (g (g (g (g x))))))

;; (define (test-proposal)
;;   (let ([init (make-program '() '(+ (+ (+ a a a) (+ c c c) (+ d d d)) (f (f (f (f (f (f (f (f (f (f (f (+ a a a)))))))))))) (+ a a a)))])
;;     (define (random-walk steps program)
;;       (let* ([proposed (proposal program)]
;;              [next-program (first proposed)])
;;         (pretty-print proposed)
;;         (if (= 0 steps)
;;             program
;;             (random-walk (- steps 1) next-program))))
;;     (random-walk 10 init)))

;; (test-proposal)
;; ;;(test-inline)

;; (define (test-recursion-abstraction?)
;;   (let ([r (make-recursion-abstraction '(f 0))]
;;         [a (make-named-abstraction 'G '(* (F 2 1) (+ q q) c a) '(a c))])
;;     (pretty-print r)
;;     (pretty-print (recursion-abstraction? r))
;;     (pretty-print (recursion-abstraction? a))))

;; ;;(test-recursion-abstraction?)

;; (define (test-higher-order-inline)
;;   (let* ([a1 (make-named-abstraction 'G '(* (f 3) x) '(f x))]
;;          [a2 (make-named-abstraction 'F '(+ x x x) '(x))]
;;          [body '(+ (G F 5) (F 84))]
;;          [program (make-program (list a1 a2) body)])
;;     (pretty-print (inline program .5))))
        
;; ;;(test-higher-order-inline)
  
;; (define (test-inline-recursion)
;;   (let ([r (make-recursion-abstraction '(f 0))])
;;     (pretty-print (inline-recursion r))))

;; ;;(test-inline-recursion)
(exit)