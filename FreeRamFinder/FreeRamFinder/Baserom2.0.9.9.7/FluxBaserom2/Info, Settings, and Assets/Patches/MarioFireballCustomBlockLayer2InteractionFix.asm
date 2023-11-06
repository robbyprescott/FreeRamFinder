; Fix MarioFireball bug where custom blocks don't run if they're on layer 2
org $06F7A3
    xba
    ; If running layer 2 interaction, the stack is shifted by 4 bytes
    ; (-2 because it returned from an RTS after "LDA $08,s")
    lda $0F : beq +
    lda $0A,s : xba
+   xba
    ; Original code
    cmp #$DA : beq +
    jmp $F602

warnpc $06F7C0

org $06F7C0
    +