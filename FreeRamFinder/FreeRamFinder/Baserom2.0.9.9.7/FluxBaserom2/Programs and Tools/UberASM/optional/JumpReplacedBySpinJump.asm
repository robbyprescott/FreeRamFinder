; All jumps will be spin jumps (unless jumping from a vine).
; By binavik.

main:
  LDA $74    ; climbing check (otherwise can't jump from vine)
  BNE .return
  LDA $16    
  AND #$80
  BEQ .return
  LDA #$80
  TRB $16
  LDA #$80
  TSB $18    
.return
  RTL