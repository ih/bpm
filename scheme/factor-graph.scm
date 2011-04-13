;;functions related to factor graphs
(library (factor-graph)
         (export python-format->scheme-program)
         (import (except (rnrs) string-hash string-ci-hash)
                 (church readable-scheme))
;;;basically put 'node at the front of every sub-expr and wrap in a lambda
 (define (python-format->scheme-program py-format)
   (let* ([body (convert-py-format py-format)]) 
     (list 'lambda '() body)))

 (define (convert-py-format py-sexpr)
   (if (null? py-sexpr)
       py-sexpr
       (if (list? py-sexpr)
           (pair 'node (map convert-py-format (rest py-sexpr)))
           py-sexpr))))

