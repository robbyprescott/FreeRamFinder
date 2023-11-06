;This piece of ASM makes the player instantly die, when he loses his powerup.
;This ASM is meant to be inserted as gamemode 14 or as level-asm. It runs on every (sub)screen in a level.
;See idoplLevel.asm for more customizability (Should be chosen, if you need the extra options).
;Version 2.1
;Created by Badummzi, small optimizations by Maarfy

; SJC: added small Yoshi/star power check (thanks KevinM), 
; and then modified so that "Yoshi loss" doesn't play
; simultaneously with normal death sound when you die with Yoshi

!FreeRAMInstakill = $0EBB

main:
    LDA !FreeRAMInstakill : BNE +   ; enabled by default, set address to disable
    LDA $1497|!addr : BNE death     ; Flashing invulnerability timer. That is, 
                                        ; no cape i-frames, Yoshi loss, or star power
	LDA $71                         ; Animation?
	CMP #$01
	BNE returnInstakill

death:
	;LDA #$36   ; no Yoshi run off sound on top of normal death sound
	;STA $1DFC|!addr
	JSL $00F606|!bank  ; death

returnInstakill:
    +
	RTL