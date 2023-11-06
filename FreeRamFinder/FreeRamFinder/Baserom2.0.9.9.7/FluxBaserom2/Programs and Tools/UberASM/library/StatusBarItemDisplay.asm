;handle custom reserve item display on status bar

;Defines for easy hardcoded property settings

!Palette8 = %00000000
!Palette9 = %00000010
!PaletteA = %00000100
!PaletteB = %00000110
!PaletteC = %00001000
!PaletteD = %00001010
!PaletteE = %00001100
!PaletteF = %00001110

!SP1SP2 = %00000000
!SP3SP4 = %00000001

;probably should've made it global with config in a folder that is loaded by all files. like how GHB blocks handled this
!FreeRam = $0DC4|!addr

;Item box variables
;Related with display
;Item positions are positions where item is displayed. they are from vanilla SMW, so if you have custom display, change them,
;setting ItemYPos to value between F0-FF will disable display but not the function. it's adviced to disable display with EasyPropSettings from the main uberASM file.
;do note that it doesn't support other methods of display by default (for example minimalist's layer 3 display), you'll need ASM knowledge to tinker with your custom status bar to get it working (untill solution is provided by the author of this resource aka me (RussianMan))

	!ItemXPos = $78
	!ItemYPos = $0F

;the same as in powerups sprite.
ItemTile:
	db $6D,$80,$26,$26,$89

;unlike custom sprites there's no easy CFG setting. those values are taken from unmodified power-ups configurations, but you can change them easily with defines from EasyPropSettings.asm from ExPowerSrc folder.
;$30 includes maximum foreground priority
ItemProp:
	db !PaletteB|!SP3SP4|$30	;hammer
	db !Palette9|!SP3SP4|$30	;boomerang
	db !PaletteE|!SP1SP2|$30	;shurikens
	db !PaletteB|!SP1SP2|$30	;ice
	db !PaletteB|!SP3SP4|$30	;bubble

StatusBarItemDisplay:
LDA $0DC2|!addr		;first, check actual status bar reserve item (vanilla item)
BNE .Re			;if we have somthing, return

LDA !FreeRam+2		;take custom power item value to get correct display
BEQ .Re			;
DEC			;
TAX			;

PHB			;just in case it starts taking some garbo values.
PHK			;
PLB			;
JSR .Show		;
PLB			;

.Re
RTL			;

.Show
LDY #$E0		;normal gameplay OAM slot
BIT $0D9B|!addr		;check mode 7
BVC .Display		;

LDY #$00		;Mode 7 boss battles' OAM slot
.Display

LDA #!ItemXPos		;pretty standart display
STA $0200|!addr,y	;

LDA #!ItemYPos		;
STA $0201|!addr,y	;

LDA ItemTile,x		;
STA $0202|!addr,y	;

LDA ItemProp,x		;
STA $0203|!addr,y	;

TYA			;
LSR #2			;set 16x16 sprite size
TAY			;
LDA #$02		;
STA $0420|!addr,y	;
RTS			;