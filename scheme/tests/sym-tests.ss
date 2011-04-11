(import (sym)
        (program)
        (srfi :78))
;;;tagged-match test
(check (tag-match? 'R 'R99) => #t)
(check (tag-match? 'F 'R99) => #f)

;;;find-*-symbols test
(let* ([expr '(F1 (V1 V23) F5 V2)])
  (check (find-tagged-symbols expr (func-symbol)) => '(F1 F5)))

(let* ([expr '(F1 (V1 V23) F5 V2)])
  (check (find-tagged-symbols expr (var-symbol)) => '(V1 V23 V2)))

(check-report)
(exit)


