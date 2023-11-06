;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Spawn Wrapper - By dtothefourth
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; SJC notes on how to use: In order to get a custom sprite with its own extra bit/bytes into an enemy stack,
; you need to make sure both the custom sprite itself and this sprite wrapper are inserted through PIXI.
; Note the number that you inserted the sprite wrapper as in your PIXI list, and enter it below (in this file), after !Sprite.
; Then fill out the settings you want for it. (!ExByte1, !ExtraBit, etc.)
; Note that for each sprite stack that requires a custom sprite with extra bytes, you'll need to make a separate copy of SpriteStackCustomWrapper. 
; So you may just want to make several copies of this, named WrapperForCustomGoombaStack.asm (+ a .cfg with the corresponding name) or whatever, etc.

; Now it's time to actually put wrapper into the SpriteStacker itself. So insert the sprite stacker in LM (Insert Manual menu).
; Then, in the stacker's extra property bytes, where you'd normally put the # of your sprite, you'll instead put the number of the WRAPPER
; (otherwise following the instructions for custom sprite insertion, as described in SpriteStacker.asm).
; Make sure you don't insert the number of the custom sprite itself here -- only the # of the custom sprite's wrapper!


!Sprite = #$40	; Example (orb), number of the custom sprite you want included, as you put in PIXI's list
!State  = #$01  ; Generally 1,8,9 (9 for carryable stuff like keys, 1 for stuff that needs to run its init routine)
!Custom = 1		; 1 to spawn a custom sprite
!ExtraBit  = 0		; 1 to set the extra bit

;Extra bytes to set on sprite
!ExByte1 = #$00  ; Set the extra property bytes for the custom sprite here
!ExByte2 = #$00 
!ExByte3 = #$00
!ExByte4 = #$00

print "MAIN ",pc
	RTL


print "INIT ",pc
	TXY

	LDA !Sprite
	if !Custom
	STA !7FAB9E,x
	else
	STA !9E,y
	endif

	JSL $07F7D2|!BankB

	if !Custom

		LDA #$08|(!ExtraBit*4)
		STA !7FAB10,x
		JSL $0187A7|!BankB

	endif

	LDA !ExByte1
	STA !extra_byte_1,x
	LDA !ExByte2
	STA !extra_byte_2,x
	LDA !ExByte3
	STA !extra_byte_3,x
	LDA !ExByte4
	STA !extra_byte_4,x


	LDA !State
	STA !14C8,y
	INX

	RTL                