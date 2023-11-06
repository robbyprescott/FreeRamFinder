init:                   ;\  This section is to be used in the INIT code of levelASM
   REP #$20             ; | 
   LDA #$0D02           ; | Use Mode 02 on register 210D
   STA $4330            ; | 4330 = Mode, 4331 = Register
   LDA #$9E00           ; | Address of HDMA table
   STA $4332            ; | 4332 = Low-Byte of table, 4333 = High-Byte of table
   SEP #$20             ; | 
   LDA.b #$7F           ; | Address of HDMA table, get bank byte
   STA $4334            ; | 4334 = Bank-Byte of table
   JMP main                  ;/  End HDMA setup	  	

;The Table takes up 115 bytes of the free RAM
;It ranges from $7F9E00 - $7F9E72 (both addresses included)

main:
   LDA #$08             ;\ 
   LDX $14AF|!addr      ; |
   BEQ +                ; | Replace with BNE to invert the condition.
   TSB $0D9F|!addr      ; | Enable HDMA channel 3
   BRA ++               ; |
+  TRB $0D9F|!addr      ; | Disable HDMA channel 3
++                      ;/ 

                        ;\  This section is to be used in the MAIN code of levelASM
   LDY #$00             ; | Y will be the loop counter.
   LDX #$00             ; | X the index for writing the table to the RAM
   LDA $13              ; | Speed of waves
   LSR #2               ; | Slowing down A
   STA $00              ;/  Save for later use.

   PHB : PHK : PLB      ;\  Preservev bank
.Loop:                  ; | Jump back if not finished writing table
   LDA #$06             ; | Set scanline height
   STA $7F9E00,x        ; | for each wave
   TYA                  ; | Transfer Y to A, to calculate next index
   ADC $00              ; | Add frame counter
   AND #$0F             ; | 
   PHY                  ; | Preserve loop counter
   TAY                  ;/  Get the index in Y

   LDA.w .WaveTable,y   ;\  Load in wave value
   LSR                  ; | Half only
   CLC                  ; | Clear Carry for addition
   ADC $1A              ; | Add value to layer X position (low byte)
   STA $7F9E01,x        ; | store to HDMA table (low byte)
   LDA $1B              ; | Get high byte of X position
   ADC #$00             ; | Add value to layer X position (low byte)
   STA $7F9E02,x        ;/  store to HDMA table (high byte)

   PLY                  ;\  Pull original loop counter
   CPY #$25             ; | Compare if we have written enough HDMA entries.
   BPL .End             ; | If bigger, end HDMA
   INX                  ; | Increase X, so that in the next loop, it writes the new table data...
   INX                  ; | ... at the end of the old one instead of overwritting it.
   INX                  ; | 
   INY                  ; | Increase loop counter
   BRA .Loop            ;/  Repeat loop

.End:                   ;\  Jump here when at the end of HDMA
   PLB                  ; | Pull back data bank.
   LDA #$00             ; | End HDMA by writting 00...
   STA $7F9E03,x        ; | ...at the end of the table.
   RTL                  ;/  

.WaveTable:             ;\  
   db $00               ; | 
   db $01               ; | 
   db $02               ; | 
   db $03               ; | 
   db $04               ; | 
   db $05               ; | 
   db $06               ; | 
   db $07               ; | 
   db $07               ; | 
   db $06               ; | 
   db $05               ; | 
   db $04               ; | 
   db $03               ; | 
   db $02               ; | 
   db $01               ; | 
   db $00               ;/ 