#!r6rs
;;lazy functions
(library (lazy)
         (export lazy-list lazy-pair? lazy-pair lazy-equal? lazy-list->list list->lazy-list lazy-null? lazy-append lazy-null lazy-length compute-depth lazy-list->all-list lazy-remove lazy-repeat lazy-map lazy-first lazy-rest lazy-list-size)
         (import (rnrs)
                 (util)
                 (noisy-number)
                 (church readable-scheme))
         (define lazy-null '())
         (define lazy-null? null?)
         (define (lazy-pair a b) (lambda (tag) (if (eq? tag 'first) a (if (eq? tag 'rest) b 'lazy-pair))))
         (define (lazy-first l-pair)
           (l-pair 'first))
         (define (lazy-rest l-pair)
           (l-pair 'rest))
         (define (lazy-pair? a) (if (procedure? a) (eq? 'lazy-pair (a 'type?)) false))

         (define lazy-list (lambda args (if (pair? args) (lazy-pair (first args) (apply lazy-list (rest args))) args)))


         ;;returns false if finds missmatch, otherwise returns amount of sexprs matched.
         (define (seq-sexpr-equal? t1 t2 depth eq-policy)
           (if (= depth 0)
               0
               (if (and (lazy-pair? t1) (lazy-pair? t2))
                   (let ((left (seq-sexpr-equal? (t1 'first) (t2 'first) (- depth 1) eq-policy)))
                     (if (eq? false left)
                         false
                         (seq-sexpr-equal? (t1 'rest) (t2 'rest) left eq-policy)))
                   (if (eq-policy t1 t2)
                       (- depth 1)
                       false))))

         (define (sexpr-equal? t1 t2 eq-policy)
           (if (and (lazy-pair? t1) (lazy-pair? t2))
               (and (sexpr-equal? (t1 'first) (t2 'first) eq-policy)
                    (sexpr-equal? (t1 'rest) (t2 'rest) eq-policy))
               (eq-policy t1 t2)))

         ;;opt-args can be depth/depth equal function/equal function
         (define (lazy-equal? a b . opt-args)
           (let ([depth (parse-opt-depth opt-args)]
                 [eq-policy (parse-opt-equality opt-args)])
            (if (null? depth)
                (sexpr-equal? a b eq-policy)
                (not (eq? false (seq-sexpr-equal? a b depth eq-policy))))))

         ;;assumes if an equality function was passed in it was the second argument
         (define (parse-opt-equality opt-args)
           (cond [(null? opt-args) equal?]
                 [(and (= (length opt-args) 1) (number? (first opt-args))) equal?]
                 [(= (length opt-args) 1) (first opt-args)]
                 [else (second opt-args)]))

         ;;assumes if a depth is passed it is the first argument
         (define (parse-opt-depth opt-args)
           (cond [(null? opt-args) opt-args]
                 [(number? (first opt-args)) (first opt-args)]
                 [else '()]))


         (define (lazy-all-equal? lazy-lst1 lazy-lst2)
           (let ([lst1 (lazy-list->all-list lazy-lst1)]
                 [lst2 (lazy-list->all-list lazy-lst2)])
                   (equal? lst1 lst2)))
                      
         (define (lazy-list->all-list lazy-lst)
           (if (not (lazy-pair? lazy-lst))
               lazy-lst
               (let* ([left (lazy-list->all-list (lazy-lst 'first))]
                      [right (lazy-list->all-list (lazy-lst 'rest))])
                 (pair left right))))

         (define (compute-depth lazy-lst)
           (if (not (lazy-pair? lazy-lst))
               2
               (let* ([left (compute-depth (lazy-lst 'first))]
                      [right (compute-depth (lazy-lst 'rest))])
                 (+ left right))))

         (define (lazy-list-size a)
           (if (lazy-pair? a)
               (+ 1 (lazy-list-size (a 'first)) (lazy-list-size (a 'rest)))
               1))


         (define (lazy-append lazy-lst1 lazy-lst2)
           (if (lazy-null? lazy-lst1)
               lazy-lst2
               (lazy-pair (lazy-lst1 'first) (lazy-append (lazy-lst1 'rest) lazy-lst2))))

         (define (lazy-repeat reps thunk)
           (if (= reps 0)
               lazy-null
               (lazy-pair (thunk) (lazy-repeat (- reps 1) thunk))))

         (define (lazy-map proc lazy-lst)
           (if (lazy-null? lazy-lst)
               lazy-null
               (lazy-pair (proc (lazy-lst 'first)) (lazy-map proc (lazy-lst 'rest)))))

         
         (define (lazy-length lazy-lst)
           (if (null? lazy-lst)
               0
               (+ 1 (lazy-length (lazy-lst 'rest)))))

         (define (list->lazy-list lst)
           (if (pair? lst)
               (apply lazy-list (map list->lazy-list lst))
               lst))

         (define (lazy-remove item lazy-lst)
           (if (not (lazy-pair? lazy-lst))
               lazy-lst
               (if (lazy-all-equal? (lazy-lst 'first) item)
                   (lazy-remove item (lazy-lst 'rest))
                   (lazy-pair (lazy-lst 'first) (lazy-remove item (lazy-lst 'rest))))))
  ;;        (define (lazy-uniform-draw lazy-lst)
  ;; (lazy-list-ref lazy-lst (random-from-range 0 (- (lazy-length lazy-lst) 1))))

         (define (lazy-list-ref lazy-lst indx)
           (if (= indx 0)
               (if (lazy-pair? lazy-lst)
                   (lazy-lst 'first)
                   lazy-lst)
               (lazy-list-ref (lazy-lst 'rest) (- indx 1))))
         
         (define (lazy-list->list a depth)
           (if (= 0 depth)
               (pair 'unf 0)
               (if (lazy-pair? a)
                   (let* ((left (lazy-list->list (a 'first) (- depth 1)))
                          (right (lazy-list->list (a 'rest) (rest left))))
                     (pair (pair (first left) (first right)) (rest right)))
                   (pair a (- depth 1))))))
