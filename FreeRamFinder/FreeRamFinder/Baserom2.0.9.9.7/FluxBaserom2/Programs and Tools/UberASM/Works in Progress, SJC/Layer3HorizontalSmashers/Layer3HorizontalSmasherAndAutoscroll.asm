; SJC: This old code is janky.
; Need to fix smasher position reset on death (it reverts back at load).
; Also, behavior is janky if you're standing on top of right smasher.
; (Left one seems to be better though?) 

; Use ExGFX330 and 331

;;; Horizontal Layer 3 Smashers + Autoscroll ;;;
;;;   by Medic and leod                      ;;;
;;;                                          ;;;
;;; To use properly, insert the given ExGFX  ;;;
;;; files into the spots they're named after ;;;
;;; in the Layer 3 Bypass window (the green  ;;;
;;; Poison Mushroom), and set scrolling to   ;;;
;;; "No Vertical or Horizontal Scrolling".   ;;;


;; DEFINES ;;
!start = $01
; Which side to start smashing from.
; $00 = left; $01 = right

!FreeRAM = $0E73|!addr
; $09 bytes of consecutive freeram
; Default value works fine unless used already!

!scrollto = $0100
; Which screen position the autoscroll should scroll to.
; $1900 means exactly up to the start of screen 19.
; If you want it to move all the way up to screen 3 for example,
; use $0300, etc.
; Warning: If you scroll all the way to $0000, be sure to add a ceiling to the room, otherwise, if the player jumps above the screen, they will die.


;;    TABLES      ;;
;DONT CHANGE THESE ;
!stat = !FreeRAM+0|!addr
!timer = !FreeRAM+1|!addr
!spd = !FreeRAM+2|!addr
!frac = !FreeRAM+3|!addr
!pos = !FreeRAM+4|!addr ;2 bytes!
!timer2 = !FreeRAM+6|!addr
!x = !FreeRAM+7|!addr
!1570 = !FreeRAM+8|!addr

load:
STZ !FreeRAM+0|!addr ; originally $0F5E
STZ !FreeRAM+1|!addr ; originally $0F60, etc. (always increase by two)
STZ !FreeRAM+2|!addr
STZ !FreeRAM+3|!addr
STZ !FreeRAM+4|!addr
STZ !FreeRAM+5|!addr
STZ !FreeRAM+6|!addr
STZ !FreeRAM+7|!addr
STZ !FreeRAM+8|!addr
RTL

init:
REP #$20
LDA #$0080
STA $24
SEP #$20
LDA #$07
STA !timer
LDA #!start
STA !x ;start left or right?
RTL

main:
LDA $9D
ORA $13D4|!addr
BEQ +
RTL
+

;kill when mario is offscreen
REP #$20
LDA $1464|!addr
CLC : ADC #$00E8
CMP $96
SEP #$20
BCS .NoKill
JSL $80F606
RTL
.NoKill



REP #$20
LDA $1464|!addr
CMP #!scrollto
SEP #$20
BEQ .NoLayer1
BCC .NoLayer1

DEC !timer  ;this block of code moves layer
LDA !timer
BNE +
LDA #$07    ;timer setting?
STA !timer  ;move layer 1
REP #$20
DEC $1464|!addr
LDA $1464|!addr
SEP #$20

.NoLayer1

+
LDA !timer
CMP #$06
BNE +
REP #$20
DEC $24     ;next frame Cx
SEP #$20
+           ;until here i guess

REP #$20
LDA !pos
STA $22
SEP #$20    ;update position

LDA !timer2
BEQ +
DEC !timer2 ;decrement timer2
+
LDX !x
JSR Interact
lda !stat
JSL $0086DF
dw stat1
dw stat2
dw stat3
dw stat4
dw stat5


initpos1:
db $20,$E0
initspeed:
db $04,$FC
cmpos:
db $40,$C0
addspd:
db $07,$F9
cmpos2:
db $A0,$20
stat1:
LDA !timer2
BNE .return
LDA !x
EOR #$01
STA !x
LDX !x
INC !stat
LDA #$80
STA !timer2
REP #$20
LDA #$0080
STA $24
SEP #$20
LDA initpos1,x
STA !pos
STX !pos+1
STZ !frac
STZ !spd

.return:
RTL

stat2:
LDA !timer2
BEQ +
LDA initspeed,x
STA !spd
JSR update
RTL
+
INC !stat
RTL


stat3:
JSR update
CPX #$00
BNE lollazy
LDA !spd
BMI +
CMP #$40
BCS ++
+
CLC : ADC #$07
STA !spd
++
LDA !pos
CMP #$B0
BCC .return
AND #$F0
STA !pos
;LDA #$30
;STA $1887|!addr
LDA #$09
STA $1DFC|!addr
LDA #$30
STA !timer2
INC !stat
.return
RTL

lollazy:
LDA !spd
BPL +
CMP #$C0
BCC ++
+
CLC : ADC #$F9
STA !spd
++
LDA !pos
CMP #$59
BCS .return
AND #$F0
STA !pos
LDA #$30
STA $1887|!addr
LDA #$09
STA $1DFC|!addr
LDA #$30
STA !timer2
INC !stat
.return
RTL

stat4:
LDA !timer2
BNE .return
INC !stat
.return
RTL

returnspeed:
db $E0,$20

stat5:
LDA returnspeed,x
STA !spd
JSR update
LDA !pos
BNE .return
STZ !stat
LDA #$A0
STA !timer2
LDA #$30
STA $24
STZ $25
.return
RTL

update:
LDA !spd
ASL : ASL : ASL : ASL
CLC : ADC !frac
STA !frac
PHP : PHP
LDY #$00
LDA !spd
LSR : LSR : LSR : LSR
CMP #$08
BCC +
ORA #$F0
DEY
+
PLP
PHA
ADC !pos
STA !pos
TYA
ADC !pos+1
STA !pos+1
PLA
PLP
ADC #$00
STA $1491|!addr
RTS


Interact:
CPX #$00
BNE +
REP #$20
LDA #$00B0
SEC : SBC $24
CLC : ADC $1C
SEP #$20
STA $05
XBA
STA $0B
REP #$20
LDA #$0100
SEC : SBC $22
CLC : ADC $1A
SEP #$20
STA $04
XBA
STA $0A

LDA #$7F
STA $06
STA $07
JSR SolidContact

LDA #$10
STA $06
REP #$20
LDA #$017F
SEC : SBC $22
CLC : ADC $1A
SEP #$20
STA $04
XBA
STA $0A
JSR SolidContact


BRA ++
+

REP #$20
LDA #$00B0
SEC : SBC $24
CLC : ADC $1C
SEP #$20
STA $05
XBA
STA $0B
REP #$20
LDA #$0200-$7F
SEC : SBC $22
CLC : ADC $1A
SEP #$20
STA $04
XBA
STA $0A
LDA #$7F
STA $06
STA $07
JSR SolidContact

LDA #$10
STA $06
REP #$20
LDA #$0200-$8F
SEC : SBC $22
CLC : ADC $1A
SEP #$20
STA $04
XBA
STA $0A
JSR SolidContact


++
RTS


;;;;;
; LEOD'S SOLID SPRITE ROUTINE
; ASSUMES THAT SPRITE SLOT A IS FILLED IN
; Which side Mario is touching the sprite from is stored to !1570
; Values are: 00 = no contact; 01 = top; 02 = bottom; FE = left; FF = right
;;;;;

SolidContact:
JSL $03B664           ;fill in mario clipping

STZ !1570             ;no contact ram
JSL $03B72B           ;check if the filled in objects intersect
BCS .Contact          ;go to NoContact if no contact
RTS
  .Contact


;check if mario should ride the sprite before the edges so he isnt
;stuck on top because hes "inside" the sprite technically
JSR Get_Solid_Vert
CPY #$00
BEQ .DecideDownOrSides


LDY $187A|!addr               ;load yoshi flag into y
LDA $0F
SEC : SBC #$10
CMP .HeightReq,y
BCS .DecideDownOrSides  ;if difference is less than FF-E6, mario isnt quite high enough
BPL .DecideDownOrSides  ;if difference is positive, mario is -below-

INC !1570               ;tell sprite that mario is touching from above (01)
                        ;INC works because it's re-set to 00 every frame

LDA #$01
STA $1471|!addr               ;set "on sprite" flag

LDA #$E1                ;load E1
LDY $187A|!addr
BEQ .NoYoshi
LDA #$D1                ;if on yoshi, load D1 instead (one block higher)
  .NoYoshi
CLC
ADC $05                 ;add sprite y position, low byte
SEC
SBC #$01                ;substract one to align mario
STA $96                 ;store to mario y position, low byte
LDA $0B                 ;load sprite y position, high byte
ADC #$FF                ;decrease by 1 or keep same depending on overflow
STA $97                 ;store to mario y position

RTS


.HeightReq        ;height difference requirement with and without yoshi
db $D4,$C6,$C6

  .DecideDownOrSides
  LDA !stat
  CMP #$02
  BEQ ++
  CMP #$03
  BNE +
  ++
LDA !spd
EOR #$FF
INC
STA $7B
  +
LDA $0A
XBA               ;load left edge of sprite
LDA $04
REP #$20
SEC
SBC #$000C        ;take into account right edge
CMP $D1           ;compare to mario
SEP #$20
BCS .HorzCheck

REP #$20
CLC
ADC #$0008        ;get back left edge of sprite
STA $0C
SEP #$20

LDA $0C
CLC
ADC $06           ;add width to get right edge
STA $0C
LDA $0D
ADC #$00
STA $0D
REP #$20
LDA $0C
CMP $D1           ;compare to mario
SEP #$20
BCC .HorzCheck

;mario is touching the sprite from below
LDA $77           ;if mario is on floor, dont signal sprite that hes touching
AND #$04
BEQ .DoSignal     ;but still keep it solid

LDA $7D           ;load mario y speed
BPL .NoContact    ;if he is moving downwards, return


  .DoSignal
LDA #$02
STA !1570       ;tell sprite that mario is touching from below (02)

  .NoSignal
LDA #$08          ;store #$10 to mario speed
STA $7D

LDA #$01
STA $1DF9|!addr

RTS

  .HorzCheck
;check if mario -was- outside the sprite horizontally
JSR Get_Solid_Horz
LDA $0F                 ;get range difference between sprite and mario
BMI .MarioLeft
;mario is to right of sprite

SEC
SBC $06                 ;substract width for left edge
BPL .NoContact

;mario is touching right
LDA #$FE
STA !1570        ;tell sprite mario is touching right (FE)

LDA $04
CLC
ADC #$FE
STA $04
LDA $0A
ADC #$FF
STA $0A

LDA $04
CLC
ADC $06
STA $0C

LDA $0A
ADC #$00
STA $0D

REP #$20
LDA $0C
STA $94
SEP #$20


LDA $7B
BPL .NoContact      ;unless mario is moving left, zero out speed
STZ $7B

RTS

  .MarioLeft
;mario is to left of sprite
CLC
ADC #$10          ;add mario width
BMI .NoContact

;mario is touching left
DEC !1570       ;tell sprite mario is touching left (FF)
                  ;dec works because it's re-set to 00 every frame

LDA $04
SEC
SBC #$0D
STA $0C

LDA $0A
SBC #$00
STA $0D

REP #$20
LDA $0C
STA $94
SEP #$20

LDA $7B
BMI .NoContact      ;unless mario is moving right, zero out speed
STZ $7B

  .NoContact
RTS




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; vertical mario/sprite position check
; changed for a specific solid sprite routine to use filled-in clip values
; Y = 1 if mario above sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;org $03B829 

Get_Solid_Vert:       
LDY #$00        ;init as 0
LDA $D3         ;mario y pos
SEC
SBC $05         ;minus sprite y pos
STA $0F         ;store range difference in 0F
LDA $D4         ;mario y pos high
SBC $0B         ;minus sprite y pos high + overflow
BPL MarioLower  ;if the result is not positive (so Mario would be below)
INY             ;increase y
  MarioLower:
STY $0E         ;store in $0E
RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; horizontal mario/sprite position check
; changed for a specific solid sprite routine to use filled-in clip values
; Y = 1 if mario left of sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Get_Solid_Horz:
LDY #$00        ;init as 0
LDA $D1         ;mario x pos
SEC
SBC $04         ;minus sprite x pos
STA $0F         ;store range difference in 0F
LDA $D2         ;mario x pos high
SBC $0A         ;minus sprite x pos high + overflow
BPL MarioRight  ;if the result is not positive (so Mario would be to the right)
INY             ;increase y
  MarioRight:
STY $0E         ;store in $0E
RTS
