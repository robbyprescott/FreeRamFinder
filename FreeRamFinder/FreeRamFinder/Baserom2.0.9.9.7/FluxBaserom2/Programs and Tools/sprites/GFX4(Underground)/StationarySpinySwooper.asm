;A Spiny/Swooper that remains stationary and not affected by gravity or anything like that.
;Extra Prop Byte 1 (via CFG or JSON) decides wether its a spiny or a swooper (clear - swooper, set - spiny)

;use 16x16 tile or 8x8 tiles.
;0 - one 16x16 tile
;non-0 - four 8x8 tiles forming 16x16 image
!SwooperGFXSize = 0
!SpinyGFXSize = 1

;tilemaps for 16x16
!16x16SwooperTile1 = $C0
!16x16SwooperTile2 = $E8

!16x16SpinyTile1 = $80
!16x16SpinyTile2 = $82

;tilemaps for 8x8
EightByEightBatTilemap:
db $C0,$C1,$D0,$D1			;frame 1
db $E8,$E9,$F8,$F9			;frame 2

EightByEightSpinyTilemap:
db $84,$84,$84,$84			;frame 1
db $94,$94,$94,$94			;frame 2

incsrc SwooperEasyPropDefines.txt

;used for spiny's 8x8 graphics
FlipsSpiny:
db $00,!PropXFlip,!PropYFlip,!PropXFlip|!PropYFlip

;used for bat's 8x8 graphics
FlipsBat:
db $00,$00,$00,$00

!AnimRate = 8				;how long does it take to animate

!AlwaysFace = 0				;will make the sprite always face the player. only really works if the graphics are not symmetrical

;you probably don't want to change these
XDisp:
db $00,$08,$00,$08

YDisp:
db $00,$00,$08,$08

!GFXFrame = !1602,x

Print "INIT ",pc
LDA #!AnimRate
STA !1540,x

if not(!AlwaysFace)			;it always faces the player if this is enabled, so this becomes pointless
  %SubHorzPos()				;face the player on spawn
  TYA					;
  STA !157C,x				;
endif
RTL

Print "MAIN ",pc
PHB
PHK
PLB
JSR Hazard
PLB
RTL

Hazard:
JSR GFX					;show very low res graphics

LDA !14C8,x				;dead or freeze flag set = don't act
EOR #$08				;
ORA $9D					;
BNE .Re					;
%SubOffScreen()				;

if !AlwaysFace
  %SubHorzPos()				;face the player always
  TYA					;
  STA !157C,x				;
endif

JSL $01803A|!bank			;interact with other sprite and player

LDA !14C8,x				;
CMP #$08				;i guess this ensures that the sprite disappears in a puff of smoke (if set to)
BNE .FallingDown			;because checking for 02 specifically doesn't work for w/e reason

;animate
LDA !1540,x				;don't change frame if animation timer is ticking
BNE .Re					;

LDA !GFXFrame				;
EOR #$01				;
STA !GFXFrame				;

LDA #!AnimRate				;refresh timer
STA !1540,x				;

.Re
RTS					;

.FallingDown
LDA !1656,x				;check for disappear in a cloud of smoke CFG bit. looks like the sprite can't normally die in a puff of smoke when jumped on, even if the bit is set
BPL .Re					;

LDA #$04				;actually die in a puff of smoke
STA !14C8,x				;

LDA #$1F				;
STA !1540,x				;timer for smoke
RTS					;

;handy macros, do not handle GetDrawInfo or any other preparation
;don't have to copy-paste the code that way and have those big ugly If statements
macro SixteenExSixteenGFX(Tile1,Tile2)
  LDA $00				;
  STA $0300|!addr,y			;tile x-pos

  LDA $01				;
  STA $0301|!addr,y			;tile y-pos

  LDA $03				;display one tile or the other based on current GFX frame
  LSR					;
  LDA #<Tile1>				;
  BCC ?StoreTile			;

  LDA #<Tile2>				;
?StoreTile
  STA $0302|!Base2,y			;

  LDA $02				;prop
  STA $0303|!Base2,y			;

  LDA #$00				;one 16x16 tile
  LDY #$02				;16x16 size
  %FinishOAMWrite()			;can macros call other macros? I guess they can
  RTS					;
endmacro

macro EightExEightGFX(TilemapTable,FlipsTable)
  LDX #$03				;4 tiles to loop through

?Loop
  LDA XDisp,x				;
  XBA					;

  LDA $02				;check if flipped horizontally, will shift tiles around accordingly
  ASL					;
  ASL					;
  XBA					;
  BCC ?NoFlipX				;

  EOR #$08				;basically flip tile position

?NoFlipX
  CLC : ADC $00				;
  STA $0300|!addr,y			;tile x-pos

  LDA YDisp,x				;

  BIT $02				;vertical flip check
  BPL ?NoFlipY				;

  EOR #$08				;

?NoFlipY
  CLC : ADC $01				;
  STA $0301|!addr,y			;tile y-pos

  STX $04				;

  LDA $03				;
  ASL					;
  ASL					;
  CLC : ADC $04				;
  TAX					;
  LDA <TilemapTable>,x			;show appropriate tile, also based on anim frame
  STA $0302|!addr,y			;

  LDX $04				;

  LDA $02				;prop
  EOR <FlipsTable>,x			;and appropriate flip
  STA $0303|!addr,y			;

  INY #4				;
  DEX					;
  BPL ?Loop				;loop until all tiles are done

  LDX $15E9|!addr			;
  LDA #$03				;4 tiles
  LDY #$00				;8x8 size
  %FinishOAMWrite()			;
  RTS					;
endmacro

GFX:
%GetDrawInfo()				;all the prep stuff

LDA !15F6,x				;
ORA $64					;
STA $02					;

LDA !157C,x				;x-flip based on its face direction
LSR					;
BCS .NoXFlip				;

LDA #!PropXFlip				;
TSB $02					;

.NoXFlip
LDA !14C8,x				;y-flip based on its state (if falling down, it'll flip)
CMP #$08				;
BEQ .Normal				;

LDA #!PropYFlip				;
TSB $02					;

.Normal
LDA !GFXFrame				;
STA $03					;

LDA !extra_prop_1,x			;check if should show spiny graphics
BNE .IsSpiny				;

if !SwooperGFXSize
  %EightExEightGFX(EightByEightBatTilemap,FlipsBat)
else
  %SixteenExSixteenGFX(!16x16SwooperTile1,!16x16SwooperTile2)
endif

;looks a little wonky, but trust me, swooper gfx ends here

.IsSpiny
if !SpinyGFXSize
  %EightExEightGFX(EightByEightSpinyTilemap,FlipsSpiny)
else
  %SixteenExSixteenGFX(!16x16SpinyTile1,!16x16SpinyTile2)
endif

;spiny graphics routine ends here. source: dude trust me