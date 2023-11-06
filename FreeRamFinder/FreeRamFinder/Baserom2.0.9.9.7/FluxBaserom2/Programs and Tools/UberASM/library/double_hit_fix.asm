; How many frames of cooldown to have ($00-$7F)
!cooldown = $08

!switch = $14AF

; 1 byte of freeramDoubleHit
!freeramDoubleHit = $0ED5|!addr

init:
    lda !switch : lsr : ror : sta !freeramDoubleHit ; Initialize the switch state backup
    rtl

main:
    lda $9D : ora $13D4|!addr : bne .returnDoubleHit
    lda !freeramDoubleHit : bit #$7F : beq .check_switched ; If we're in not in cooldown, check if the state changed
.cooldown:
    dec : sta !freeramDoubleHit ; ; Tick the timer
    asl : lda #$00 : rol : sta !switch ; Keep the state constant
    rtl
.check_switched:
    and #$80 : asl : rol ; If the state is the same as the backup, returnDoubleHit
    cmp !switch : beq .returnDoubleHit
.init_cooldown:
    eor #$01 : lsr : ror ; Set the new state and the cooldown timer
    ora.b #!cooldown
    sta !freeramDoubleHit
.returnDoubleHit:
    rtl
