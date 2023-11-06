; By James and SJC

	lorom
	!dp = $0000
	!addr = $0000
	!Bank = $800000

!FreeRAMPenalty = $0E27	
!FreeRAMReward = $0E28
	
org $00FA45
autoclean JML YumpPrize		; Modify Flat Palace Switch routine to give prize if Mario Yumps successfully, and/or punish if Mario fails the Yump.

freecode

YumpPrize:
LDA $16		; Buttons newly pressed (BYETUDLR).
ORA $18		; Buttons newly pressed (AXLR----).
BPL NoYump		; Go here if A or B not pressed.

LDA !FreeRAMReward ; If set, will give extra reward when yump
BEQ NormalRoutine
INC $18E4 ; Set reward here (one-up)
    NormalRoutine:
LDA #$20		; Shake ground timer.
STA $1887|!addr		;
JML $00FA4A|!Bank		; Return to normal routine.

NoYump:		;
LDA !FreeRAMPenalty ; If set, will do the following (kill you and reset) if you DON'T yump
BEQ NormalRoutine
LDA #$01
STA $0E29
STZ $1F27|!addr,x	; SJC: I think this is only the GREEN switch palace activation flag?
STZ $13D2|!addr		; Color of the currently pressed switch palace, or #$00 for None. 
                    ; It's set to #$01 when the player hits a switch palace, and then set to the correct color 
					;(#$01 for Yellow, #$02 for Blue, #$03 for Red and #$04 for Green, others are oddly colored and/or flipped) by the message box routine.
JSL $00F606|!Bank		; Kill Mario subroutine.
PLA		; Nothing else in the Flat Palace Switch routine needs to run, so nuke the return address...
PLA		;
PLY		; Restore Y... (it's preserved before the Flat Palace Switch routine is called)
JML $00EED1|!Bank		; And jump out of the routine. We also skip past some code relating to music and the level end timer.

;LDA #$2A		; Play "Wrong" SFX.
;STA $1DFC|!addr		; SFX Bank.

;LDA #$29		; Play "Correct" SFX.
;STA $1DFC|!addr		; SFX Bank.