print "One-way block for Mario only, which allows him to go down (but not back up)."

;behaves $25

print "Solid if Mario goes up"
db $37
JMP MarioBelow : JMP return : JMP return : JMP SpriteV : JMP return : JMP return
JMP MarioFireBall : JMP return : JMP return : JMP return : JMP return : JMP solid

MarioBelow:
	LDA $7D			;\so if you stack this one-way down block,
	BMI solid		;/wouldn't make mario zip downwards very fast.
	RTL
SpriteV:
	RTL
MarioFireBall:
	LDA $173D|!addr,x
	BPL return
solid:
	LDY #$01		;\become solid
	LDA #$30		;|
	STA $1693|!addr	;/
return:
	RTL