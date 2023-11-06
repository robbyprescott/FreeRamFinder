; GFX03 must be in SP4. See levels 1F, 101, 10D

;Castle Candle Flame generator but in a uberASM form.
; If ylou have multple entrances/checkpoints, don't need to put a generator for each one.

!CandleFlameSpr = $05				;add "+!ClusterOffset" without quotations if you want to use a custom cluster candle flame

FlameXPositions:
db $50,$90,$D0,$10

!FlameYPosition = $F0

;from PIXI (dont change)
!ClusterOffset = $09

init:
LDA $71						;if castle entrance/no yoshi sign cutscene plays
CMP #$0A					;don't put flames (if the sublevel you're using does have candles, you'll have to use a sprite command)
BEQ .Re						;

LDA #$01					;
STA $18B8|!addr					;run cluster sprites

LDY #$03					;put 4 candle flames

.Loop
LDA #!CandleFlameSpr
STA $1892|!addr,y

LDA FlameXPositions,y
STA $1E16|!addr,y

LDA #!FlameYPosition
STA $1E02|!addr,y
TYA
ASL #2
STA $0F4A|!addr,y				;initial animation frame

DEY
BPL .Loop

.Re
RTL