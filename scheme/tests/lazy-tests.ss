#!r6rs
(import
  (rnrs)
  (pi lazy)
  (church readable-scheme)
  (srfi :78 lightweight-testing))

(pretty-print (compute-depth #t))
(pretty-print (lazy-equal? #t #t 3))

