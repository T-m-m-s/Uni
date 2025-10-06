;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ex-lab-5) (read-case-sensitive #t) (teachpacks ((lib "drawings.ss" "installed-teachpacks"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "drawings.ss" "installed-teachpacks")) #f)))
;EX-5--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; (manhattan-3d 0 0 7) → 1
; (manhattan-3d 2 0 2) → 6
; (manhattan-3d 1 1 1) → 6
; (manhattan-3d 1 1 5) → 42
; (manhattan-3d 2 3 1) → 60
; (manhattan-3d 2 3 3) → 560

(define manhattan-3d  ; Restituisce il numero di percorsi diversi di lunghezza minima attraverso un 
                      ; reticolo tridimensionale fra punti che distano  i, j e k unità lungo le tre direzioni 
  (lambda (i j k)  ; i, j e k = tre punti nello spazio tridimensionale
    (cond
      ((= k 0) (manhattan i j))  ; Se uno dei tre punti è 0 allora calcola bidimensionalmente sugli altri due
      ((= i 0) (manhattan j k))
      ((= j 0) (manhattan i k))
      (else
        (+
          (+ (manhattan-3d (- i 1) j k) (manhattan-3d i (- j 1) k))
          (manhattan-3d i j (- k 1))
        )
      )
    )
  )
)

(define manhattan  ; Restituisce il numero di percorsi di Manhattan dal punto i al punto j
  (lambda (i j)  ; i e j = due punti nello spazio bidimensionale
    (cond
      ((= i 0) 1)
      ((= j 0) 1)
      (else (+ (manhattan i (- j 1)) (manhattan (- i 1) j)))
    )
  )
)
