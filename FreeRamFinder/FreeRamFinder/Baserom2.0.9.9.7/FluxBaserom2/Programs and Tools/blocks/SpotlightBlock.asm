; By SJC, based on Ersanio disassembly and MFG block

print "Activates the spotlight."

!SwitchSFX = 1 ; change to 0 if you don't want it to make the on/off switch sound

!bounce_num			= $0D	; See RAM $1699 for more details. If set to 0, the block changes into the Map16 tile directly
!bounce_block		= $FF	; See RAM $9C for more details. Can be set to $FF to change the tile manually
!bounce_properties	= $08	; YXPPCCCT properties

db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH
JMP MarioCape : JMP MarioFireBall : JMP TopCorner : JMP HeadInside : JMP BodyInside
JMP WallRun : JMP WallFeet

Shared:

    ;STZ !C2,x		;Clear "light has been turned on" flag
	
	PHA			;Preserve A
	LDY #$0B		;Prepare for loop through 12 (22 on SA-1) sprites
Label:
    LDA !14C8,y		;\Sprite status
	CMP #$08		; |If it is (so) not normal
	BNE Label0		;/Skip

	LDA !9E,y		;\If the dark room sprite is present
	CMP #$C6		; |Then continue
	BNE Label0		;/ 

	LDA !C2,y		;\
	EOR #$01		; |Turn the switch on/off (flip bits)
	STA !C2,y		;/

Label0:			
    DEY			;\Decrease loop counter
	BPL Label		;/If not done yet, loop.
	PLA			;recover A
	
	if !SwitchSFX
	LDA #$0B
	STA $1DF9
    endif

    PHX
	PHY
	;LDA.b #!bounce_tile
	;STA $02
	;$03 is already set
	LDA #!bounce_num
	LDX #$FF
	LDY #$00
	%spawn_bounce_sprite()
	LDA #!bounce_properties
	STA $1901|!addr,y
	PLY
	PLX
	
	RTL
	
MarioBelow:
    LDA $7D			;\Must be going up.
	BPL Return		;/ Necessary to prevent weird side activation
    BRA Shared
	RTL
	
SpriteH:
    %sprite_block_position()
	%check_sprite_kicked_horiz_alt() ; changed from %check_sprite_kicked_horizontal()
	BCS Shared
    RTL

SpriteV:
    %sprite_block_position()
	LDA $14C8,x
	CMP #$09
	BCC Return
	LDA $AA,x
	BPL Return
	LDA #$10
	STA $AA,x
	
MarioCape:	
	BRA Shared

MarioFireBall:			;>fireballs should go through coins!
BodyInside:			;>fireballs should go through coins!
WallFeet:

MarioAbove:
TopCorner:

HeadInside:
MarioSide:
WallRun:
Return:
RTL