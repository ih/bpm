(import (tree)
        (srfi :78)
        (_srfi :1)
        (program)
        (church readable-scheme))

;;;node-data->expression
(check (node-data->expression '(data (.1) (1))) => '(data (color .1) (size 1)))
;;;replace-color
(check (replace-color (make-program (list (make-named-abstraction 'F1 '(V1) '(N (data (color V1) (size 2))))) '(N (data (color 3) (size 1)) (F1 10) (F1 10)))) => (make-program (make-named-abstraction '(V1) 'F1 '(N (data (list V1 15) (size 2)))) '(N (data (list 3 15) (size 1)) (F1 10) (F1 10))))

(check (eval (replace-color (make-program (list (make-named-abstraction 'F1 '(N (data (color V1) (size 2))) '(V1))) '(N (data (color 3) (size 1)) (F1 10) (F1 10)))) (interaction-environment)) => '((data (3 15) (1)) ((data (10 15) (2))) ((data (10 15) (2)))))
;;;ghost-node? tests
(check-report)
(exit)