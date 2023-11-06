;this is a simple block that breaks upon yoshi's stomp/"Ground Pound, Yoshi's Stomp Effect"
;By RussianMan, requested by Zuluna

incsrc YoshiGroundPound_Defines.cfg

!SoftBreak = 0				;set to 1 to make this block "soft" when ground-pounding, which means it'll act like air and won't count player as grounded (won't cancel Player's custom ground pound, won't make constant stomp if on yoshi)

db $42
JMP RETURN : JMP MarioAbove : JMP RETURN
JMP RETURN : JMP RETURN : JMP RETURN : JMP RETURN
JMP TopCorners : JMP RETURN : JMP RETURN

TopCorners:
MarioAbove:
if !MarioGroundPoundFlag

  LDA $18E7|!addr			;yoshi yellow power check
  BEQ .CheckPound			;check if we're actually riding a yoshi (so the player can't leave yoshi behind and still activate blocks)

  LDA $187A|!addr
  BNE .Destroy				;allow destruction

.CheckPound
  LDA !MarioGroundPoundFlag		;not yoshi, maybe custom ground pound? 
  BEQ RETURN				;if not, return

else

  LDA $18E7|!addr
  BEQ RETURN

  LDA $187A|!addr
  BEQ RETURN

endif

.Destroy
%shatter_block()

if !SoftBreak
  LDY #$00
  LDA #$25
  STA $1693|!addr			;act like tile 25
endif

RETURN:
RTL

print "This block can be destroyed from above by Yoshi's ground pound."
