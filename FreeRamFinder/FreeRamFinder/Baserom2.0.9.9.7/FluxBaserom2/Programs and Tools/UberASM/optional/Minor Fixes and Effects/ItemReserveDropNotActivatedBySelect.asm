; disables select from activating vanilla item box drop

init:
    LDA #$01
    STA $0DF9 
	RTL