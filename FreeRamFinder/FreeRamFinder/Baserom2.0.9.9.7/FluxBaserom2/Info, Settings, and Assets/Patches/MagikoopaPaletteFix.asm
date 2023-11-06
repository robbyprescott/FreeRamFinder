;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Magikoopa Palette Correction Patch ;;
;; by andy_k_250		      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The lightest blue color in Magikoopa's	  ;;
;; fade-in/fade-out palette table was		  ;;
;; inverted in the original game for some reason. ;;
;; This patch corrects that problem.		  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!base1 = $0000
!base2 = $0000

if read1($00FFD5) == $23
sa1rom
!base1 = $3000
!base2 = $6000
endif

org $03B90C	;x1BB0C
db $00,$28		;92 7E

org $03B91C	;x1BB1C
db $40,$34		;2F 72

org $03B92C	;x1BB2C
db $A3,$40		;CC 65

org $03B93C	;x1BB3C
db $06,$4D		;69 59

org $03B94C	;x1BB4C
db $69,$59		;06 4D

org $03B95C	;x1BB5C
db $CC,$65		;A3 40

org $03B96C	;x1BB6C
db $2F,$72		;40 34

org $03B97C	;x1BB7C
db $92,$7E		;00 28