(library (testing)
         (export test-expr trivial-expr test-exprs e1)
         (import (except (rnrs) string-hash string-ci-hash)
                 (util)
                 (_srfi :1)
                 (_srfi :69)
                 (sym)
                 (abstract)
                 (util)
                 (church readable-scheme))


         (define (mean lst) (/ (apply + lst) (length lst)))

         

         (define (test-expr) '(let () (if (if #t #t #t) (if #t #t #t) (if #t #t #t))))

         (define (e1) '(let () (define F1 (lambda (v1) (if v1 v1 v1))) (F1 (F1 #t))))
         (define (test-exprs) '((let () (if (if #t #t #t) (if #t #t #t) (if #t #t #t)))
                                (let () (define F1 (lambda () (if #t #t #t))) (if (F1) (F1) (F1)))
                                (let () (define F1 (lambda () (if #t #t #t))) (if (F1) (F1) (F1)))
                                (let () (define F1 (lambda () (if #t #t #t))) (if (F1) (F1) (F1)))
                                (let () (define F1 (lambda (V1) (if V1 V1 V1))) (F1 (F1 #t)))
                                (let () (define F1 (lambda (V1) (if V1 V1 V1))) (F1 (F1 #t)))
                                (let () (define F1 (lambda (V1) (if V1 V1 V1))) (F1 (F1 #t)))
                                (let () (if #t #f #t))))

         (define (trivial-expr) '(let () #t))

         

         )
         