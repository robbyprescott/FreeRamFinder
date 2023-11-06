; Need to add speed detect both ways
; Add goal walk check
; If press and hold from standstill, add brief cooldown before walking sound?

main:
LDA $77        ; must be on ground
BEQ Return
;LDA $16
LDA $7B
CMP #$28 ; check if p-speed basically
BCC MediumPace
LDA $14   ; Frequency of SFX (lower number = higher frequency)
AND #$03  ; #$00, #$01, #$03, #$07, #$0F, #$1F, #$3F, #$7F or #$FF
BNE Return
LDA #$01  ; Sound of hit head
STA $1DF9
BRA Return
MediumPace:
CMP #$18  ; check if speed above
BCC Walk
LDA $14
AND #$07		
BNE Return
LDA #$01  
STA $1DF9
BRA Return
Walk:
CMP #$08  ; check if speed above. 08 good? Originally #$05
BCC Step
LDA $14
AND #$0F		
BNE Return
LDA #$01  ; Sound of hit head
STA $1DF9
BRA Return
Step:
;CMP #$01
;BCC Return
CMP #$04
BCS Return ; below
LDA $16 ; button press
AND #$01 ; 03 left or right		
BEQ Return
LDA #$01  ; Sound of hit head
STA $1DF9
Return:
RTL