; by mathos, big modifications by SJC

; I removed the GFX routine entirely, so that you can just drag
; the sprite on top of (block) door GFX, set to act as air. 

; As it currently is, the destination is set by the first and second byte.
; The first is the high byte, and second is lo.
; So to go to level 107 (0107), it'd be 01 07. Level 1A would be 00 1A.
; (If you set the extra bit, it'll use the screen exit instead.)




; You can also change settings by adding values to the first byte here. 

; Extra bytes: 

; First: ------HH 
; Second: SSSSw-sL
; Third: --Pcpppg 


;Hh = high byte, always either 00 or 01


; L = level or secondary exit number, lo byte.
; s = use secondary entrance.
; w = if using a secondary entrance, make destination a water level.
;     else, go to midway entrance.
; S = secondary entrance number's highest bits.


; g = has gravity.
; ppp = Palette.
; c = Is closed/unusable.
; P = can only be entered when a blue p-switch is active.
;     (this ignores the c flag)
; Dd = Decoration (D = medium star on top, d = small stars on sides).


!sfxEnterNum  = $0f         ; sfx when using the door
!sfxEnterBank = $1dfc|!addr ;
!sfxWrongNum  = $2a         ; sfx when trying to use a closed door
!sfxWrongBank = $1dfc|!addr ;

tilemap:
  .tiles:
    db $4E,$4E  ; db $64,$44 bottom and top tiles, regular door, when open
    db $4E,$4E  ; db $66,$46 bottom and top tiles, regular door, when closed
    db $4E,$4E  ;db $60,$40 bottom and top tiles, p-switch door, when open
    db $4E,$4E  ;db $62,$42 bottom and top tiles, p-switch door, when closed
  .gProp:
    db $01      ; general door tiles properties (only use --pp---t)

;================================
; WRAPPERS
;================================

print "INIT ",pc
    rtl

print "MAIN ",pc
    phb
    phk
    plb
    jsr main
    plb
    rtl
    
;================================
; MAIN
;================================

main:
    lda $9d             ; if sprites locked, return
    bne .end            ;
    lda !14C8,x         ; if abnormal status, return
    cmp #$08            ;
    bne .end            ;
    lda #$00            ; check if sprite is offscreen
    %SubOffScreen()     ;
    lda !extra_byte_3,x ; if g flag is set,
    and #$01            ; update position w/ gravity
    beq +               ;
    jsl $01802a|!bank   ;
    +                   ;
    lda $13ef|!addr     ; if mehyo is in the air, return
    beq .end            ;
    lda $16             ; if not pressing up, return
    and #$08            ;
    beq .end            ;
    jsl $01a7dc|!bank   ; if no contact with mehyo, return
    bcc .end            ;
    lda !extra_byte_3,x ; if the P flag is set,
    and #$20            ;
    beq +               ;
    lda $14ad|!addr     ; and a blue p-switch is active,
    bne .exitOK         ; use door
    bra .exitNO         ;
    +                   ;
    lda !extra_byte_3,x ; if c flag is set, can't use door
    and #$10            ;
    beq .exitOK         ;
    .exitNO:            ; play "wrong" sfx and return
    lda #!sfxWrongNum   ;
    sta !sfxWrongBank   ;
    bra .end            ;
    .exitOK             ;
    jsr processExit
    .end:
    ;jsr gfx
    rts
    
processExit:
    lda #!sfxEnterNum   ; play "enter" sfx
    sta !sfxEnterBank   ;
    lda !extra_bits,x   ; if extra bit clear,
    and #$04            ; use custom destination
    bne +               ; 
	phx                 ; \
    phb                 ; | wut
    phk                 ; |
    plb                 ; |
    jsl $03bcdc|!bank   ; |
    plb                 ; |
    txy                 ; |
    plx                 ; /
	lda !extra_byte_1,x ;
    ora #$04            ;
    sta $19d8|!addr,y 
    lda !extra_byte_2,x ;
    sta $19b8|!addr,y   ;
	+                   ; if set, use screen exit
	lda #$06            ; 
	sta $71             ;
	stz $88             ;
	stz $89             ;
    rts

;================================
; GFX
;================================

