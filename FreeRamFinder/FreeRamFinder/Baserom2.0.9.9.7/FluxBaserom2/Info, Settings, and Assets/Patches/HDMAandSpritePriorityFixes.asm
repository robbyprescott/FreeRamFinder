; SJC: These priority fixes are mainly useful if you're in certain level modes,
; e.g. using layer 3 priority + translucence, where sprites have a tendency to go behind
; other layers. However, these current fixes give them absolute priority
; in all scenarios, which leads to weird things like jumping piranhas always being in front of pipes. 

; So I've commented out a few fixes. For example, I've commented out the powerup priority fixes
; until I can find a better solution that prevents them from going in front
; of an item block when they're spawned from it.

; Make sure this is compatible with restore layer 3 message patch

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;HDMA Improvements & Bugfixes
;by Ice Man
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SA-1 Check
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if read1($00FFD5) == $23
	; SA-1 base addresses
	sa1rom
	!sa1 = 1
	!dp = $3000
	!addr = $6000
	!bank = $000000
else
	; Non SA-1 base addresses
	lorom
	!sa1 = 0
	!dp = $0000
	!addr = $0000
	!bank = $800000
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Hijacks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $0081AA|!bank						;Hijack NMI routine and
	autoclean JML HDMA_Start			;jump to our code
	NOP									;Clean left over

org $009CAD|!bank						;Keep HDMA active
	NOP #3								;on title screen

org $00C5CE|!bank						;Keep HDMA active
	NOP #3								;on animation $0B

org $00CB0C|!bank						;Fix gradients
	TSB $0D9F|!addr						;on level end

org $03C511|!bank						;Keep HDMA active
	TSB $0D9F|!addr						;during spotlight

org $04DB99|!bank						;Keep HDMA active
	TSB $0D9F|!addr						;during save prompt

org $04F40D|!bank						;Keep HDMA active
	NOP #3								;after save prompt

org $05B129|!bank						;Keep HDMA active
	NOP #3								;after message box

org $05B296|!bank						;Keep HDMA active
	TSB $0D9F|!addr						;during message box

org $0CAB98|!bank						;Keep HDMA active
	TSB $0D9F|!addr						;after animation $0B

org $0CAB92|!bank						;Affect all layers
	LDA #$A2							;during animation $0B

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Priority Fixes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;org $00E2B9|!bank
	;db $E0,$10,$20,$30					;Mario Priority

;org $018E83|!bank
	;LDA #$20							;Classic Piranha Priority

org $01C18D|!bank
	LDA #$20							;Growing Vine Priority

;org $01C39C|!bank
	;LDA #$20							; Power up from item block Priority, default 10

;org $01C4A1|!bank
	;LDA #$20							;Stationary Power Up Priority?

;org $01C6C1|!bank
	;LDA #$20							;Power-Up Priority

;org $01C6C5|!bank
	;ORA #$60							;Power-Up Priority (Flipped), default 40

org $01DB9E|!bank
	db $23,$63,$A3,$E3					;Grinder Priority

;org $01EBA9|!bank
	;LDA #$20							;On Yoshi Priority

org $029E73|!bank
	ORA #$23							;Torpedo Ted's Arm Priority

org $02B892|!bank
	LDA #$20							;Torpedo Ted Priority

;org $02E0D4|!bank
;	LDA #$20							;Jumping Piranha Priority

org $02E7C5|!bank
	LDA #$20							;Chuck's Rock Priority

;org $02EA1A|!bank
	;EOR #$6B							;Pipe Lakitu Priority

org $02F4B6|!bank
	LDA #$25							;Smoke Priority

;org $0394C5|!bank
	;db $A1,$A1,$A1,$A1,$A1				;Wooden Spike
	;db $21,$21,$21,$21,$21				;Priority

org $039784|!bank
	db $6D,$DD,$2D,$AD 					;Fishbone Priority

org $03A09B|!bank
	db $45,$25							;Blargg Priority

org $04FDAC|!bank
	LDA #$74							;Bowser Sign Priority

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;HDMA Main Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

freecode

HDMA_Start:
	LDX $0100|!addr
	LDA.l Allowed_HDMA_Modes,x
	BNE HDMA_Return

	STZ $0D9F|!addr

HDMA_Return:
	LDA #$80							;Restore previously
	STA $2100							;hijacked code
	JML $0081AF|!bank					;and return

Allowed_HDMA_Modes: 					;$00 = off, $01 = on
	db $00,$00,$00,$00,$00,$01,$01,$00	;00-07
	db $00,$00,$00,$01,$00,$01,$01,$01	;08-0F
	db $00,$00,$00,$01,$01,$01,$00,$00	;10-17
	db $01,$01,$01,$01,$01,$01,$01,$01	;18-1F
	db $01,$01,$01,$01,$01,$01,$01,$01	;20-27
	db $01,$01							;28-29
;These are all the game modes. Adjust to your needs.