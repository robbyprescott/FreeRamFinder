;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Slippery / Non-Slippery Blocks by dtothefourth
;
; This UberASM allows blocks or other code to temporarily change the
; level of slipperiness in the level and it will automatically revert
; back to whatever the level initially was set to
;
; The slippery setting can be overridden to on, half, or off and a
; block which does each is included.
;
; If you want to create sprites or other things that change the
; slippery level temporarily you can use the !Slippery free RAM as
; follows:
;
;	Slippery Byte in Binary ??ZZHHFF
;		Two bits for each of the slippery levels which allow up to a
;		four frame timer for each setting
;
;		ZZ - Zero slippery, if these bits are set slippery will be off
;
;		HH - Half slippery
;
;		FF - Full slippery
;
;		?? - Currently unused
;
;	So for example a sprite could just do something like
;		LDA #$0C
;		STA !Slippery
;	To keep it locked to half slippery
;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Slippery = $7E0ED3 ; FreeRAM, originally $7FB500 
!BackupSlippery = $7E0ED4 ; FreeRAM, originally $7FB501

init:
	LDA $86
	STA !BackupSlippery
	LDA #$00
	STA !Slippery
	RTL

main:
	LDA $9D
	ORA $13D4|!addr
	BNE +

	LDA !Slippery
	BEQ +

	BIT #$03
	BEQ ++
	
	DEC
	STA !Slippery
	BEQ Reset
	LDA #$80
	STA $86
	RTL
	++
	BIT #$0C
	BEQ ++
	
	SEC
	SBC #$04
	STA !Slippery
	BEQ Reset
	LDA #$40
	STA $86
	RTL
	++
	SEC
	SBC #$10
	STA !Slippery
	BEQ Reset
	LDA #$00
	STA $86
	RTL
Reset:
	LDA !BackupSlippery
	STA $86
	+
	RTL

