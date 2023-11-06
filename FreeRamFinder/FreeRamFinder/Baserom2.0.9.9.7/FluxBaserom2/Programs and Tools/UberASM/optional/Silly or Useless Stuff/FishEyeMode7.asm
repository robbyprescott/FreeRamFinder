; If used, need to make compatible with retry

init:
REP #$20
LDA #$1B02 ; \ 16-bit write to one register. $211B
STA $4330 ; /
LDA #$1E02 ; \ Same for $211E.
STA $4340 ; /
LDA.w #HScl ; Address for HDMA table.
STA $4332 ; \ Same address for both $211B and $211E.
STA $4342 ; /
LDY.b #HScl/65536 ; 
STY $4334 ; \
STY $4344 ; /
SEP #$20
LDA #$18 ; Enable channels 3 and 4.
TSB $0D9F ; Actually it was STA $420C in my patch, but for SMW, use TSB $0D9F.
RTL

; Now this is going to be one huge table. 3 bytes for each scanline.
HScl:
db $71 : dw $01AA : db $01 : dw $01A5 ; 72
db $01 : dw $01A0 : db $01 : dw $019B 
db $01 : dw $0196 : db $01 : dw $0191
db $01 : dw $018C : db $01 : dw $0187
db $01 : dw $0182 : db $01 : dw $017D
db $01 : dw $0178 : db $01 : dw $0173
db $01 : dw $016E : db $01 : dw $0169
db $01 : dw $0164 : db $01 : dw $015F
db $01 : dw $015A : db $01 : dw $0155 ; 82
db $01 : dw $0150 : db $01 : dw $014B
db $01 : dw $0146 : db $01 : dw $0141
db $01 : dw $013C : db $01 : dw $0137
db $01 : dw $0132 : db $01 : dw $012D
db $01 : dw $0128 : db $01 : dw $0124
db $01 : dw $0120 : db $01 : dw $011C
db $01 : dw $0118 : db $01 : dw $0114
db $01 : dw $0110 : db $01 : dw $010C ; 92
db $01 : dw $0109 : db $01 : dw $0106
db $01 : dw $0103 : db $01 : dw $0100
db $01 : dw $00FD : db $01 : dw $00FA
db $01 : dw $00F7 : db $01 : dw $00F4
db $01 : dw $00F1 : db $01 : dw $00EE
db $01 : dw $00EB : db $01 : dw $00E8
db $01 : dw $00E6 : db $01 : dw $00E4
db $01 : dw $00E2 : db $01 : dw $00E1 ; A2
db $01 : dw $00E0 : db $01 : dw $00DF
db $01 : dw $00DE : db $01 : dw $00DD
db $01 : dw $00DC : db $01 : dw $00DB
db $01 : dw $00DA : db $01 : dw $00D9
db $01 : dw $00D8 : db $01 : dw $00D7
db $01 : dw $00D6 : db $01 : dw $00D5
db $01 : dw $00D4 : db $01 : dw $00D3
db $01 : dw $00D2 : db $01 : dw $00D1 ; B2
db $01 : dw $00D0 : db $01 : dw $00CF
db $01 : dw $00CE : db $01 : dw $00CD
db $01 : dw $00CC : db $01 : dw $00CB
db $01 : dw $00CA : db $01 : dw $00C9
db $01 : dw $00C8 : db $01 : dw $00C7
db $01 : dw $00C6 : db $01 : dw $00C5
db $01 : dw $00C4 : db $01 : dw $00C3
db $01 : dw $00C2 : db $01 : dw $00C1 ; C2
db $01 : dw $00C0 : db $01 : dw $00BF
db $01 : dw $00BE : db $01 : dw $00BD
db $01 : dw $00BC : db $01 : dw $00BB
db $01 : dw $00BA : db $01 : dw $00B9
db $01 : dw $00B8 : db $01 : dw $00B7
db $01 : dw $00B6 : db $01 : dw $00B5
db $01 : dw $00B4 : db $01 : dw $00B3
db $01 : dw $00B2 : db $01 : dw $00B1 ; D2
db $01 : dw $00B0 : db $01 : dw $00AF
db $01 : dw $00AE : db $01 : dw $00AD
db $01 : dw $00AC : db $01 : dw $00AB
db $01 : dw $00AA : db $01 : dw $00A9
db $01 : dw $00A8 : db $01 : dw $00A7
db $01 : dw $00A6 : db $01 : dw $00A5
db $01 : dw $00A4 : db $01 : dw $00A3 ; E0
db $00