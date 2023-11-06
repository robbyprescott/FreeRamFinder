; This goes to the hub, 
; or to the level number below or above the current level,
; upon specific button holds + presses

!HubNumber = $013B

main:
LDA $17				;check if controller button is held
AND #$20			;L button
CMP #$20
BNE OtherSelect
LDA $16				;check if controller button is newly pressed.
AND #$20			; 20 Select button
CMP #$20
BNE OtherSelect			;
REP #$20                ; \
LDA #!HubNumber                ; | Teleport the player to hub
JSL TeleportYee

OtherSelect:
LDA $17				;check if controller button is held
AND #$10			;R button
CMP #$10
BNE LowerOrHigherLevel
LDA $16				;check if controller button is newly pressed.
AND #$20			; 20 Select button
CMP #$20
BNE LowerOrHigherLevel			;
REP #$20                ; \
LDA #!HubNumber                ; | Teleport the player to hub
JSL TeleportYee
;SEP #$20

LowerOrHigherLevel:
LDA $17				;check if controller button is held
AND #$10			;R button
CMP #$10
BNE PressRight			;

LDA $18				;check if controller button is newly pressed..
AND #$20			;L button
CMP #$20
BNE PressRight			;

REP #$20
LDA $010B
CMP #$013A
BEQ NoUnderflow
SEP #$20
;LDA #$2A
;STA $1DFC

REP #$20
LDA $010B
DEC
JSL TeleportYee
NoUnderflow:
SEP #$20
RTL

PressRight:
LDA $17				;check if controller button is held
AND #$20			;L button
CMP #$20
BNE Return			;

LDA $18				;check if controller button is newly pressed..
AND #$10			;R button
CMP #$10
BNE Return			;

REP #$20
LDA $010B
CMP #$013C
BEQ NoOverflow
SEP #$20
;LDA #$2A
;STA $1DFC

REP #$20
LDA $010B
INC
JSL TeleportYee
NoOverflow:
SEP #$20
Return:
RTL ;

TeleportYee:
	PHX
	PHY

	PHA
	STZ $88

	SEP #$30

	JSL $03BCDC ; |!bank
	PLA
	STA $19B8|!addr,x
	PLA
	ORA #$04
	STA $19D8|!addr,x

	LDA #$06
	STA $71

	PLY
	PLX
	RTL