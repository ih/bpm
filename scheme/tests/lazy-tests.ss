#!r6rs
(import (rnrs)
        (lazy)
        (church readable-scheme)
        (srfi :78 lightweight-testing))

;;;lazy-equal with different policy tests
(set-policy! 'original)
(check (lazy-equal? (lazy-list 'a 20 300) (lazy-list 'a 20 300)) => #t)
(check (lazy-equal? (lazy-list 'a 19 300) (lazy-list 'a 20 300)) => #f)
(set-policy! 'noisy-number)
(check (lazy-equal? (lazy-list 'a 19 300) (lazy-list 'a 20 300)) => #t)
(check (lazy-equal? (lazy-list 'a 19 30) (lazy-list 'a 20 300)) => #f)
       
(check-report)
