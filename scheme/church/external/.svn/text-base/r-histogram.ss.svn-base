#!r6rs

(library (church external r-histogram)
         (export histogram hist truehist)
         (import (church utils rnrs)
                 (church external r-project)
                 (_srfi :1)
                 (_srfi :69)
                 (only (ikarus) inexact->exact exact->inexact)
                 (only (ikarus) format))

 (define (histogram values filetype title) ; xlab ylab . args)
   (define next-int 0)
   (define val-to-int (make-hash-table))
   (define labels '())
   (define int-values (map (lambda (val) (hash-table-ref val-to-int
                                                          val
                                                          (lambda () (begin (hash-table-set! val-to-int val next-int)
                                                                            (set! labels (append labels (list val)))
                                                                            (set! next-int (+ 1 next-int))
                                                                            (hash-table-ref val-to-int val)))))
                            values))
   (define r-port (open-r-port))
   (begin
     (r r-port filetype title)
     (r r-port "hist" int-values "col=" "lightblue" "axes=" "False" "ann=" "False")
     ;(r r-port "axis" 1 "at=" (iota (length labels)) "lab=" (list "\"true\"" "\"false\""))
     (r r-port "axis" 1 "at=" (iota (length labels)) "lab=" (map (lambda (x) (format "\"~a\"" x)) labels))
     (r r-port "axis" 2)
     (close-r-port r-port)))
 
 (define (count-values values)
  (define count-table (make-hash-table))
  (define counts '())
  (define labels '())
  (begin
    
    ;build the count table
    (for-each 
     (lambda (val)
       (let* ((last-total (hash-table-ref count-table val (lambda () 0)))
              (new-total (+ last-total 1)))
         (hash-table-set!  count-table val new-total)))
     values)
    
    ;build the label and count lists
    (for-each 
     (lambda (key)
       (let ((count (hash-table-ref count-table key (lambda () 0))))
         (begin
           (set! labels (append labels (list key)))
           (set! counts (append counts (list count))))))
     (hash-table-keys count-table))
    
    (cons labels counts)))
     
 
 ;calculate the percentages and use a barplot instead of a histogram
 (define (hist values title) ; xlab ylab . args)
   (define res (count-values values))
   (define labels (first res))
   (define counts (cdr res))
   (define total (length values))
   (define normalized-counts (map (lambda (c) (/ c total)) counts))

   (define r-port (open-r-port))
   
   (begin
     (r r-port "png" (string-append title ".png"))
     (r r-port "barplot" normalized-counts "main=" title "col=" "lightblue" "names.arg=" (map (lambda (x) (format "\"~a\"" x)) labels) "ylim=" (list 0 1))
     (close-r-port r-port)))
 
 (define (set-precision n)
   (let* ((max-decimals 3)
          (k (expt 10.0 max-decimals)))
     (if (number? n)
         (if (integer? n)
             (inexact->exact n)
             (/ (round (* n k))
                k))
         n)))

 
 ;build a true histogram with continuous values
 (define (truehist values title) ; xlab ylab . args)
   (define r-port (open-r-port))
   (define new-values (map set-precision values))
   (begin
     (display new-values)
     (r r-port "library" 'MASS)
     (r r-port "png" (string-append title ".png"))
     (r r-port "truehist" new-values "main=" title "col=" "lightblue" "xlab=" "values")
     (close-r-port r-port)))
 
 
 )
         ; "pdf('~a.pdf'); hist(~a, main='~a', col='lightblue', xlab='~a', ylab='~a'~a)" title "~a" title xlab ylab parameters) values)))



;; (define r-port (open-r-port))
;; (r r-port "plot" (list 1 2 3)
;;                  (map log (list 1 2 3))
;;                  "xlab=" "x"
;;                  "ylab=" "y"
;;                  "main=" "title" 
;;                  "type=" "l")
;; (close-r-port r-port)

;;axis(1, at=1:5, lab=c("Mon","Tue","Wed","Thu","Fri"))
;
;# Make y axis with horizontal labels that display ticks at 
;# every 4 marks. 4*0:g_range[2] is equivalent to c(0,4,8,12).
;axis(2, las=1, at=4*0:g_range[2])