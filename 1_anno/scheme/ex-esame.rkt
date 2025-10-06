;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ex-esame) (read-case-sensitive #t) (teachpacks ((lib "drawings.ss" "installed-teachpacks"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "drawings.ss" "installed-teachpacks")) #f)))
;;EX 1
(define match
    (lambda (u v)
        (if (or (string=? u "") (string=? v ""))
            ""
            (let ( (uh (string-ref u 0)) (vh (string-ref v 0)) (s (match (substring u 1) (substring v 1))))
                (if (char=? uh vh)
                    (string-append (string uh) s)
                    (string-append "*" s)
                )
            )
        )
    )
)

;;EX 2
(define offset (char->integer #\0))

(define last-digit
  (lambda (base) (integer->char (+ (- base 1) offset))))

(define next-digit
  (lambda (dgt) (string (integer->char (+ (char->integer dgt) 1)))))

(define increment
  (lambda (num base) ; 2 <= base <= 10
    (let ((digits (string-length num)))
      (if (= digits 0)
          "1"
          (let ((dgt (string-ref num (- digits 1))))
            (if (char=? dgt (last-digit base))
                (string-append (increment (substring num 0 (- digits 1)) base) "0")
                (string-append (substring num 0 (- digits 1)) (next-digit dgt))
            )
          )
      )
    )
  )
)

;;EX 3

(define lcs
  (lambda (u v)
    (lcs-rec 0 u 0 v)
  )
)

(define lcs-rec
  (lambda (i u j v)
    (cond
      ((or (string=? u "") (string=? v "")) '())
      ((char=? (string-ref u i) (string-ref v j))
       (cons (list (+ 1 i) (+ 1 j) (string (string-ref u i)))
             (lcs-rec i (substring u 1) j (substring v 1))))
      (else (better (lcs-rec (+ i 1) u j (substring v 1))
                    (lcs-rec i (substring u 1) (+ j 1) v)))
    )
  )
)


(define better
  (lambda (x y)
    (if (< (length x) (length y)) y x)
  )
)

;; EX 4

(define cyclic-string
  (lambda (pattern length)
    (repeat-pattern pattern length length)
  )
)

(define repeat-pattern
  (lambda (pattern length i)
    (if (= length 0)
      ""
      (if (<= i (string-length pattern))
        (substring pattern 0 i)
        (repeat-pattern (string-append pattern pattern) (- length 1) i)
      )
    )
  )
)

;; EX 5

(define av
  (lambda (myList)
    (if (or (null? myList) (null? (cdr myList)))
      null
      (cond
        ((< (+ (car myList) (car (cdr myList))) 0) (cons -1 (av (cdr myList))) ) 
        ((= (+ (car myList) (car (cdr myList))) 0) (cons 0 (av (cdr myList))) )
        (else
          (cons 1 (av (cdr myList)))
        )
      )
    )
  )
)

;; EX 6

(define belong
  (lambda (x list)
    (if (null? list)
      false
      (if (= x (car list))
        true
        (belong x (cdr list))
      )
    )
  )
)

(define shared
  (lambda (list1 list2)
    (if (or (null? list1) (null? list2))
      null
      (if (>= (length list1) (length list2))
        (if (belong (car list1) list2)
          (if (= (car list1) (car list2))
            (cons (car list1) (shared (cdr list1) (cdr list2)))
            (shared list1 (cdr list2))
          )
          (shared (cdr list1) list2)
        )
        (shared list2 list1)
      )
    )
  )
)

;; EX 7

(define parity-check-failures
  (lambda (myList)
    (if (null? myList)
      null
      (view-list myList 0)
    )
  )
)

(define view-list
  (lambda (myList pos)
    (if (null? myList)
      null
      (if (even? (occasions (car myList)))
        (view-list (cdr myList) (add1 pos))
        (cons pos (view-list (cdr myList) (add1 pos)))
      )
    )
  )
)

(define occasions
  (lambda (str)
    (if (string=? str "")
      0
      (if (char=? (string-ref str 0) #\1)
        (+ 1 (occasions (substring str 1)))
        (occasions (substring str 1))
      )
    )
  )
)

;; EX 8

(define sorted-char-list
  (lambda (str)
    (if (string=? str "")
      null
      (let ((myList (writeC (string-downcase str) '())))
        (if (null? myList)
          null
          (sort myList char<?)
        )
      )
    )
  )
)

(define writeC
  (lambda (str appList)
    (if (string=? str "")
      null
      (if (member? (string-ref str 0) appList)
        (writeC (substring str 1) appList) 
        (cons (string-ref str 0) (writeC (substring str 1) (cons (string-ref str 0) appList)))
      )
    )
  )
)

;; EX 9

(define clean-up
  (lambda (myList)
    (if (null? myList)
      null
      (if (member? (car myList) (cdr myList))
        (clean-up (cdr myList))
        (cons (car myList) (clean-up (cdr myList)))
      )
    )
  )
)

;; EX 10

(define longest-contiguous-repeat
  (lambda (myList)
    (if (null? myList)
      null
      (compare myList '() '())
    )
  )
)

(define compare
  (lambda (myList appList mostList)
    (if (null? myList)
      (check-bigger appList mostList)
      (if (null? appList)
        (compare (cdr myList) (list (car myList) 1) (list (car myList) 1))
        (if (string=? (car myList) (car appList))
          (if (string=? (car myList) (car mostList))
            (compare (cdr myList) (list (car myList) (+ (second appList) 1)) (list (car mostList) (+ (second mostList) 1)))
            (compare (cdr myList) (list (car myList) (+ (second appList) 1)) (check-bigger appList mostList))
          )
          (compare (cdr myList) (list (car myList) 1) (check-bigger appList mostList))
        )
      )
    ) 
  )
)

(define check-bigger
  (lambda (list1 list2)
    (if (null? list2)
      (if (null? list1)
        null
        list1
      )
      (if (< (second list1) (second list2))
        list2
        list1
      ) 
    )
  )
)

;; 19/01/23 ---------------------------------------------------------------------------------------------------

;; EX 1

(define matrix-vector-product
  (lambda (listM listV)
    (if (or (null? listM) (null? listV))
      null
      (if (null? (cdr listM))
        (list (scalar-product (car listM) listV))
        (cons (scalar-product (car listM) listV) (matrix-vector-product (cdr listM) listV))
      )
    )
  )
)

(define scalar-product ; val: numero
  (lambda (u v) ; u, v: liste numeriche
    (if (null? u)
      0
      (+ (* (car u) (car v)) (scalar-product (cdr u) (cdr v)))
    )
  )
)

;; EX 2

(define scs ; val: stringa
  (lambda (u v) ; u, v: stringhe
    (cond
      ((string=? u "") v)
      ((string=? v "") u)
      ((char=? (string-ref u 0) (string-ref v 0))
        (string-append (substring u 0 1) (scs (substring u 1) (substring v 1)))
      )
      (else
        (let ((x (scs (substring u 1) v))
              (y (scs u (substring v 1))))
          (if (< (string-length x) (string-length y))
            (string-append (substring u 0 1) x)
            (string-append (substring v 0 1) y)
          )
        )
      )
    )
  )
)

;; EX 3

(define 2-3-tessellations
  (lambda (n)
    (cond
      ((= n 0) (list null))
      ((= n 1) null)
      ((= n 2) (list (list 2)))
      (else
        (append
          (map (add-leftmost-tile 2) (2-3-tessellations (- n 2)) )
          (map (add-leftmost-tile 3) (2-3-tessellations (- n 3)) )
        )
      )
    )
  )
)

(define add-leftmost-tile
  (lambda (tile)
    (lambda (x) (cons tile x))
  )
)

;; 21/01/22 ---------------------------------------------------------------------------------------------------

;; EX 1

(define cyclic-pattern
  (lambda (pattern length)
    (if (or (<= length 0) (> (remainder (string-length pattern) length) 0))
      ""
      (if (= (string-length pattern) length)
        pattern
        (if (check (substring pattern 0 length) (substring pattern length) length)
          (string-append (substring pattern 0 length) (cyclic-pattern (substring pattern length) length))
          ""
        )
      )
    )
  )
)

(define check
  (lambda (pattern str length)
    (if (string=? str "")
      #t
      (if (string=? pattern (substring str 0 length))
        (check pattern (substring str length) length)
        #f
      )
    )
  )
)

;; EX 2

(define tess-1x-2 ; val: intero
  (lambda (n) ; n: intero non negativo
    (if (<= n 2)
      1
      (+ (tess-1x-2 (- n 2)) (tess-1x-2 (- n 3)))
    )
  )
)

;; EX 3 b

(define paths ; val: lista di stringhe
  (lambda (i j k) ; i, j, k: interi non negativi
    (paths-rec i j k k)
  )
)

(define paths-rec
  (lambda (i j k u)
    (cond
      ((= i 0) (list (make-string j #\1)))
      ((= j 0) (if (> i u) null (list (make-string i #\0))))
      ((= u 0) (map (lambda (x) (string-append "1" x)) (paths-rec i (- j 1) k k)))
      (else
        (append
          (map (lambda (x) (string-append "0" x)) (paths-rec (- i 1) j k (- u 1)))
          (map (lambda (x) (string-append "1" x)) (paths-rec i (- j 1) k k))
        )
      )
    )
  )
)

;; 29/01/21 ---------------------------------------------------------------------------------------------------

;; EX 1

(define pair
  (lambda (x y)
    (list (/ (+ x y) 2) (/ (abs (- x y)) 2))
  )
)

(define pair-list
  (lambda (list1 list2)
     (if (not (= (length list1) (length list2)))
       null
       (if (or (null? list1) (null? list2))
         null
         (cons (pair (car list1) (car list2)) (pair-list (cdr list1) (cdr list2)))
       )
     )
   )
)

;; EX 2

(define lcs-align ; val: coppia di liste di caratteri
  (lambda (u v) ; u, v: stringhe
    (let ( (m (string-length u)) (n (string-length v)) )
      (cond
        ( (or (= m 0) (= n 0)) (list (string->list u) (string->list v)) )
        ( (char=? (string-ref u 0) (string-ref v 0)) (lcs-align (substring u 1) (substring v 1)))
        (else
          (let ((du (lcs-align (substring u 1) v)) (dv (lcs-align u (substring v 1))))
            (if (> (+ (length (car du)) (length (cadr du))) (+ (length (car dv)) (length (cadr dv))))
              (list (car dv) (cons (string-ref v 0) (cadr dv)))
              (list (cons (string-ref u 0) (car du)) (cadr du))
            )
          )
        )
      )
    )
  )
)

;; EX 4

(define parity-check? ; val: booleano
  (lambda (words) ; words: lista non vuota di stringhe di 0/1 della stessa lunghezza
    (rec-check? words 0 (string-length (car words)))
  )
)
 
(define rec-check?
  (lambda (words k n)
    (if (< k n)
      (let ((kths (map (bit k) words))) ; kths: lista dei valori dei bit in posizione k nelle parole di words
        (if (even? (count-ones kths))
          (rec-check? words (+ k 1) n)
          false
        )
      )
      true
    )
  )
)

(define bit
  (lambda (k)
    (lambda (word) (string->number (substring word k (+ k 1))))
  )
)

(define count-ones
  (lambda (cs)
    (if (null? cs)
      0
      (+ (car cs) (count-ones (cdr cs)))
    )
  )
)

;; 04/02/20 ---------------------------------------------------------------------------------------------------

;; EX 2

(define standard-form
  (lambda (myList)
    (if (null? myList)
      null
      (cons (checkW (car myList)) (standard-form (cdr myList)))
    )
  )
)

(define checkW
  (lambda (word)
    (if (string=? word "")
      ""
      (if (string-upper-case? word)
        word
        (string-append (string-upcase (substring word 0 1)) (substring word 1))
      )
    )
  )
)

;; EX 3

(define btr-val-tr
  (lambda (btr)
    (btr-val-rec btr 0)
  )
)

(define btr-val-rec
  (lambda (btr i)
    (let ((k (string-length btr)))
      (if (= k 0)
        i
        (let ((q (substring btr 1)) (t (string-ref btr 0)))
          (btr-val-rec q (+ i (cond ((char=? t #\-) -1) ((char=? t #\.) 0) ((char=? t #\+) +1) )))
        )
      ))))