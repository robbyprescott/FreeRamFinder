; Press L or R to shoot
; Add upward-shooting feature, and spin jump while holding?

;; Sprite shooter based on the Carriable Sprite Template that I made.
;; By Abdu

;; Extra Byte 1 is the sprite number. Good examples include 53, throwblock
;; See here for more: https://www.smwcentral.net/?p=viewthread&t=26742
;; Extra Byte 2 is the state the sprite will spawn in, if set to 0 it will be changed to 1 automatically for you. 
;; 0A, kicked. 8, normal. 09, carryable.
;; Check out https://www.smwcentral.net/?p=memorymap&a=detail&game=smw&region=ram&detail=0984148beee5  for more details.
;;
;; Extra Byte 3 is the speed sprites will spawn in. For a sprite to stay at a kicked status when spawned the min speed is 21, 
;; direction will be set based on the player facing direction.
;;
;; Extra Byte 4 is the extra bits for the sprite spawned. 0 and 1 are for normal sprites, 2 and 3 for custom sprites.
;; Extra Byte 5-8 are the Extra Bytes 1-4 for the spawned sprite.

;=======Misc sprite tables defines=======
!SpriteDir				= !157C
!DisableContact			= !154C
!Timer					= !1540
!SpriteNum				= !1504
!SpriteStatus			= !1534
!XSpeed					= !1510		
!ExtraBit				= !151C	
;========================================

;=======Changeable values defines=======
!Tile 					= $88		; Tile used for graphics.
!CannonSFX 				= $09		; sound to make when the player shoots something.
!CannonPort 			= $1DFC|!Base2
!CoolDown				= $10		; Cool down between each time you shoot.
!DisableContactFrames	= $10		; How long to disable contact with the player when you let go of the shooter.
;========================================

print "INIT", pc
	LDA #$09
	STA !14C8,x
	; maybe its the move to store the extra byte stuff here in other ram addresses.
	LDA !extra_byte_1,x		;\ need to do this to access the extra bytes
	STA $8A					;|
	LDA !extra_byte_2,x		;|
	STA $8B					;|
	LDA !extra_byte_3,x		;|
	STA $8C					;/

	LDA [$8A]
	STA !SpriteNum,x
	LDY #$00
	
	INY
	LDA [$8A],y
	BNE +
	INC 					; if the status is set to 0 which for dead sprites just set it to be the init phase 
	+
	STA !SpriteStatus,x
	
	INY
	LDA [$8A],y				;\
	STA !XSpeed,x			;/

	INY
	LDA [$8A],y				;\ need to store it to scratch ram rather than stack because if the sprite fails to spawn 
	STA !ExtraBit,x			;/ it will just return.
	
RTL

; just incase someone tries to do something stupid.
print "MAIN", pc
	PHB : PHK : PLB
	LDA #$09
	STA !14C8,x
	JSR Carriable
	PLB
RTL

print "CARRIABLE", pc
	JSR Carriable
RTL

Carriable:
	LDA $9D
	BNE .draw
	JSL $01802A|!BankB 		; update X and Y position, interact with objects and apply gravity.
	LDA !1588,X
	AND #$04	
	BEQ .inAir
	JSR Bounce
	

	.inAir
	LDA !1588,X
	AND #$08	
	BEQ .noCeiling

	LDA #$10				; set Y speed whenever the sprite is touching a ceiling.
	STA !AA,x
	LDA !1588,X
	AND #$03
	BNE .noCeiling

	LDA !E4,x : CLC : ADC #$08 : STA $9A
	LDA !14E0,x : ADC #$00 : STA $9B
	
	LDA !D8,x : AND #$F0 : STA $98
	LDA !14D4,x : STA $99

	LDA !1588,x						;\
	AND #$20						;|
	ASL #3							;|
	ROL								;|
	AND #$01						;| Activate block
	STA $1933|!Base2				;|
	LDY #$00						;|
	LDA $1868|!Base2				;|
	JSL $00F160|!BankB				;/
	LDA #$08
	STA !1FE2,x

	.noCeiling
	
	LDA !1588,X
	AND #$03
	BEQ .noSide

	JSR InteractSideBlock		; interact with the side of the block.
	.noInteractWithSide
	LDA !B6,x
	ASL
	PHP
	ROR !B6,x
	PLP
	ROR !B6,x
	.noSide
	JSR InteractionCarriable


	
	.draw
	JSR Graphics
	LDA #$00			;\
	%SubOffScreen()		;/ make sure of this
RTS

InteractionCarriable:
	JSL $01803A|!BankB		; interact with player and other sprites.
	BCC .Ret

	
	LDA !DisableContact,x
	BNE .Ret

	LDA $15				;\ check if X/Y are presed
	AND #$40			;|
	BEQ .noCarry		;/
	
	LDA $1470|!Base2
	ORA $187A|!Base2
	BNE .noCarry
	
	LDA #$0B
	STA !14C8,x
	INC $1470|!Base2
	LDA #$08
	STA $1498|!Base2
	RTS

	.noCarry
	JSR MakeSolid
	.Ret
RTS

MakeSolid: 						; check out ($01AAB7)
	LDA !D8,x					;\ check to see if we are hitting the botton 8 pixels of the sprite.
	SEC : SBC $D3				;|
	CLC : ADC #$08 : CMP #$20 	;|
	BCC PushPlayer				;| push out the player
	BPL HittingTop				;/ if the player is higher than that then push up
	LDA #$10					;\ push the player down, since the player's head is inside
	STA $7D						;/
	RTS
HittingTop:
	LDA $7D						;\ if the player is already going up
	BMI Return					;/ just return
	STZ $7D						; zero out Y speed.
	STZ $72						;\ set the player to be on a solid sprite
	
	INC $1471|!Base2			;/ $1471 is the ram address to see what type of solid sprite we are standing on.
	LDA #$1F					; how much to push up when not on yoshi
	LDY $187A|!Base2
	BEQ notOnYoshi
	LDA #$2F					; how much to push up when on yoshi
	notOnYoshi:
	STA $00
	LDA !D8,x : SEC : SBC $00 : STA $96 ;\ push player on top of the sprite
	LDA !14D4,x : SBC #$00 : STA $97	;/

Return:
	RTS

PushSpeed:					; How quickly to push ther player to either side of the key/P-switch.
	db $01,$00,$FF,$FF

PushPlayer: 				; $01AB31
	STZ $7B					; clear player X speed.
	%SubHorzPos()
	TYA
	ASL
	TAY
	REP #$20
	LDA $94
	CLC : ADC PushSpeed,y : STA $94
	SEP #$20
RTS


BounceSpeed:								; Table which contains the bounce speed for carriable sprites when they hit the ground
	db $00,$00,$00,$F8,$F8,$F8,$F8,$F8
	db $F8,$F7,$F6,$F5,$F4,$F3,$F2,$E8
	db $E8,$E8,$E8,$00,$00,$00,$00,$FE		; sprites like goombas use the values starting at the $00s here.
	db $FC,$F8,$EC,$EC,$EC,$E8,$E4,$E0
	db $DC,$D8,$D4,$D0,$CC,$C8

; straight up yeeted from the all.log ($0197D5)
Bounce:					; Subroutine to make carryable sprites bounce when they hit the ground.
	LDA !B6,x 
	PHP	
	BPL +
	EOR #$FF : INC A
	
	+		
	LSR				
	PLP				
	BPL +	
	EOR #$FF : INC A
	
	+		
	STA !B6,x
	LDA !AA,x					;\ 
	PHA							;| Set a normal ground Y speed.
	JSR SetSomeYSpeed			;/
	PLA
	LSR
	LSR
	TAY
	.noExtraBounce
	LDA BounceSpeed,y			;\ 
	LDY !1588,x					;| Get the Y speed to make the sprite bounce at when it hits the ground.
	BMI Ret						;|
	STA !AA,x
Ret:
	RTS		

SetSomeYSpeed:					; Subroutine to set Y speed for a sprite when on the ground.
    LDA !1588,x                 ;\ See if the sprite on layer 2 
	BMI .onLayer2				;/ if it is then branch


	LDA #$00					; if not then set the Y speed to be 0
	LDY !15B8,x				    ; Check if we are on a slope
	BEQ .setYspeed				; if we are not then just set the speed

    .onLayer2
	LDA #$18
    .setYspeed	
	STA !AA,x
	RTS	




; Yeeted from the all.log ($01999E)
InteractSideBlock:				; Subroutine for thrown sprites interacting with the sides of blocks.
	LDA #$01					;\ SFX for hitting a block with any sprite.
	STA $1DF9|!Base2			;/
	JSR InvertDirSpeed			; Invert the sprite's X speed.
	LDA !15A0,x					;\ 
	BNE .offscreen				;|
	LDA !E4,x					;|
	SEC							;|
	SBC $1A						;|
	CLC							;|
	ADC #$14					;|
	CMP #$1C					;|
	BCC .offscreen				;|
	LDA !1588,x					;| If it's far enough on-screen, make it actually interact with the block.
	AND #$40					;|  i.e. this is the code that lets you actually hit a block with a thrown sprite.
	ASL							;|
	ASL							;|
	ROL							;|
	AND #$01					;|
	STA $1933|!Base2			;|
	LDY #$00					;|
	LDA $18A7|!Base2			;|
	JSL $00F160|!BankB			;|
	LDA #$05					;|
	STA !1FE2,x					;/
	.offscreen:	
	.ret
	RTS

InvertDirSpeed:
	LDA !B6,X		 
	EOR #$FF		
	INC A			
	STA !B6,X		
	LDA !SpriteDir,x
	EOR #$01		
	STA !SpriteDir,x
RTS




		
; Format for the carry table below 
; Right, left, left while turning, right when turning, sliding/going down a pipe/climbing while turning, centered.
CarryXLow: 			db $0B, $F5, $04, $FC, $04, $00
CarryXHigh: 		db $00, $FF, $00, $FF, $00, $00

DropXOffsetLow: 	db $F3, $0D 			; how far off Mario will the sprite drop (format: right, left)
DropXOffsetHigh: 	db $FF, $00

DropXSpeed:  		db $FC, $04  			; the X speed at which the sprite will drop (format: right, left)

KickXSpeed:			db $D2, $2E, $CC, $34	; X Speed when the sprite is kicked, 3rd and 4th values are the speed given when the sprite is spat out of yoshi's mouth.



print "CARRIED", pc

	JSR Carried
	LDA $13DD|!Base2		;\ Check if player is turining around
	BNE .infrontOfPlayer	;/

	LDA $1419|!Base2		;\ check if going in a pipe
	BNE .infrontOfPlayer	;/

	LDA $1499|!Base2		;\ check if the face the screen timer is set
	BEQ +					;/ if not then no need to zero out OAM index.
	
	.infrontOfPlayer
	STZ !15EA,x 	; Zero out OAM slot so the sprite can appear infront of the player.
	
	+
	LDA $64
	PHA
	LDA $1419|!Base2
	BEQ .draw
	LDA #$10	;\ if going in a pipe then just make sure the tile is behind the object.
	STA $64		;/ (its your duty to make the graphics routine use $64.)
	.draw
	JSR Graphics
	PLA
	STA $64
	LDA $9D
	BNE +
	;; if you have some extra code you wanna add whenever the sprite is carried add it here.
	
	LDA !Timer,x
	BNE +
	LDA $18		;\ check if L/R are pressed.
	AND #$30	;|
	BEQ +		;/

	JSR Shoot
	+
	RTL

SmokeOffset:
	db $F0, $10
Shoot:
	LDA #$10
	LDY $76									;\
	BNE + 									;| If mario facing left then we just flip A 
	EOR #$FF : INC 							;/ if facing left we just store A to $00 without flipping
	+ 
	STA $00 : STZ $01 : STZ $02 : STZ $03	; clear Y offset and speed will be set after it being spawned.

	LDA !ExtraBit,x		;\ need to store it to scratch ram rather than stack because if the sprite fails to spawn 
	STA $05				;/ it will just return.
	AND #$02
	CLC
	BEQ +
	SEC
	+

	LDA !SpriteNum,x	; extra byte 1 has the sprite number
	%SpawnSprite()
	BCC + 				; spawning sprite failed so return
	RTS
	+

	LDA $76
	EOR #$01
	STA !157C,y


	LDA !SpriteStatus,x
	STA !14C8,y
	
	; Set the right speed based on the player facing direction.
	; There probably is a better way to do this tbh just too tired to think.
	LDA !XSpeed,x
	STA $00
	BMI .leftSpeed

	LDA !157C,y
	BEQ .setSpeed
	LDA $00
	EOR #$FF
	INC
	STA $00
	BRA .setSpeed

	.leftSpeed
	LDA !157C,y
	BNE .setSpeed
	LDA $00
	EOR #$FF
	INC
	STA $00

	.setSpeed
	LDA $00
	STA !B6,y
	.nokick
	
	STY $06
	LDA $05					;\ get the extra bits
	AND #$02				;| if the sprite spawned is not custom then don't set the extra bytes
	BEQ .notCustom			;/
	
	; LDX $15E9|!Base2
	LDA !extra_byte_1,x		;\ need to do this to access the extra bytes
	STA $8A					;|
	LDA !extra_byte_2,x		;|
	STA $8B					;|
	LDA !extra_byte_3,x		;|
	STA $8C					;/

	TYX
	LDY #$04				;\ load up extra byte values for the spawned sprite. 
	LDA [$8A],y				;|
	STA !extra_byte_1,x		;|
	INY						;|
	LDA [$8A],y				;|
	STA !extra_byte_2,x		;|
	INY						;|
	LDA [$8A],y				;|
	STA !extra_byte_3,x		;|
	INY						;|
	LDA [$8A],y				;|
	STA !extra_byte_4,x		;/




	.notCustom
	LDX $06
	LDA $05			;\ Set the extra bit for the sprite here
	ASL #2			;|
	ORA !7FAB10,x	;|
	STA !7FAB10,x	;/

	LDX $15E9|!Base2
	LDY $76
	LDA SmokeOffset,y
	STA $00 : STZ $01		;\
	LDA #$1B : STA $02		;| Spawning smoke
	LDA #$01				;|
	%SpawnSmoke() 			;/
	LDA #!CannonSFX : STA !CannonPort
	LDA #!CoolDown : STA !Timer,x
	.Ret
RTS


Carried:
    JSL $019138|!BankB      ; interact with objects
    LDA $71                 ;\ if not powering up or down, entering pipe, etc
    CMP #$01                ;| then just skip over this
    BCC +                   ;/
    LDA $1419|!Base2
    BNE +

    LDA #$09                ;\ Make the sprite carriable
    STA !14C8,x             ;/
    RTS
    
    +
	; LDA $14C8,X				;$019FF4	|\ 
	; CMP #$08					;$019FF7	|| If the sprite returned to normal status (e.g. Goombas un-stunning), return.
	; BEQ Return01A014			;$019FF9	|/

    LDA $9D					;\ game is frozen so just offset the sprite.0
    BNE .justoffset			;/

    JSL $018032|!BankB	; Interact with other sprites.
    LDA $1419|!Base2    ;\ if player is going in a pipe then just offset the sprite
    BNE .justoffset     ;/
    BIT $15             ;\ if X/Y arent pressed just let go.
    BVC LetGo           ;/
	.justoffset
    JSR OffsetSprite

RTS



LetGo:
    STZ !1626,x
    LDY #$00    			; put the Y speed for when letting go of the sprite in Y.
    
    STY !AA,x

	LDA #$09				;\ Set the sprite to be carriable
	STA !14C8,x				;/

	LDA $15					;\ check if up is being pressed
	AND #$08				;|
	BNE Up					;/
	

	LDA $15					;\ if down not pressed that means
	AND #$04				;|
	BEQ SideWays			;| just kick sideways
	BRA Drop				;/ else just drop

	.checkSideKick
	LDA $15					;\ Check if left/right is pressed
	AND #$03				;|
	BNE SideWays			;/ if not not then drop the sprite

Drop:
	LDY $76												;\ move X position of the sprite .
	LDA $D1 : CLC : ADC DropXOffsetLow,y : STA !E4,x	;|
	LDA $D2 : ADC DropXOffsetHigh,y : STA !14E0,x		;/
	%SubHorzPos()
	LDA DropXSpeed,y : CLC : ADC $7B : STA !B6,x 		; set some X speed for dropping the sprite
	STZ !AA,x											; no Y speed.
	BRA DisableContact									; done with dropping so disable contact.

SideWays:
	JSL $01AB6F|!BankB				; show the contact.
	LDY $76
	LDA $187A|!Base2
	BEQ .notRidingYoshi
	INY #2
	.notRidingYoshi
	LDA KickXSpeed,y
	STA !B6,x
	EOR $7B
	BMI DisableContact					; not moving in the same direction as the player so just disable contact
	LDA $7B								;\ Moving in the same direction so
	STA $00								;| half the player's speed and add it to the sprite's speed.
	ASL $00								;|
	ROR									;/
	CLC : ADC KickXSpeed,y : STA !B6,x

DisableContact:
	LDA #!DisableContactFrames	;\ how many frames to disable contact with the player.
	STA !DisableContact,x		;/

	LDA #$0C					;\ show the kicking pose
	STA $149A|!Base2			;/
RTS

;; Code that is ran when X/Y are let go and the up button is being pressed..
Up:
	JSL $01AB6F|!BankB			; show the contact.
	LDA #$90					;\ Up kicked Y speed.
	STA !AA,x					;/

	LDA $7B						;\
	STA !B6,x					;|
	ASL							;|
	ROR !B6,x					;/ Sprite gets half of the player's X speed.
	BRA DisableContact




; Credit to KevinM KoopaShell disassembly for the OffsetSprite routine


OffsetSprite:

	LDA $13E0|!Base2 	;\ if the player is in the dying animation
	CMP #$3E 	        ;| then there is no need to offset 
	BNE ++ 		        ;/ the sprite to be where the player is at
    RTS

	++
    LDA $76 			;\ 00 = left, 01 = right so need to flip for our table
	EOR #$01 			;| will be used as index to the CarryXoffset
	TAY 				;/
	STA !SpriteDir,x
	LDA $1499|!Base2 	; Timer for player to face the screen
	BEQ +
	INY #2				; this puts us at index 2 if the player is facing right 3 if facing left
	CMP #$05 			; if $1499|!Base2 is set to #$05 then that we need to increment once more.
	BCC +
	INY 				; Y now should be 3 if facing right or 4 if facing left
	
	+
	LDA $1419|!Base2 	; going through a pipe (for yoshi)
	BEQ + 				; not going through pipe so we skip
	CMP #$02  			; if we are facing the screen then we just set Y to be 5
	BEQ ++
	
	+
 	LDA $13DD|!Base2 	; Pose used while the player is on the ground and turning around with a non-zero X speed. 
	ORA $74 			; or if the player is carrying an item while being on the net then we center the carryable sprite
	BEQ +++ 			; if neither we just branch
	
	++
 	LDY #$05 			; set index to be #$05
	
	+++
 	PHY 				; save our index to get later
	LDY #$00
	LDA $1471|!Base2
	CMP #$03 
	BEQ +
	LDY #$3D 			; if calculated using current frame then we use #$3D else #$00 is used
	
	+
 	LDA $94,y			;\ Player X pos low byte
	STA $00				;/

	LDA $95,y 			;\ Player X pos high byte
	STA $01 			;/

	LDA $96,y 			;\ Player Y pos low byte
	STA $02 			;/

	LDA $97,y 			;\ Player Y pos high byte
	STA $03 			;/
	PLY

	LDA $00 				;\
	CLC : ADC CarryXLow,y 	;| Setting the sprite X low byte offset from the player while carrying 
	STA !E4,x 				;/

	LDA $01					;\
	ADC CarryXHigh,y		;| Setting the sprite X high byte offset from the player while carrying 
	STA !14E0,x				;/

	LDA #$0D 				; Player's Y offset when they are big
	LDY $73 				; load player is ducking flag
	BNE +
	LDY $19					; if the player is big then Y #$0D offset is used
	BNE ++ 
 	
	+ 	
 	LDA #$0F				; if player is small or ducking then the offset is set to #$0F

 	++ 
 	LDY $1498|!Base2
	BEQ +
	LDA #$0F

 	+ 	
 	CLC : ADC $02 			;\ add Y offset to Player's Y position and 
	STA !D8,x 				;/ store it to low byte Y pos of sprite

	LDA $03
	ADC #$00 			    ;\ add Y offset to Player's Y position and 
	STA !14D4,x 			;/ store it to low byte Y pos of sprite

	LDA #$01 				;\ Set carry flag and carried animation flag.
	STA $1470|!Base2 		;|
	STA $148F|!Base2 		;/
RTS

	
Properties: db $00, $40
Graphics:
	LDA !SpriteDir,x
	TAY
	LDA Properties,y
	STA $02

    %GetDrawInfo()
    LDA $00
    STA $0300|!Base2,y
    LDA $01
    STA $0301|!Base2,y
    LDA #!Tile
    STA $0302|!Base2,y
    LDA !15F6,x
    ORA $64
	ORA $02
    STA $0303|!Base2,y

    LDA #$00 				; A = (number of tiles drawn - 1)
    LDY #$02 				; 16x16 tiles
	JSL $01B7B3|!BankB 		; don't draw if offscreen
RTS

