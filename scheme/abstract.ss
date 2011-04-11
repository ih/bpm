#!r6rs

;; TODO:


;; - make a test case for getting anonymous functions when inlining
;; - inlining with higher-order functions leads to loss of irreducibility through the creation of anonymous functions? rewrite applied lambdas in the body of a program 
(library (abstract)
         (export true-compressions all-compressions compressions test-abstraction-proposer abstraction-move proposal beam-search-compressions beam-compression all-iterated-compressions iterated-compressions inline unique-programs sort-by-size possible-abstractions internalize-arguments)
         (import (except (rnrs) string-hash string-ci-hash)
                 (only (ikarus) set-car! set-cdr!)
                 (_srfi :1)
                 (_srfi :69)
                 (only (srfi :13) string-drop)
                 (church readable-scheme)
                 (program)
                 (inverse-inline)
                 (unification)
                 (util)
                 (sym)
                 (mem))
         


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

         


         ;; data structures & associated functions
;;;~~~~~~~~~~~~~~~~~~code for compressions~~~~~~~~~~~~~~~~~ (not sure if this is the right starting point)

;;;~~~~~~~~~~~~end code for compressions~~~~~~~~~~~~~~~~~~~~~         
;;;=========code for internalize-arguments=============================
         ;;a transformation is performed for each variable of each abstraction 
         (define (internalize-arguments program . nofilter)
           (let* ([abstractions-with-variables (filter has-arguments? (program->abstractions program))])
             (concatenate (map (curry abstraction-internalizations program) abstractions-with-variables))))

         (define (has-arguments? abstraction)
           (not (null? (abstraction->vars abstraction))))

         ;;return a program transformation is returned for each variable in abstraction
         (define (abstraction-internalizations program abstraction)
           (map (curry internalize-argument program abstraction) (abstraction->vars abstraction)))

         ;;rewrite the abstraction to have the variable in the abstraction be a mixture of the values its taken on in the program
         ;;rewrite applications of the abstraction function in the program to not have the variable
         (define (internalize-argument program abstraction variable)
           (let* ([new-abstraction (remove-abstraction-variable program abstraction variable)]
                  [program-with-new-abstraction (program->replace-abstraction program new-abstraction)]
                  [new-program (remove-application-argument program-with-new-abstraction abstraction variable)])
             new-program))

         ;;creates a "mixture" distribution over instances of the variable being removed
         (define (remove-abstraction-variable program abstraction variable)
           (let* ([mixture-elements (find-variable-instances program abstraction variable)]
                  [mixture-sexpr (make-mixture-sexpr mixture-elements)]
                  [new-pattern `(let ([,variable ,mixture-sexpr]) ,(abstraction->pattern abstraction))]
                  [new-variables (delete variable (abstraction->vars abstraction))])
             (make-named-abstraction (abstraction->name abstraction) new-pattern new-variables)))

         (define (find-variable-instances program abstraction variable)
           (let* ([abstraction-applications (program->abstraction-applications program abstraction)]
                  [variable-position (abstraction->variable-position abstraction variable)]
                  [variable-instances (map (curry ith-argument variable-position) abstraction-applications)])
             variable-instances))

         ;;i+1 because the first element is the function name
         (define (ith-argument i function-application)
           (list-ref function-application (+ i 1)))

         (define (remove-ith-argument i function-application)
           (append (take function-application (+ i 1)) (drop function-application (+ i 2))))

         (define (make-mixture-sexpr mixture-elements)
           `((uniform-draw (list ,@(map thunkify mixture-elements)))))

         (define (thunkify sexpr) `(lambda () ,sexpr))


         ;;rewrite applications of abstraction in program to not have the variable argument 
         (define (remove-application-argument program abstraction variable)
           (define (abstraction-application? sexpr)
              (if (non-empty-list? sexpr)
                  (equal? (first sexpr) (abstraction->name abstraction))
                  #f))
           (define (change-application variable-position application)
              (remove-ith-argument variable-position application))
           (let* ([variable-position (abstraction->variable-position abstraction variable)]
                  [program-sexpr (program->sexpr program)]
                  [changed-sexpr (sexp-search abstraction-application? (curry change-application variable-position) program-sexpr)]
                  [new-program (sexpr->program changed-sexpr)])
             new-program))

         ;;assumes abstractions and only abstractions have name of the form '[FUNC-SYMBOL][Number]
         (define (application? sexpr)
           (if (non-empty-list? sexpr)
               (func? (first sexpr))))         
;;;=========end code for internalize-arguments========================

;;;**********begin code for similarity-replacmenet*******************
         
;;;**********end code for similarity-replacement******************         
         (define (true-compressions program)
           (compressions program))

         (define (all-compressions program)
           (compressions program 'all))


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
