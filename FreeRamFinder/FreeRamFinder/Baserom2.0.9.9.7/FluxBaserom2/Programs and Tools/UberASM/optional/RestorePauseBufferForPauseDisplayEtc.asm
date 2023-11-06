; By default this is set to display the song info
; when you press L or R when paused.
; Write your text corresponding to the song number you want (in Text.asm),
; then match with the number in the LM music menu

!FreeRAM = $0DFA

load:
    ;LDA #$01
	;STA !FreeRAM
    RTL
	
init:    
    STZ $0EAC ; restore pause buffer	
	RTL
	
main:
	; Don't use JSL for this in level main; only GM14
	RTL