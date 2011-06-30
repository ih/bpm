;;functions related to factor graphs
(library (tree)
         (export tree->expression node-data->expression desugar gaussian->mean gaussian->variance replace-gaussian)
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
           `(data (color ,(first (second lst))) (size ,(first (third lst)))))

         ;;used in scoring (computing the likelihood for a program that generates trees)
         ;;replace-color::program->program
         (define (desugar program)
           (define (gaussian? sexpr)
             (tagged-list? sexpr 'gaussian))
           (define (uniform-choice? sexpr)
             (tagged-list? sexpr 'uniform-choice))
           (define (return-parameters sexpr)
             `(list 'gaussian-parameters ,(second sexpr) ,(third sexpr)))
           (define (uniform-draw-conversion sexpr)
             `((uniform-draw (list ,@(map thunkify (rest sexpr))))))
           (define tests+replacements (zip (list uniform-choice?) (list uniform-draw-conversion)))
           (define (apply-transforms sexpr)
             (fold (lambda (test+replacement expr)
                     (sexp-search (first test+replacement) (second test+replacement) expr))
                   sexpr
                   tests+replacements))
           (define (desugar-abstraction abstraction)
             (make-named-abstraction (abstraction->name abstraction) (apply-transforms (abstraction->pattern abstraction)) (abstraction->vars abstraction)))
           (let* ([converted-abstractions (map  desugar-abstraction (program->abstractions program))]
                  [converted-body (apply-transforms (program->body program))])
             (make-program converted-abstractions converted-body)))

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