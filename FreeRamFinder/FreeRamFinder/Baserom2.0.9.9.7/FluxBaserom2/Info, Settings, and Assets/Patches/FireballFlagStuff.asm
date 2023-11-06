;Fireball throw flag patch. By RussianMan, with mods by SJandCharlieTheCat
; Make sure compatible with...

;!addr is needed for SA-1 only if RAM address is in range of $0100-$1FFF (if $00-$FF, don't need !addr)
;can be freeram, but you can set it to anything
;for example if you set this to $75 (player in water flag), you can disable fireball throwing when underwater
!Flag = $0DED ;
!Flag2 = $0DEE ; 

if read1($00FFD5) == $23		; check if the rom is sa-1
	sa1rom
	!addr = $6000
	!bank = $000000
else
	!addr = $0000
	!bank = $800000
endif

org $00D08C
autoclean JML FireOrNot

freecode 

FireOrNot:
LDA !Flag				;defined flag
BNE .NoFire				;if set, can't shoot a fireball at all


LDA $18     ; L/R check
AND #$30 
BEQ .NormalFire ; If no press, go to normal X/Y check
LDA !Flag2  ; if  L/R no flag set,  go to no fire
BNE .NoFire
BRA .Fire       ; (If press, fire)
.NormalFire
BIT $16					;restored code (on X/Y press, spawn a fireball)
BVC .MaybeNoFire ; if LRAdd, won't MaybeNoFire

.Fire
JML $00D0AA|!bank			;spawn a fireball

.NoFire
JML $00D0AD|!bank			;don't spawn a fireball

.MaybeNoFire
JML $00D090|!bank			;maybe spawn a fireball via spinjumping
