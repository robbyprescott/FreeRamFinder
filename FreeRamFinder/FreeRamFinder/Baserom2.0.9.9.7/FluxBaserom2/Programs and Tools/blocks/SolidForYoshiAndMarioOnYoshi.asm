; By Reinddeer
; Modified by SJandCharlieTheCat


!SolidFromOtherAngles   = 0     ;By default, solid for Mario and Yoshi from all angles. Can be set to be solid only when on top of the block.
!ActsLikeNoYoshi	= $0025	;What to act like when not riding Yoshi, needs to be 4 digits and have a $ at the start (buffer with zeroes if not)
!ActsLikeYoshi		= $0130	;What to act like when riding Yoshi, needs to be 4 digits and have a $ at the start (buffer with zeroes if not)


db $37 

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner

MarioBelow: : MarioAbove: : MarioSide: : TopCorner:

LDA $187A|!addr 		;Riding yoshi flag
BNE +				;Is Mario riding yoshi?  If so, skip to plus
LDY.b #!ActsLikeNoYoshi>>8	;Sets the blocks act as
LDA.b #!ActsLikeNoYoshi
STA $1693|!addr
RTL
+
LDY.b #!ActsLikeYoshi>>8	;Sets the blocks act as
LDA.b #!ActsLikeYoshi
STA $1693|!addr
RTL

SpriteV: : SpriteH:
LDY.b #!ActsLikeYoshi>>8	;Sets the blocks act as
LDA.b #!ActsLikeYoshi
STA $1693|!addr


MarioCape: : MarioFireball:
RTL


print "This block is only solid for Yoshi or for Mario when he's riding Yoshi."