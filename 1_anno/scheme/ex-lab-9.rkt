;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ex-lab-9) (read-case-sensitive #t) (teachpacks ((lib "drawings.ss" "installed-teachpacks") (lib "hanoi.ss" "installed-teachpacks"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "drawings.ss" "installed-teachpacks") (lib "hanoi.ss" "installed-teachpacks")) #f)))
;EX-9-1--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; (crittazione "ALEA IACTA EST IVLIVS CAESAR DIXIT" (cif-cesare 3))

(define alf '(#\A #\B #\C #\D #\E #\F #\G #\H #\I #\L #\M #\N #\O #\P #\Q #\R #\S #\T #\V #\X))  ; Alfabeto
(define aZ (- (length alf) 1))  ; Lunghezza dell'alfabeto

(define crittazione  ; Dati una stringa ed una regola di crittazione, restituisce la stringa crittata
  (lambda (msg rgl)  ; msg = stringa da crittare, rgl = regola di crittazione
    (if (= 0 (string-length msg))
      ""
      (string-append (string (rgl (string-ref msg 0))) (crittazione (substring msg 1) rgl))
    )
  )
)

(define cif-cesare  ; dati il numero di rotazioni, restituisce la regola di crittazione
  (lambda (rot)  ; rot = numero di rotazioni
    (lambda (c)
      (if (= (trad c) -1)
        #\-
        (let ((a (+ (trad c) rot)))
          (if (<= a aZ)
            (list-ref alf a)
            (list-ref alf (- a (+ aZ 1)))
          )
        )
      )
    )
  )
)

(define belong?  ; Controlla se un carattere c è presente nell'alfabeto
  (lambda (c l)  ; c = carattere da cercare, l = lista alfabeto
    (if (null? l)
      #false
      (if (char=? c (car l))
        #true
        (belong? c (cdr l))
      )
    )
  )
)

(define trad  ; Restituisce la posizione di un carattere nell'alfabeto
  (lambda (c)  ; c = carattere da cercare
    (if (not (belong? c alf))
      -1
      (checkp c alf 0)
    )
  )
)

(define checkp  ; Helper per trad
  (lambda (c l k)  ; c = carattere da cercare, l = lista alfabeto, k = counter
    (if (char=? c (car l))
      k
      (checkp c (cdr l) (+ k 1))
    )
  )
)

;EX-9-2--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(define H
  (lambda (f g) 
    (lambda (m n)
      (if (= n 0)
        (f m)
        (g m ((H f g) m (- n 1)))
      )
    )
  )
)

(define i  ; funzione identità
  (lambda (x)
    x
  )
)

(define s2
  (lambda (u v)
    (+ v 1)
  )
)

(define add (H i s2))

(define z  ; funzione che assume valore 0
  (lambda (x)
    0
  )
)

(define mul (H z add))

(define u  ; funzione che assume valore 1
  (lambda (x)
    1
  )
)

(define pow (H u mul))
