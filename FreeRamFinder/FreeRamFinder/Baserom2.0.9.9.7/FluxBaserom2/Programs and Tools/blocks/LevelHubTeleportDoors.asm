;level-specific teleport block (cursor click)

!SpriteNumberMainHub = $B3
!SpriteNumberOtherHub = $B4

!SFX = $0F		;sound effect played when teleporting.
!SFXPort = $1DFC	;port used for above SFX.

if !sa1
!extra_byte_1 = $400099
else
!extra_byte_1 = $7FAB40
endif

db $42
JMP Return : JMP Return : JMP Return 
JMP Run : JMP Run : JMP Return : JMP Return
JMP Return : JMP Return : JMP Return

Run:
LDA !7FAB9E,x		;load custom sprite number
CMP #!SpriteNumberMainHub		; cursor in first level, big Y leaps
BEQ Stuff		;if not equal, return.
CMP #!SpriteNumberOtherHub		; cursor in first level, big Y leaps
BNE Return		;if not equal, return.

Stuff:
LDA #!SFX		;load SFX number
STA !SFXPort|!addr	;store to address to play it.

     tya
     xba
     lda $1693|!addr
     rep #$20
     %teleport()

Return:
RTL		;Return.


print "A teleport block, that teleports the player when the Cursor sprite clicks over it."