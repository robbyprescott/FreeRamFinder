; By SJandCharlieTheCat
; I need to add code for disabling HOLDS for A, B, X, and Y only, too

; You don't need to change anything with this. Just use the blocks which will disable or enable the button. 
; By default, both presses and holds will be disabled for all buttons except
; for B and Y, where holding (but not pressing) these is still enabled.

; Watch out for soft-locks! Will probably want to use this in conjunction
; with the UberASM that lets you use L/R to reset.


!DisableHoldRight = 1
!DisableHoldLeft = 1
!DisableHoldDown = 1
!DisableHoldUp = 1
!DisableHoldB = 0
!DisableHoldY = 0
!DisableHoldA = 0
!DisableHoldX = 0

!FreeRAMNoRight = $0DE1
!FreeRAMNoLeft = $0DE2
!FreeRAMNoDown = $0DE3 
!FreeRAMNoUp = $0DE4
!FreeRAMNoB = $0DE5
!FreeRAMNoY = $0DE6
!FreeRAMNoA = $0DE7
!FreeRAMNoX = $0DE8

main:
    LDA !FreeRAMNoRight 
    BEQ Next
    LDA #$01
    TRB $16  ; Disables presses
    TRB $18  ; controller 2       
if !DisableHoldRight = 1
    TRB $15  
    TRB $17
endif	
    BRA Return
Next:
    LDA !FreeRAMNoLeft 
    BEQ Next2
    LDA #$01
    TRB $16  ; Disables presses
    TRB $18  ; controller 2       
if !DisableHoldLeft = 1
    TRB $15  
    TRB $17
endif
    BRA Return
Next2:
    LDA !FreeRAMNoDown 
    BEQ Next3
    LDA #$01
    TRB $16  ; Disables presses
    TRB $18  ; controller 2       
if !DisableHoldDown = 1
    TRB $15  
    TRB $17
endif
    BRA Return	
Next3:
    LDA !FreeRAMNoUp 
    BEQ Next4
    LDA #$01
    TRB $16  ; Disables presses
    TRB $18  ; controller 2       
if !DisableHoldUp = 1
    TRB $15  
    TRB $17
endif		
    BRA Return
Next4:
    LDA !FreeRAMNoB 
    BEQ Next5
    LDA #$80
	TSB $0DAA
	TSB $0DAB
	if !DisableHoldB = 1
	LDA $15
    EOR $17
    BPL Return ; BMI for check only A
    LDA #$80
    TRB $15  
    TRB $17
    endif
	BRA Return
Next5:	
    LDA !FreeRAMNoY 
    BEQ Next6
    LDA #$40
	TSB $0DAA
	TSB $0DAB
	if !DisableHoldY = 1
    endif	
	BRA Return
Next6:
    LDA !FreeRAMNoA 
    BEQ Next7
    LDA #$80
	TSB $0DAC
	TSB $0DAD
	if !DisableHoldA = 1
    endif	
	BRA Return
Next7:
    LDA !FreeRAMNoX 
    BEQ Return
    LDA #$40
	TSB $0DAC
	TSB $0DAD
	if !DisableHoldX = 1
    endif
Return:
    RTL