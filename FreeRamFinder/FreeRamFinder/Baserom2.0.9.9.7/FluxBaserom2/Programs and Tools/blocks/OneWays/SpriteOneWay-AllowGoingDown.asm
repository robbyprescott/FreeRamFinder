;If anything tries to go through the block going up, it will block it,
;otherwise it will let them pass.
;behaves $25

print "Solid for sprites ONLY (block-interactable sprites) when they go up, but allows down"
db $37
JMP MarioBelow : JMP return : JMP return : JMP SpriteV : JMP return : JMP return
JMP MarioFireBall : JMP return : JMP return : JMP return : JMP return : JMP solid


SpriteV:
	LDA !sprite_speed_y,x
	BMI solid
	RTL
solid:
	LDY #$01		;\become solid
	LDA #$30		;|
	STA $1693|!addr	;/
MarioBelow:
MarioFireBall:
return:
	RTL