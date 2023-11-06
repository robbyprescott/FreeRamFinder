print "You can set these blocks to any act-as (on first two Map16 pages), and they'll be activated automatically by wall-running on them."

;#######################################;
;# Wall Run Activated Blocks           #;
;# By MarkAlarm                        #;
;# Credit unnecessary, but appreciated #;
;#######################################;

; Though act-as must be from first two M16 pages

;#################;
;# Main Pointers #;
;#################;

db $37
JMP Return : JMP Return : JMP Return
JMP Return : JMP Return : JMP Return : JMP Return
JMP Return : JMP Return : JMP Return
JMP WallRun : JMP WallRun

;####################;
;# Wall Run Routine #;
;####################;

WallRun:
	STZ $1933|!addr			; only work on layer 1 (might add layer 2 compatibility in the future
	
	LDA $19
    CMP #$02 ; cape check
    BNE Return
    LDA $16
    AND #$40 ; press Y or X
    BEQ Return
	
	PHY						; \ preserve Y
	LDY #$00				; | clear Y for this subroutine
	LDA $1693|!addr			; | get the map16 low byte, the act as
	JSL $00F160|!bank		; | trigger block subroutine
	PLY						; / restore Y

Return:
	RTL

print "An block that gets activated upon wall running."
