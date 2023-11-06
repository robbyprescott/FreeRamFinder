; By SJCharlie, modifying MFG's block
; Need to figure out proper bounce direction for sprites without warping Mario

db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioInside : JMP MarioHead
JMP WallRun : JMP WallFeet


!activate_sides		= 1		; Whether the note block can be bounced from the sides or not.

!bounce_num			= $0A	; See RAM $1699 for more details. If set to 0, the block changes into the Map16 tile directly
!bounce_block		= $FF	; See RAM $9C for more details. Can be set to $FF to change the tile manually
!bounce_properties	= $02	; YXPPCCCT properties. 02 is first palette and first GFX page

!allow_duplication = 0		; By default, custom blocks are immune to block duplication
							; But it is possible to still enable them if you recreate
							; the code which handles interaction with bounce blocks.

MarioHead:
MarioSide:
if !activate_sides
    LDA #$08
	STA $1DFC
	LDA $93
	INC
BRA DoBounce
endif

Return:
Fireball:
MarioInside:
WallRun:
WallFeet:
RTL

MarioAbove:
MarioCorner:
	LDA #$03
    BRA DoBounce

SpriteH:  
    RTL
SpriteV:
	LDA !D8,x          ;sprites reset their y speed when on ground so this snippet make the sprite rise by 2 pixels so y speed is changeable 
    SEC
    SBC #$02
    STA !D8,x
	
	LDA !14D4,x
	SBC #$00
	STA !14D4,x
 
    LDA !14C8,x                ; \ The address thingy that has the value if something is alive and other shit
    CMP #$08                ; | comparing to see if alive
    BCC Return        ; /  
    LDA #$9F   ; Sprite height. Don't go above this, or jank. Default was $A8.
    STA !AA,x                ; /
	
	;STA !1FE2,x
	%sprite_block_position()
	PHX
	PHY
	TAY
	LDA #!bounce_num
	LDX #!bounce_block
	%spawn_bounce_sprite()
	LDA #!bounce_properties
	STA $1901|!addr,y
	PLY
	PLX
	
	LDA !14C8,x
	CMP #$0B 
	BEQ Return
    LDA #$08
	STA $1DFC ; Play bouncing sound, unless Mario carrying sprite
	
	RTL
	
MarioBelow:
Cape:
	LDA #$00

DoBounce:
	;WDM
	PHX
	PHY
	TAY
	LDA #!bounce_num
	LDX #!bounce_block
	%spawn_bounce_sprite()
	LDA #!bounce_properties
	STA $1901|!addr,y

	PLY
	PLX
    RTL

print "A noteblock that also bounces sprites up."