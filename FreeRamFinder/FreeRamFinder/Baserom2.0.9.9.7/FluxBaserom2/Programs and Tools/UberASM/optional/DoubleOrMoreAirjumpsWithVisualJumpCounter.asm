; Requires GFX20 in SP4 to display tiles correctly

;Airjumps + Jump Counter
;This is HammerBrother's Airjumps uberASM with jump counter attached (as a sprite tile).
;Press a jump button in the air and the player character will perform a jump or a spin jump, and the jump counter will go up or down (or just show infinity)
;By RussianMan
;Requested by 1UPDudes

!NumberOfAdditionalJumpsInMidair	= 2		;>How many extra jumps (9 max), 0 = infinite (cheeta-jump).
 !Freeram_JumpCountLeft	= $1479|!addr	;>[1 byte], a counter of how many jumps left (not applied if infinite).
!NJumpYSpeed		= $B0		;>How fast the player rises ($80-$FF where $80 is the fastest), normal jump.
!SJumpYSpeed		= $B6		;>Same as above, but spin.


!Freeram_JumpCounter = $0E2B|!addr	;1 byte of freeram, used for jump counter

!CountUp = 0				;how to count jumps? count to 0 or from 0? 0 - count down, 1 - count up

!MinimalistDisplay = 1			;show only when midair. 0 - show always, 1 - show when airborn (will show the counter if the game is paused regardless)

;0 - allow both airspins and airjumps
;1 - allow only airspins or airjumps depending on initial jump
;2 - disable airspins completely, can't airspin or airjump if initial jump was spinjump
!SubsequentJumpMode = 0

;Sound defines!
!SpinJumpSFX = $04 
!SpinJumpBank = $1DFC

!NormJumpSFX = $35			;if you're using AddMusicK, change this to $35 or if you have set !JumpSFXOn1DFC in Addmusic's tweaks.asm to false, change to $2B
!NormJumpBank = $1DFC			;if you're using AddMusicK, change this to $1DFC or if you have set !JumpSFXOn1DFC in Addmusic's tweaks.asm to false, change to $1DF9

;number 0-9 tiles
Tiles:
db $80,$B6,$B5,$B4,$B3,$A7,$A6,$A5,$A4,$A3

!InfinityTile = $B7			;used if you set !NumberOfAdditionalJumpsInMidair to 0 for infinite jumps

!YDispSmall = $08			;displacement for the counter
!YDispBig = $00

;easy props return! DON'T edit these defines, only change !Prop
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

!Prop = !Palette8|!SP3SP4|$30			;By default: Palette 8, Sprite Page 3 and 4, highest priority

!oamIndex   =   $0000   ; OAM index (from $0200) to use.
    ; ^ don't touch this one unless you know how it works.
    ;   this default value isn't really used by much so it should be fine.

main:
.Airjump
	..Checks
	LDA $13D4|!addr			;can't jump when paused
	BNE ..Return			;

	LDA $77				;\If mario is on ground, restore jumps
	AND.b #%00000100		;|
	BNE ..RestoreJumps		;/
	LDA $74				;>If net/vine climbing...
	ORA $75				;>Or water
	BNE ..RestoreJumps		;>Then restore jumps
	LDA $71				;\Don't jump when doing such actions such as dying.
	ORA $1407|!addr			;\
	BNE ..Return			;/
	LDA $7D				;\If already going up, don't allow the player to waste jumps.
	BMI ..Return			;/

if !SubsequentJumpMode == 2
{
	LDA $140D|!addr
	BNE ..Return
}
endif

	LDA $16				;\If pressing jump, confirm
	ORA $18				;|
	BPL ..Return			;/

	...ContinueChecking
	if !NumberOfAdditionalJumpsInMidair != 0
		LDA !Freeram_JumpCountLeft	;\If no jumps left, return.
		BEQ ..Return			;/
	endif

	..JumpConfirm
	if !NumberOfAdditionalJumpsInMidair != 0
		;if you are using absolute long addresses for freeram, you can uncomment below
		;LDA !Freeram_JumpCountLeft	;\Consume jump
		;DEC A 				;|
		;STA !Freeram_JumpCountLeft	;/

		;this is for zero page and absolute addresses, comment this (append ; at the beginning), if using long absolute addresses, because DEC $xxxxxx doesn't exist.
		DEC !Freeram_JumpCountLeft
	endif

	..TypeOfJump
if !SubsequentJumpMode == 0
;can change to airjump or airspin at will
	LDA $16				;\Go to normal jump if B is pressed.
	BMI ...NormalJump		;/
	LDA $18				;\Go to spinjump if A is pressed.
	BPL ..Return			;/
elseif !SubsequentJumpMode == 1
;only perform the same jump (pressing A if jumping won't change to airspin and will continue airjumping)
	LDA $140D|!addr
	BEQ ...NormalJump
endif

;don't need airspins with !SubsequentJumpMode set to 2
if !SubsequentJumpMode != 2
	...Spinjump
	LDA #$01			;\Switch to spinjump
	STA $140D|!addr			;/
	LDA #!SJumpYSpeed		;\Spinjump up
	STA $7D				;/
	LDA #!SpinJumpSFX		;\SFX
	STA !SpinJumpBank|!addr		;/
	BRA ..BothJumps
endif

	...NormalJump
	STZ $140D|!addr			;>Switch to normal jump
	LDA #!NJumpYSpeed		;\Jump up
	STA $7D				;/
	LDA #!NormJumpSFX		;\SFX
	STA !NormJumpBank|!addr		;/

	..BothJumps
	LDA #$0B			;\Jump pose (replaces long jump pose)
	STA $72				;/

if !CountUp
  INC !Freeram_JumpCounter		;affect jump counter also, count up
else
  DEC !Freeram_JumpCounter		;count down
endif

	BRA ..Return			;>In case if you have code below (which is the case).

	..RestoreJumps
if !NumberOfAdditionalJumpsInMidair != 0
	LDA.b #!NumberOfAdditionalJumpsInMidair
	STA !Freeram_JumpCountLeft
endif

if !NumberOfAdditionalJumpsInMidair
  if !CountUp
	STZ !Freeram_JumpCounter	;set counter to 0
  else
        STA !Freeram_JumpCounter	;refresh counter to what we should have
  endif
endif

if !MinimalistDisplay : RTL		;end prematurely

	..Return

;some code from offscreen indicator by Thomas/kaizoman666

    LDA $13D4|!addr			; added by SJC, skp when paused
	BNE .actualreturn			;
	
    REP #$20
    LDA $80					;check if player's offscreen vertically, then don't draw the counter (so it won't wrap around)
    CMP #$FFE1					;check if below the screen
    BPL .GoOn
    SEP #$20
    RTL						;offscreen, return

.GoOn
    LDX $19					;or above the screen
    BNE +					;depending on wether the player's grown up or not
    CLC : ADC #$0008
+   CMP #$00D9
    SEP #$20
    BPL .actualreturn

;draw jump counter

.draw
    LDA $7E					;X-pos
    STA $0200|!addr+!oamIndex

    LDA #!YDispSmall				;make it closer to mario if small
    LDX $19					;
    BEQ +					;
    LDA #!YDispBig				;otherwise adjust to big mario size

+   CLC
    ADC $80					;Y-pos
    STA $0201|!addr+!oamIndex

if !NumberOfAdditionalJumpsInMidair
    LDY !Freeram_JumpCounter
    LDA Tiles,y
else
    LDA #!InfinityTile
endif
    STA $0202|!addr+!oamIndex			;tile depending on number of jumps

    LDA #!Prop
    STA $0203|!addr+!oamIndex			;property

    STZ $0420|!addr+(!oamIndex/4)		;8x8

.actualreturn
    RTL