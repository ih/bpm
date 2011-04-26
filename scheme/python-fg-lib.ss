(library (python-fg-lib)
         (export fg->image fg->img-score image->factor-graph) 
         (import (except (rnrs) string-hash string-ci-hash)
                 (scheme-tools py-pickle)
                 (util)
                 ;(church external py-pickle)
                 )

         (define fg-dir "python /home/ih/factor-graphics/")

         (define fg->image
           (py-pickle-function (string-append fg-dir "python/fg2image.py")))

         (define fg->img-score
           (py-pickle-function (string-append fg-dir "python/scoreImFg.py")))

;;         not exporting until issues w/ py-pickle have been worked out, see a temporary definition in factor-graph.scm
         (define image->factor-graph
           (py-pickle-function (string-append fg-dir "python/im2fg.py"))
)

         (define (strings->symbols sexpr)
           (sexp-search string? string->symbol sexpr))

         ;;just for testing purposes until factor-graph format decided upon
         ;; (define (fg->img-score image+factor-graph)
         ;;   (log 1))
         
         ;;temporary definition until issues w/ py-pickle worked out
         ;; (define (image->factor-graph image)
         ;;   '(N (data (label 1) (radius 10) (blobbiness 3.5) (Distance 5 .5) (Straightness 0 0.1))
         ;;         (N (data (label 2) (radius 5) (blobbiness 3.5) (Distance 3 .5) (Straightness 0 0.1))
         ;;            (N (data (label 3) (radius 2) (blobbiness 3.5) (Distance 2 .5) (Straightness 0 0.1))
         ;;               (N (data (label 4) (radius 5) (blobbiness 10) (Distance 5 .5) (Straightness 0 0.1)))
         ;;               (N (data (label 5) (radius 5) (blobbiness 10) (Distance 5 .5) (Straightness 0 0.1)))))))
         )

