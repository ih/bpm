;;;log-prior is -size*3 for this example
;;;TRANFORMATION (LOG-PRIOR LOG-LIKELIHOOD LOG-POSTERIOR SEMANTICS-PRESERVING)
;;;DATA INCORPORATION  (-942 -166.3990606640429 -1108.399060664043 #t)
(let ()
  (lambda ()
    (uniform-choice
     (node (data (color (gaussian 54.0 25)) (size 0.3))
           (node (data (color (gaussian 2e1 25)) (size 0.3)))
           (node (data (color (gaussian 21.0 25)) (size 0.3))))
     (node (data (color (gaussian 244.0 25)) (size 0.3))
           (node (data (color (gaussian 235.0 25)) (size 0.3)))
           (node (data (color (gaussian 198.0 25)) (size 0.3))))
     (node (data (color (gaussian 34.0 25)) (size 1))
           (node (data (color (gaussian 108.0 25)) (size 0.1))
                 (node (data (color (gaussian 99.0 25)) (size 0.1))
                       (node
                        (data (color (gaussian 121.0 25)) (size 0.1))
                        (node
                         (data (color (gaussian 135.0 25)) (size 0.1))
                         (node
                          (data (color (gaussian 105.0 25))
                                (size 0.1))
                          (node
                           (data (color (gaussian 104.0 25))
                                 (size 0.1))
                           (node
                            (data (color (gaussian 77.0 25))
                                  (size 0.1))
                            (node
                             (data (color (gaussian 88.0 25))
                                   (size 0.1))
                             (node
                              (data (color (gaussian 112.0 25))
                                    (size 0.1))
                              (node
                               (data
                                (color (gaussian 125.0 25))
                                (size 0.1))
                               (node
                                (data
                                 (color (gaussian 39.0 25))
                                 (size 0.1))
                                (node
                                 (data
                                  (color (gaussian 43.0 25))
                                  (size 0.3))
                                 (node
                                  (data
                                   (color
                                    (gaussian 47.0 25))
                                   (size 0.3)))
                                 (node
                                  (data
                                   (color
                                    (gaussian 27.0 25))
                                   (size 0.3)))))))))))))))
           (node (data (color (gaussian 134.0 25)) (size 0.1))
                 (node (data (color (gaussian 85.0 25)) (size 0.1))
                       (node
                        (data (color (gaussian 126.0 25)) (size 0.1))
                        (node
                         (data (color (gaussian 118.0 25)) (size 0.1))
                         (node
                          (data (color (gaussian 108.0 25))
                                (size 0.1))
                          (node
                           (data (color (gaussian 72.0 25))
                                 (size 0.1))
                           (node
                            (data (color (gaussian 2e1 25))
                                  (size 0.1))
                            (node
                             (data (color (gaussian 75.0 25))
                                   (size 0.1))
                             (node
                              (data (color (gaussian 106.0 25))
                                    (size 0.1))
                              (node
                               (data (color (gaussian 59.0 25))
                                     (size 0.1))
                               (node
                                (data
                                 (color (gaussian 72.0 25))
                                 (size 0.1))
                                (node
                                 (data
                                  (color (gaussian 117.0 25))
                                  (size 0.1))
                                 (node
                                  (data
                                   (color
                                    (gaussian 226.0 25))
                                   (size 0.3))
                                  (node
                                   (data
                                    (color
                                     (gaussian 187.0 25))
                                    (size 0.3)))
                                  (node
                                   (data
                                    (color
                                     (gaussian 211.0 25))
                                    (size 0.3)))))))))))))))))
     (node (data (color (gaussian 19.0 25)) (size 0.3))
           (node (data (color (gaussian 36.0 25)) (size 0.3)))
           (node (data (color (gaussian 27.0 25)) (size 0.3)))))))

;;;INVERSE INLINE (-495 -166.3990606640429 -661.399060664043 #t)
(let ()
  (define F1
    (lambda (V1 V2)
      (data (color (gaussian V1 25)) (size V2))))
  (lambda ()
    (uniform-choice
     (node (F1 54.0 0.3) (node (F1 2e1 0.3))
           (node (F1 21.0 0.3)))
     (node (F1 244.0 0.3) (node (F1 235.0 0.3))
           (node (F1 198.0 0.3)))
     (node (F1 34.0 1)
           (node (F1 108.0 0.1)
                 (node (F1 99.0 0.1)
                       (node (F1 121.0 0.1)
                             (node (F1 135.0 0.1)
                                   (node (F1 105.0 0.1)
                                         (node (F1 104.0 0.1)
                                               (node (F1 77.0 0.1)
                                                     (node (F1 88.0 0.1)
                                                           (node (F1 112.0 0.1)
                                                                 (node (F1 125.0 0.1)
                                                                       (node (F1 39.0 0.1)
                                                                             (node (F1 43.0 0.3)
                                                                                   (node (F1 47.0 0.3))
                                                                                   (node (F1 27.0 0.3))))))))))))))
           (node (F1 134.0 0.1)
                 (node (F1 85.0 0.1)
                       (node (F1 126.0 0.1)
                             (node (F1 118.0 0.1)
                                   (node (F1 108.0 0.1)
                                         (node (F1 72.0 0.1)
                                               (node (F1 2e1 0.1)
                                                     (node (F1 75.0 0.1)
                                                           (node (F1 106.0 0.1)
                                                                 (node (F1 59.0 0.1)
                                                                       (node (F1 72.0 0.1)
                                                                             (node (F1 117.0 0.1)
                                                                                   (node (F1 226.0 0.3)
                                                                                         (node (F1 187.0 0.3))
                                                                                         (node (F1 211.0 0.3))))))))))))))))
     (node (F1 19.0 0.3) (node (F1 36.0 0.3))
           (node (F1 27.0 0.3))))))

;;;INVERSE INLINE (-357 -166.3990606640429 -523.399060664043 #t)
(let ()
  (define F2
    (lambda (V3 V4 V5)
      (node (F1 V3 0.1) (node (F1 V4 0.1) V5))))
  (define F1
    (lambda (V1 V2)
      (data (color (gaussian V1 25)) (size V2))))
  (lambda ()
    (uniform-choice
      (node (F1 54.0 0.3) (node (F1 2e1 0.3))
        (node (F1 21.0 0.3)))
      (node (F1 244.0 0.3) (node (F1 235.0 0.3))
        (node (F1 198.0 0.3)))
      (node (F1 34.0 1)
        (F2 108.0 99.0
          (F2 121.0 135.0
            (F2 105.0 104.0
              (F2 77.0 88.0
                (F2 112.0 125.0
                  (node (F1 39.0 0.1)
                    (node (F1 43.0 0.3) (node (F1 47.0 0.3))
                      (node (F1 27.0 0.3)))))))))
        (F2 134.0 85.0
          (F2 126.0 118.0
            (F2 108.0 72.0
              (F2 2e1 75.0
                (F2 106.0 59.0
                  (F2 72.0 117.0
                    (node (F1 226.0 0.3)
                      (node (F1 187.0 0.3))
                      (node (F1 211.0 0.3))))))))))
      (node (F1 19.0 0.3) (node (F1 36.0 0.3))
        (node (F1 27.0 0.3))))))

;;;INVERSE INLINE (-273 -166.3990606640429 -439.3990606640429 #t)
(let ()
  (define F3
    (lambda (V6 V7 V8)
      (node (F1 V6 0.3) (node (F1 V7 0.3))
        (node (F1 V8 0.3)))))
  (define F2
    (lambda (V3 V4 V5)
      (node (F1 V3 0.1) (node (F1 V4 0.1) V5))))
  (define F1
    (lambda (V1 V2)
      (data (color (gaussian V1 25)) (size V2))))
  (lambda ()
    (uniform-choice (F3 54.0 2e1 21.0)
      (F3 244.0 235.0 198.0)
      (node (F1 34.0 1)
        (F2 108.0 99.0
          (F2 121.0 135.0
            (F2 105.0 104.0
              (F2 77.0 88.0
                (F2 112.0 125.0
                  (node (F1 39.0 0.1) (F3 43.0 47.0 27.0)))))))
        (F2 134.0 85.0
          (F2 126.0 118.0
            (F2 108.0 72.0
              (F2 2e1 75.0
                (F2 106.0 59.0
                  (F2 72.0 117.0 (F3 226.0 187.0 211.0))))))))
      (F3 19.0 36.0 27.0))))

;;;RECURSION-REPLACEMENT (-219 -199.01848746879895 -418.018487468799 #f)
(let ()
  (define F3
    (lambda (V6 V7 V8)
      (node (F1 V6 0.3) (node (F1 V7 0.3))
        (node (F1 V8 0.3)))))
  (define F2
    (lambda (V3 V4)
      ((lambda (V5) (node (F1 V3 0.1) (node (F1 V4 0.1) V5)))
        (if (flip 9/11)
            (F2 121.0 135.0)
            (uniform-choice
              (node (F1 39.0 0.1) (F3 43.0 47.0 27.0))
              (F3 226.0 187.0 211.0))))))
  (define F1
    (lambda (V1 V2)
      (data (color (gaussian V1 25)) (size V2))))
  (lambda ()
    (uniform-choice (F3 54.0 2e1 21.0)
      (F3 244.0 235.0 198.0)
      (node (F1 34.0 1) (F2 108.0 99.0) (F2 134.0 85.0))
      (F3 19.0 36.0 27.0))))

;;;SAME VARIABLE REPLACEMENT (-213 -200.97987093558524 -413.97987093558527 #f)
(let ()
  (define F3
    (lambda (V6 V7)
      ((lambda (V8)
         (node (F1 V6 0.3) (node (F1 V7 0.3))
           (node (F1 V8 0.3))))
        V7)))
  (define F2
    (lambda (V3 V4)
      ((lambda (V5) (node (F1 V3 0.1) (node (F1 V4 0.1) V5)))
        (if (flip 9/11)
            (F2 121.0 135.0)
            (uniform-choice
              (node (F1 39.0 0.1) (F3 43.0 47.0))
              (F3 226.0 187.0))))))
  (define F1
    (lambda (V1 V2)
      (data (color (gaussian V1 25)) (size V2))))
  (lambda ()
    (uniform-choice (F3 54.0 2e1) (F3 244.0 235.0)
      (node (F1 34.0 1) (F2 108.0 99.0) (F2 134.0 85.0))
      (F3 19.0 36.0))))

;;;SAME VARIABLE REPLACEMENT (-207 -202.3678873547221 -409.3678873547221 #f)
(let ()
  (define F3
    (lambda (V7)
      ((lambda (V6)
         ((lambda (V8)
            (node (F1 V6 0.3) (node (F1 V7 0.3))
              (node (F1 V8 0.3))))
           V7))
        V7)))
  (define F2
    (lambda (V3 V4)
      ((lambda (V5) (node (F1 V3 0.1) (node (F1 V4 0.1) V5)))
        (if (flip 9/11)
            (F2 121.0 135.0)
            (uniform-choice (node (F1 39.0 0.1) (F3 47.0))
              (F3 187.0))))))
  (define F1
    (lambda (V1 V2)
      (data (color (gaussian V1 25)) (size V2))))
  (lambda ()
    (uniform-choice (F3 2e1) (F3 235.0)
      (node (F1 34.0 1) (F2 108.0 99.0) (F2 134.0 85.0))
      (F3 36.0))))

;;;INVERSE INLINE (-204 -202.3678873547221 -406.3678873547221 #t)
(let ()
  (define F4 (lambda (V9 V10) (node (F1 V9 0.1) V10)))
  (define F3
    (lambda (V7)
      ((lambda (V6)
         ((lambda (V8)
            (node (F1 V6 0.3) (node (F1 V7 0.3))
                  (node (F1 V8 0.3))))
          V7))
       V7)))
  (define F2
    (lambda (V3 V4)
      ((lambda (V5) (F4 V3 (F4 V4 V5)))
       (if (flip 9/11)
           (F2 121.0 135.0)
           (uniform-choice (F4 39.0 (F3 47.0)) (F3 187.0))))))
  (define F1
    (lambda (V1 V2)
      (data (color (gaussian V1 25)) (size V2))))
  (lambda ()
    (uniform-choice (F3 2e1) (F3 235.0)
                    (node (F1 34.0 1) (F2 108.0 99.0) (F2 134.0 85.0))
                    (F3 36.0))))

;;;STABLE