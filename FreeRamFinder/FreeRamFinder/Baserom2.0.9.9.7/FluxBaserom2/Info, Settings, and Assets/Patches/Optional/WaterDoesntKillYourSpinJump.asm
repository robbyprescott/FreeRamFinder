; If you enter into water while spinning, not only will you keep spin, but
; if you go to swim, you'll still "spin-swim." 
; However, if you DON'T enter water while spinning (or if you're on the ground in water), you'll still only 
; be able to normal swim when pressing A

; Still need to fix pose, and
; ability to spin jump from ground while in water

org $00D990
NOP #3

; CODE_00D988:        9C ED 13      STZ.W $13ED               
; CODE_00D98B:        64 73         STZ RAM_IsDucking         
; CODE_00D98D:        9C 07 14      STZ.W $1407               
; CODE_00D990:        9C 0D 14      STZ.W RAM_IsSpinJump             
; CODE_00D993:        A4 7D         LDY RAM_MarioSpeedY       
; CODE_00D995:        AD 8F 14      LDA.W $148F               
; CODE_00D998:        F0 51         BEQ CODE_00D9EB


; This swim upward only if press (otherwise constant swim)?

;CODE_00D9EB:        A5 16         LDA $16                   
;CODE_00D9ED:        05 18         ORA $18                   
;CODE_00D9EF:        10 1A         BPL CODE_00DA0B           
