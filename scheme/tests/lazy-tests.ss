#!r6rs
(import (rnrs)
        (lazy)
        (church readable-scheme)
        (noisy-number)
        (srfi :78 lightweight-testing))

;;;lazy-equal with different policy tests
(set-policy! 'original)
(check (lazy-equal? (lazy-list 'a 20 300) (lazy-list 'a 20 300)) => #t)
(check (lazy-equal? (lazy-list 'a 19 300) (lazy-list 'a 20 300)) => #f)
(set-policy! 'noisy-number)
(check (lazy-equal? (lazy-list 'a 19 300) (lazy-list 'a 20 300)) => #t)
(check (lazy-equal? (lazy-list 'a 19 30) (lazy-list 'a 20 300)) => #f)
;;;lazy-topology-equal tests
(set-policy! 'topology-only)
(let ([lazy-node (lazy-pair (lazy-list 'data (list 1) (list -0.2) (list 2 0.1) (list 0 0.1)) '())]
      [lazy-node2 (lazy-pair (lazy-list 'data (list 1) (list -0.2) (list 2 0.1) (list 0 0.1)) '())])
 (check (lazy-equal? lazy-node lazy-node2) => #t))

;;lazy-data? tests
(let ([lazy-data (lazy-list 'data (list 0) (list -0.2) (list 2 0.1) (list 0 0.1))])
     (check (lazy-data? lazy-data) => #t))

(let ([lazy-node (lazy-pair (lazy-list 'data (list 1) (list -0.2) (list 2 0.1) (list 0 0.1)) '())]
      [lazy-node2 (lazy-pair (lazy-list 'data  (list 0 0.1)) '())])
 (check (lazy-topology-equal? lazy-node lazy-node2 20) => #t))


(check-report)
(exit)