; by dirty!
; modify timers

; This patch requires 11 bytes of empty ram, preferably cleared on level load or overworld load
; Alternatively you can remove whatever you don't plan on using, so empty space isn't being wasted
; For the most part it should all be in alphabetical order so removing what isn't used is easier to do
; Anything removed here should also be removed inside the UberASM file

; Empty ram changed here must also be changed inside the Uber ASM .asm file

; sa1 stuff
!addr = $0000
!bank	= $800000
!1540 = $1540

if read1($00FFD5) == $23
sa1rom
!addr = $6000
!bank	= $000000
!1540 = $32C6
endif

!BulletBillShooter_RAM    = 	$18C6|!addr
!PSwitches_RAM            =   	$18B7|!addr
!PBalloon_RAM             =   	$18BB|!addr


org $02B46B|!bank ; Bill Shooter
autoclean JSL BillShooterMain
NOP

org $01C304|!bank ; PBalloon
autoclean JSL PBalloonMain
NOP

org $01AB1A|!bank ; Pswitches
autoclean JSL PSwitchMain
NOP

freedata

BillShooterMain:
LDA !BulletBillShooter_RAM		   ; empty ram
BEQ .original	 ; check if 0, if 0 just run original code
LDA !BulletBillShooter_RAM	     ; load value stored in !BulletBillShooter_RAM
STA $17AB|!addr,X	   ; store to shooter timer
RTL
.original
LDA #$60	     ; original code
STA $17AB|!addr,X	   ; original code
RTL

PBalloonMain:
LDA !PBalloon_RAM	      ; empty ram
BEQ .original         	; check if 0, if 0 just run original code
LDA !PBalloon_RAM	      ; load value stored in !PBalloon_RAM
STA $1891|!addr	              ; pballoon timer
RTL
.original
LDA #$FF	              ; original code
STA $1891|!addr	              ; original code
RTL

PSwitchMain:
LDA !PSwitches_RAM	    ; empty ram
BEQ .original         	; check if 0, if 0 just run original code
LDA !PSwitches_RAM	    ; load value stored in !KeyholeShrink_RAM
STA $14AD|!addr,Y	            ; pswitch timer
RTL
.original
LDA #$B0	              ; original code
STA $14AD|!addr,Y	            ; original code
RTL