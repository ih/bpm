(import (sym)
        (srfi :78))
;;;tagged-match test
(check (tag-match? 'R 'R99) => #t)
(check (tag-match? 'F 'R99) => #f)


