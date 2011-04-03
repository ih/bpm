#!r6rs

;; TODO:


;; - make a test case for getting anonymous functions when inlining
;; - inlining with higher-order functions leads to loss of irreducibility through the creation of anonymous functions? rewrite applied lambdas in the body of a program 
(library (abstract)
         (export true-compressions all-compressions compressions test-abstraction-proposer abstraction-move sexpr->program proposal beam-search-compressions beam-compression make-program  pretty-print-program program->sexpr size get-abstractions make-abstraction abstraction->define define->abstraction var? func? normalize-names func-symbol all-iterated-compressions iterated-compressions inline unique-programs sort-by-size program->body program->abstraction-applications program->abstractions abstraction->vars abstraction->pattern abstraction->name abstraction->variable-position make-named-abstraction unique-commutative-pairs possible-abstractions find-tagged-symbols set-indices-floor! condense-program replace-matches)
         (import (except (rnrs) string-hash string-ci-hash)
                 (only (ikarus) set-car! set-cdr!)
                 (_srfi :1)
                 (_srfi :69)
                 (only (srfi :13) string-drop)
                 (church readable-scheme)
                 (unification)
                 (util)
                 (sym)
                 (mem))
         

         (define (identity x) x)

         ;;var-symbol and func-symbol are functions that return symbols so that they can be used in bher
         ;;think about moving these to a constants file since they're now separated due to unification-policies

         (define (func-symbol) 'F) 

         ;; compute the size of a program
         (define (size expr)
           (if (list? expr)
               (cond [(tagged-list? expr 'begin) (size (rest expr))] ;; ignore 'begin symbol
                     [(tagged-list? expr 'define) (size (cddr expr))] ;; ignore 'define symbol + args
                     [else (apply + (map size expr))])
               1))


         ;;here pairs are lists of two items not scheme pairs
         (define (commutative-pair-equal pair1 pair2)
           (or (equal? pair1 pair2)
               (and (equal? (first pair1) (second pair2)) (equal? (second pair1) (first pair2)))))

         ;; there are ways to speed this up by preprocessing lst
         (define (unique-commutative-pairs lst func)
           (define (pairing-recursion lst1 lst2)
             (if (null? lst2)
                 '()
                 (let ((from1 (first lst1)))
                   (append (map (lambda (from2) (func from1 from2)) lst2)
                           (pairing-recursion (rest lst1) (rest lst2))))))
           (delete-duplicates (pairing-recursion lst (rest lst)) commutative-pair-equal))

         (define (list-unique-commutative-pairs lst)
           (unique-commutative-pairs lst list))

         ;;language specific functions ;use reg-exps
         ;;temp fix b/c problems access to srfi 13
         (define (var? expr)
           (if (symbol? expr)
               (let* ([var-string (symbol->string (var-symbol))]
                      [string-expr (symbol->string expr)])
                 ;; (string-prefix? var-pattern string-expr))))
                 (equal? (substring string-expr 0 1) var-string))
               #f))

         (define (func? expr)
           (if (symbol? expr)
               (let* ([func-string (symbol->string (func-symbol))]
                      [string-expr (symbol->string expr)])
                 ;; (string-prefix? var-pattern string-expr))))
                 (equal? (substring string-expr 0 1) func-string))
               #f))

         (define (make-abstraction pattern variables)
           (make-named-abstraction (sym (func-symbol)) pattern variables))
         (define (make-named-abstraction name pattern variables)
           (list 'abstraction name variables pattern))

         (define abstraction->name second)
         (define abstraction->vars third)
         (define abstraction->pattern fourth)

         ;; make a define statement out of an abstraction, format is (define name (lambda (vars) body))
         (define (abstraction->define abstraction)
           (let ((name (abstraction->name abstraction))
                 (variables (abstraction->vars abstraction))
                 (pattern (abstraction->pattern abstraction)))
             (list 'define name (list 'lambda variables pattern))))

         (define (abstraction->variable-position abstraction variable)
           (list-index (lambda (x) (equal? variable x)) (abstraction->vars abstraction)))

         (define (make-program abstractions body)
           (list 'program abstractions body))
         (define program->abstractions second)
         (define program->body third)

         ;;it might also be possible to search over program->sexpr, but then we'd need a more complicated predicate to avoid the definition of the target-abstraction
         (define (program->abstraction-applications program target-abstraction)
           (define (target-abstraction-application? sexpr)
             (if (non-empty-list? sexpr)
                 (if (equal? (first sexpr) (abstraction->name target-abstraction))
                     #t
                     #f)
                 #f))
           (let* ([abstraction-patterns (map abstraction->pattern (program->abstractions program))]
                  [possible-locations (pair (program->body program) abstraction-patterns)])
             (deep-find-all target-abstraction-application? possible-locations)))

         (define (program->sexpr program)
           `(let ()  
              ,@(map abstraction->define (program->abstractions program))
              ,(program->body program)))

         ;;assumes format of (let () definitions body); if format fails to hold then program is an empty set of abstractions and the sexpr as the body
         (define (sexpr->program sexpr)
           (define (abstraction-sexpr? x)
             (if (and (not (null? x)) (list? x))
                 (equal? (first x) 'define)
                 #f))
           (let*-values ([(no-scope-sexpr) (remove-scope sexpr)]
                         [(abstractions body) (span abstraction-sexpr? no-scope-sexpr)])
             (make-program (map define->abstraction abstractions) (first body))))

         (define (sexpr->signatures sexpr)
           (let* ([program (sexpr->program sexpr)]
                  [defs (program->abstractions program)]
                  [names (map abstraction->name defs)]
                  [vars (map abstraction->vars defs)])
             (map pair names vars)))


         (define (remove-scope sexpr)
           (define (scope? x)
             (or (equal? 'let x) (null? x)))
           (let*-values ([(scope program) (span scope? sexpr)])
             program))
         
         (define (get-abstractions sexpr)
           (define (abstraction-sexpr x)
             (if (and (not (null? x)) (list? x))
                 (equal? (first x) 'define)
                 #f))
           (define (get-defines sexpr)
             (if (list? sexpr)
                 (filter 
                  sexpr)
                 '()))
           (map define->abstraction (get-defines sexpr)))

         ;;define is of the form (define name (lambda (vars) body))
         (define (define->abstraction definition)
           (let* ([name (second definition)]
                  [vars (second (third definition))]
                  [body (third (third definition))])
             (make-named-abstraction name body vars)))

         ;;assumes program in sexpr form is (let () definitions body)
         (define (get-body sexpr)
           #f)

         ;; FIXME: assumes that there is only one program for each size
         (define (unique-programs programs)
           (define ht (make-hash-table eqv?))
           (map (lambda (p) (hash-table-set! ht (size (program->sexpr p)) p)) programs)
           (map rest (hash-table->alist ht)))

         (define (sort-by-size programs)
           (let* ([program-sizes (map (compose size program->sexpr) programs)]
                  [programs-with-size (zip programs program-sizes)]
                  [size< (lambda (a b) (< (second a) (second b)))])
             (map first (list-sort size< programs-with-size))))

         (define (shortest-n n programs)
           (max-take (sort-by-size programs) n))

         ;;used to ensure all function and variable names are in consecutive order; important for when trying to generate a program from a grammar that matches a compressed program
         (define (normalize-names expr)
           (define ht (make-hash-table eqv?))
           (define (traverse action expr)
             (if (or (primitive? expr) (null? expr))
                 (if (or (func? expr) (var? expr))
                     (action expr)
                     expr)
                 (map (curry traverse action) expr)))
           ;;build table
           (define (add-to-table expr)
             (if (func? expr)
                 (hash-table-set! ht expr (sym (func-symbol)))
                 (hash-table-set! ht expr (sym (var-symbol)))))
           (define (relabel expr)
             (hash-table-ref ht expr))
           (reset-symbol-indizes!)
           (let* ([signatures (sexpr->signatures expr)])
             (traverse add-to-table signatures))
           (traverse relabel expr))
         


         ;; data structures & associated functions


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
         
         (define (set-indices-floor! expr)
           (let ([funcs (find-tagged-symbols expr (func-symbol))]
                 [vars (find-tagged-symbols expr (var-symbol))])
             (begin
               (raise-tagged! (func-symbol) funcs)
               (raise-tagged! (var-symbol) vars))))

         (define (find-tagged-symbols expr tag)
           (filter (curry tag-match? tag) (primitives expr)))

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

         ;;free variables can occur when the pattern for an abstraction contains variables that were part of the matched expressions e.g. if the expression was (+ v1 v1 a) (+ v1 v1 b) then the pattern would be (+ v1 v1 v2)
         ;;we "capture" the variables by adding them to the function definition
         ;;an alternative approach would be to have nested abstractions
         
         (define (capture-free-variables abstraction)
           (let* ([free-vars (get-free-vars abstraction)])
             (if (null? free-vars)
                 abstraction
                 (let* ([new-vars (append free-vars (abstraction->vars abstraction))] 
                        [old-pattern (abstraction->pattern abstraction)]
                        ;;add new-pattern with new variable names for captured-vars to prevent isomorphic abstractions
                        [old-name (abstraction->name abstraction)]
                        [no-free-abstraction (make-named-abstraction old-name old-pattern new-vars)])
                   no-free-abstraction))))

         ;;searches through the body of the abstraction  and returns a list of free variables
         (define (get-free-vars abstraction)
           (let* ([pattern (abstraction->pattern abstraction)]
                  [non-free (abstraction->vars abstraction)]
                  [free '()]
                  [free-var? (lambda (x) (and (var? x) (not (member x non-free))))]
                  [add-to-free! (lambda (x) (set! free (pair x free)))])
             (sexp-search free-var? add-to-free! pattern)
             free))


         ;; joins definitions and program body into one big list
         
         (define (condense-program program)
           `(,@(map abstraction->pattern (program->abstractions program))
             ,(program->body program)))

         
         ;; compute a list of compressed programs, nofilter is a flag that determines whether to return all compressions or just ones that shrink the program
         
         (define (compressions program . nofilter)
           (let* ([condensed-program (condense-program program)]
                  [abstractions (possible-abstractions condensed-program)]
                  [compressed-programs (map (curry compress-program program) abstractions)]
                  [program-size (size (program->sexpr program))]
                  [valid-compressed-programs
                   (if (not (null? nofilter))
                       compressed-programs
                       (filter (lambda (cp) (<= (size (program->sexpr cp))
                                                (+ program-size 1)))
                               compressed-programs))])
             valid-compressed-programs))

         
         

         (define (true-compressions program)
           (compressions program))

         (define (all-compressions program)
           (compressions program 'all))

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

         ;; iteratively compress program, filter programs using cfilter before recursing
         
         (define (iterated-compressions cfilter program)
           (let ([compressed-programs (cfilter (compressions program))])
             (append compressed-programs
                     (apply append (map (curry iterated-compressions cfilter) compressed-programs)))))

         ;; compute all entries of full (semi)lattice
         
         (define all-iterated-compressions
           (curry iterated-compressions (lambda (x) x)))

         ;; before exploring, boil down set of programs to eliminate duplicates
         ;; NOTE: uses unique-programs which currently compares by length!
         
         (define unique-iterated-compressions
           (curry iterated-compressions unique-programs))

         ;; NOTE: uses unique-programs which currently compares by length!
         
         (define (beam-search-compressions n program)
           (iterated-compressions (lambda (progs) (shortest-n n (unique-programs progs)))
                                  program))

         ;;compress a single step, used as a mcmc proposal
         
         (define (inverse-inline program prob-inverse-inline prob-inline)
           (let* (;;[db (pretty-print "inverse-inline")]
                  [possible-compressions (compressions program)])
             (if (null? possible-compressions)
                 (list program prob-inverse-inline prob-inverse-inline)
                 (let* ([compression-choice (uniform-draw possible-compressions)]
                        [fw-prob (+ prob-inverse-inline (- (log (length possible-compressions))))]
                        ;;backward probability is the probability of choosing the abstraction to inline
                        [abstractions (program->abstractions compression-choice)]
                        [bw-prob (+ prob-inline (- (log (length abstractions))))])
                   (list compression-choice fw-prob bw-prob)))))

         ;;returns a new proposal along with forward/backward probability, used in mcmc
         
         (define (proposal program)
           (let* ([prob-inline (- (log 2.0))]
                  [prob-inverse-inline (log (- 1 (exp prob-inline)))])
             (if (flip (exp prob-inline))
                 (inline program prob-inline prob-inverse-inline)
                 (inverse-inline program prob-inverse-inline prob-inline)))) ;;better way to do this?
         

         (define (test-abstraction-proposer sexpr)
           (list '(if t f t) (log .2) (log .8)))
         
         (define (abstraction-move sexpr)
           (define get-program first)
           (define get-fw-prob second)
           (define get-bw-prob third)
           (let* ([program (sexpr->program sexpr)]
                  [new-program+fw+bw (proposal program)]
                  [new-sexpr (program->sexpr (get-program new-program+fw+bw))]
                  [fw-prob (get-fw-prob new-program+fw+bw)]
                  [bw-prob (get-bw-prob new-program+fw+bw)])
             (list new-sexpr fw-prob bw-prob)))

         ;;inlining or decompression code; returns an expanded program and the probability of moving to that particular expansion
         
         (define (inline program prob-inline prob-inverse-inline)
           (let* ([abstractions (program->abstractions program)])
             ;;[db (pretty-print "inline")])
             (if (null? abstractions)
                 ;;is this right? if you inline a program w/o abstraction you cannot get back by inverse-inlining (unless the inverse-inline has no possible abstractions) so should we use the prob-of-inline as the probability of returning to this state
                 (list program prob-inline prob-inline) 
                 (let* ([inline-choice (uniform-draw abstractions)]
                        [remaining-abstractions (delete inline-choice abstractions)]
                        ;;[db (pretty-print (list "inline abstractions" (length abstractions) program))]
                        [fw-prob (+ prob-inline (- (log (length abstractions))))]
                        [inlined-program (inverse-replace-matches inline-choice (make-program remaining-abstractions (program->body program)))]
                        ;;backward probability is the probability of choosing the abstraction we inlined times probability of inverse inlining
                        [number-possible-compressions (length (compressions inlined-program))]
                        ;;[db (pretty-print (list "inline compressions" number-possible-compressions prob-inverse-inline))]
                        [bw-prob (if (= 0 number-possible-compressions)
                                     -inf.0
                                     (+ prob-inverse-inline (- (log number-possible-compressions))))])
                   ;;[db (pretty-print (list "fw bw" fw-prob bw-prob))])
                   (list inlined-program fw-prob bw-prob)))))
         

         ;;given a program body and an abstraction replace all function applications of teh abstraction in the body with the instantiated pattern
         ;;FIXME needs to be called recursively on expressions
         
         (define (inverse-replace-matches abstraction sexpr)
           (cond
            [(abstraction-instance? sexpr abstraction)
             (if (list? sexpr)
                 (instantiate-pattern (map (curry inverse-replace-matches abstraction) sexpr) abstraction)
                 (instantiate-pattern sexpr abstraction))]
            [(list? sexpr) (map (curry inverse-replace-matches abstraction) sexpr)]
            [else sexpr]))

         ;;test whether an expression is an application of the abstraction e.g. (F 3 4) for the abstraction F, also checks if abstraction is being used in higher-order function e.g. (G 3 F)
         
         (define (abstraction-instance? sexpr abstraction)
           (if (and (list? sexpr) (not (null? sexpr)))
               (let* ([name (abstraction->name abstraction)]
                      [num-vars (length (abstraction->vars abstraction))]
                      [num-vals (length (rest sexpr))])
                 (and (equal? (first sexpr) name) (eq? num-vars num-vals)))
               (if (equal? (abstraction->name abstraction) sexpr) #t #f)))


         ;;the sexpr is of the form (F arg1...argN) where F is the name of the abstraction and N is the number of variables in the abstraction pattern; return the pattern with all the variables replaced by the arguments to F; the first case deals with the abstraction being used in a higher-order functions; the second case deals with abstraction
         
         (define (instantiate-pattern sexpr abstraction)
           (cond [(equal? sexpr (abstraction->name abstraction))
                  (make-anon abstraction)]
                 [else (let* ([var-values (rest sexpr)]
                              [var-names (abstraction->vars abstraction)])
                         (fold replace-var (abstraction->pattern abstraction) (zip var-names var-values)))]))

         (define (make-anon abstraction)
           `(lambda ,(abstraction->vars abstraction) ,(abstraction->pattern abstraction)))

         ;;replace the named variable in the pattern with a value
         
         (define (replace-var name-value pattern)
           (define name first)
           (define value second)
           (sexp-replace (name name-value) (value name-value) pattern))



         (define (pretty-print-program program)
           (let ([sexpr (program->sexpr program)])
             (pretty-print sexpr)
             (for-each display (list "size: " (size sexpr) "\n\n"))))


         (define (beam-compression sexpr beam-size)
           (for-each display (list "original expr:\n" sexpr "\n"
                                   "size: " (size sexpr)
                                   "\n\n"
                                   "compressing...\n"))
           (let ([top-compressions (sort-by-size
                                    (unique-programs
                                     (beam-search-compressions beam-size (make-program '() sexpr))))])
             (if (null? top-compressions)
                 (display "not compressible\n")
                 (first top-compressions)))))
         
;; -potential issue if you try to inline a function that calls itself and it is not in the form (f (f (f (x))))); if you start from programs without abstraction this may never occur since any recursive function should abstract to (f(f(f(x)))) form 
