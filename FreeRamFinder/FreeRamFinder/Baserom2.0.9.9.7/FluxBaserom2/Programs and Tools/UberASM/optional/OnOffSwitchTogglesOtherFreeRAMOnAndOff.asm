; This simple Uber ties a defined FreeRAM address/trigger to the on/off switch, 
; so you can just use the preeexisting on/off switch to toggle it, without
; having to make a separate block/switch to do this.

; You could tie it to anything else, too, like a p-switch ($14AD)


!OtherRAM = $19   ; $19 isn't actually FreeRAM (actually Mario powerup), but is just an example

init:
    STZ !OtherRAM
    RTL

main:
	LDA $14AF         ; On/off switch
    BEQ	Nope
	LDA #$01
	STA !OthereRAM
	RTL
	
	Nope: 
	BRA init