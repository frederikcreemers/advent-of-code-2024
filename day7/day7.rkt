#lang racket

(define (concat-numbers n1 n2)
  (define magn (+ (exact-floor (log n2 10)) 1))
  (+ (* (expt 10 magn) n1) n2)
)

(define (computable? outcome terms)
  (define first-term (first terms))
  (if (equal? (length terms) 1)
      (equal? first-term outcome)
      (let (
            [second-term (first (rest terms))]
            [other-terms (rest (rest terms))]
            )
        (or
         (computable? outcome (list* (* first-term second-term) other-terms))
         (computable? outcome (list* (+ first-term second-term) other-terms))
         (computable? outcome (list* (concat-numbers first-term second-term) other-terms))
        )
      )
  )
)

(define (computable-value line)

  (define-values (str-outcome str-terms) 
    (apply values (string-split line ":"))
  )
  (define outcome (string->number str-outcome))
  (define terms (map string->number (string-split str-terms)))
  (if (computable? outcome terms) outcome 0)
)

(define (sum-lines-in-file filename)
  (with-input-from-file filename
    (lambda ()
      (let loop ([sum 0])
        (define line (read-line))
        (if (eof-object? line)
            sum
            (loop (+ sum (computable-value line))))))))

(define total (sum-lines-in-file "input.txt"))
(printf "The sum is: ~a\n" total)