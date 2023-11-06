; https://www.smwcentral.net/?p=section&a=details&id=25646&r=0#comment-50271

if read1($00FFD5) == $23
	sa1rom
	!addr = $6000
else
	lorom
	!addr = $0000
endif

!freeRAM = $1473|!addr

org $019D39
	LDA #$00
	autoclean JSL get_gfx
	
org $019D8F
	LDA #$00
	JSL get_gfx
	
org $019F24
	LDA #$00
	JSL get_gfx
	
org $019D95
	LDA #$03
	JSL get_gfx
	
org $019DF3
	LDA #$01
	JSL get_gfx
	
org $019DF9
	LDA #$02
	JSL get_gfx

freecode
get_gfx:
	PHP
	STA $09
	STZ $0A
	REP #$30
	PHX
	LDA !freeRAM
	AND #$00FF
	STA $06
	ASL
	CLC
	ADC $06
	TAX
	LDA.l pointer_table,X
	STA $06
	LDA #$0001
	AND $09
	BEQ +
		INC $06
	+
	SEP #$20
	LDA.l pointer_table+2,X
	STA $08
	PLX
	PLP
	PHY
	TXY
	LDA [$06],Y
	PLY
	PHA
	LDA #$02
	AND $09
	BEQ +
		PLA
		STA.w $0306|!addr,Y
		RTL
	+
	PLA
	STA.w $0302|!addr,Y
	RTL

pointer_table:
	dl $019B83
	dl tilemap				;Add more pointers here as needed, just make sure each has a unique name
		
tilemap:                                    ;Be sure to copy this table if you need another pointer
    db $82,$A0,$82,$A2,$84,$A4              ;$019B83 - Koopa (2-byte)
    db $8C,$8A,$8E                          ;$019B86 - Shell (1-byte, but indexed from above)
    db $C8,$CA,$CA,$CE,$CC,$86,$4E          ;$019B8C - Shell-less Koopa (fourth byte unused)
    db $E0,$E2,$E2,$CE,$E4,$E0,$E0          ;$019B93 - Shell-less blue Koopa (fourth byte unused)
    db $A3,$A3,$B3,$B3,$E9,$E8,$F9,$F8      ;$019B9A - Para-goomba
    db $E8,$E9,$F8,$F9,$E2,$E6
    db $AA,$A8,$A8,$AA                      ;$019BA8 - Goomba
    db $A2,$A2,$B2,$B2,$C3,$C2,$D3,$D2      ;$019BAC - Para-bomb
    db $C2,$C3,$D2,$D3,$E2,$E6
    db $CA,$CC,$CA                          ;$019BBA - Bob-omb
    db $AC,$CE,$AE,$CE,$83,$83,$C4,$C4      ;$019BBD - Classic / Jumping Piranha Plant
    db $83,$83,$C5,$C5
    db $8A                                  ;$019BC9 - Football
    db $A6,$A4,$A6,$A8                      ;$019BCA - Bullet Bill
    db $80,$82,$80                          ;$019BCE - Spiny
    db $84,$84,$84,$84,$94,$94,$94,$94      ;$019BD1 - Spiny egg (4-byte)
    db $A0,$B0,$A0,$D0                      ;$019BD9 - ???
    db $82,$80,$82                          ;$019BDD - Buzzy Beetle
    db $00,$00,$00                          ;$019BE0 - ???
    db $86,$84,$88                          ;$019BE3 - Buzzy Beetle shell
    db $EC,$8C,$A8,$AA,$8E,$AC              ;$019BE6 - Spike Top
    db $AE,$8E                              ;$019BEC - Hopping Flame
    db $EC,$EE,$CE,$EE,$A8,$EE              ;$019BEE - Lakitu
    db $40,$40                              ;$019BF4 - Moving Ledge Hole?
    db $A0,$C0,$A0,$C0,$A4,$C4,$A4,$C4      ;$019BF6 - Magikoopa
    db $A0,$C0,$A0,$C0
    db $40                                  ;$019C02 - Throwblock / exploding turnblock
    db $07,$27,$4C,$29,$4E,$2B,$82,$A0      ;$019C03 - Climbing Koopa
    db $84,$A4
    db $67,$69,$88,$CE                      ;$019C0D - Fish
    db $8E,$AE                              ;$019C11 - ???
    db $A2,$A2,$B2,$B2                      ;$019C13 - Thwimp (4-byte)
    db $00,$40,$44,$42,$2C,$42              ;$019C17 - ???
    db $28,$28,$28,$28,$4C,$4C,$4C,$4C      ;$019C1D - Springboard (4-byte)
    db $83,$83,$6F,$6F
    db $AC,$BC,$AC,$A6                      ;$019C29 - ???
    db $8C,$AA.$86,$84                      ;$019C2D - Bony Beetle
    db $DC,$EC,$DE,$EE                      ;$019C31 - ???
    db $06,$06,$16,$16,$07,$07,$17,$17      ;$019C35 - Podoboo (4-byte)
    db $16,$16,$06,$06,$17,$17,$07,$07
    db $84,$86                              ;$019C45 - [Unused]
    db $00,$00,$00,$0E,$2A,$24,$02,$06      ;$019C47 - Yoshi
    db $0A,$20,$22,$28,$26,$2E,$40,$42
    db $0C
    db $04,$2B                              ;$019C58 - [Unused]
    db $6A,$ED                              ;$019C5A - Eerie
    db $88,$8C,$A8,$8E,$AA,$AE,$8C,$88      ;$019C5C - Boo
    db $A8
    db $AE,$AC,$8C,$8E                      ;$019C65 - Rip Van Fish
    db $CE,$EE                              ;$019C69 - Vertical Dolphin
    db $C4,$C6                              ;$019C6B - Diggin' Chuck's Rock
    db $82,$84,$86                          ;$019C6D - Monty Mole
    db $8C                                  ;$019C70 - Ledge-dwelling Monty Mole's Dirt, ? Sphere
    db $CE,$CE,$88,$89,$CE,$CE,$89,$88      ;$019C71 - Ground-dwelling Monty Mole's Dirt (4-byte)
    db $F3,$CE,$F3,$CE                      ;$019C79 - Sumo Bros. Lightning
    db $A7,$A9                              ;$019C7D - Ninji