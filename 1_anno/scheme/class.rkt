(define crittazione ; val: stringa
    (lambda (msg rgl) ; msg: stringa - rgl: procedura [char -> char]
        (if (sring=? msg "")
            ""
            (string-append (string (rgl (string-ref msg 0))) (crittazione (substring msg 1) rgl))
        )
    )
)

(define reg-cesare
    (lambda (c)
        (let ((a (+ (char->integer c) 3)))
            (if  (<= (+ a 3) aZ)
                (integer->char a)
                (integer->char (- a 26))
            )
        )
    )
)

(define aZ (char->integer #\Z))
(define aA (char->integer #\A))

(define reg-decrittazione-gen ; val: procedura [char -> char]
    (lambda (rgl) ; rgl: procedura [char -> char] biiettiva 
        (lambda (c) ; c: char
            (ricerca rgl c aA)
        )
    )
)

(define ricerca ;val: char
    (lambda (rgl c a) ; rgl: procedura [char -> char] biiettiva - c: char - a: integer (ascii)
        (if (char=? (rgl (integer->char a)) c)
            (integer->char a)
            (ricerca rgl c (+ a 1))
        )
    )
)