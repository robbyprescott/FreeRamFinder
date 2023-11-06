;!MainSoundEffect = $29

!bounce_num			= $09			;>The bounce block sprite number
!bounce_properties	= $04			;> Palette B, 06. $04 is palette A (%00000100). $00 is palette 8, Mario. 
                                    ; The properties of bounce blocks (palette, tile number high byte)

db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV
JMP SpriteH : JMP MarioCape : JMP MarioFireball : JMP TopCorner
JMP BodyInside : JMP HeadInside : JMP WallFeet : JMP WallBody


MarioBelow:
    LDA $7D
    BPL Return
    BRA TriggerCheck
SpriteH:
	%check_sprite_kicked_horiz_alt() ; alt handles dropped from above jank better than %check_sprite_kicked_horizontal()
	BCS SpriteStuff
    RTL
SpriteV:
	LDA $14C8,x
	CMP #$08 ; 9
	BCC Return
	LDA $AA,x
	BPL Return
	LDA #$10 ; handles weird below clipping
	STA $AA,x
SpriteStuff:
    %sprite_block_position()	
TriggerCheck:	
	REP #$20
    LDA $7FC0FC ; check if already
	AND #$0001
	BNE Other
    SEP #$20
	
    REP #$20 
    LDA $7FC0FC ; The specified trigger here is Custom 00.
	            ; $7FC0F8 is one-shot
    ORA #$0001  ; #$03 would trigger 00 and 01. #$01 triggers just 00. 
                ; All following #%0000000 format, from right to left. 
                ; For example, 4 slots would be #%00001111, or #$0F. 
                ; #$1F for 5 slots, etc.
    STA $7FC0FC
    SEP #$20
	
	;LDA #!MainSoundEffect
	;STA $1DFC
	
	LDA #$01 ; hit head sound
	STA $1DF9 ; hit head sound
	
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
Other:
    REP #$20 
    LDA $7FC0FC ; The specified trigger here is Custom 00.
	            ; $7FC0F8 is one-shot
    AND #$FFFE  ; #$03 triggers 00 and 01. #$01 triggers just 00. 
                ; All following #%0000000 format, from right to left. 
                ; For example, 4 slots would be #%00001111, or #$0F. 
                ; #$1F for 5 slots, etc.
    STA $7FC0FC
    SEP #$20
	
	;LDA #!MainSoundEffect
	;STA $1DFC
	
	LDA #$01 ; hit head sound
	STA $1DF9 ; hit head sound
	
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
	
	; bounce sprite
	
MarioAbove:
BodyInside:
MarioSide:
TopCorner:
HeadInside:
MarioCape:
MarioFireball:
WallFeet:
WallBody:
Return:
RTL

print "An on-off switch which, unlike the normal one, will toggle a different RAM address ($7FC0FC) than the normal $14AF switch."