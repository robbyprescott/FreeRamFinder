;Patch by JackTheSpades, mods by SJC
;Requested by Two Tails
; https://www.smwcentral.net/?p=section&a=details&id=20902
;Patch makes it so, that the player can't carry sprites while....

!FreeRAM = $0EB3 ; $1929 

if read1($00FFD5) == $23
    sa1rom
    !addr = $6000
    !bank = $000000
else
    lorom
    !addr = $0000
    !bank = $800000
endif

org $01AA5E ; hijacks same spot that no pressed p-switch carry does
	autoclean JSL HandlePickup
	NOP #2

org $01E6D2 ; Springboard routine. Should be compatible with springboard fixes
	autoclean JSL HandlePickup
	NOP #2

org $02862F
	autoclean JSL HandleThrowBlock

freecode

HandlePickup:
	;The secret is... if A is not zero after the RTL, Mario can't pick up sprites
	;So, modifing this patch should be fairly easy.

	LDA !FreeRAM		
	BNE .nope	;/
	LDA $1470|!addr	;\ restore-code
	ORA $187A|!addr	;/
	; !163E,x ; add if want to make no pressed p-switch carry global
	RTL
.nope:
	INC		;If codes branches here, then A = 0, so we INC to make it 1
	RTL

HandleThrowBlock:
	LDA !FreeRAM
	BNE .nope
	JSL $02A9E4	;Restorecode
	RTL
.nope
	LDA #$FF	;After the RTL, there comes a "BMI Return", so to make it always return...
	RTL