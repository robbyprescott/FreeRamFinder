!Speed = $08                ;   How fast Mario will go while duckwalking. Only values 00-7F allowed!

main:
       LDA $73              ; Mario ducking?
       BEQ .Return
       LDA $77
       AND #$04
       BEQ .Return          ; return
       LDA $187A|!addr	; riding Yoshi?
       BNE .Return          ; Return	
       LDA $15
       AND #$03             ; Only keep Left and Right values
       BEQ .Return
       CMP #$03             ; If you're pressing both buttons
       BEQ .Return          ; Return
       LSR
       TAX
       LDA .XSpeeds,x
       STA $7B
       TXA
       EOR #$01
       STA $76
.Return
       RTL                  ;Return

.XSpeeds:
       db !Speed,-!Speed
