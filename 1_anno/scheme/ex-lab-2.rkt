;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ex-lab-2) (read-case-sensitive #t) (teachpacks ((lib "drawings.ss" "installed-teachpacks") (lib "hanoi.ss" "installed-teachpacks"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "drawings.ss" "installed-teachpacks") (lib "hanoi.ss" "installed-teachpacks")) #f)))
; EX-2 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(set-puzzle-shift-step!)

(glue-tiles (glue-tiles larger-tile (shift-right smaller-tile 2)) (shift-down (shift-right (half-turn (glue-tiles larger-tile (shift-right smaller-tile 2))) 2) 1))

(glue-tiles (shift-down (shift-right (glue-tiles (shift-down smaller-tile 4) larger-tile) 2) 1) (half-turn (glue-tiles (shift-down smaller-tile 4) larger-tile)))