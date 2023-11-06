;this is inverted question block by Mandew, modified to work with yoshi ground pound per request
;while at it I added more defines for more customization as well


db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

; [DEFINES][DEFINES][DEFINES][DEFINES][DEFINES][DEFINES][DEFINES][DEFINES]

incsrc YoshiGroundPound_Defines.cfg

!BounceSpeed = $30				;bounce speed given after ground pounding the block. set to 0 to disable (automatically converted to negative)

!ActivateSoundEf = #$01
!ActivateSoundBank = $1DFC|!addr

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

!itemsprite = #$06			; Block item sprite. Set to coin from coin block by default -
							; According to https://www.smwcentral.net/?p=nmap&m=smwrom#02887D :
							
								;00 - nothing
								;01 - mushroom
								;02 - flower
								;03 - star
								;04 - cape
								;05 - 1-Up
								;06 - coin
								;07 - coin (sets multiple-coin-block timer)
								;08 - growing vine
								;09 - nothing?
								;0A - P-switch (blue/gray depending on block X position)
								;0B - key/wings/balloon/shell (depending on block X position)
								;0C - green Yoshi egg
								;0D - green Koopa shell (with stun timer set)
								;0E - changing item
								;0F - directional coins
								;10 - key (but a random blue shell-less Koopa also pops out)
								;11-FF - completely glitchy; best not to use

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

TopCorner:
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
	
	PHX
	PHY
	
	LDA !BounceSprite
	
	LDX !blocktogenerate		; Block to generate. Check and edit the values under [DEFINES]
	
	LDY #$00						; Input for Bounce Block's direction
								; According to SMWDisC.txt, tables at $02873A ("BlockBounceSpeedY") and $02873E ("BlockBounceSpeedX")
								;
									; #$00 = Up
									; #$01 = Right
									; #$02 = Left
									; #$03 = Down (makes player bounce like on a note block!)
					
	%spawn_bounce_sprite()
	
	PLY
	PLX
	
	LDA !itemsprite				; Block item to spawn. Check and edit the values under [DEFINES]
	%spawn_item_sprite()

	LDA !ActivateSoundEf
	STA !ActivateSoundBank		; Plays Hit ? Block Sound Effects

MarioBelow:
MarioSide:

BodyInside:
HeadInside:

WallFeet:
WallBody:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
Skip:
RTL

print "This is an inverted question block that spawns an item when groundpounded from above."