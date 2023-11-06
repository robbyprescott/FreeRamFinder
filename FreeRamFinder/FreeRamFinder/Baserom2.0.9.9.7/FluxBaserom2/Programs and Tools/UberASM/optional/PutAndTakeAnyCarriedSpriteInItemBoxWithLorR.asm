; By SJandCharlieTheCat
; Works with two or three different patches, already applied

!SpriteItemBoxValue = $0D ; key, see Default Item Box Values in documentation for conversion values. 
!SpriteItemBoxStatus = $0DF5 ; match below
!SpriteNormalNumber = $80
!DropIfYouTakeDamage = 0 ; item falls down when you take damage as big Mario

; $0DF4 = 1 Initialise
; $0DF5 = 9 Carryable, flipped, stunned
; $0DF6 = A Kicked
; $0DF7 = B Carried

;     LDA #$01
;     STA $0DF9 ; disables select from activating vanilla item box drop

main:
if !DropIfYouTakeDamage
LDA #$01
STA $0DF8 ; FreeRAM
endif
LDA #$01
STA !SpriteItemBoxStatus
LDA $9D
ORA $13D4         ; Freeze checks
BNE SpriteIsAlreadyInBox

LDX #!sprite_slots-1 ; This is #$0C?
.loop
LDA !9E,x
CMP #!SpriteNormalNumber ; Check sprite
BNE .next
LDA !14C8,x
CMP #$0B ; Check if carrying
BNE .next

LDA $18 
AND #$20 ; #$20 is L, #$10 is R
BEQ SpriteIsAlreadyInBox 
LDA #!SpriteItemBoxValue ; Transfer/spawn this in item box
STA $0DC2 

BRA KillSprite ; Simultaneously remove from Mario's hands

.next
DEX
BPL .loop

KillSprite:
PHX					;Push the X register
LDX #$00			;innitiate the counter
loop2:
LDA $14C8,x
CMP #$0B ; kill (any) sprite that's carried
BNE notkill ; BCC?
LDA #$04			;\ Make the sprite dissapear in a puff of smoke
STA $14C8,x			;/
LDA #$38            ; 08 is normal spin jump sound
STA $1DFC           ; 1DF9 
LDA #$1F
STA $1540,x
notkill:
INX					;Move on to the next slot
CPX #$0C			;\If they haven't all been checked, go back to the beginning
BCC loop2			;/
PLX					;Pull the X register from the stack

SpriteIsAlreadyInBox:
LDA $0DC2         ; Check if item already in box
CMP #!SpriteItemBoxValue
BNE End
LDA $18 ; here begins transfer to item
AND #$10 ; #$20 is L, #$10 is R
BEQ End
STZ $0DC2 ; kill item in box
LDA #$10
STA $1DF9 ; magikoopa SFX
; Here begins simplified carry (Thomas)

LDX #!sprite_slots-1
  - LDA !14C8,x
    BEQ Found
    DEX
    BPL -
  End:
    RTL
    
  Found:
    LDA #!SpriteNormalNumber : STA !9E,x
    LDA #$0B        : STA !14C8,x
    JSL $07F7D2|!bank
    
    LDA $76 : EOR #$01 : TAY
    LDA $94 : CLC : ADC .xOffsL,y : STA !E4,x
    LDA $95 :       ADC .xOffsH,y : STA !14E0,x
    
    LDA #$0D
    LDY $73
    BNE +
    LDY $19
    BNE ++
  + LDA #$0F
 ++ CLC     : ADC $96  : STA !D8,x
    LDA $97 : ADC #$00 : STA !14D4,x
    RTL
    
  .xOffsL: db $F7,$09
  .xOffsH: db $00,$FF
   