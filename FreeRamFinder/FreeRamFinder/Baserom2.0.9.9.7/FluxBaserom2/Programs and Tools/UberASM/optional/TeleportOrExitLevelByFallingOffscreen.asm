; By Kevin, modified by SJC

!Teleport = 1 ; Set to 1 to teleport to level set in screen exit. 
              ; If not, will use the selected exit option below

; What kind of exit to trigger, if !Teleport = 0
; - $00 : Return to OW, no event
; - $01 : Normal exit
; - $02 : Secret exit 1
; - $03 : Secret exit 2
; - $04 : Secret exit 3
; - $80 : No event, but it'll switch players in 2P mode
!ExitType = $00

main:
    lda $9D             ;\
    ora $13D4|!addr     ;| If game frozen, skip (including death animation).
    bne .return         ;/
    rep #$20            ;\
    lda $80             ;| If Y position on screen is < $00F6, skip.
    cmp #$00F6          ;| (original routine triggers death/Yoshi wings level exit when Y >= $0100,
    sep #$20            ;| so have some pixels of leniency to avoid triggering it).
    bmi .return         ;/
	if !Teleport
	LDA #$06 ; teleport to screen exit
    STA $71
    STZ $88
    STZ $89
	bra .return
	endif
    lda.b #!ExitType    ;\ Set exit type.
    sta $0DD5|!addr     ;/
    lda #$01            ;\
    sta $1DE9|!addr     ;| Set flag to activate an event on OW.
    sta $13CE|!addr     ;/
    lda #$0B            ;\ Change to "Load OW" GM.
    sta $0100|!addr     ;/
.return
    rtl
