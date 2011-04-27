;;functions related to factor graphs
(library (tree)
         (export tree->expression node-data->expression)
         (import (except (rnrs) string-hash string-ci-hash)
                 (church readable-scheme)
                 (_srfi :1))
         (define GHOST-NODE 'GN)
         (define NODE 'N)
         (define DATA 'data)
         
;;;basically put 'node at the front of every sub-expr and wrap in a lambda
         (define (tree->expression tree)
             (if (null? tree)
                 '()
                 (pair 'N (pair (node-data->expression (first tree)) (map tree->expression (rest tree))))))

         (define (node-data->expression lst)
           `(data ,(pair 'color (second lst)) ,(pair 'size (third lst)))))
