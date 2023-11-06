; By SJandCharlieTheCat, with some inspo from Blind Devil

; This minimalist code will simply lock Mario 
; and make him invisible, then warp you to the current screen exit
; after the level timer runs out (or technically when it hits 1).
; Useful for cutscenes, e.g. in Flip the Switch
; (Note that Mario can still interact with powerups if they touch him.)



!Invisible = 1
!MidLevelTrigger = 0 ; if this is enabled, the transition "scene" will only be triggered
                     ; upon a RAM (e.g. block) trigger in-level.
!TriggerRAM = $14AF  ; If above used
!Time = $001 ; don't change this

init:
    if !MidLevelTrigger = 1
	LDA !TriggerRAM
	BNE Return
	endif
	Return:
	RTL
main:
	if !MidLevelTrigger = 1
	LDA !TriggerRAM
	BNE Return2
	endif
	
	STZ $7B ; Mario won't move at all, or even fall,
	STZ $7D ; so you can place him anywhere on-screen
	
	if !Invisible
    LDA #$7F ; Invisible 
	STA $78
	endif
	
	LDA #$FF ; Mario won't be hurt by sprites
    STA $1497|!addr
	
    LDA #$FF
    STA $0DAA
    STA $0DAC
    STZ $15 ; no controls
    STZ $17
	
	LDA $0F33	;load ones
	CMP.b #!Time&15	;only low nybble
	BNE Return2	;if not equal return

	LDA $0F32	;load tens
	CMP.b #!Time>>4&15
	BNE Return2

	LDA $0F31
	CMP.b #!Time>>8&15
	BNE Return2

;teleport
	LDA #$06
	STA $71
	STZ $89
	STZ $88
    Return2:
	RTL