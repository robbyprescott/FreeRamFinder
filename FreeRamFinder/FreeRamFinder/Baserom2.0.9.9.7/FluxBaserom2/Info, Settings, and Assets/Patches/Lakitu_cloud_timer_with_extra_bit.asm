;==================================================
; Lakitu Cloud Time Limit
; By Erik
;
; This patch will give the original lakitu cloud
; a time limit, similar to when you kill a normal
; lakitu, when the extra bit is set to 1.
; Requires PIXI to be run once to work.
;==================================================

!time   = $40           ;   Original: $FF

;---

;   Co-processor checks
if read1($00FFD5) == $23
        sa1rom
        !addr   = $6000
        !bank   = $000000
        !7FAB10 = $6040
else
        lorom
        !addr   = $0000
        !bank   = $800000
        !7FAB10 = $7FAB10
endif

assert read4($02FFE2) == $44535453,     "Please use PIXI before inserting this patch."

;---

org $01E839                             ;   set the time limit
        autoclean JSL set_time_limit
org $01E7D0                             ;   don't make a lakitu appear again
        autoclean JML check_respawn

;---

freedata
set_time_limit:
        LDA $7B
        STA $B6,x       ;   same as SA-1, nice
        LDA !7FAB10,x
        AND #$04
        BEQ +
        LDA $18E0|!addr
        BNE +
        LDA.b #!time
        STA $18E0|!addr
+       RTL

;-

check_respawn:
        LDA !7FAB10,x
        AND #$04
        BNE .no_respawn
        LDA #$FF
        STA $18C0|!addr
        JML $01E7D5|!bank

.no_respawn
        JML $01E7DA|!bank

