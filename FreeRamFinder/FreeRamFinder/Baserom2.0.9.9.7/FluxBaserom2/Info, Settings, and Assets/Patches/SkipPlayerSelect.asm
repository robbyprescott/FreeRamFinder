; Don't apply if you're going to use replaces player select with retry / no-retry select

org $009D25
    db $00 ; vanilla $12

org $009DFA
    ldx #$00 ; vanilla $A5,$16,$05,$18
    bra +

org $009E0D ; CODE_009E0D:        8E B2 0D      STX.W $0DB2  
    +