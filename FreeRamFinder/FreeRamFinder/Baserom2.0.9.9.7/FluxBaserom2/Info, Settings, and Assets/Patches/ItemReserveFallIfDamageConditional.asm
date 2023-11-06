

org $00F5F8
autoclean JSL ItemFallIfDamage

freecode

ItemFallIfDamage:
LDA $0DF8
BNE Return
JSL $028008 ; INC $1534,x for slow-fall, but where?
Return:
RTL