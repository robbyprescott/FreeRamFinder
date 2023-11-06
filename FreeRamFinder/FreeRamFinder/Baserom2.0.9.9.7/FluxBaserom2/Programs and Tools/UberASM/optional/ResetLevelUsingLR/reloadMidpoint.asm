; This code will reload the current translevel, spawning at the midpoint if obtained.
;  NOTE: for spawning at the midpoint to work, the level must have
;        "use seperate settings for midway entrance" checked.

main:
    LDY #$00
    LDA $13CE|!addr
    BNE ++
    LDX $13BF|!addr
    BIT $1EA2|!addr,x
    BVC +
 ++ LDY #$0C
  +
    LDA $13BF|!addr
    CMP #$25
    BCC +
    SEC
    SBC #$24
    INY
  +
    STY $0D
    STA $0C
    JSL LRReset
    RTL
