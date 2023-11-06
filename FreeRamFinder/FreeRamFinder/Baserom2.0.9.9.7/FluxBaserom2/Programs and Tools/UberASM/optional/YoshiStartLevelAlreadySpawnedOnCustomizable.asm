;; UberASM which allows you to start a level already riding 
;; various types of Yoshis, with different abilities and colors

;; by Abdu, and modified by SJandCharlieTheCat
; Yoshi color select only works for yoshi you spawn on, I think


 
!FlyingYoshi = 0      ; set to 1 to start on a Yoshi already with wings, without needing to eat a shell
!StompingYoshi = 0    ; set to 1 to start on a Yoshi with stomp ability, without needing to eat a shell
                      
                      ; Note that if you choose either of these and then eat a shell, 
                      ; the original ability will be lost or change until you don't have the shell

!YoshiColor = !Green  ; Write the color name of the Yoshi you want to start with here, from the options below. 
                      ; If !Blue or !Yellow, etc., will gain respective abilities upon eating ANY color shell              

!Yellow     = $04
!Blue       = $06
!Red        = $08
!Green      = $0A


!MarioPowerUp = $00   ; You can also set which powerup Mario spawns on Yoshi with.
                      ; 00 is small Mario, 01 is big Mario, 02 cape, 03 fire

!MidwaySpawnYoshi = 0 ; if set will spawn yoshi when the midway is grabbed, otherwise will not spawn yoshi.

; Code:

init:
    if !MidwaySpawnYoshi == 0
        LDA $13CE|!addr
        BNE .return
    endif
    
    LDA #!YoshiColor
    STA $13C7|!addr   ; Yoshi color

    JSL $00FC7A|!bank   ; force player on Yoshi

    LDA #!MarioPowerUp
    STA $19
    
.return:
RTL

main:
if !FlyingYoshi
    LDA #$02
    STA $141E|!addr   ; give wings GFX, but not actual flight?
    STA $1410|!addr
endif

if !StompingYoshi
    LDA #$01
    STA $18E7|!addr
    STZ $141E
    STZ $1410
endif
RTL
