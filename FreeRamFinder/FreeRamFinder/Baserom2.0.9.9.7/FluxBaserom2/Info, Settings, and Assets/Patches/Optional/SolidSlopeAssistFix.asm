if read1($00FFD5) == $23
	sa1rom
	!bank = $000000
else
	lorom
	!bank = $800000
endif

org $00ED52
autoclean JML MarioAbove

org $00EDF3
JML TopCorner

org $01933F
JML SpriteV


freedata

MarioAbove:
	CPY #$31			; Custom slope assist tile
	BEQ .SlopeAssist	;
	CPY #$6E			; Vanilla slopes
	BCS .Slopes			;
JML $00ED56|!bank		;

.Slopes:
JML $00ED5E|!bank		;

.SlopeAssist:
JML $00ED69|!bank		;


TopCorner:
	CPY #$31			; Custom slope assist tile
	BEQ .NotSolid		;
	CPY #$6E			; Vanilla slopes
	BCS .NotSolid		;
JML $00EDF7|!bank		;

.NotSolid:
JML $00EE1D|!bank		;


SpriteV:
	CMP #$31			; Custom slope assist tile
	BEQ .SlopeAssist	;
	CMP #$6E			; Vanilla slopes
	BCS .Slopes			;
JML $0193B8|!bank		; Fixed

.Slopes:
JML $019343|!bank		; Fixed

.SlopeAssist:
JML $019386|!bank		;
