; SJC: I basically made a hybrid of Nowieso's Customizable Sprite Killer 
; and MarioFanGamer's (updated) Destroy Yoshi block, in order to also destroy Yoshi
; if he's being ridden, and also destroy items in his mouth.  


; I've also noted a very obscure glitch here: in one level where I had baby Yoshi placed toward the top
; of the screen, with adult Yoshi toward the bottom, the sprite killer wouldn't kill
; Yoshi while Mario is riding him. But when baby Yoshi is brought down, it's fine.


!PlayerOffset = $10			; When the player is on ground
!deathtype		=	1		;0 = sprite disappears without SFX
!killIfCarried	=	1		;1 = kill the sprite if it gets carried
!playSFX		=	1		;1 = play a SFX when !deathtype is 1
!SFX			=	$08		;sfx to play
!SFXBank		= 	$1DF9

db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioInside : JMP MarioHead


SpriteV:
SpriteH:
    LDA $9E,x
	CMP #$35
	BEQ DeleteEatenSprite
if !killIfCarried == 0
	LDA !14C8,x
	CMP #$0B
	BEQ Return
endif
    if !deathtype == 0
	STZ !14C8,x
    else
	BRA Destroy
	endif
Return:
Fireball:
Cape:
RTL

MarioBelow:
MarioAbove:
MarioSide:
MarioCorner:
MarioInside:
MarioHead:
	LDX #!sprite_slots		; Loop through all sprite slots
.Loop:						;
	LDA !14C8,x				; Sprite is alive?
	CMP #$08				;
	BCC .Next				;
	LDA !9E,x				;
	CMP #$35				; Sprite is Yoshi?
	BEQ .HasYoshi			;
.Next:						;
	DEX						;
	BPL .Loop				;
RTL							;
							;
							;
.HasYoshi:					;
	LDA $187A|!addr			; If riding Yoshi?
	BEQ Return				;
if !PlayerOffset			;
	LDA $72					; Skip if in the air
	BNE .InAir				;
	REP #$20				; A = 16-bit
	LDA.w #!PlayerOffset	; Offset player by some pixels
	CLC : ADC $96			;
	STA $96					;
	SEP #$20				; A = 8-bit
.InAir:						;
endif						;
							;
; Credits to Akaginite for this
DeleteEatenSprite:			;
	LDA $18AC|!addr			;\ if Yoshi has sprite in mouth.
	BEQ .No					;/
	STZ $18AC|!addr			; Reset mouth timer.
	PHY						;
	LDY !160E,x				;
	BMI +					;
	LDA #$00				;\ Sprite of Yoshi in mouth will be deleted.
	STA !14C8,y				;/
+	PLY						;
							;
.No:						;
	STZ $187A|!addr			; Dismount from Yoshi.
	LDA #$02				; Set some things.
	STA !1FE2,x				;
	STZ !C2,x				;
	LDA #$03				; Disable Yoshi drums.
	STA $1DFA|!addr			;
	STZ $0DC1|!addr			; Clear Yoshi flag
							;
Destroy:					;
	STX $15E9|!addr			; Set sprite index (stars will be otherwise misplaced).
if !sa1						; Additional fixes for SA-1
	TXA						;
	CLC : ADC #$16			; Y-Position
	STA $CC					;
	TXA						;
	CLC : ADC #$2C			; X-Position
	STA $EE					;
endif						;
	LDA #!SFX				; Play sound effect.
	STA !SFXBank			;
	LDA #$04				; Puff of Smoke.
	STA !14C8,x				;
	LDA #$1F				; Timer.
	STA !1540,x				;
	PHY						;
	JSL $07FC3B|!bank		; Spawn spin jump stars
	PLY						;
RTL							;

print "Kills all sprites which interact with blocks - even if you're riding Yoshi, and even if Yoshi has a sprite in his mouth. The version at block number 295 will also kill Mario; and the version at 45F will simply be solid for Mario. Note that if you destroy a vanilla spring, it will warp Mario. This is an unavoidable behavior of all sprite killers, unless you apply the included optional patch."