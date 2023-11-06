;Castle Candle Flame that goes above layer 3 for layer 3 backgrounds

incsrc EasyPropDefines.txt

AnimationTimings:
db $03,$07,$07,$07,$0F,$07,$07,$0F

CastleFlameTiles:
db $E2,$E4,$E2,$E4

CastleFlameGfxProp:
;db $09,$09,$49,$49
db !PaletteC|!SP3SP4|$10		;$10 - low priority, goes above layer 3 BG but behinnd layer 1
db !PaletteC|!SP3SP4|$10
db !PaletteC|!SP3SP4|!PropXFlip|$10
db !PaletteC|!SP3SP4|!PropXFlip|$10

OAMSlots:
db $F0,$F4,$F8,$FC			;candles use very last OAM slots, to ensure nothing goes behind them and everything else has priority

print "MAIN ",pc
PHB
PHK
PLB
TYX					;a simple wrapper for these disassemblies that swaps X and Y because vanilla clusters use X for sprite tables, and custom ones use Y (for w/e reason)
JSR CandleFlame
TXY
PLB
RTL

CandleFlame:
LDA $9D					;don't animate if freeze flag is set
BNE .GFX

JSL $01ACF9|!bank			;random number generator
AND #$07
TAY
LDA $13					;change frame depending on random timing... randomly.
AND AnimationTimings,y
BNE .GFX

INC $0F4A|!addr,x			;animation frame

.GFX
LDY OAMSlots,x
LDA $1E16|!addr,x			;x-pos
SEC : SBC $22
STA $0300|!addr,y

LDA $1E02|!addr,x			;y-pos
SEC : SBC $24
STA $0301|!addr,y

PHY
PHX
LDA $0F4A|!addr,x			;tile and props based on current frame of animation
AND #$03
TAX
LDA CastleFlameTiles,x
STA $0302|!addr,y

LDA CastleFlameGfxProp,x
STA $0303|!addr,y
PLX
TYA
LSR #2
TAY
LDA #$02				;display 16x16 tile
STA $0460|!addr,y			;
PLY					;

LDA $0300|!addr,y
CMP #$F0
BCC .Re

LDA $0300|!addr,y			;copies OAM info to the different one, but also support x-pos high byte for smooth transition
STA $03EC|!addr

LDA $0301|!addr,y
STA $03ED|!addr

LDA $0302|!addr,y
STA $03EE|!addr

LDA $0303|!addr,y
STA $03EF|!addr

LDA #$03
STA $049B|!addr				;still 16x16, but also x-pos high byte bit

.Re
RTS