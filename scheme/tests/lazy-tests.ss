#!r6rs
(import (rnrs)
        (lazy)
        (church readable-scheme)
        (noisy-number)
        (srfi :78 lightweight-testing))

;;;lazy-equal with different policy tests

(check (lazy-equal? (lazy-list 'a 20 300) (lazy-list 'a 20 300)) => #t)
(check (lazy-equal? (lazy-list 'a 19 300) (lazy-list 'a 20 300)) => #f)

(check (lazy-equal? (lazy-list 'a 19 300) (lazy-list 'a 20 300) noisy-number-eq?) => #t)
(check (lazy-equal? (lazy-list 'a 19 30) (lazy-list 'a 20 300) noisy-number-eq?) => #f)
       
(check-report)
