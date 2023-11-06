;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sprite Height Fix by Edit1754, further changed by Davros and SJandCharlieTheCat.
;;
;; Makes a few sprites shift up by 1 pixel during their initialization routine. In other
;; words, it fixes that irritating problem where the Exploding Block, Turn Block Bridges,
;; Info Box, Grey Moving Castle Block, Swooper Bat and Light Switch Block look awkward
;; when mixed in with regular blocks because it's a pixel too low.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sprite Height Init code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if read1($00FFD5) == $23
	sa1rom
endif

org $018215

                    dw InitExplodingBlk     ; Exploding Block

org $01822F

                    dw Align                ; Turn Block Bridge, horizontal and vertical 

org $018231

                    dw Align                ; Turn Block Bridge, horizontal

org $0182EF

                    dw Align                ; Info Box

org $0182F3

                    dw Align                ; Grey Moving Castle Block

org $0182F9

                    dw Align                ; Swooper Bat

org $018305

                    dw Align                ; Grey falling platform

org $01830D

                    dw Align                ; Light Switch Block for dark room

org $0185B7

Align:

org $01FFF0

InitExplodingBlk:   JSR Align               ; align height routine
                    JMP $83A4               ; exploding block init routine