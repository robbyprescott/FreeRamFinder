; Make sure this is the same as the patch
!freeram = $0EDA

; How many fireballs to have in this level
!level_amount = $02 ; $02 is vanilla

init:
    lda.b #!level_amount : sta !freeram
    rtl