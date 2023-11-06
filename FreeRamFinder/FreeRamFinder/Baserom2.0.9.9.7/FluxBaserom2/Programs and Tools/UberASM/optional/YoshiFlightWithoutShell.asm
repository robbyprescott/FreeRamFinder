; ===Flying Yoshi===
; Gives yoshi the ability to fly without a shell for the level it is inserted in.
; Basically it's like going to C8 or 1C8 in the original game.
; HuFlungDu
; No credit neccesary
; Feel free to PM me if you have any problems

main:
LDA $0EBE ; when set, won't fly. Can set on level load and then trigger with STZ in block
BNE .returnYoshiFly
LDA #$02			;\Give yoshi wings
STA $1410|!addr		;/
LDA $187A|!addr		;\Check if riding yoshi
BEQ .returnYoshiFly			;/
LDA $77             ;\
AND #$04			;|Doesn't work if not in air
BNE .returnYoshiFly			;/
LDA #$80			;\
CMP $7D			    ;|
BCC .sweetboy		;|Check if your going down
LDA #$24			;|
CMP $7D			    ;|
BCS .sweetboy		;/
LDA #$24			;\ if so, lower speed
STA $7D			    ;/
.sweetboy:
LDA $16				;\
AND #$80			;|check if B is pressed
BEQ .returnYoshiFly			;/
LDA #$BF			;\ If so, fly
STA $7D			    ;/
.returnYoshiFly:
RTL