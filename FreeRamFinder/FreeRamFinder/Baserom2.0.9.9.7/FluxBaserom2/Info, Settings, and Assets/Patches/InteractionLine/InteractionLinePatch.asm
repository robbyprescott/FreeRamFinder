;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Interaction Line
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc InteractionLineDef.asm

; Defines taken from GPS

if read1($00FFD5) == $23; SA-1 detection code
	sa1rom
	!sa1 = 1			; SA-1 Pack v1.10+ identifier
	!dp = $3000
	!addr = $6000
	!bank = $000000
	!bank8 = $00
else
	!sa1 = 0			; SA-1 flag
	!dp = $0000			; Direct Page remap ($0000 - LoROM/FastROM, $3000 - SA-1 ROM)
	!addr = $0000		; Address remap ($0000 - LoROM/FastROM, $6000 - SA-1 ROM)
	!bank = $800000		; Long address remap ($800000 - FastROM, $000000 - SA-1 ROM)
	!bank8 = $80		; Bank byte remap ($80 - FastROM, $00 - SA-1 ROM)
endif

macro define_sprite_table(name, name2, addr, addr_sa1)
if !sa1 == 0
    !<name> = <addr>
else
    !<name> = <addr_sa1>
endif
    !<name2> = !<name>
endmacro

; Regular sprite tables
%define_sprite_table(sprite_num, "9E", $9E, $3200)
%define_sprite_table(sprite_speed_y, "AA", $AA, $9E)
%define_sprite_table(sprite_speed_x, "B6", $B6, $B6)
%define_sprite_table(sprite_misc_c2, "C2", $C2, $D8)
%define_sprite_table(sprite_y_low, "D8", $D8, $3216)
%define_sprite_table(sprite_x_low, "E4", $E4, $322C)
%define_sprite_table(sprite_status, "14C8", $14C8, $3242)
%define_sprite_table(sprite_y_high, "14D4", $14D4, $3258)
%define_sprite_table(sprite_x_high, "14E0", $14E0, $326E)
%define_sprite_table(sprite_speed_y_frac, "14EC", $14EC, $74C8)
%define_sprite_table(sprite_speed_x_frac, "14F8", $14F8, $74DE)
%define_sprite_table(sprite_misc_1504, "1504", $1504, $74F4)
%define_sprite_table(sprite_misc_1510, "1510", $1510, $750A)
%define_sprite_table(sprite_misc_151c, "151C", $151C, $3284)
%define_sprite_table(sprite_misc_1528, "1528", $1528, $329A)
%define_sprite_table(sprite_misc_1534, "1534", $1534, $32B0)
%define_sprite_table(sprite_misc_1540, "1540", $1540, $32C6)
%define_sprite_table(sprite_misc_154c, "154C", $154C, $32DC)
%define_sprite_table(sprite_misc_1558, "1558", $1558, $32F2)
%define_sprite_table(sprite_misc_1564, "1564", $1564, $3308)
%define_sprite_table(sprite_misc_1570, "1570", $1570, $331E)
%define_sprite_table(sprite_misc_157c, "157C", $157C, $3334)
%define_sprite_table(sprite_blocked_status, "1588", $1588, $334A)
%define_sprite_table(sprite_misc_1594, "1594", $1594, $3360)
%define_sprite_table(sprite_off_screen_horz, "15A0", $15A0, $3376)
%define_sprite_table(sprite_misc_15ac, "15AC", $15AC, $338C)
%define_sprite_table(sprite_slope, "15B8", $15B8, $7520)
%define_sprite_table(sprite_off_screen, "15C4", $15C4, $7536)
%define_sprite_table(sprite_being_eaten, "15D0", $15D0, $754C)
%define_sprite_table(sprite_obj_interact, "15DC", $15DC, $7562)
%define_sprite_table(sprite_oam_index, "15EA", $15EA, $33A2)
%define_sprite_table(sprite_oam_properties, "15F6", $15F6, $33B8)
%define_sprite_table(sprite_misc_1602, "1602", $1602, $33CE)
%define_sprite_table(sprite_misc_160e, "160E", $160E, $33E4)
%define_sprite_table(sprite_index_in_level, "161A", $161A, $7578)
%define_sprite_table(sprite_misc_1626, "1626", $1626, $758E)
%define_sprite_table(sprite_behind_scenery, "1632", $1632, $75A4)
%define_sprite_table(sprite_misc_163e, "163E", $163E, $33FA)
%define_sprite_table(sprite_in_water, "164A", $164A, $75BA)
%define_sprite_table(sprite_tweaker_1656, "1656", $1656, $75D0)
%define_sprite_table(sprite_tweaker_1662, "1662", $1662, $75EA)
%define_sprite_table(sprite_tweaker_166e, "166E", $166E, $7600)
%define_sprite_table(sprite_tweaker_167a, "167A", $167A, $7616)
%define_sprite_table(sprite_tweaker_1686, "1686", $1686, $762C)
%define_sprite_table(sprite_off_screen_vert, "186C", $186C, $7642)
%define_sprite_table(sprite_misc_187b, "187B", $187B, $3410)
%define_sprite_table(sprite_tweaker_190f, "190F", $190F, $7658)
%define_sprite_table(sprite_misc_1fd6, "1FD6", $1FD6, $766E)
%define_sprite_table(sprite_cape_disable_time, "1FE2", $1FE2, $7FD6)

; Romi's Sprite Tool defines.
%define_sprite_table(sprite_extra_bits, "7FAB10", $7FAB10, $6040)
%define_sprite_table(sprite_new_code_flag, "7FAB1C", $7FAB1C, $6056) ;note that this is not a flag at all.
%define_sprite_table(sprite_extra_prop1, "7FAB28", $7FAB28, $6057)
%define_sprite_table(sprite_extra_prop2, "7FAB34", $7FAB34, $606D)
%define_sprite_table(sprite_custom_num, "7FAB9E", $7FAB9E, $6083)
%define_sprite_table(sprite_extra_byte1, "7fAB40", $7fAB40, $60A4)
%define_sprite_table(sprite_extra_byte2, "7fAB4C", $7fAB4C, $60BA)
%define_sprite_table(sprite_extra_byte3, "7fAB58", $7fAB58, $60D0)
%define_sprite_table(sprite_extra_byte4, "7fAB64", $7fAB64, $60E6)

org $00E92E
autoclean JML MarioInteraction

org $01914F
JSL SpriteInteraction
BRA $00

org $029FDB
JML FireballInteraction
NOP

org $029F13
JML BubbleFix

freedata

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Mario interaction
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MarioInteraction:
	LDA !InteractionType	; Save time by not running custom interaction
	BEQ .Return				; if not enabled
	LDA #$00				; Index of interaction points
	LDX $19					; Big...
	BEQ .SmallMario			;
	LDX $73					; ... and not ducking...
	BNE .SmallMario			;
	LDA #$18				; ... means different interaction
.SmallMario:				;
	LDX $187A|!addr			; On Yoshi?
	BEQ .NoYoshi			;
	CLC : ADC #$30			; Another set of interactions
.NoYoshi:					;
	REP #$20				; A = 16-bit
	AND #$00FF				; Clear high byte
	CLC						;
	ADC #InteractPointY		; Table of Mario's interaction points (Y offsets)
	STA $00					;
	LDX !InteractionType	; Get interaction type
	PEA .Return-1			; Set return address
	LDA.l MarioInteractions-2,x
	PHA						; Push address
	SEP #$20				; A = 8-bit
RTS							; Closer to JMP smh
							;
.Return:					;
	LDA $185C|!addr			; Can Mario interact with blocks
	BEQ .BlockInteraction	; (Ghost house ledge)
JML $00E933|!bank			;
							;
.BlockInteraction:			;
JML $00E938|!bank			;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Sprite interaction
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpriteInteraction:
	STA $1695|!addr			; Restore
	STZ !164A,x				;
	LDA !InteractionType	; No code if no interaction enabled
	BEQ .NoInteraction		;
	TXY						;
	REP #$20				; A = 16-bit
	LDX !InteractionType	;
	LDA.l SpriteInteractions-2,x
	PHA						;
	SEP #$20				; A = 8-bit
	TYX						;
RTS							; JMP in disguise
							;
.NoInteraction:				;
RTL							; Check only for blocks


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Fireball interaction
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FireballInteraction:
	LDA !InteractionType	; No code if no interaction enabled
	BEQ .NoInteraction		;
	LDA $1715|!addr,x		; Get interaction point of fireball
	CLC : ADC #$08			;
	STA $00					;
	LDA $1729|!addr,x		; High byte
	ADC #$00				;
	STA $01					;
	PEA .NoInteraction-1	; Set return address
	REP #$20				;
	TXY						;
	LDX !InteractionType	; Get interaction type
	LDA.l FireballInteractions-2,x
	PHA						;
	TYX						;
	SEP #$20				;
RTS							;
							;
.NoInteraction:				;
	LDA $0E					;
	BEQ .NoGround			;
	INC $175B|!addr,x		; Increment interacted with block counter by one
JML $029FE0|!bank			;
							;
.NoGround:					;
JML $02A010|!bank			;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Bubble interaction
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BubbleFix:
	LDA $85					; Water level means no air (why'd you check for water level anyway?)
	BNE .StillAlive			;
	LDA !InteractionType	; No code if no interaction enabled
	BEQ .CheckTile			;
	LDA $1715|!addr,x		; Bubble Y position
	CLC : ADC #$08			; Offset
	CMP !InteractionPos		; Compare low bytes
	LDA $1729|!addr,x		; Same with high byte
	SBC !InteractionPos+1	; Carry over the carry from previous calculation
	BPL .StillAlive	 		; Just what it says!
							;
.CheckTile:					;
JML $029F17|!bank			; Check for tile number
							;
							;
.StillAlive:				;
JML $029F2A|!bank			; Keep bubble definitively alive


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Other things
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc InteractionLineCodes.asm
