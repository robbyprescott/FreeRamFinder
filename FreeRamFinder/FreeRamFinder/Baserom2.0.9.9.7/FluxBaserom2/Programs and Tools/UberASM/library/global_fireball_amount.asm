; Make sure this is the same as the patch
!freeram = $0EDA

; How many fireballs to have globally
!global_amount = $05

init:
    lda.b #!global_amount : sta !freeram
    rtl
