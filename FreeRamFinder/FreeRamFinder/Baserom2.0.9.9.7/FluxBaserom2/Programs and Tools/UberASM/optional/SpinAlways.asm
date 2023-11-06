; This makes you always spin, and never be able to normal jump. 
; By SJC, based on code by Binavik and Francium.
; Issue: If you jump from vine, still normal jump sound. LDA #$04 : STA $1DFC

!ConstantSpinAnimation = 1

main:
  if !ConstantSpinAnimation
  LDA #$FF
  STA $14A6
  endif
  LDA #$01   ; constant spin state
  STA $140D  
  LDA $74    ; climbing check (otherwise can't jump from vine)
  BNE .return
  LDA $16    ; This next code prevents the normal jump sound from ever playing.
  AND #$80
  BEQ .return
  LDA #$80
  TRB $16
  LDA #$80
  TSB $18    
.return
  RTL