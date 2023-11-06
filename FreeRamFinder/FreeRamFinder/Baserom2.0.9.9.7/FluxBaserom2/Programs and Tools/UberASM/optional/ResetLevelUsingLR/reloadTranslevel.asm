; This code will reload the current translevel (aka the starting room of the level).

main:
    STZ $0D
    LDA $13BF|!addr
    CMP #$25
    BCC +
    SEC
    SBC #$24
    INC $0D
  +
    STA $0C
    JSL LRReset
    RTL
