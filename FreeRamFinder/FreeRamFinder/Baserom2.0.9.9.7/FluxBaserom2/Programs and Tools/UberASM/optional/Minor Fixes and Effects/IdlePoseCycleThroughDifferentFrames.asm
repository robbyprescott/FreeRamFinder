; 3 bytes
!freeram = $7FBFFD

; Frames of the idle pose
; You can have how many you want (max 64 per row), but keep the same number in all rows
idle_frames:
.small:
    db $00,$01,$02,$03,$04 ; See here for values + pose GFX: https://imgur.com/JW4rkEE
.big:
    db $10,$11,$12,$13,$14
.small_yoshi:
    db $20,$21,$22,$23,$24
.big_yoshi:
    db $30,$31,$32,$33,$34
; When caped, it will use the big / big_yoshi frames for Mario,
; and these frames for the cape. Just keep all $00 to make it stay still
.cape:
    db $00,$01,$02,$03,$04

; How many frames before idle
; You can use 60*X with X = how many seconds
!idle_time = 60*4

; How fast the idle frames are (0-7)
; Higher = slower (the idle frames will change every 2^!idle_frequency frames)
!idle_frequency = 3

; Don't edit
!idle_timer #= !freeram+0
!curr_pose  #= !freeram+2

!tot_frames = (idle_frames_big-idle_frames_small)

init:
    lda #$00
    sta !idle_timer
    sta !idle_timer+1
    sta !curr_pose
    rtl

main:
    lda $13D4|!addr : ora $1426|!addr : ora $9D : bne .return
    lda $1490|!addr : ora $1493|!addr : ora $71 : ora $74 : ora $7B
    ora $15 : ora $16 : ora $17 : ora $18 : bne init
    rep #$20
    lda !idle_timer : cmp.w #!idle_time : bcs .idle
    inc : sta !idle_timer
    sep #$20
    rtl
.idle:
    sep #$20
    lda !curr_pose
    ldx $19 : beq +
    clc : adc.b #!tot_frames
+   ldx $187A|!addr : beq +
    clc : adc.b #2*!tot_frames
+   tax
    lda.l idle_frames,x : sta $13E0|!addr
    lda $19 : cmp #$02 : bne +
    lda !curr_pose : tax
    lda.l idle_frames_cape,x : sta $13DF|!addr
+   lda $14 : and.b #(1<<(!idle_frequency))-1 : bne .return
    lda !curr_pose : inc
    cmp.b #!tot_frames : bcc +
    lda #$00
+   sta !curr_pose
.return:
    rtl