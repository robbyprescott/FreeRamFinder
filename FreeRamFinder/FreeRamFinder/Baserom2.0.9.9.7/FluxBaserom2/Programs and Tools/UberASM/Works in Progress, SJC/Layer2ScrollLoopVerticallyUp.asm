; By spoons, minor edits by SJandCharlieTheCat

; Use e.g. Level mode 02, interactable layer 2
; Use a V-scroll None setting, like H-scroll Variable and V-scroll None

!ScrollUpward = 1 ; Don't set to 0 currently -- downward scroll broken. #$3A+$5A and #$3A close though

main:
    LDA $9D		;\ If sprites locked,
    ORA $13D4|!addr
    BNE .return	;/ branch
    
    STZ $1412|!addr	; Disable vertical scroll
	if !ScrollUpward = 1
    INC $1468|!addr	; Scroll layer 2 upwards
	else
	DEC $1468|!addr
    endif
    LDA $1468|!addr	;\ If not time for layer 2 to return,
    CMP.b #$10 ; initial position $10. SJC removed original +$80
    BNE .return	;/ branch
    LDA.b #$10	;\ Reset layer 2 position -- maybe adjust $10 here and above
    STA $1468|!addr	;/
    .return

    RTL