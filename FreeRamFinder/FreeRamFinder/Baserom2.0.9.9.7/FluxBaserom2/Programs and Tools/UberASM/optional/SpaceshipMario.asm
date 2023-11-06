;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Made by wiiqwertyuiop
; Forces you to move right, and when up hit up or don you will go up or down.
;
; Random things for your changing plessure:
;
!SpeedH = $15	;right/left speed
!SpeedV = $1A	;down/up speed
;
; That's it....
;.....
; OHH! Wait if you touch a wall or the ground... you will die. 
; Give me credit! And PM me if you have trouble.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main:
	REP #$20	;\ Enter 16-bit mode
	LDA #$8080	;| Disable spinjump...
	TSB $0DAC|!addr	;|
	SEP #$20	;/ Return back to 8-bit mode

	LDA $71		; Do not run the code if Mario is dying
	CMP #$09
	BEQ return

	LDA $77		;\ CHECK IF NOT TOUCHING
	AND #$07	;| wall or ground
	BEQ +		;/ If so, branch to main code

	JSL $00F606	; Kill Mario
+
	LDA $15		;\
	AND #$04	;|
	BNE Down	;|
	LDA $15		;| What buttons to press
	AND #$08	;| (possible values: 01=Right, 02=Left, 04=Down, 08=Up
	BNE Up		;| 10=Start, 20=Select, 40=Y and X, 80=B and A)
	LDA $15		;|
	AND #$01	;|
	BNE Right	;|
	LDA $15		;|
	AND #$02	;|
	BNE Left	;/
	STZ $7B		; Set Mario's X-speed to 0
	STZ $7D		; Set Mario's Y-speed to 0
	RTL

Down:
	LDA #!SpeedV
	STA $7D
	RTL

Up:
	LDA.b #($100-!SpeedV)
	STA $7D
	RTL

Right:
	LDA #!SpeedH
	STA $7B
	STZ $7D		; Set Mario's Y-speed to 0
	RTL

Left:
	LDA.b #($100-!SpeedH)
	STA $7B
	STZ $7D		; Set Mario's Y-speed to 0
return:
	RTL