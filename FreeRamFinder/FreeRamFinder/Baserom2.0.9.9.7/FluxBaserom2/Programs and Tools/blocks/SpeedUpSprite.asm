; Will speed up certain block-interactable sprites that 
; are moving a certain speed, to the specified speed.

!right_speed = $53
!left_speed = -!right_speed

db $42
JMP Return : JMP Return : JMP Return
JMP SpriteV : JMP SpriteH : JMP Return : JMP Return
JMP Return : JMP Return : JMP Return

SpriteV:
Return:
	RTL

SpriteH:
	;~ check direction: speed $80 or above => sprite moves left
	LDA !B6,x
	CMP #$80
	BCS Left

Right:
	;~ skip if sprite is slower than !right_speed
	LDA !B6,x
	CMP #!right_speed
	BCS Return

	;~ set sprite x speed to !right_speed
	LDA #!right_speed
	STA !B6,x
	RTL

Left:
	;~ skip if sprite is slower than !left_speed
	LDA !B6,x
	CMP #!left_speed
	BMI Return

	;~ set sprite x speed to !left_speed
	LDA #!left_speed
	STA !B6,x
	RTL

print "Speeds UP certain block-interactable sprites (i.e. a kicked shell) to the defined speed."