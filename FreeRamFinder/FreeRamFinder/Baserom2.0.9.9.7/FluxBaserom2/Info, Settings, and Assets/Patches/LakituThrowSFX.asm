!sfx     = $23 ; 26 for a more subtle
!sfxport = $1DF9


; Hijack
org $01EA27
autoclean JSL LakituSfx
NOP

freecode

LakituSfx:
    LDA #!sfx       ;\ Play the sfx
    STA !sfxport    ;/
    LDA #$08        ;\ Restore original code
    STA $14C8,y     ;/
    RTL