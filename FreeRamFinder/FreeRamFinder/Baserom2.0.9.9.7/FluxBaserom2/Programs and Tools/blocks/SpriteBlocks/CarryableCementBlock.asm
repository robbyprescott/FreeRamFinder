; ------------------------------ ;
;     Carryable Cement Block     ;
; ------------------------------ ;

!SpriteNum = $64		; Custom sprite number. Set this to the number you use for the block sprite in PIXI's list.txt.
!Timer = $0		; Default FF. How long the carryable block will remain so until it turns back into a block. Remains carryable forever if set to 0 (excluding wall hits).

!BlockNumber = $0000		; Map16 tile that the block sprite should change into. If $0000, it will revert back to the Map16 tile number of the block that
							; spawned it (AKA the Map16 tile number you choose for this block).

db $37
JMP Return : JMP Main : JMP Main
JMP Return : JMP Return : JMP Return : JMP Return
JMP Main : JMP Return : JMP Return
JMP Main : JMP Return

Main:
LDA $1470|!addr		; If the player...
ORA $148F|!addr		; is carrying something...
ORA $187A|!addr		; or riding Yoshi,
BNE Return		; Return.
LDA $16		;
ORA $18		;
ASL		; If X or Y aren't pressed,
BPL Return		; Return.
LDA #!SpriteNum		; Sprite number.
SEC		; Custom sprite.
%spawn_sprite()		;
BCS Return		; Return if spawn failed.
TAX		; Move sprite slot to X.
%move_spawn_to_player()
LDA #$0B		; Sprite status = carried.
STA !14C8,x		;
LDA #$01		; Set "carrying something" flags.
STA $1470|!addr		;
STA $148F|!addr		;
if !Timer
if !Timer == $FF
LDA #!Timer		; Don't add anything if #$FF.
else
LDA #!Timer+1		; Timer value + 1 since the sprite reverts to block form when its carry timer is at 1, not 0.
endif
STA !1504,x		; Table for carry timer.
endif
if !BlockNumber
LDA.B #!BlockNumber		; Defined Map16 tile number, low byte.
STA !1510,x		; Table to hold low byte of tile the sprite should turn into.
LDA.B #!BlockNumber>>8		; Defined Map16 tile number, high byte.
STA !151C,x		; Table to hold high byte of tile the sprite should turn into.
else
LDA $03		; Map16 low byte.
STA !1510,x
LDA $04		; Map16 high byte.
STA !151C,x
endif
LDA $1933|!addr		; Layer the block is on.
STA !1528,x		; Preserve this in sprite table so the sprite will blockify on the same layer.
%erase_block()

Return:
RTL

print "A cement block that can be picked up, carried around, and thrown. It will turn back into the block when thrown against a wall or carried into an enemy, or when the configurable carry timer runs out. Make sure is sprite file 101 is in SP2 for the GFX to display properly."