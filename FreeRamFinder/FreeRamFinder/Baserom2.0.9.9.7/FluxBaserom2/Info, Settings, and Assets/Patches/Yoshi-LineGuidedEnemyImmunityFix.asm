; Modified by SJandCharlieTheCat to remove explosion stuff, so only Yoshi fixes 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;						;;
;;	Explosion & Yoshi Immunity Fix		;;
;;			by SkywinDragoon	;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This patch will fix two bugs:
;; 1. Explosion will be immune to cape, sliding, star, and explosion
;; 2. Line guided sprites can't damage Yoshi
;; 
;; Custom Sprite Guide:
;;	in .cfg file,
;;	If "Invincible to star/cape/fire/bouncing bricks"($167A, bit 1)bit is set,
;;	"Don't disable clipping when killed with star"($167A, bit 0)bit will function as "Damages Yoshi"
;;	So, turning bit 1 only will make immune to explosions, and canot harm Yoshi.
;;	and turning bit 1, and 0 will make immune to explosions, and harm Yoshi.

header
	lorom
	!9E = $009E
	!167A = $167A
	!1534 = $1534
	!190F = $190F
if read1($00ffd5) == $23
	sa1rom
	!9E = $3200
	!167A = $7616
	!1534 = $32B0
	!190F = $7658
endif
org $01F651
autoclean JSL SkipExplosion
NOP

org $07F52C                     ; Table starts $07F4C7
	db $23,$23,$23,$23	; $167A Sprite fix 65,66,67,68
                                ; vanilla $22,$22,$22,$22

freecode
SkipExplosion:
	LDA !9E,y		; I don't know if it is neccessary...
	CMP #$35		; Yoshi won't hurt another Yoshi.
	BEQ .Restore		;
	LDA !167A,y		; Check if the both bits are set
	AND #$03		; Bit 0 : Damages Yoshi
	CMP #$03		; Bit 1 : Immune to Explosions, Star, Cape, Fireball, etc...
	BEQ .ApplySkip		; If yes, try damage yoshi.
.Restore:
	LDA !167A,y		; Hijacked code
	AND #$02		; This will make sprites immune to explosions will not also damage Yoshi.
	RTL
.ApplySkip
	LDA #$00		; Try damage Yoshi.
	RTL
.Return:
	RTL