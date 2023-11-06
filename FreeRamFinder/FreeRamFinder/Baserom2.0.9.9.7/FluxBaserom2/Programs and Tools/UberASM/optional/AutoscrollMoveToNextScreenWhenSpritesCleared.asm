;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Auto-SCROLL Stop/Start, by lolcats439, just brought over to Uber by SJC
;;
;; Description: When all enemies on the screen are killed, this will SCROLL to the next screen, 
;; stop, and repeat. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


!Sound = $29      ; sound to play when all enemies on screen are killed
!ScrollType = $0C ; Scrolling command to run: 0C = Auto-SCROLL level. Other commands are at label Ptrs05BC87 in AllLog, here: https://floating.muncher.se/bot/alllog2/smwdisc.txt
!Speed = $9C      ; Speed of Auto-scrolling: 00 = Slow, 9C = Medium, C2 = Fast (may glitch)
!WaitFrames = $20 ; how many frames (+ 1) to wait between killing the last enemy and scrolling the screen

; FreeRAM
!Timer = $0E7E     ;\ FreeRAM addresses; if you get glitched graphics, try changing these to different FreeRAM
!PrevScreen = $0E7F
!SpritesFound = $0E80

; List of normal sprites that should not stop the screen from scrolling.
; The rows do not need to be exactly 16 bytes long, you can just add or delete 
; a sprite number in any row and change the ListLength value

IgnoreList:       
db $0E,$21,$2C,$2D,$2F,$35,$3E,$41,$42,$43,$45,$49,$4A,$52,$54,$55
db $56,$57,$58,$59,$5B,$5C,$5D,$5E,$5F,$60,$61,$62,$63,$64,$6A,$6B
db $6C,$6D,$74,$75,$76,$77,$78,$79,$7A,$7B,$7D,$7E,$7F,$80,$81,$83
db $84,$87,$8A,$8B,$8D,$8E,$8F,$9C,$A3,$B1,$B2,$B7,$B8,$B9,$BA,$BB
db $C0,$C1,$C4,$C6,$C7,$C8,$E0

!ListLength = $47 ; number of items in list in hex

;;;;;;;;;;;;

main:
STZ $1411          ;\ disable horizontal scrolling
LDA $5D            ;| If on last screen in level, return
SEC                ;|
SBC $1463          ;|
CMP #$01           ;|
BEQ Return         ;/

JSR CheckForSprites;\ 
LDA !PrevScreen    ;| Stop scrolling when at next screen
CMP $1463          ;| SMW's auto-scroll code takes a frame before it actually starts moving
BEQ Skip1          ;| this code is to avoid stopping the auto-scroll before it starts moving
LDA !SpritesFound  ;| and only stop once we are actually at the next screen
BEQ Skip6          ;| comment out this line to make it stop at every screen even if no enemies
STZ $143E          ;|
STZ $1446          ;|
STZ $1447          ;|
Skip1:             ;/

LDA $143E          ;\ Return if screen is scrolling
BNE Return         ;/

LDA !SpritesFound  ;\ 
BNE Return         ;|
LDA !Timer         ;| Check if timer is set
BEQ SetTimer       ;| if not, set it
DEC !Timer         ;| Decrement timer
CMP #$01           ;| Timer has been set, check if it ran out
BNE Return         ;/ if not, return

LDA #!Sound        ;\ Timer has run out
STA $1DFC          ;| play sound effect
BRA Scroll         ;/ and scroll the screen

SetTimer:          ;\ Timer is not set, set it
LDA #!WaitFrames   ;|
STA !Timer         ;|
BRA Return         ;/

Scroll:            ;\ 
LDA #!ScrollType   ;| set sprite command number
STA $143E          ;|
LDA #!Speed        ;| set auto-scroll speed
STA $1440          ;|
Skip6:             ;|
LDA $1463          ;| record number of current screen
STA !PrevScreen    ;/

Return:
RTL

CheckForSprites:
LDY #$0B           ;\ Check if any sprites on screen
STZ !SpritesFound  ;|
Loop:              ;|
LDA $14C8,y        ;|
CMP #$08           ;|
BNE Skip3          ;/
LDX #!ListLength
Loop2:
LDA $009E,y        ;\ Do not stop scrolling if vanilla sprite is
CMP IgnoreList,x   ;| in ignore list
BEQ Skip5          ;| ($7FAB9E is custom sprite)
DEX                ;|
BPL Loop2          ;/
BRA Skip4
Skip5:
TYX                ;\ make sure it's not a custom sprite
LDA !extra_bits,x  ;| this will not ignore custom sprites
CMP #$02           ;|
BCC Skip3          ;/
Skip4:
LDA $14E0,y        ;\ Make sure sprite is actually on screen (killable)
CMP $1463          ;|
BNE Skip3          ;|
LDA #$01           ;|
STA !SpritesFound  ;/
Skip3:
DEY                ;\ branch up if loop not finished
BPL Loop           ;/
RTS