(import (program)
        (srfi :78))

;;;make-named-abstraction test
(check (make-named-abstraction 'F1 '(+ V1 V2) '(V1 V2)) => '(abstraction F1 (V1 V2) (+ V1 V2)))


(check-report)
(exit)