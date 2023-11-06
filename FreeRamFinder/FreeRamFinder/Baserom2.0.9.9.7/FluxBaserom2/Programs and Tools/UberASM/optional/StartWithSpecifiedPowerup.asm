; By SJandCharlieTheCat

; Will make the player already have the specified power-up when starting a level,
; as well as every time after reset (after dying in the level)


!Powerup = !None    ;  See the options below

!Big = $01          ; Put the name of the desired powerup after !Powerup above
!Cape = $02
!Fire = $03
!None = $00

!StarPower = 1     ; You can also start with star power, on top of the other powerups
                   ; 1 for yes, 0 for no
!StarTimer = $FF

load:
LDA #!Powerup
STA $19

if !StarPower
LDA #!StarTimer         ; Star power timer. C4 is close to normal. 64 is very short. FF is infinite, I think
STA $1490        ; Actual star power
endif
RTL