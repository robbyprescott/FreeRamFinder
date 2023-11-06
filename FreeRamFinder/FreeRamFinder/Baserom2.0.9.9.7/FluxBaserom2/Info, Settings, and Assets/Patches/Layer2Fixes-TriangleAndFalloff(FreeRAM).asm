; SJC notes: This combined patch fixes how triangles work in layer 2 levels,
; and fixes the fast fall-off speed from layer 2 ground. Dtothefourth made the triangle fix,
; and mario90 made the fall-off fix, and then Binavik combined the two to make them compatible (because of $00EE35).


; Note that if you want to be able to run up a layer 2 wall, make sure you insert both the triangle itself 
; and the triangle assist tile into your level as layer 2 tiles.

; Uses two different FreeRAM addresses, $0EAA and $7FB540 




!FreeRAM = $7FB740 ;Any FreeRAM, change if conflicting

if read1($00FFD5) == $23	;sa-1 compatibility
  sa1rom
  !BankB = $000000
  !addr = $6000
else
  !BankB = $800000
  !addr = $0000
endif

!Layer2FreeRAM = $0EAA|!addr


org $00F048|!BankB
	autoclean JSL NoteLayer

org $00EAE1|!BankB
	autoclean JML Layer1Only

org $00EE35|!BankB
	autoclean JSL Layer1OnlyFly

org $00EF60
autoclean JML Layer2Flag

freecode

NoteLayer:
	LDA $1933|!addr
	STA !FreeRAM
	INX
	STX.W $13E3|!addr
	RTL

Layer1Only:
	LDA $1933|!addr
	CMP.L !FreeRAM
	BEQ +
	JML $00EB77|!BankB
	+
	LDA $13E3|!addr
	BNE +
	JML $00EB77|!BankB
	+
	JML $00EAE9|!BankB
	
Layer1OnlyFly:
	LDA $1933|!addr
	CMP.L !FreeRAM
	BEQ +

	LDA $13E3|!addr
	BEQ +
	BRA ++
	
	+
	LDA #$24
	STA $72
	

AirFlagTweak:
	LDA #$24		;Original code to flag if Mario is in the air
	STA $72
	++
	LDA $1402|!addr		;Ignore the tweak if on a noteblock
	BNE Return
	LDA !Layer2FreeRAM	;If Mario was on Layer 2, jump to speed tweak
	BNE Layer2
Return:
	STZ !Layer2FreeRAM	;Clear the flag
	RTL
Layer2:
	LDA #$06		;Vanilla Y speed setting when Mario is on ground
	STA $7D
	STZ !Layer2FreeRAM	;Clear the flag
	RTL
	
Layer2Flag:
	LDX $8E			;Check for Mario on Layer 2
	BPL NormalY
	LDX #$01		;Set flag if yes
	STX !Layer2FreeRAM
NormalY:
	STA $7D			;Restore original code
	TAX
	BPL CODE_00EF68
	JML $00EF65
CODE_00EF68:
	JML $00EF68
	