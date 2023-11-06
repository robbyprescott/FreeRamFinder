; By SJandCharlieTheCat, WIP
; Act as 130

print "Spawns a specified sprite a few tiles above the block when you touch it. Customizable" 
; If !PressUpCheck, kind of acts like a door, spawning the sprite above when you press up while inside it.
; Can also be set to spawn the sprite directly INTO the block when you touch it. (You can change the label to only spawn when hit from below.)

; May need to change !SpriteState and other stuff for living sprites

!SpriteNumber = $C8 ; spotlight block thing
!SpriteState = $08

!SpawnAboveBlock = 1 ; otherwise, if 0, will spawn INTO block directly
!TileDistanceAbove = $30 ; $10 is only a single tile above Mario. Add $10 more for each full tile length extra.
!PressUpCheck = 0
!Solid = 0 ; block will act as solid if 1

!sfx 			 = $10
!sfx_bank		 = $1DF9

db $37
JMP Mario : JMP Mario : JMP Mario : JMP Return
JMP Return : JMP Return : JMP Return : JMP Mario
JMP Mario : JMP Mario : JMP Return : JMP Return

Mario:
    if !Solid = 0
    LDY #$00		;\
    LDA #$25		;| Act as
    STA $1693       ;/
	endif
    ; You can add ground check
	if !PressUpCheck
	LDA $16
	AND #$08  
	BEQ Return
	endif	
SpriteSpawn:
	LDA #!SpriteNumber 
	CLC
	%spawn_sprite()
	BCS Return
	if !SpawnAboveBlock = 1
	TAX ; This all replicates %move_spawn_multiple_above_block()
	LDA $98
	AND #$F0 
	SEC
	SBC #!TileDistanceAbove
	STA !D8,x
	LDA $99
	SBC #$00
	STA !14D4,x
	LDA $9A
	AND #$F0
	STA !E4,x
	LDA $9B
	STA !14E0,x
	else
	%move_spawn_into_block()	;move sprite position to block
	endif
	LDA #!SpriteState		
    STA !14C8,x					;sprite carried status
	;LDA #!timer
	;STA !1540,x
destroyBlock:
	%erase_block()
	%glitter()
	LDA #!sfx
	STA !sfx_bank|!addr	
	Return:
    RTL