(library (noisy-number)
         (export noisy-number-threshold close? make-noisy-number noisy-number-eq?)
         (import (rnrs)
                 (church external math-env))

         (define noisy-number-threshold 3)

         (define (close? a b)
           (< (abs (- b a)) noisy-number-threshold))

         (define variance 1)

         (define (make-noisy-number et1 et2)
           (let ([mean (/ (+ et1 et2) 2)])
             (sample-gaussian mean variance)))

         (define (noisy-number-eq? a b)
           (if (and (number? a) (number? b))
               (close? a b)
               (eq? a b)))
         )

