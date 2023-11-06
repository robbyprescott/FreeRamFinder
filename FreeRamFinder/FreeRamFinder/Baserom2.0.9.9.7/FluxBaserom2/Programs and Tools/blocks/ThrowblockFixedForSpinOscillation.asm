db $37
JMP Return : JMP Main : JMP Main : JMP Return
JMP Return : JMP Return : JMP Return : JMP Main
JMP Main : JMP Main : JMP Return : JMP Return
Main:
LDA $1470|!addr				;do not run the code if player is carrying something
ORA $148F|!addr				;do not run the code if player is carrying something
ORA $187A|!addr				;do not run the code if player is riding yoshi
ORA $74						;do not run the code if player is climbing
BNE Return
checkInput:
LDA $16                     ;change to "LDA $15" to make you pick up the throwblock automatically if Y / X is held
BIT #$40
BEQ Return
spawnSprite:
LDA #$53					;sprite number to spawn
CLC
%spawn_sprite()
BCS Return
%move_spawn_into_block()	;move sprite position to block
LDA #$0B		
STA !14C8,x					;sprite carried status
LDA #$FF
STA !1540,x
destroyBlock:
%erase_block()
Return:
RTL
print "This is just like a normal throwblock, but corrected for spin oscillation for reliable grabbing. That is, if you're spinning in midair and try to grab this, your grabbing hitbox won't oscillate back and forth on either side of Mario. (In this sense, it's similar to the cape-spin fix.)"