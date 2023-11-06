; The only negative thing is a visual bug where the castle door and fuse reset their position,
; i.e. they reappear in certain cutscenes when the castle has been destroyed.

org $8CC94E
autoclean JML CastleSceneSkip

!CastleSceneRAM = $1450  ; RAM in the scroll command region, castle cutscenes reuse other RAM in this region so it should be safe

freecode

CastleSceneSkip:
LDA $15         ;\ check if Start is pressed
AND #$10        ;/
BEQ .Return

.StartPressed
LDA !CastleSceneRAM
BNE .EndScene   ; if it's nonzero, the button was pressed on a previous frame, so end scene
INC !CastleSceneRAM  ; otherwise, set a flag and return.
      ; skipping on the first possible frame causes a freeze, so this ensures Start is pressed for at least 2 frames

.Return
LDA $1443       ;\ replaced
BEQ +           ;/
JML $8CC953
+
JML $8CC97D

.EndScene
STZ $1443       ;\ clear timers to end castle destruction scene
STZ $144D       ;/
LDX $13C6       ; which castle cutscene is this?
LDA.l .Table-1,x;\ set scene pointer to its final value for that cutscene (jumps to 0CCFDE)
STA $1442       ;/
LDA #$90        ;\
STA $16         ;/ set controller as if B was pressed this frame
JML $8CC99A

.Table
db $05,$04,$03,$07,$09,$01,$04
