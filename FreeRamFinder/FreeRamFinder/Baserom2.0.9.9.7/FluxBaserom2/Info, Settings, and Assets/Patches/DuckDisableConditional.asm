!freeram = $0DFC

org $00D600
autoclean jml checkduck

freecode 

checkduck:
lda !freeram
bne +
lda $15
and #$04
jml $00D604 ; |!bank
+
jml $00D60B ; |!bank

;CODE_00D600:        A5 15         LDA RAM_ControllerA       ;\
;CODE_00D602:        29 04         AND.B #$04                ;| if down is not being held,
;CODE_00D604:        F0 05         BEQ CODE_00D60B           ;/
;CODE_00D606:        85 73         STA RAM_IsDucking ($73)         ; Mario isn't ducking anymore