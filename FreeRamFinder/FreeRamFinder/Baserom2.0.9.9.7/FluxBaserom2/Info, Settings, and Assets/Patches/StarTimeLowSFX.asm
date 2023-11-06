;; ========================================
;;  Star Time Low SFX
;;  By StackDino
;; ===================================

if read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!bank = $000000
	!sa1 = 1
else
	lorom
	!dp = $0000
	!addr = $0000
	!bank = $800000
	!sa1 = 0
endif

org $00E2E3|!bank
autoclean JSL StarTimeLowSFX

freecode
StarTimeLowSFX:
    LDA $0EC2 ; FreeRAM, when set
	BNE Return
	LDA $1490|!addr			;; Load star timer
	CMP #$1E			;; Compares if A contains $1E
	BNE +
	LDA #$24			;; Load "P-switch time low"
	STA $1DFC|!addr			;; Play SFX
+
	LDA $13
	CPY #$05			;; Time to restore level music ($1DFB)
	Return:
	RTL