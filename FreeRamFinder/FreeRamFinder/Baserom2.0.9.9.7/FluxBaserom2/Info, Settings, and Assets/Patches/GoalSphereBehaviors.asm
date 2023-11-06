;Sprites become Coins by Goal Sphere
;by Isikoro, with edits by SJandCharlieTheCat
;If !FreezeMarioCompletely set, use Uber FreezeMarioCompletelyOnFlag.asm, to freeze in horizontal levels too

!MusicRAMTrigger = $0DF2 ; if set, will skip the end-level music, and keep playing your normal level music
!GoalWalk = 0	; If 0, will simply remain in place after getting, instead of walking (though still gravity)
!SpritesTurnIntoCoins = 1

; Secret exit functionality?

; The secret exit works only if the sprite is set to make the player walk
; after touching it.  It's an annoying quirk of SMW's exit handling.  It is possible
; to circumvent this by using the hex edit at $00C9FE.

; LDA #$01
; STA $141C

;;;;;;

	!dp = $0000
	!addr = $0000
	!bank = $800000
	!sa1 = 0
	!gsu = 0

if read1($00FFD6) == $15
	sfxrom
	!dp = $6000
	!addr = !dp
	!bank = $000000
	!gsu = 1
elseif read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!bank = $000000
	!sa1 = 1
endif

;;;;;

;;; Goal point sphere
org $019C70 : db $C2 : org $07F448 : db $3A                                       ; Tile

org $018778
autoclean JSL SphereStuff
NOP #12 ; takes care of additional bytes from 01877C - 87

org $00B041
autoclean JSL Black_FG_Only
NOP

org $00C921
LDA $13C6|!addr
BNE $08	; NoWalk, credits?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

freecode;

SphereStuff:
LDA #$01
STA $0E6F ; freeze n place unless (see gm14)
if !GoalWalk = 0
LDA #$FF
STA $13C6|!addr
endif
if !SpritesTurnIntoCoins
JSL $00FA80|!bank	; Sprites become Coins
STZ $14C8,x
endif
LDA #$FF
STA $1493
STA $0DDA               ;|end the level.
LDA !MusicRAMTrigger 
BNE Return
LDA #$03 ; vanilla 0B? Fixed for AMK, SJC                
STA $1DFB               ;  Change music
Return:
RTL


Black_FG_Only:
LDA $0D9B|!addr
BPL +
LDA $0680|!addr	; Mode 7 ... With Sprites
+
CMP #$03
RTL
