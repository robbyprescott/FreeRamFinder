; No powerup or powerdown freeze

!no_powerup_animation = 1
!no_powerdown_animation = 1

main:
lda $0EC3 ; you can set this to trigger it on and off in a level if you want
beq returnPowerup
if !no_powerup_animation
    lda $71 : cmp #$02 : beq .mushroom
              cmp #$03 : beq .cape
              cmp #$04 : bne +
.fire:
    lda #$01 : sta $149B|!addr
    bra +
.mushroom:
    stz $1496|!addr
    bra +
.cape:
    lda #$01 : sta $1496|!addr
+
endif
if !no_powerdown_animation
    lda $71 : cmp #$01 : bne +
    stz $1496|!addr
+
endif
    returnPowerup:
    rtl
