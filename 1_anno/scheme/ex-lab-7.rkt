;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ex-lab-7) (read-case-sensitive #t) (teachpacks ((lib "drawings.ss" "installed-teachpacks"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "drawings.ss" "installed-teachpacks")) #f)))
;EX-7-1--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; (belong? 18 '(5 7 10 18 23))
; (belong? 18 '(5 7 10 12 23)) 

(define belong?  ; Verifica se l'intero n appartiene alla lista list
  (lambda (n list)  ; n = intero, list = lista di interi
    (if (null? list)
      #false
      (if (= n (car list))
        #true
        (belong? n (cdr list))
      )
    )
  )
)

;EX-7-2--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; (position 7 '(7 8 24 35 41))
; (position 35 '(7 8 24 35 41))

(define position  ; Restituisce la posizione dell'interno n nella lista list
  (lambda (n list)  ; n = intero, list = lista di interi
    (if (not (belong? n list))
      -1
      (checkp n list 0)
    )
  )
)

(define checkp  ; Helper per trovare la posizione ricorsivamente
  (lambda (n list c)  ; n = intero, list = lista di interi, c = counter
    (if (= n (car list))
      c
      (checkp n (cdr list) (+ c 1))
    )
  )
)

;EX-7-3--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; (sorted-ins 24 '())
; (sorted-ins 5 '(7 8 24 35 41))
; (sorted-ins 24 '(7 8 24 35 41))

(define sorted-ins  ; Dato un intero n e una lista list, restituisce la lista list con n inserito in modo ordinato
  (lambda (n list)  ; n = intero, list = lista di interi
    (if (null? list)
      (cons n null)
      (if (belong? n list)
        list
        (if (< n (car list))
          (cons n list)
          (cons (car list) (sorted-ins n (cdr list)))
        )
      )
    )
  )
)

;EX-7-4--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; (sorted-list '(35 8 41 24 7))
; (sorted-list '(35 24 8 41 24 7))

(define sorted-list  ; Dato una lista list, restituisce la lista list ordinata senza ripetizioni
  (lambda (list)  ; list = lista di interi
    (if (or (null? list) (null? (cdr list)))
      list
      (sorted-ins (car list) (sorted-list (cdr list)))  ; Se l'elemento non appartiene alla lista, viene inserito in modo ordinato
    )
  )
)