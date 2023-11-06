print "Kinda jank. Emulates an immobile shell, with a limited number of bounces on each one (see the number above). Can be used with number indicator (though if so must use Uber to actually have indicator change). Side hitbox currently a little too severe, so I've added a define to turn off if you want. (If so, will only kill from below, and act as solid from side). WIP by SJC."

; Based on
; Pixel perfect spike
; by MarioFanGamer

!KillIfTouchSide = 1
!FreeRAM = $0ECF

db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP TopCorner : JMP MarioInside : JMP MarioHead
JMP WallRun : JMP WallSide

MarioAbove:
TopCorner:
MarioInside:
    LDA #$01
	STA !FreeRAM
	
    PHY
	LDA $98
	AND #$0F
	ASL
	TAY
	LDA $9A
	AND #$0F
	ASL
	TAX
	REP #$20
	LDA SpikeHitbox,y
	AND Bitflags,x
	SEP #$20
	BEQ .NotTouched
	;begin code
	LDA $140D
	BNE .IfSpin
	LDY #$10	;act like tile 130
	LDA #$30
	STA $1693
	LDA #$14
	STA $1DF9
	LDA #$AA ; 
    STA $7D  ; boost
    REP #$10				;   16-bit XY
    LDX $03					; \ 
    INX						; / Load next Map16 number
    %change_map16()			;   Change the block
    SEP #$10				;   8-bit XY
	%create_smoke()
	;end
	PLY	
	BRA Return
	
.IfSpin
    ; Because block itself act as 130, when you spin-jump on it,
    ; even if explicitly STA $140D here, will force you into a normal jump	
    ;LDY #$00	;act like tile 130
	;LDA #$25
	;STA $1693
	LDA #$F7 ; If as low as FA, janky if you spin-jump a straight line of them. (Could use swooper block instead.)  
    STA $7D  ; boost
	LDA #$01
	STA $140D
    %create_smoke()
    %erase_block()
.NotTouched
	PLY
	RTL
	
MarioSide:
    if !KillIfTouchSide = 0
    BRA Return
	endif
MarioBelow:
MarioHead:
    JSL $00F606
	BRA Return
Cape:
Fireball:
SpriteV:
SpriteH:
    LDA #$13 ; or 14?
	STA $1DF9
    %sprite_block_position()
    %create_smoke()
    %erase_block()
WallRun:
WallSide:
Return:
    RTL

Bitflags:
dw $8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100
dw $0080,$0040,$0020,$0010,$0008,$0004,$0002,$0001

SpikeHitbox:
dw %1111111111111111 ; or %0111111111111110
dw %1111111111111111
dw %1111111111111111
dw %1111111111111111
dw %1111111111111111
dw %1111111111111111
dw %0000000000000000
dw %0000000000000000
dw %0000000000000000
dw %0000000000000000
dw %0000000000000000
dw %0000000000000000
dw %0000000000000000
dw %0000000000000000
dw %0000000000000000
dw %0000000000000000