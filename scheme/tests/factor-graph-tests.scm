(import (factor-graph)
        (srfi :78)
        (_srfi :1)
        (church readable-scheme))

;;;ghost-node? tests
(let ([python-factor-graph '(GN 
                             (GN
                              (N (data (radius 1.2) (blobbiness -0.2) (Distance 2 0.1) (Straightness 0 0.1))
                                  (N (data (radius 0.8) (blobbiness -0.1) (Distance 3 0.1) (Straightness 0 0.1))
                                      (N (data (radius 0.6) (blobbiness -0.2) (Distance 2 0.1) (Straightness 0 0.1)))))))])
  (check (ghost-node? python-factor-graph) => #t))

(let ([python-factor-graph '(N1 (data (radius 1.2) (blobbiness -0.2) (Distance 2 0.1) (Straightness 0 0.1))
           (N2 (data (radius 0.8) (blobbiness -0.1) (Distance 3 0.1) (Straightness 0 0.1))
               (N3 (data (radius 0.6) (blobbiness -0.2) (Distance 2 0.1) (Straightness 0 0.1)))))])
  (check (ghost-node? python-factor-graph) => #f))

;;;python-data->scheme tests
(let ([py-data '(data (radius 0.6) (blobbiness -0.2) (Distance 2 0.1) (Straightness 0 0.1))])
  (check (python-data->scheme py-data) => `(node 'data (list 0.6) (list -.2) (list 2 0.1) (list 0 0.1))))
;;;python-node->scheme tests
(let ([py-node '(N (data (radius 0.6) (blobbiness -0.2) (Distance 2 0.1) (Straightness 0 0.1)))])
  (check (python-node->scheme py-node) => `(node ,(python-data->scheme (second py-node)))))

(let ([py-nodes '(N (data (radius 0.8) (blobbiness -0.1) (Distance 3 0.1) (Straightness 0 0.1))
                    (N (data (radius 0.6) (blobbiness -0.2) (Distance 2 0.1) (Straightness 0 0.1))))])
  (check (python-node->scheme py-nodes) => `(node ,(python-data->scheme (second py-nodes)) ,(python-node->scheme (third py-nodes)))))
;;;python-ghost-node->scheme tests
(let ([python-factor-graph '(GN 
                             (GN
                              (N (data (radius 1.2) (blobbiness -0.2) (Distance 2 0.1) (Straightness 0 0.1))
                                  (N (data (radius 0.8) (blobbiness -0.1) (Distance 3 0.1) (Straightness 0 0.1))
                                      (N (data (radius 0.6) (blobbiness -0.2) (Distance 2 0.1) (Straightness 0 0.1)))))))])
  (check (python-ghost-node->scheme python-factor-graph)
         =>
         `(node
           (node
            ,(python-node->scheme (second (second python-factor-graph)))))))
;;;convert-py-format tests
;; (let ([python-factor-graph '(GN2 
;;                              (GN1
;;                               (N1 (data (radius 1.2) (blobbiness -0.2) (Distance 2 0.1) (Straightness 0 0.1))
;;                                   (N2 (data (radius 0.8) (blobbiness -0.1) (Distance 3 0.1) (Straightness 0 0.1))
;;                                       (N3 (data (radius 0.6) (blobbiness -0.2) (Distance 2 0.1) (Straightness 0 0.1)))))))])
;;  (check (convert-py-format python-factor-graph) => '((((data (1.2) (-0.2) (2 0.1) (0 0.1))
;;                                                       ((data (0.8) (-0.1) (3 0.1) (0 0.1))
;;                                                        ((data (0.6) (-0.2) (2 0.1) (0 0.1)))))))))
(check-report)
(exit)