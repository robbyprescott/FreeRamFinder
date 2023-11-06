;This fixes the glitch where if there's a Boo Ceiling in the level, any sprite in slot 0 will be warped around the screen as if it were one of the ghosts.

org $02FBFF
    bra $00

org $02FC0B
    bra $01
    nop