;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Yoshi's Fireball Disassembly
; This is a disassembly of extended sprite 11 in SMW, Yoshi's Fireball.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc YoshiFireballEasyPropDefines.txt

;Graphic stuff
!Tile1 = $04				;First Fireball's Frame
!Tile2 = $2B				;Second Fireball's Frame

!YoshiFireProp = !PaletteA|!SP3SP4	;graphical prop

;Not so fun fact: the clipping table for extended<->cape interaction only contains entries for extended sprites 02-0D. from $0E onward the clipping is garbage. thanks nintendo.
;if you don't want cape interaction, set this to 0
!CapeInteraction = 1

;Or edit the dimensions
!CapeInteractionClipXOffset = $03
!CapeInteractionClipYOffset = $01
!CapeInteractionWidth = $01
!CapeInteractionHeight = $BD

;fireball kill defines and tables:
FireKillXSpeed:
db $F0,$10				;Killed sprite's X speed (when "can be killed with 5 fireballs" configuration bit is enabled)

!FireKillScore = $04			;score awarded for killing a tough foe (that takes 5 fireballs to kill). view ROM address $02ACE5 on SMWC's ROM map for values. by default $04 = 1000 points

!EnemyBounceSpeed = -$30		;upward speed when defeated with 5 fireballs
!CoinBounceSpeed = -$30			;upward speed when the sprite turn into a coin

!FireballKillSprite = $21		;what sprite to turn into when killed with a single fireball (moving coin by default)

;when killed with 5 fireballs
!Sound_5FireballKill = $02
!Sound_5FireballKillAddr = $1DF9

;when killed with a fireball (turns into a coin)
!Sound_FireballKill = $03
!Sound_FireballKillAddr = $1DF9

Print "CAPE",pc
if !CapeInteraction
{
LDA #!CapeInteractionClipXOffset
STA $00					;x-clipping offset

LDA #!CapeInteractionClipYOffset
STA $02					;y-clipping offset

LDA #!CapeInteractionWidth
STA $01					;width

LDA #!CapeInteractionHeight		;since the tables end after height, the opcodes or addresses are now height (which means you can erase this sprite with cape from way below)
STA $03					;height

%ExtendedCapeClipping()
BCC CAPE_RETURN				;if didn't interact, return

LDA #$07				;puff of smoke timer
STA $176F|!addr,X

LDA #$01				;Change the sprite into a puff of smoke.
STA $170B|!addr,x

CAPE_RETURN:
}
endif
RTL

Print "MAIN ",pc
LDA $9D					;if frozen in act
BNE JustGFX				;there's nothing you can do, except of this

LDA #$01				;
%ExtendedSpeed()			;X speed and Y speed with no gravity

JSR FireballInteract			;interact with sprites

JustGFX:
%ExtendedGetDrawInfo()			;erase offscreen n' stuff

LDA $01					;x-pos
STA $0200|!Base2,y			;

LDA $02					;y-pos
STA $0201|!Base2,y			;

LDA $14					;change the graphic tile every some frames
LSR #3					;
LDA #!Tile1				;
BCC NoTileChange			;
LDA #!Tile2				;

NoTileChange:
STA $0202|!Base2,y			;tile

LDA $1747|!Base2,x			;Tile properties depend on it's X speed
AND #$80				;specifically, the x-flip
EOR #$80				;if facing left, does apply the x-flip
LSR					;/2 = 40, which is x-flip
ORA #$30|!YoshiFireProp			;high FG/BG priority
STA $0203|!Base2,y			;GFX property

TYA					;It's a 16x16 sprite
LSR #2					;
TAY					;
LDA #$02				;
STA $0420|!Base2,y			;size
RTL					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Fireball interaction
;
;Shared between this sprite and Mario's fireball
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FireballInteract:
TXA					;
EOR $13					;
AND #$03				;
;BNE Return				;only interact every 1/4 frames (also depends on the fireball's sprite slot)
BEQ .Continue				;(branch out of bounds, original would use a fireball GFX RTS just above since it's also a JSR routine)
RTS					;

.Continue
PHX					;
TXY					;
STY $185E|!Base2			;save fireball's sprite slot

LDX #!SprSize-3				;Loop through all sprite slots... that's a lie of course, not all needs to be interacted with

FireLoop:	
STX $15E9|!Base2			;save normal sprite's slot

LDA !14C8,x				;If the sprite we're gonna interact with
CMP #$08				;is not in normal condition
BCC NextSpr				;Ignore it

LDA !167A,x				;Check tweaker bits
AND #$02				;If sprite's invincible to fireballs
ORA !15D0,x				;Or if is on yoshi's tongue
ORA !1632,x				;Or if it is behind foreground layer (like net koopa)
EOR $1779|!Base2,y			;Unless the fireball itself is also behind FG
BNE NextSpr				;Ignore it

JSL $03B69F|!BankB			;Sprite's clipping
JSR GetFireHitbox			;Fireball's specific "get clipping" routine
JSL $03B72B|!BankB			;check intecation
BCC NextSpr				;If no contact, next sprite

;LDA $170B,y				;Check if it's a Yoshi's Fireball
;CMP #$11				;It is, in fact, a yoshi's fireball. So we don't need that.
;BEQ .Continue				;
;PHX					;
;TYX					;
;JSR Smoke				;This "kills" the fireball
;PLX					;Actually, just turns into smoke.

.Continue
LDA !166E,x				;If the sprite cannot be killed with fireballs
AND #$10				;
BNE NextSpr				;Ignore it

LDA !190F,x				;If the sprite doesn't takes 5 fireballs to kill
AND #$08				;
BEQ TurnIntoCoin			;Kill it right away

INC !1528,x				;"Decrease" Fire HP (chucks, maybe koopalings, i didn't check)

LDA !1528,x				;If not hit 5 times
CMP #$05				;
BCC NextSpr				;Next please

NoCoinKill:
LDA #!Sound_5FireballKill		;Sound effect
STA !Sound_5FireballKillAddr|!addr	;

LDA #$02				;Make the sprite fall offscreen
STA !14C8,x				;

LDA #!EnemyBounceSpeed			;Upward speed
STA !AA,x				;

%SubHorzPos()				;
LDA FireKillXSpeed,y			;X speed depending on the sprite's facing
STA !B6,x				;move away from Mario

if !SA1 == 1
  REP #$20				;fix score for SA-1
  TXA
  CLC : ADC #!sprite_y_low
  STA $CC
  TXA
  CLC : ADC #!sprite_x_low
  STA $EE
  SEP #$20
endif

LDA #!FireKillScore			;
JSL $02ACE5|!BankB			;Give score
;BRA NextSpr				;(original sprite has NextSpr after coin kill, but to solve SA-1's branch out of bounds issue, I moved it here)

NextSpr:
LDY $185E|!Base2			;restore fireball's sprite slot
DEX					;next sprite
BMI EndLoop				;processed all sprites, exit the loop
JMP FireLoop				;

EndLoop:
PLX					;
STX $15E9|!Base2			;Restore fireball's sprite slot

Return:
RTS					;

TurnIntoCoin:
LDA #!Sound_FireballKill		;Sound pleasy
STA !Sound_FireballKillAddr|!Base2	;

LDA #!FireballKillSprite		;Sprite turns into
STA !9E,x				;#$21 - Moving coin (by default anyway)

LDA #$08				;
STA !14C8,x				;it has a normal status
JSL $07F7D2|!BankB			;configuration properties

LDA #!CoinBounceSpeed			;Make it bounce up slightly
STA !AA,x				;

%SubHorzPos()				;face and move away from the player
TYA					;
EOR #$01				;
STA !157C,x				;
BRA NextSpr				;moved NextSpr

;does what it says on the tin, fireball's hitbox
GetFireHitbox:
LDA $171F|!Base2,y		;Get X position
SEC				;Calculate hitbox
SBC #$02			;
STA $00				;

LDA $1733|!Base2,y		;
SBC #$00			;Take care of high byte
STA $08				;

LDA #$0C			;width
STA $02				;

LDA $1715|!Base2,y		;Y pos
SEC				;
SBC #$04			;
STA $01				;

LDA $1729|!Base2,y		;
SBC #$00			;
STA $09				;

LDA #$13			;height
STA $03				;
RTS				;