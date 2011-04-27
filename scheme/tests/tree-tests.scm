(import (tree)
        (srfi :78)
        (_srfi :1)
        (church readable-scheme))

;;;node-data->expression
(check (node-data->expression '((.1) (1))) => '(data (color .1) (size 1)))

;;;ghost-node? tests
(check-report)
(exit)