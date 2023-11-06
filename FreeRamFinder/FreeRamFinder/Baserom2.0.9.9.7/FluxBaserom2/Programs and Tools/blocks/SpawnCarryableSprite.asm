; Modified by SJandCharlieTheCat

!StunTimer = $FF ; for bobomb, galoomba, etc.


!sfx 			 = $10
!sfx_bank		 = $1DF9

db $37
JMP Mario : JMP Mario : JMP Mario : JMP Return
JMP Return : JMP Return : JMP Return : JMP Mario
JMP Mario : JMP Mario : JMP Return : JMP Return

PSwitchPal:      db $06,$02

NoTimer:	
	CLC
	%spawn_sprite()
	BCS Return
	%move_spawn_into_block()	;move sprite position to block
	LDA #$0B		
    STA !14C8,x					;sprite carried status
destroyBlock:
	%erase_block()
	%glitter()
	LDA #!sfx
	STA !sfx_bank|!addr	
Return:
    RTL

Mario:
	LDA $1470|!addr				;do not run the code if player is carrying something
	ORA $148F|!addr				;do not run the code if player is carrying something
	ORA $187A|!addr				;do not run the code if player is riding yoshi
	ORA $74						;do not run the code if player is climbing
	BNE Return
checkInput:
	LDA $15
	BIT #$40
	BEQ Return
ArbitraryLabel:
    LDA $1693 
    CPY #$00 	
    CMP #$49 
    BNE Next 
	LDA #$53					; throwblock
    BRA NoTimer
Next:
    LDA $1693 
    CPY #$00 	
    CMP #$4A 
    BNE Next2
	LDA #$06					; blue shell
    BRA NoTimer
Next2:
    LDA $1693 
    CPY #$00 	
    CMP #$4B 
    BNE Next3
	LDA #$80					; key
    BRA NoTimer 
Next3:
    LDA $1693 
    CPY #$00 	
    CMP #$4C 
    BNE Next4
	LDA #$2F					; spring
    BRA NoTimer
Next4:
    LDA $1693 
    CPY #$00 	
    CMP #$4D
    BNE Next5
	LDA #$3E					; p-switch
    CLC
	%spawn_sprite()
	BCS Return
	%move_spawn_into_block()	;move sprite position to block
	;LDA #!switchType
	;STA !151C,x
	PHY
	LDY #$00
	;LDY #!switchType
	LDA PSwitchPal,y
	STA !15F6,x
	PLY
	LDA #$0B		
    STA !14C8,x					;sprite carried status
	BRA destroyBlock2
Next5:
    LDA $1693 
    CPY #$00 	
    CMP #$4E 
    BNE Next6
	LDA #$2D					; baby Yoshi
    BRA TimerSpawn
Next6:
    LDA $1693 
    CPY #$00 	
    CMP #$4F 
    BNE Next7	
	LDA #$0F					; goomba
    BRA TimerSpawn
Next7:
    LDA $1693 
    CPY #$00 	
    CMP #$50 
    BNE Next8
	LDA #$0D ; bomb	
    BRA TimerSpawn
Next8:	
    LDA $1693 
    CPY #$00 	
    CMP #$51 
    BNE Return2
	LDA #$A2 ; mechak
    BRA TimerSpawn
Return2:
	RTL
	
;11 beetle (not used)
	
TimerSpawn:	
	CLC
	%spawn_sprite()
	BCS Return2
	%move_spawn_into_block()	;move sprite position to block
	LDA #$0B		
    STA !14C8,x			;sprite carried status
	LDA #!StunTimer
	STA !1540,x
destroyBlock2:
	%erase_block()
	%glitter()
	LDA #!sfx
	STA !sfx_bank|!addr	
    RTL
	
print "This block spawns a sprite, automatically carried, with the block erasing itself afterwards. Note that the bobomb and mechakoopa require the correct sprite GFX to display properly."