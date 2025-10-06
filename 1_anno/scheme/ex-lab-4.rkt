;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ex-lab-4) (read-case-sensitive #t) (teachpacks ((lib "drawings.ss" "installed-teachpacks"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "drawings.ss" "installed-teachpacks")) #f)))
;EX-4--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; (btr-sum "-+--" "+") → "-+-."
; (btr-sum "-+--" "-") → "-.++"
; (btr-sum "+-.+" "-+.-") → "."
; (btr-sum "-+--+" "-.--") → "--++."
; (btr-sum "-+-+." "-.-+") → "-.-.+"
; (btr-sum "+-+-." "+.+-") → "+.+.-"


(define btr-sum  ; Dari due valori in BTR, restituisce la loro somma sempre in BTR
  (lambda (val1 val2)  ; val1 = 1o valore in BTR, val2 = 2o valore in BTR
    (cond
      ((= (string-length val1) 0) val2)
      ((= (string-length val2) 0) val1)
      (else (normalized-btr (btr-carry-sum val1 val2 #\.)))
    )
  )
)

(define btr-carry-sum  ; Dari due valori in BTR, restituisce la loro somma con il riporto
  (lambda (val1 val2 c)  ; val1 = 1o valore in BTR, val2 = 2o valore in BTR, c = carry
    (cond
      ((and (= (string-length val1) 0) (= (string-length val2) 0)) "")
      ((= (string-length val1) 0) (btr-carry-sum (make-string (string-length val2) #\.) val2 c))
      ((= (string-length val2) 0) (btr-carry-sum val1 (make-string (string-length val1) #\.) c))
      (else
        (let ((s (btr-digit-sum (lsd val1) (lsd val2) c)) (r (btr-carry (lsd val1) (lsd val2) c)))
          (string-append (btr-carry-sum (head val1) (head val2) r) (string s))
        )
      )
    )
  )
)

(define normalized-btr  ; Restituisce la rappresentazione non vuota equivalente rimuovendo zeri superflui
  (lambda (val1)  ; val1 = valore in BTR da normalizzare
    (cond
      ((<= (string-length val1) 1) val1)
      ((or (char=? (string-ref val1 0) #\-) (char=? (string-ref val1 0) #\+)) val1)
      (else (normalized-btr (substring val1 1)))
    )
  )
)

(define lsd  ; Restituisce la cifra meno significativa di val1
  (lambda (val1)  ; val1 = valore in BTR
    (if (= (string-length val1) 0)
      #\.
      (string-ref val1 (- (string-length val1) 1))
    )
  )
)

(define head  ; Restituisce la parte di val1 che precede l'ultima cifra
  (lambda (val1)  ; val1 = valore in BTR
    (if (= (string-length val1) 0)
      ""
      (substring val1 0 (- (string-length val1) 1))
    )
  )
)

(define btr-digit-sum  ; Date due cifre in BTR, ed il riporto, restituisce la somma di suddette cifre
  (lambda (u v c)  ; u = cifra 1, v = cifra 2, c = riporto
    (cond
      ((char=? u #\-)                
        (cond
          ((char=? v #\-)
            (cond
              ((char=? c #\-) #\.)
              ((char=? c #\.) #\+)
              ((char=? c #\+) #\-)
            )
          )
          ((char=? v #\.)
            (cond
              ((char=? c #\-) #\+)
              ((char=? c #\.) #\-)
              ((char=? c #\+) #\.)
            )
          )
          ((char=? v #\+) c)
        )
      )
      ((char=? u #\.)
        (cond
          ((char=? v #\-)
            (cond
              ((char=? c #\-) #\+)
              ((char=? c #\.) #\-)
              ((char=? c #\+) #\.)
            )
          )
          ((char=? v #\.) c)
          ((char=? v #\+)
            (cond
              ((char=? c #\-) #\.)
              ((char=? c #\.) #\+)
              ((char=? c #\+) #\-)
            )
          )
        )
      )
      ((char=? u #\+)
        (cond
          ((char=? v #\-) c)
          ((char=? v #\.)
            (cond
              ((char=? c #\-) #\.)
              ((char=? c #\.) #\+)
              ((char=? c #\+) #\-)
            )
          )
          ((char=? v #\+)
            (cond
              ((char=? c #\-) #\+)
              ((char=? c #\.) #\-)
              ((char=? c #\+) #\.)
            )
          )
        )
      )
    )
  )
)

(define btr-carry  ; Date due cifre in BTR, ed il riporto, restituisce il riporto della somma di suddette cifre
  (lambda (u v c)  ; u = cifra 1, v = cifra 2, c = riporto
    (cond
      ((char=? u #\-)                
        (cond
          ((char=? v #\-)
            (cond
              ((char=? c #\-) #\-)
              ((char=? c #\.) #\-)
              ((char=? c #\+) #\.)
            )
          )
          ((char=? v #\.)
            (cond
              ((char=? c #\-) #\-)
              ((char=? c #\.) #\.)
              ((char=? c #\+) #\.)
            )
          )
          ((char=? v #\+)
            (cond
              ((char=? c #\-) #\.)
              ((char=? c #\.) #\.)
              ((char=? c #\+) #\.)
            )
          )
        )
      )
      ((char=? u #\.)
        (cond
          ((char=? v #\-)
            (cond
              ((char=? c #\-) #\-)
              ((char=? c #\.) #\.)
              ((char=? c #\+) #\.)
            )
          )
          ((char=? v #\.)
            (cond
              ((char=? c #\-) #\.)
              ((char=? c #\.) #\.)
              ((char=? c #\+) #\.)
            )
          )
          ((char=? v #\+)
            (cond
              ((char=? c #\-) #\.)
              ((char=? c #\.) #\.)
              ((char=? c #\+) #\+)
            )
          )
        )
      )
      ((char=? u #\+)
        (cond
          ((char=? v #\-)
            (cond
              ((char=? c #\-) #\.)
              ((char=? c #\.) #\.)
              ((char=? c #\+) #\.)
            )
          )
          ((char=? v #\.)
            (cond
              ((char=? c #\-) #\.)
              ((char=? c #\.) #\.)
              ((char=? c #\+) #\+)
            )
          )
          ((char=? v #\+)
            (cond
              ((char=? c #\-) #\-)
              ((char=? c #\.) #\+)
              ((char=? c #\+) #\+)
            )
          )
        )
      )
    )
  )
)