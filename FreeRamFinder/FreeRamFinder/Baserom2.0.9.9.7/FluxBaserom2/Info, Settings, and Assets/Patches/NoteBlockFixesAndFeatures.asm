; By KevinM, hybridized and made conditional by SJC

!FreeRAM = $0E20
!FreeRAM2 = $0E21
!NormalYSpeed   = $A0   ; Y speed when normal jumping off the note block (vanilla = $A0)
!SpinYSpeed     = $B0   ; Y speed when spinning off the note block.

if read1($00FFD5) == $23
    sa1rom
    !sa1 = 1
    !dp = $3000
    !addr = $6000
    !bank = $000000
else
    lorom
    !sa1 = 0
    !dp = $0000
    !addr = $0000
    !bank = $800000
endif

org $02916C : autoclean jml Main

freedata

Main:
    lda !FreeRAM
	beq default
    lda #!NormalYSpeed
    bit $17
    bpl +
    lda #$01
    sta $140D|!addr
    lda #!SpinYSpeed
+   sta $7D
    bra end
default:
    lda #!NormalYSpeed	
	sta $7D
	lda !FreeRAM2
	beq end
    stz $140D
	end:
    jml $029170|!bank
