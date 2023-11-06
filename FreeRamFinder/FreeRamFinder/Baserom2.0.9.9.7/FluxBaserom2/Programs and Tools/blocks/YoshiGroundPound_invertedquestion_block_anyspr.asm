db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

; [DEFINES][DEFINES][DEFINES][DEFINES][DEFINES][DEFINES][DEFINES][DEFINES]

incsrc YoshiGroundPound_Defines.cfg

!BounceSpeed = $30				;bounce speed given after ground pounding the block. set to 0 to disable (automatically converted to negative)

!ActivateSoundEf = #$02
!ActivateSoundBank = $1DFC|!addr

!spawnthissprite = $0F			; Sprite number of sprite to spawn. #$0F is Goomba (Galoomba).

!spriteiscustom = 0				; Whether or not the sprite will be a custom sprite inserted with SpriteTool or PIXI

!skipinit = 0					; Whether or not to skip the INIT routine for the sprite.
								; You'll need to experiment to see what works well with which setting.
								; 	Just make sure to have a back up of your ROM. Don't worry if it crashes; just close down the emulator
								; 	and try different settings.

!goright = 0					; Whether or not the sprite should be facing right when coming out of the block.
								; This value may not take effect depending on the sprite's INIT routine,
								; 
									; 0 = Sprite will be facing Left
									; 1 = Sprite will be facing Right

;extra byte values for custom sprites (only 4 bytes, because the rest are stored in ROM, i.e. cannot be modified)
;0 - disable storing to save space
!ExtraByte1 = $00	; First extra byte
!ExtraByte2 = $00	; Second extra byte
!ExtraByte3 = $00	; Third extra byte
!ExtraByte4 = $00	; Fourth extra byte

!blocktogenerate = #$0D		; Block to generate.
							; According to SMWDisC.txt, at ("TileGenerationPtr"), table at $00BFC9 :
						
								; 01 - empty space 
								; 02 - empty space 
								; 03 - vine 
								; 04 - tree background, for berries 
								; 05 - always turning block 
								; 06 - coin 
								; 07 - Mushroom scale base 
								; 08 - mole hole 
								; 09 - invisible solid 
								; 0a - multiple coin turnblock 
								; 0b - multiple coin q block 
								; 0c - turn block 
								; 0d - used block 
								; 0e - music block 
								; 0f - music 
								; 10 - all way music block 
								; 11 - sideways turn block 
								; 12 - tranlucent 
								; 13 - on off 
								; 14 - side of pipe, left 
								; 15 - side of pipe, right 
								; 16 - used 
								; 17 - O block from 1up game 
								; 18 - invisible block containing wings 
								; 19 - cage 
								; 1a - cage 
								; 1b -  

!BounceSprite = #$03					; Input for Bounce Sprite number
								; 	Whichever is put here is only graphical,
								;	*EXCEPT* #$07, which sets a Turn Block timer [which doesn't even really work all that well].
								;	If you want to make it look like a Turn Block without setting that timer,
								;	use #$01.
								;
								; 	According to SMWDisC, table at $029062 ("BounceSpritePtrs")
								
									;	00 - Nothing (Bypassed above) 
									; 	01 - Turn Block without turn 
									; 	02 - Music Block 
									; 	03 - Question Block 
									; 	04 - Sideways Bounce Block 
									; 	05 - Translucent Block 
									; 	06 - On/Off Block
									; 	07 - Turn Block 

; [CODE][CODE][CODE][CODE][CODE][CODE][CODE][CODE][CODE][CODE][CODE][CODE]

Skip:
RTL

MarioAbove:
	LDA $7D						; So Mario cannot activate this block if going upwards.
	BMI Skip					;

if !MarioGroundPoundFlag

  LDA $18E7|!addr			;yoshi yellow power check
  BEQ .CheckPound			;check if we're actually riding a yoshi (so the player can't leave yoshi behind and still activate blocks)

  LDA $187A|!addr
  BNE .Activate				;allow destruction

.CheckPound
  LDA !MarioGroundPoundFlag		;not yoshi, maybe custom ground pound? 
  BEQ Skip				;if not, return

else

  LDA $18E7|!addr
  BEQ Skip

  LDA $187A|!addr
  BEQ Skip

endif

.Activate
if !BounceSpeed
  LDA #-!BounceSpeed
  STA $7D
endif
	
	;Input: A = Bounce sprite number,  X = $9C value, Y = bounce sprite direction,
;       $02-$03 = Map16 number (only if $9C or X is $1C or larger)
;Ouput: Y = Slot used
	
; note: this only works with Bounce Block unrestrictor
	
	PHX
	PHY
	
	LDA !BounceSprite
	
	LDX !blocktogenerate		; Block to generate. Check and edit the values under [DEFINES]
	
	LDY #$00					; Input for Bounce Block's direction
								; According to SMWDisC.txt, tables at $02873A ("BlockBounceSpeedY") and $02873E ("BlockBounceSpeedX")
								;
									; #$00 = Up
									; #$01 = Right
									; #$02 = Left
									; #$03 = Down (makes player bounce like on a note block!)

	%spawn_bounce_sprite()
	
	PLY
	PLX
	
; Routine to spawn the sprite inside the block:	

	if !spriteiscustom == 1		; Makes sprite be custom, when applicable
		SEC
	else
		CLC
	endif	
	
;Input: A = sprite number, CLC = CLear Custom, SEC = SEt Custom
;Output: Carry clear = spawned, carry set = not spawned, A = slot used

	LDA #!spawnthissprite	; 
	%spawn_sprite_block()	; This will spawn the sprite from the block.

	TAX
	
	LDA #$40			; Setting the Sprite's Y speed.
	STA !AA,x			;
	
	LDA #23				; This makes the newly spawned sprite not interact
	STA !1FE2,x			; with the Bounce Sprites. This is necessary so the sprite won't die instantly.
	
	STZ !B6,x			; Setting the Sprite's X speed to 0

if !skipinit
	LDA #$08			; Skips the INIT routine when applicable.
	STA !14C8,x
endif

if !ExtraByte1
	LDA #!ExtraByte1
	STA !extra_byte_1,x
endif

if !ExtraByte2
	LDA #!ExtraByte2
	STA !extra_byte_2,x
endif

if !ExtraByte4
	LDA #!ExtraByte3
	STA !extra_byte_3,x
endif

if !ExtraByte4
	LDA #!ExtraByte4
	STA !extra_byte_4,x
endif

if !goright
	LDA #$01			; Forces the sprite to go right when applicable.
	STA !157C,x
endif

	TXA	
	%move_spawn_into_block()	; Moves the sprite into the block.

	LDA !ActivateSoundEf
	STA !ActivateSoundBank			; Plays Hit ? Block Sound Effects (by default)
	
SpriteV:
SpriteH:

MarioBelow:
MarioSide:

TopCorner:
BodyInside:
HeadInside:

WallFeet:
WallBody:

MarioCape:
MarioFireball:
RTL

if !spriteiscustom
  print "An Inverted Question Block that Mario can activate from above by ground pound that will spawn a custom sprite ", hex(!spawnthissprite)
else
  print "An Inverted Question Block that Mario can activate from above by ground pound that will spawn a vanilla sprite ", hex(!spawnthissprite)
endif