#!r6rs

(library (church external math-env)
         
         (export pi
                 logistic
                 lnfact lngamma
		 random-integer
                 random-real
                 beta-pdf
                 gamma-pdf
                 dirichlet-lnpdf
                 poisson-pdf
                 gaussian-pdf
                 gaussian-lnpdf
                 tdist-pdf
                 discrete-pdf
		 mmultinomial-lnpdf
                 sample-discrete
                 sample-poisson
                 sample-gaussian
                 sample-generalized-tdist
                 sample-tdist
                 sample-beta
                 sample-gamma
                 sample-dirichlet
		 sample-mmultinomial
		 seed-rng randomize-rng)
                 
         (import (church utils rnrs)
                 (only (_srfi :1) first)
                 (church external gsl-bindings))
         
         
         (define pi 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067982148086513282306647093844609550582231725359408128481117450284102701938521105559644622948954930381964428810975665933446128475648233786783165271201909145648566923460348610454326648213393607260249141273724587006606315588174881520920962829254091715364367892590360011330530548820466521384146951941511609433057270365759591953092186117381932611793105118548074462379962749567351885752724891227938183011949129833673362440656643086021394946395224737190702179860943702770539217176293176752384674818467669405132000568127145263560827785771342757789609173637178721468440901224953430146549585371050792279689258923542019956112129021960864034418159813629774771309960518707211349999998372978049951059731732816096318595024459455346908302642522308253344685035261931188171010003137838752886587533208381420617177669147303598253490428755468731159562863882353787593751957781857780532171226806613001927876611195909216420198938095257201065485863278865936153381827968230301952035301852968995773622599413891249721775283479131515574857242454150695950829533116861727855889075098381754637464939319255060400927701671139009848824012858361603563707660104710181942955596198946767837449448255379774726847104047534646208046684259069491293313677028989152104752162056966024058038150193511253382430035587640247496473263914199272604269922796782354781636009341721641219924586315030 )
         
         (define (logistic x) (/ 1 (+ 1 (exp (- x)))))
         
         
         ; GSL
                  
         (define lnfact gsl-lnfact)
         (define lngamma gsl-lngamma)
         (define random-integer gsl-rng-uniform-int)
         (define random-real gsl-rng-uniform-pos)

         (define beta-pdf gsl-beta-pdf)
         (define gamma-pdf gsl-gamma-pdf)
         (define dirichlet-lnpdf gsl-dirichlet-lnpdf)
         (define poisson-pdf gsl-poisson-pdf)
         (define discrete-pdf gsl-discrete-pdf)
         (define (gaussian-pdf val mu var) (gsl-gaussian-pdf (- mu val) var))
	 ; the constant 1.837... is log(2 pi)
         (define (gaussian-lnpdf val mu var)
	   (* -0.5 (+ (+ 1.8378770664093453 (log var)) (/ (* (- val mu) (- val mu)) var) )) )
         (define tdist-pdf gsl-tdist-pdf)
	 (define mmultinomial-lnpdf gsl-multinomial-lnpdf)

         (define sample-beta gsl-beta)
         (define sample-gamma gsl-gamma)
         (define sample-dirichlet gsl-dirichlet)
         (define sample-poisson gsl-poisson)         
         (define sample-discrete gsl-discrete)
         (define (sample-gaussian mu sigma) (+ mu (gsl-gaussian sigma)))
         (define sample-tdist gsl-tdist)
         (define (sample-generalized-tdist nu mu sigma-sq) (+ (* (gsl-tdist nu) (sqrt sigma-sq)) mu))
	 (define sample-mmultinomial gsl-multinomial)

         (define seed-rng gsl-rng-set)
	 (define randomize-rng gsl-rng-randomize)
         
         ; PLT Science Library

         ;(require (planet "poisson.ss" ("williams" "science.plt") "random-distributions"))
         ;(require (planet "gaussian.ss" ("williams" "science.plt") "random-distributions"))
         ;(require (planet "discrete.ss" ("williams" "science.plt") "random-distributions"))
         ;(require (planet "gaussian.ss" ("williams" "science.plt") "random-distributions"))
         ;(require (planet "beta.ss" ("williams" "science.plt") "random-distributions"))
         ;(require (planet "gamma.ss" ("williams" "science.plt") "random-distributions"))
         ;(require (planet williams/science/special-functions/gamma))
         ;
         ;(define (sample-gaussian mu sigma) 
         ;  (random-gaussian (current-pseudo-random-generator) mu sigma))
         ;
         ;(define (sample-poisson a) 
         ;  (random-poisson (current-pseudo-random-generator) a))
         ;
         ;(define (sample-discrete dist) 
         ;  (random-discrete (current-pseudo-random-generator) (make-discrete (list->vector dist))))
         ;
         ;(define (sample-beta a b)
         ;  (random-beta (current-pseudo-random-generator) a b))
         ;
         ;(define (sample-gamma a b)
         ;  (random-gamma (current-pseudo-random-generator) a b))
         ;
         ;(define (discrete-pdf args val) 
         ;  (exact->inexact (plt-discrete-pdf (make-discrete (list->vector (first args))) val)))

)