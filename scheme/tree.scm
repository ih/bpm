;;functions related to factor graphs
(library (tree)
         (export tree->expression node-data->expression replace-color)
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
                 (pair 'N (pair (node-data->expression (first tree)) (map tree->expression (rest tree))))))

         (define (node-data->expression lst)
           `(data ,(pair 'color (second lst)) ,(pair 'size (third lst))))

         ;;used in scoring (computing the likelihood for a program that generates trees)
         ;;replace-color::program->program
         (define (replace-color program)
           (define (color? sexpr)
             (tagged-list? sexpr 'color))
           (define (return-parameters sexpr)
             `(list ,(second sexpr) 15))
           (define (replace-in-abstraction abstraction)
             (make-named-abstraction (abstraction->name abstraction) (sexp-search color? return-parameters (abstraction->pattern abstraction)) (abstraction->vars abstraction)))
           (let* ([converted-abstractions (map replace-in-abstraction (program->abstractions program))]
                  [converted-body (sexp-search color? return-parameters (program->body program))])
             (make-program converted-abstractions converted-body))))
