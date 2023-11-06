; Started by SJandCharlieTheCat; later assimilated to Iceguy's patch 
; This will make Mario go to sleep after inactivity


!IdleLength = $03 ; how many seconds of inactivity before sleep
!BrightnessEffect = 1
!BrightnessFadeAmount = $07 ; $0F is normal. $0A is still only a little dark.
!VolumeChange = 0
!IdlePose = $33 ; replace cutscene frame? $25 is vanilla, Mario facing away from camera
!ZzzAboveMario = 1; Will spawn the Rip Van Fish's sleepy "ZZZ" above Mario
!FreeRAM = $0E81

init:
    STZ !FreeRAM
	RTL
	
main:
    LDA $13E0 ; check if default standing pose on ground
    BNE Undo  ; branch if in any moving pose
    LDA !FreeRAM ; trigger count		
	CMP #!IdleLength		
	BCS ++			
	LDA $13
	AND #$3F
	BNE +			; Increment the timer every 1 second.
	INC !FreeRAM
+   RTL

++  
    LDA $7B     ; after inactivity, as long as you remain
	ORA $7D     ; unmoving
    BMI Undo    ; (branch if you move)
	if !BrightnessEffect
	LDA #!BrightnessFadeAmount	
	STA $0DAE
	endif
	if !VolumeChange
	LDA #$2E   
	STA $1DF9
	endif
    LDA #!IdlePose   
    STA $13E0
	if !ZzzAboveMario
    LDA #$06
	TAY
	LDA !15A0,x
	ORA !186C,x
	BNE Return
	TYA
	DEC !1528,x
	BPL Return
	PHA
	LDA #$28
	STA !1528,x
	LDY #$0B
Loop:
	LDA $17F0|!addr,y
	BEQ FreeSlotFound
	DEY
	BPL Loop
	DEC $185D|!addr
	BPL EndLoop
	LDA #$0B
	STA $185D|!addr
EndLoop:
	LDY $185D|!addr
FreeSlotFound:
	PLA
	STA $17F0|!addr,y
	LDA $94
	CLC
	ADC #$06
	STA $1808|!addr,y
	LDA $96
	CLC
	ADC #$00
	STA $17FC|!addr,y
	LDA #$7F
	STA $1850|!addr,y
	LDA #$FA 
	STA $182C|!addr,y
	endif
    BRA Return
	
Undo:	
	STZ !FreeRAM
	if !BrightnessEffect
	LDA #$0F		; 
	STA $0DAE       ; Restore brightness.
	endif
	if !VolumeChange
	LDA #$2F    
	STA $1DF9
	endif
	Return:
	RTL