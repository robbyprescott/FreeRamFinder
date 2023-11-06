; You can modify $18E8 stuff to make grow instant, instead of freeze
; Grow Yoshi code shamelessly taken from Dijef's disassembly

!SpriteNumber = $2D ; baby Yoshi
!Trigger = $14AF

main:
    LDX #!sprite_slots-1
.loop

    LDA !sprite_num,x
    CMP #!SpriteNumber
    BEQ .thing

.next
    DEX
    BPL .loop
    RTL

.thing
if read4($02FFE2) == $44535453 ; if pixi is installed
    LDA !extra_bits,x ; check if sprite is custom
    AND #$08
    BNE .next
endif

    ;LDA !sprite_x_high,x
    ;XBA
    ;LDA !sprite_x_low,x
	
	LDA !Trigger
	BEQ .next
	STZ $18AC               ;clear Yoshi eat timer
	STZ $141E               ;clear Yoshi wings
	LDA #$35 : STA !9E,x	;Set sprite ID to Yoshi
	LDA #$08 : STA !14C8,x	;Change state to normal
	LDA #$1F : STA $1DFC             ;Play grow sound
	LDA !D8,x : SBC #$10 : STA !D8,x		;\ Adjust Y position
	LDA !14D4,x : SBC #$00 : STA !14D4,x	;/
	LDA !15F6,x : PHA		;Save palette
	JSL $07F7D2 ;           ;init sprite tables
	PLA : AND #$FE : STA !15F6,x			;restore palette
	LDA #$0C : STA !1602,x	;Set growing pose
	DEC !160E,x				;No sprite on tongue
	LDA #$20 : STA $18E8 ;  ;Growing timer, default 40
	;STZ !RAM
    BRA .next