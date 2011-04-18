;;functions related to factor graphs
(library (factor-graph)
         (export python-format->scheme-program ghost-node? python-data->scheme python-node->scheme python-ghost-node->scheme data?)
         (import (except (rnrs) string-hash string-ci-hash)
                 (church readable-scheme)
                 (_srfi :1))
         (define GHOST-NODE 'GN)
         (define NODE 'N)
         (define DATA 'data)
         ;;temporary definition, should be a python function
         ;; (define (image->factor-graph image)
         ;;   '(N (data (label 1) (radius 10) (blobbiness 3.5) (Distance 5 .5) (Straightness 0 0.1))
         ;;         (N (data (label 2) (radius 5) (blobbiness 3.5) (Distance 3 .5) (Straightness 0 0.1))
         ;;            (N (data (label 3) (radius 2) (blobbiness 3.5) (Distance 2 .5) (Straightness 0 0.1))
         ;;               (N (data (label 4) (radius 5) (blobbiness 10) (Distance 5 .5) (Straightness 0 0.1)))
         ;;               (N (data (label 5) (radius 5) (blobbiness 10) (Distance 5 .5) (Straightness 0 0.1)))))))
;;;basically put 'node at the front of every sub-expr and wrap in a lambda
         (define (python-format->scheme-program py-format)
           (let* ([body (convert-py-format py-format)]) 
             (list 'lambda '() body)))

         ;; (define (convert-py-format py-sexpr)
         ;;   (cond [(null? py-sexpr) py-sexpr]
         ;;         [(ghost-node? py-sexpr) (python-ghost-node->scheme py-sexpr)]
         ;;         [(node? py-sexpr) (python-node->scheme py-sexpr)]
         ;;         [(data? py-sexpr) (python-data->scheme py-sexpr)]
         ;;         [else (error 'convert-py-format "unrecognized python expression for factor graph" py-sexpr)]))

         ;;works if we know what the data attributes are ahead of time and can define functions for each of the attribute names
         (define (convert-py-format py-sexpr)
           py-sexpr)



         (define (ghost-node? py-sexpr)
           (tagged-list? py-sexpr GHOST-NODE))
         (define (node? py-sexpr)
           (tagged-list? py-sexpr NODE))
         (define (data? py-sexpr)
           (tagged-list? py-sexpr DATA))
         (define (python-ghost-node->scheme py-sexpr)
           `(node ,(convert-py-format (second py-sexpr))))         
         (define (python-node->scheme py-sexpr)
           `(node ,@(map convert-py-format (rest py-sexpr))))
         (define (python-data->scheme py-sexpr)
           `(node 'data ,@(map data-attributes->scheme (rest py-sexpr))))
         (define (data-attributes->scheme py-sexpr)
           (pair 'list (rest py-sexpr))))
