; by MarioFanGamer and lx5
; Cleaned up by AmperSam (and a couple small tweaks by SJandCharlieTheCat)

db $42

print "Question block that spawns a stunned bob-omb. Requires GFX02 in SP4."

!Sprite = $0D	; sprite number
!IsCustom = CLC ; CLC for normal, SEC custom sprite
!SetExtraBit = 1
!State = $01	; Usually $08 for normal, $09 for carryable sprites
                ; If a sprite with a timer like a throwblock (53), though, $01 for init
!1540_val = $3E	; If you use powerups, this should be $3E
				; Carryable sprites uses it as the stun timer

!ExtraByte1 = $00	; First extra byte (only applyable if extra bytes in GIEPY are enabled)
!ExtraByte2 = $00	; Second extra byte
!ExtraByte3 = $00	; Third extra byte
!ExtraByte4 = $00	; Fourth extra byte

!Placement = %move_spawn_into_block()
		; Use %move_spawn_above_block() if the sprite should appear above the block, otherwise %move_spawn_into_block() 
		
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioInside : JMP MarioHead

Return:
MarioAbove:
MarioSide:
Fireball:
MarioCorner:
MarioInside:
MarioHead:
RTL

SpriteH:
	%check_sprite_kicked_horiz_alt() ; changed from %check_sprite_kicked_horizontal()
	BCS SpriteShared
RTL

SpriteV:
	LDA $14C8,x
	CMP #$09
	BCC Return
	LDA $AA,x
	BPL Return
	LDA #$10
	STA $AA,x

SpriteShared:
	%sprite_block_position()

Cape:
MarioBelow:
SpawnItem:
	PHX
	PHY
	LDA #$03
	LDX #$0D
	LDY #$00
	%spawn_bounce_sprite()
	LDA #$00
	STA $1901,y

	LDA #$02
	STA $1DFC
	
	LDA #!Sprite
	!IsCustom

	%spawn_sprite_block()
	TAX
	!Placement
	
	;TXA
	;%move_spawn_relative()

	LDA #!State
	STA $14C8,x
	LDA #!1540_val
	STA $1540,x
	LDA #$D0
	STA $AA,x
	LDA #$2C
	STA $154C,x
	
	if !SetExtraBit
	LDA #$04
	STA !7FAB10,x
	endif
	
	;LDA #!ExtraByte1
	;STA !sprite_extra_byte1,x
	;LDA #!ExtraByte2
	;STA !sprite_extra_byte2,x
	;LDA #!ExtraByte3
	;STA !sprite_extra_byte3,x
	;LDA #!ExtraByte4
	;STA !sprite_extra_byte4,x

KeepGoing:
	LDA $190F,x
	BPL Return2
	LDA #$10
	STA $15AC,x
Return2:
	PLY
	PLX
RTL
