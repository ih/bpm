(library (inverse-inline)
         (export possible-abstractions replace-matches compressions)
         (import (except (rnrs) string-hash string-ci-hash)
                 (program)
                 (_srfi :1)
                 (sym)
                 (unification)
                 (program)
                 (church readable-scheme)
                 (util))
                  ;;return valid abstractions for any matching subexpressions in expr
         ;;valid abstractions are those without free variables
         (define (possible-abstractions expr)
           (let* ([subexpr-pairs (list-unique-commutative-pairs (all-subexprs expr))]
                  [abstractions (map-apply (curry anti-unify-abstraction expr) subexpr-pairs)])
             (filter-abstractions  abstractions)))

         ;;takes expr so that each abstraction can have the indices for function and variables set correctly
         ;;setting the indices floor only works if all functions in the program appear in expr, this is not the case if there are abstractions in the program that are not applied in the body 
         (define (anti-unify-abstraction expr expr1 expr2)
           (let* ([none (set-indices-floor! expr)]
                  [abstraction (apply make-abstraction (anti-unify expr1 expr2))]
                  [none (reset-symbol-indizes!)])
             abstraction))
         

         
         ;;;remove undesirable abstractions and change any that have free variables
         (define (filter-abstractions abstractions)
           (define (remove-isomorphic abstractions)
             (delete-duplicates abstractions))
           (define (remove-nonmatches abstractions)
             (define (match? abstraction)
               (let* ([body (abstraction->pattern abstraction)])
                 (not (var? body))))
             (filter match? abstractions))
           (let* ([no-free-vars (map capture-free-variables abstractions)]
                  [no-isomorphisms (remove-isomorphic no-free-vars)]
                  [no-nonmatches (remove-nonmatches no-isomorphisms)])
             no-nonmatches))
         

         ;; doesn't deal with partial matches, could use more error checking;
         (define (replace-matches s abstraction)
           (let ([unified-vars (unify s
                                      (abstraction->pattern abstraction)
                                      (abstraction->vars abstraction))])
             (if (false? unified-vars)
                 (if (list? s)
                     (map (lambda (si) (replace-matches si abstraction)) s)
                     s)
                 (pair (abstraction->name abstraction)
                       (map (lambda (var) (replace-matches (rest (assq var unified-vars)) abstraction))
                            (abstraction->vars abstraction))))))

         (define (base-case? pattern var)
           (equal? (second (third pattern)) var))

         ;; throw out any matches that are #f
         
         (define (get-valid-abstractions subexpr-matches)
           (let ([abstractions (map third subexpr-matches)])
             (filter (lambda (x) x) abstractions)))

         (define (get/make-valid-abstractions subexpr-matches)
           (let* ([abstractions (map third subexpr-matches)]
                  [non-false (filter (lambda (x) x) abstractions)]
                  [no-free-vars (map capture-free-variables non-false)])
             no-free-vars))

                  ;; joins definitions and program body into one big list
         (define (condense-program program)
           `(,@(map abstraction->pattern (program->abstractions program))
             ,(program->body program)))

         ;; both compressee and compressor are abstractions
         (define (compress-abstraction compressor compressee)
           (make-named-abstraction (abstraction->name compressee)
                                   (replace-matches (abstraction->pattern compressee) compressor)
                                   (abstraction->vars compressee)))

         (define (compress-program program abstraction)
           (let* ([compressed-abstractions (map (curry compress-abstraction abstraction)
                                                (program->abstractions program))]
                  [compressed-body (replace-matches (program->body program) abstraction)])
             (make-program (pair abstraction compressed-abstractions)
                           compressed-body)))

         
         ;; compute a list of compressed programs, nofilter is a flag that determines whether to return all compressions or just ones that shrink the program
         (define (compressions program . nofilter)
           (let* ([condensed-program (condense-program program)]
                  [abstractions (possible-abstractions condensed-program)]
                  [compressed-programs (map (curry compress-program program) abstractions)]
                  [prog-size (program-size program)]
                  [valid-compressed-programs
                   (if (not (null? nofilter))
                       compressed-programs
                       (filter (lambda (cp) (<= (program-size cp)
                                                prog-size))
                               compressed-programs))])
             valid-compressed-programs)))