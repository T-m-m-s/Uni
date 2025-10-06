;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ex-lab-1) (read-case-sensitive #t) (teachpacks ((lib "drawings.ss" "installed-teachpacks") (lib "hanoi.ss" "installed-teachpacks"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "drawings.ss" "installed-teachpacks") (lib "hanoi.ss" "installed-teachpacks")) #f)))
;EX-1 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; (frase "gatto" "cacciare" "topi") → "il gatto caccia i topi"
; (frase "mucca" "mangiare" "fieno") → "la mucca mangia il fieno"
; (frase "sorelle" "leggere" "novella") → "le sorelle leggono la novella"
; (frase "bambini" "amare" "favole") → "i bambini amano le favole"
; (frase "musicisti" "suonare" "pianoforti") → "i musicisti suonano i pianoforti"
; (frase "cuoco" "friggere" "patate") → "il cuoco frigge le patate"
; (frase "camerieri" "servire" "clienti") → "i camerieri servono i clienti"
; (frase "mamma" "chiamare" "figlie") → "la mamma chiama le figlie"

; Maschile/Femminile

(define maschile?  ; Restituisce true se la parola passata è maschile
  (lambda (s)  ; s = stringa da verificare
    (let ((desinenza (substring s (- (string-length s) 1))))
      (if (or (string=? desinenza "o" ) (string=? desinenza "i" )) #true #false)
    )
  )
)

; Plurale/Singolare

(define singolare? ; Restituisce true se la parola passata è singolare
  (lambda (s)  ; s = stringa da verificare
    (let ((desinenza (substring s (- (string-length s) 1))))
      (if (or (string=? desinenza "o" ) (string=? desinenza "a" )) #true #false)
    )
  )
)

; Coniugazione

(define are?  ; Restituisce true se il verbo passato è in prima coniugazione
  (lambda (verbo)  ; verbo = verbo (all'infinito) da verificare
    (if (string=? (substring verbo (- (string-length verbo) 3)) "are") #true #false)
  )
)

(define gestione-verbo  ; Gestisce il verbo in base a singolare/plurale del soggetto e coniugazione
  (lambda (verbo soggetto)  ; verbo = verbo (all'infinito) da gestire
    (cond
      ((singolare? soggetto) (if (are? verbo) (string-append (substring verbo 0 (- (string-length verbo) 2))) (string-append (substring verbo 0 (- (string-length verbo) 3)) "e"))) ; s
      ((not (singolare? soggetto)) (if (are? verbo) (string-append (substring verbo 0 (- (string-length verbo) 2)) "no") (string-append (substring verbo 0 (- (string-length verbo) 3)) "ono"))) ; p
    )
  )
)


; Articoli

(define articolo  ; Restituisce l'articolo corretto in base a singolare/plurale del soggetto
  (lambda (sostantivo)  ; sostantivo = stringa da verificare
    (cond
      ((and (singolare? sostantivo) (maschile? sostantivo)) (string-append "il"))
      ((and (not (singolare? sostantivo)) (maschile? sostantivo)) (string-append "i"))
      ((and (singolare? sostantivo) (not (maschile? sostantivo))) (string-append "la"))
      ((and (not (singolare? sostantivo)) (not (maschile? sostantivo))) (string-append "le"))
    )
  )
)

; Main

(define frase  ; Unisce la frase corretta in base al verbo, al soggetto e al coniugato
  (lambda (s p c)  ; s = soggetto, p = verbo, c = coniugato
    (string-append (articolo s) " " s " " (gestione-verbo p s) " " (articolo c) " " c)
  )
)