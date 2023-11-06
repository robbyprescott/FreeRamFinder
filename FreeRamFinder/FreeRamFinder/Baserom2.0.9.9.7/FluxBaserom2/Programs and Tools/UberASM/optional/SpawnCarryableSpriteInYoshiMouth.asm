;;; which item to spawn
!spriteNum		=	$0F
; 04 = green shell, 05 = red shell, 06 = blue shell, 07 = yellow shell
; 0F = goomba (surprisingly works and can be spit)
; 2F = spring, 3E = p-switch, 80 = key

; Set to 1 spawn a Disco Shell in Yoshi's mouth.
; Only works if !spriteNum is a Shell.
!discoShell		=	0

;;; if spawning a p-switch, this is the color switch to spawn
!pswitchColor	=	$00
; 00 = blue, 01 = silver

;;; settings for which buttons will spawn the item (default: L or R)
; which input address to use (either $16 or $18 is recommended; see SMWC's RAM map)
!inputAddress	=	$18
; which buttons to use to spawn the item (see above address)
!inputValue		=	%00110000

;;; Timer before yoshi swallows what you spawn
; FF is default
!swallowTimer	=	$FF

; Choose if to spawn in Yoshi's mouth only while riding him
!onlyWhenRiding	=	1

;;; Sound to play when spawning sprites
; 00 = no sound, 06 = fireball sound, 21 = Yoshi's tongue
; Check $1DF9/$1DFC RAM address for more options
!soundID		=	$19
!soundAddr		=	$1DF9|!addr

;===================================================================================
main:
	LDA !inputAddress		; checks for button presses and if you're on yoshi and can spawn an item
	AND #!inputValue
	BEQ .ret

	if !onlyWhenRiding
		LDA $187A|!addr
		BEQ .ret
	endif

	LDY $18DF|!addr			; load Yoshi's slot (+1)
	BEQ .ret				; if 0, no Yoshi, so return
	DEY						; now Y = Yoshi's slot

  .yoshifound
	LDA !160E,y
	CMP #$FF
	BNE .ret
	LDA !1594,y
	ORA $18AE|!addr
	ORA $14A3|!addr
	BNE .ret
	LDX #!sprite_slots-1	; finds a free sprite slot, doesn't spawn anything if no slot
  - LDA !14C8,x	
	BEQ .found				
	DEX
	BPL -
  .ret:
	RTL
	
  .found:	
	LDA #!spriteNum 	: STA !9E,x		; spawns the item in yoshi's mouth
	LDA #$07        	: STA !14C8,x
	TXA					: STA !160E,y
	LDA #!swallowTimer	: STA $18AC|!addr
	
	if !spriteNum == $80				; Tells the game yoshi has a key in mouth
		LDA #$01
		STA $191C|!addr
	endif

	LDA #!soundID		: STA !soundAddr
	
	JSL $07F7D2|!bank

	if !discoShell
		LDA #$01
		STA !187B,x
	endif

	if !spriteNum == $3E				; sets the p-switch colour
		LDA #!pswitchColor
		STA !151C,x

		LDA.b #read1($018466+!pswitchColor)
		STA !15F6,x
	endif
	
	RTL
