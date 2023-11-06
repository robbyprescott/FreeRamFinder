; By SJC

; By default, this will disable something (by default, disable jumps) after you reach a certain count (default coins).
; You can even increment the count whenever a certain sound plays, if you use it with the DoThingWhenSound.asm sprite generator.
; You can use that, for example, to make sure frame-perfect jumps always increment a jump count (with a caveat).

; By default, this will disable all B/A presses when you've reached the defined count (!NumberOfThings).


!Counter = $0DBF ; coin count. You can also just make it a FreeRAM counter
                 ; e.g. by using $0DFF to count fireballs shot, or
                 ; the DoThingWhenSound.asm sprite generator.
!MaxNumberOfThings = $04
!PlaySoundWhenOutOf = 1 ; if you've used up your jumps, will play the "wrong" 
                         ; sound effect after that whenever you try to jump again

main:
LDA !Counter
CMP #!MaxNumberOfThings
BCC Return ; To change to only do the thing when you're BELOW
           ; this value, change BCC here to BCS
if !PlaySoundWhenOutOf
LDA $16
ORA $18
CMP #$80
BNE Return
LDA #$2A
STA $1DFC
endif
ThingToDo:
LDA #$80 ; disable B/A presses. Use LDA #$80 : TSB $0DAA : TSB $0DAB for only B, etc.
TRB $16
TRB $18
Return:
RTL