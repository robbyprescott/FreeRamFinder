print "This block is designed so that if you upthrow a sprite like a shell or throwblock at two of these blocks together, the sprite won't get caught between the two and lose its angular momentum, falling straight down. Do NOT place this block such that sprites can be thrown at it horizontally, or else they'll simply pass through it."

!ActsLike = $0025

db $37
JMP Return			; Mario touching the tile from below
JMP Return			; Mario touching the tile from above
JMP Return			; Mario touching the tile from the side
JMP Return			; sprite touching the tile from above or below
JMP SpritePass		; sprite touching the tile from the side
JMP Return			; capespin touching the tile
JMP Return			; fire flower fireball touching the tile
JMP Return			; Mario touching the upper corners of the tile
JMP Return			; Mario's lower half is inside the block
JMP Return			; Mario's upper half is inside the block
JMP Return			; Mario is wallrunning on the side of the block
JMP Return			; Mario is wallrunning through the block

SpritePass:
	LDY.b #!ActsLike>>8		; have sprites treat this tile as if it were tile 25 (non-solid)
	LDA.b #!ActsLike
	STA $1693

Return:
	RTL

