; A.k.a. NoMomentum

main:
    LDA $15
	ORA $16
	AND #$03
	BNE $02 : STZ $7B
	RTL