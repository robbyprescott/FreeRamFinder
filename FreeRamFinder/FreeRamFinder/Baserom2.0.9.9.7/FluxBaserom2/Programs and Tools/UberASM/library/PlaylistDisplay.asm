; Level Warp Display
; by JackTheSpades
; Super sloppy mods by SJC; didn't bother to remove some unnecessary level warp stuff

; Unfortunately you can only have 16 character long names

; For its use in the baserom, I raised the vertical layer 3 position (to F) in LM itself

!Position = $0258 ; first two numbers are both x-position and y. 02 is two tiles from left. (Vertical was low without LM adjust.)
                  ; To have Y=1 you add $20, Y=2 add $40 etc.

!DisplayFreeRAM = $14AF
!Counter = $7C    ;needs to be DB or Long (2 or 6 digits, not 4)

table PlaylistDisplayTable.txt

init:
   ;LDA #$00             ; \ Reset Counter
   ;STA !Counter         ; / if need
   RTL

main:
   LDA !DisplayFreeRAM
   BEQ Return
   ;LDA #$0B             ; \ Freeze the player
   ;STA $71              ; /
   LDA $18              ; \ Press - alt 16
   AND #$30             ; | L or R - 03 is left or right
   LSR #4
   AND #$03
   TAX                  ; | increase or decrease counter based on
   LDA.l Add,x          ; | pushing L or R.
   CLC                  ; |
   ADC !Counter         ; /
   
   CMP #$FF                                  ; \
   BNE +                                     ; |
   LDA.b #(TableLevels_end-TableLevels)/2-1  ; |
   BRA ++                                    ; | Limit A to [0, n) with n being the number of
+  CMP.b #(TableLevels_end-TableLevels)/2    ; | options available and have it loop around.
   BNE ++                                    ; |
   LDA #$00                                  ; /
++
   STA !Counter         ; /

   PEA $7F|(main>>16<<8)
   PLB

   REP #$30          ; A,X,Y in 16bit mode
   LDY $837B         ; stripe index in Y
      
   ;stripe upload header
   LDA #!Position        ; layer 3, 
   STA $837D+0,y     ;
   LDA #$1F00        ; uploading 32 bytes of data
   STA $837D+2,y     ;
      
   ;get table offset in X
   LDA !Counter
   AND #$00FF
   ASL #4
   TAX
   SEP #$20
   
   ;loop counter
   LDA #$0F
   STA $00
   
.loop
   
   LDA.l TableNames,x   ; \
   STA $837D+4,y        ; | Write letter to stripe upload
   LDA #$38             ; | yxpccctt = 0011-1000
   STA $837D+5,y        ; /
   
   INX
   INY : INY
   
   DEC $00
   BPL .loop
   
   ;stripe terminator
   LDA #$FF
   STA $837D+4,y
   
   ;update index and store back
   INY : INY
   INY : INY
   STY $837B
   
   PLB   
   SEP #$10
Return:  
   RTL
   
;values to add when pressing left or right
Add:
   db $00, $01, $FF, $00
   
   
; Names, always 16 byte, so limit 16 characters
; Use capital letters only
TableNames:
   db "TRACK 2A        "
   db "TRACK 2B        "
   db "TRACK 2C        "
   db "TRACK 2D        "
   db "TRACK 2E        "
   db "TRACK 2F        "
   db "TRACK 30        "
   db "TRACK 31        "
   
;TableNo:
 ;  db "                "
 ;  db "                "
 ;  db "                "
 ;  db "                "
 ;  db "                "
 ;  db "                "
 ;  db "                "
 ;  db "                " 
   
   
macro level(level, midway)
   dw <level>|(<midway><<11)
endmacro

macro secen(num, water)
   dw <num>&$FF|((<num>&$F00)<<12)|(<water><<11)|$200
endmacro
   
; note, add $800 to go to midpoint (needs seperate midpoint settings enabled)
; or see https://www.smwcentral.net/?p=nmap&m=smwram#7E19D8 for more details on the high byte.
TableLevels:
   %level($0001, 0)
   %secen($0000, 1)
   %secen($0001, 0)
   %secen($0002, 0)
   %secen($0003, 0)
   %level($0003, 0)
   %level($0004, 0)
   %level($0005, 0)
.end
