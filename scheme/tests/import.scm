(import (srfi :1))
(define (display-all . args)
  (for-each display args))
(display-all (remove even? '(0 7 8 8 43 -4)) "\n")