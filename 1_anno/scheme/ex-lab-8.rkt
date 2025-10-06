;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ex-lab-8) (read-case-sensitive #t) (teachpacks ((lib "drawings.ss" "installed-teachpacks") (lib "hanoi.ss" "installed-teachpacks"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "drawings.ss" "installed-teachpacks") (lib "hanoi.ss" "installed-teachpacks")) #f)))
;EX-8--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; (hanoi-picture 15 19705)

(define hanoi-moves ; Restituisce la lista di mosse per risolvere il rompicapo con n dischi
  (lambda (n)  ; n = numero dischi
    (hanoi-rec n 1 2 3)
  )
)

(define hanoi-rec  ; Restituisce la lista di mosse per risolvere il rompicapo
  (lambda (n s d t)  ; n = numero dischi, s, d, t = posizioni
    (if (= n 1)
      (list (list s d))
      (let ((m1 (hanoi-rec (- n 1) s t d)) (m2 (hanoi-rec (- n 1) t d s)))
        (append m1 (cons (list s d) m2))
      )
    )
  )
)

(define hanoi-disks  ; Dati n dischi, restituisce la configurazione alla k-esima mossa
  (lambda (n k)  ; n = numero dischi, k = mosse
    (hanoi-count (hanoi-moves n) n 0 0 k)
  )
)

(define hanoi-count  ; Helper per hanoi-disks
  (lambda (moves c1 c2 c3 k)  ; moves = lista di mosse, c1, c2, c3 = numero di dischi per posizione, k = mosse
    (if (= k 0)
      (list (list 1 c1) (list 2 c2) (list 3 c3))
      (let ((x (car (car moves))) (y (second (car moves))))
        (cond
          ((= x 1) (if (= y 2) (hanoi-count (cdr moves) (- c1 1) (+ c2 1) c3 (- k 1)) (hanoi-count (cdr moves) (- c1 1) c2 (+ c3 1) (- k 1))))
          ((= x 2) (if (= y 1) (hanoi-count (cdr moves) (+ c1 1) (- c2 1) c3 (- k 1)) (hanoi-count (cdr moves) c1 (- c2 1) (+ c3 1) (- k 1))))
          ((= x 3) (if (= y 1) (hanoi-count (cdr moves) (+ c1 1) c2 (- c3 1) (- k 1)) (hanoi-count (cdr moves) c1 (+ c2 1) (- c3 1) (- k 1))))
        )
      )
    )
  )
)

(define hanoi-picture  ; Dati n dischi, restituisce l'immagine della configurazione alla k-esima mossa
  (lambda (n k)  ; n = numero dischi, k = mosse
    (let ((asts (hanoi-ast (hanoi-moves n) (range 1 (+ n 1) 1) '() '() k)))
      (cond
        ((empty? (first asts))
          (if (empty? (second asts))
            (above (draw (third asts) n 3) (towers-background n))
            (if (empty? (third asts))
              (above (draw (second asts) n 2) (towers-background n))
              (above (above (draw (second asts) n 2) (draw (third asts) n 3)) (towers-background n))
            )
          )
        )
        ((empty? (second asts))
          (if (empty? (third asts))
            (above (draw (first asts) n 1) (towers-background n))
            (if (empty? (first asts))
              (above (draw (third asts) n 3) (towers-background n))
              (above (above (draw (first asts) n 1) (draw (third asts) n 3)) (towers-background n))
            )
          )
        )
        ((empty? (third asts))
          (if (empty? (first asts))
            (above (draw (second asts) n 2) (towers-background n))
            (if (empty? (second asts))
              (above (draw (first asts) n 1) (towers-background n))
              (above (above (draw (first asts) n 1) (draw (second asts) n 2)) (towers-background n))
            )
          )
        )
        (else (above (above (above (draw (first asts) n 1) (draw (second asts) n 2)) (draw (third asts) n 3)) (towers-background n)))
      )
    ) 
  )
)

(define hanoi-ast  ; Restituisce la configurazione delle aste alla k-esima mossa
  (lambda (moves a1 a2 a3 k)  ; moves = lista di mosse, a1, a2, a3 = aste per posizione, k = mosse
    (if (= k 0)
      (list a1 a2 a3)
      (let ((x (car (car moves))) (y (second (car moves))))
        (cond
          ((= x 1) (if (= y 2) (hanoi-ast (cdr moves) (cdr a1) (cons (car a1) a2) a3 (- k 1)) (hanoi-ast (cdr moves) (cdr a1) a2 (cons (car a1) a3) (- k 1))))
          ((= x 2) (if (= y 1) (hanoi-ast (cdr moves) (cons (car a2) a1) (cdr a2) a3 (- k 1)) (hanoi-ast (cdr moves) a1 (cdr a2) (cons (car a2) a3) (- k 1))))
          ((= x 3) (if (= y 1) (hanoi-ast (cdr moves) (cons (car a3) a1) a2 (cdr a3) (- k 1)) (hanoi-ast (cdr moves) a1 (cons (car a3) a2) (cdr a3) (- k 1))))
        )
      )
    )
  )
)

(define draw  ; Data un'asta, restituisce l'immagine dell'asta configurata
  (lambda (ast n p)  ; ast = asta, n = numero dischi, p = posizione dell'asta
    (let ((t (- (length ast) 1)))
      (if (= (length ast) 1)
        (disk-image (car ast) n p t)
        (above (disk-image (car ast) n p t) (draw (cdr ast) n p))
      )
    )
  )
)