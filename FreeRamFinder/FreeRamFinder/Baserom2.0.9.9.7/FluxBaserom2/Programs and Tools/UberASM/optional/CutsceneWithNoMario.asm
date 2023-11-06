; By SJandCharlieTheCat, with some inspo from Blind Devil

; This minimalist code will simply lock Mario 
; and make him invisible, then wait a defined amount of time
; before warping you to the current screen exit.
; Useful for cutscenes, e.g. in Flip the Switch
; (Note that Mario can still interact with powerups if they touch him.)


!TimeToWait = $3F ; ~5 or 6 seconds?

;How long to wait before advancing the cutscene.
;Possible values: $01-$FF. (e.g. $1F would be approx. 2 seconds, $FF would be 16 seconds, etc.)
;It uses one of the unused decrementing RAM addresses, precisely $14AC.

!Invisible = 1
!MidLevelTrigger = 0 ; if this is enabled, the transition "scene" will only be triggered
                     ; upon a RAM (e.g. block) trigger in-level.
!TriggerRAM = $14AF  ; If above used


init:
    if !MidLevelTrigger = 1
	LDA !TriggerRAM
	BNE Return
	endif
	LDA #!TimeToWait	;Load amount of fourth frames to wait.
	STA $14AC	;Store to unused decrementer.
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
	
	LDA $14AC|!addr	; Check if timer decremented
	CMP #$01
	BNE Return2:				   
	LDA #$06 ; teleport
    STA $71
    STZ $88
    STZ $89
    Return2:
	RTL