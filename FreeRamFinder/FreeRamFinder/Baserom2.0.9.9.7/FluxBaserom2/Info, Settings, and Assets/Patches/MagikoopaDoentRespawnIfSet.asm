; When RAM flag set, this patch will make Magikoopa not reappear after he's been killed by Mario

!freeram = $0E01

if read1($00FFD5) == $23
    sa1rom
    !addr = $6000
    !14C8 = $3242
else
    lorom
    !addr = $0000
    !14C8 = $14C8
endif

org $01AC89
    autoclean jsl magikoopa

freedata

magikoopa:
    lda !freeram
	beq .respawn
    lda !14C8,x : cmp #$08 : beq .respawn
.erase:
    stz $18C1|!addr
    rtl
.respawn:
    lda #$FF : sta $18C0|!addr
    rtl