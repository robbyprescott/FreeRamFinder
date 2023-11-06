; By SJC

!SpinJumpFromAboveCausesBounceSprite = 0

!SoundEffect = $38
!Bank = $1DFC

!YXPPCCCT = $04 ; 04 is Palette A

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH
JMP MarioCape : JMP MarioFireBall : JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioSide:
HeadInside:
MarioFireBall:
BodyInside:
Return:
	RTL
MarioAbove:
TopCorner:
    LDA $19
	BEQ Return
    LDA $140D
	BEQ Return
	LDA #$D0
	STA $7D
	
	%create_smoke()			;>smoke
	%erase_block()			;>Delete self.
	
	LDA $5B				;\Check if vertical level = true
	AND #$01			;|
	BEQ +				;|
	PHY				;|
	LDA $99				;|Fix the $99 and $9B from glitching up if placed
	LDY $9B				;|other than top-left subscreen boundaries of vertical
	STY $99				;|levels!!!!! (barrowed from the map16 change routine of GPS).
	STA $9B				;|(this switch values $99 <-> $9B, since the subscreen boundaries are sideways).
	PLY				;|
+					;/
	REP #$20			;\Move 1 block right.
	LDA $9A				;|
	CLC : ADC #$0010		;|
	STA $9A				;|
	SEP #$20			;/
	
	%create_smoke()			;
	%erase_block()	
	
	if !SpinJumpFromAboveCausesBounceSprite = 1
	BRA SpinBounce
	endif
	RTL
MarioBelow:
	LDA #$10			;if hit from the bottom, act like "ceiling"
    STA $7D				;just give mario some downward speed, alright
	BRA Destroy
	JSL $00F606
	RTL
SpriteH:
	%check_sprite_kicked_horiz_alt() ; alt handles dropped from above jank better than %check_sprite_kicked_horizontal()
	%sprite_block_position()
	BCS Destroy
    RTL
SpriteV:
	LDA $14C8,x
	CMP #$08 ; 9
	BCC Return
	LDA $AA,x
	BPL Return
	LDA #$10 ; handles weird below clipping
	STA $AA,x
    %sprite_block_position()
MarioCape:
Destroy:
;BounceBlock
	PHX
	PHY
	LDA #$01 ; $1699, bounce sprite. 01 normal turnblock. 07 is turning turnblock
	LDX #$02 ; $9C, Map16 tile. 02 is tile 25. 05 is always turning.
	LDY #$00
	%spawn_bounce_sprite()
	LDA #!YXPPCCCT 
	STA $1901,y
	PLY
	PLX
	
	LDY #$01		;\
    LDA #$30		;| Act solid during Map16 change, handles janky side interaction
    STA $1693       ;/

	%create_smoke()			;>smoke
	%erase_block()			;>Delete self.
	
	LDA $5B				;\Check if vertical level = true
	AND #$01			;|
	BEQ +				;|
	PHY				;|
	LDA $99				;|Fix the $99 and $9B from glitching up if placed
	LDY $9B				;|other than top-left subscreen boundaries of vertical
	STY $99				;|levels!!!!! (barrowed from the map16 change routine of GPS).
	STA $9B				;|(this switch values $99 <-> $9B, since the subscreen boundaries are sideways).
	PLY				;|
+					;/
	REP #$20			;\Move 1 block right.
	LDA $9A				;|
	CLC : ADC #$0010		;|
	STA $9A				;|
	SEP #$20			;/
	
	%create_smoke()			;
	%erase_block()			;

SpinBounce:
	
	PHX
	PHY
	LDA #$01 ; $1699, bounce sprite. 01 normal turnblock. 07 is turning turnblock
	LDX #$02 ; $9C, Map16 tile. 02 is tile 25. 05 is always turning.
	LDY #$00
	%spawn_bounce_sprite()
	LDA #!YXPPCCCT
	STA $1901,y
	PLY
	PLX
	
	

    LDA #!SoundEffect			;\Play sfx.
	STA !Bank		;/
    
	RTL

print "Left tile of the two-tile wide shatter block. Will be shattered by kicked sprites, Mario below, or big Mario spin-jump from above. Don't use in true vertical levels! If you had planned on doing this, use the tall horizontal level mode to emulate a vertical level instead."