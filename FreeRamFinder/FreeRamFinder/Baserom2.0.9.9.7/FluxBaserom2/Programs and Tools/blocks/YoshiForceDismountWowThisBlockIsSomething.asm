; -------------------- ;
; Force Yoshi Dismount ;
; -------------------- ;

!ZeroYoshiSpeed = 1		; If set, Yoshi will be immediately set to 0 speed. Useful for preventing Yoshi from getting through the block under any circumstances.
!SFX = $00				; SFX, default 20, Yoshi spit. Set to $00 to disable.
!SFXBank = $1DF9		; SFX bank.

;--------------------

db $42
JMP Mario : JMP Mario : JMP Mario
JMP Sprite : JMP Sprite : JMP Return : JMP Return
JMP Mario : JMP Mario : JMP Mario

Mario:
LDA $18E2|!addr		;/
BEQ Return			;|
DEC					;|
TAX					;| Check for Yoshi, and set the "disable player contact" timer if there's a Yoshi. Prevents mounting Yoshi while Mario's inside the block.
LDA #$08			;|
STA !154C,x			;\
LDA $187A|!addr		;/
BNE OffYoshi		;\ If we're riding Yoshi, dismount him.
RTL

Sprite:
TXA					;/
INC A				;| Check if the sprite touching the block is Yoshi.
CMP $18E2|!addr		;\
BNE Return
if !ZeroYoshiSpeed
STZ !B6,x			; 0 Yoshi's speed if define is set.
endif
LDA $187A|!addr		; Return if not riding Yoshi.
BEQ Return

OffYoshi:
if !sa1
TXA
CLC
ADC #$16
STA $CC		; SA-1 uses a 16-bit pointer at $CC to remap !D8,x for each sprite. I guess our block runs at a point where $CC isn't holding !D8 for Yoshi, so we
LDA #$32	; need to set that manually so Mario's Y position is set properly when dismounting Yoshi.
STA $CD
endif

PHY		; The routine we jump to below kills Y. We need to preserve it for the block's act-as.
PHK
PEA.w .return-1
PEA $80C9
JML $01ED9E|!bank		; Part of the routine that handles dismounting Yoshi, but we skip the button check to force a dismount.
.return
PLY

LDA #$08		; Set "disable player contact" timer. Doing it here too ensures it's always set regardless of whether it's Mario or Yoshi inside the block.
STA !154C,x
if !SFX
LDA #!SFX				;/
STA !SFXBank|!addr		;\ Play SFX if define is set.
endif
Return:
RTL


print "This was supposed to be the original main block that not only doesn't let Yoshi pass, but forces you to dismount him when you touch it. However, it has a hilarious unintended effect where, when you touch it with Yoshi, you did indeed dismount him, but are also vertically screen-wrapped (kind of similar to the p-switch and sprite killer glitch) and then yeeted to the right at an even greater speed than cannon speed. I kept it because it's actually kind of cool and hilarious."