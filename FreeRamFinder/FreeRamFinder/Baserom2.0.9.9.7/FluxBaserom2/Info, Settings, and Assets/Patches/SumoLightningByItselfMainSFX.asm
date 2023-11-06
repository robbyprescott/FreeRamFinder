!sfx     = $28 ; 26 softer? 23 for sillier drop sound
!sfxport = $1DF9


; Hijack
org $02DEB5
autoclean JSL SumoLightningSfx


freecode

SumoLightningSfx:
    LDA #!sfx       ;\ Play the sfx
    STA !sfxport    ;/
    LDA #$30        ;\ Restore original code
    STA $AA,x     ;/
    RTL
	
;	CODE_02DEB5:        A9 30         LDA.B #$30                
;CODE_02DEB7:        95 AA         STA RAM_SpriteSpeedY,X  