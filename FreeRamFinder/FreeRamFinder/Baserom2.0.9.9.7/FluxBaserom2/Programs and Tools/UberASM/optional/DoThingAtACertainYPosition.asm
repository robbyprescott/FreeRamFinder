!RAM = $85 ; Set this address. Current example is water level flag (this is janky if !AboveOrBelow reversed, though).
!AboveOrBelow = 0	; 1 -  Only do the thing when above the position, 0 -  when below
!Height = 20	    ;height from the very top of the level at which the player is Thinged (in 16x16 blocks). 
                    ;A horizontal level is 27 blocks tall. So put 20 if you want the 7 blocks high.
!PixelAdd = 0		;if you want to add a few pixels on top of 16x16 tiles (e.g. 4 tiles and 8 pixels), edit this define



main:
LDA $9D					;load sprites/animation locked flag
ORA $13D4|!addr				;OR with game paused flag
BNE .Re

LDA $71					;already dead, return (dunno if I need this actually)
CMP #$09
BEQ .Re

REP #$20
LDA $96					;check player's y-position
CMP.w #!Height*16+!PixelAdd
SEP #$20
if not(!AboveOrBelow)
  ;BEQ .Thing
  ;BCC .NoThing
  BMI .NoThing
else
  BPL .NoThing
  ;BCS .NoThing
endif

.Thing
LDA #$01
STA !RAM
BRA .Re

.NoThing
STZ !RAM
.Re
RTL