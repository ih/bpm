;;functions related to factor graphs
(library (tree)
         (export tree->expression node-data->expression replace-gaussian gaussian->mean gaussian->variance)
         (import (except (rnrs) string-hash string-ci-hash)
                 (program)
                 (util)
                 (church readable-scheme)
                 (_srfi :1))
         (define GHOST-NODE 'GN)
         (define NODE 'N)
         (define DATA 'data)
         
;;;basically put 'node at the front of every sub-expr and wrap in a lambda
         (define (tree->expression tree)
             (if (null? tree)
                 '()
                 (pair 'node (pair (node-data->expression (first tree)) (map tree->expression (rest tree))))))

         (define (node-data->expression lst)
           `(data (color (gaussian ,(first (second lst)) 25)) (size ,(first (third lst)))))

         ;;used in scoring (computing the likelihood for a program that generates trees)
         ;;replace-color::program->program
         (define (replace-gaussian program)
           (define (gaussian? sexpr)
             (tagged-list? sexpr 'gaussian))
           (define (return-parameters sexpr)
             `(list 'gaussian-parameters ,(second sexpr) ,(third sexpr)))
           (define (replace-in-abstraction abstraction)
             (make-named-abstraction (abstraction->name abstraction) (sexp-search gaussian? return-parameters (abstraction->pattern abstraction)) (abstraction->vars abstraction)))
           (let* ([converted-abstractions (map replace-in-abstraction (program->abstractions program))]
                  [converted-body (sexp-search gaussian? return-parameters (program->body program))])
             (make-program converted-abstractions converted-body)))

         (define gaussian->mean second)
         (define gaussian->variance third))
