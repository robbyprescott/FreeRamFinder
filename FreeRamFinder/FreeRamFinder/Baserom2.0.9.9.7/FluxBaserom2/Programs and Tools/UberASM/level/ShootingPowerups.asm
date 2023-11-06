; For use with ExGFX113 in SP3,
; and the powerup sprites themselves

;PIXI:

;21 !ShootingPowerups/powerup_hammer.asm
;22 !ShootingPowerups/powerup_boomerang.asm
;23 !ShootingPowerups/powerup_shuriken.asm
;24 !ShootingPowerups/powerup_ice.asm
;25 !ShootingPowerups/powerup_bubble.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Boomerang/Hammer Mario Power code, by ICB. Based on Ice Power by mikeyk
;; (or should I call it "Extended Sprite Shooting Ability for Mario"?)
;;
;; Description: This is a code that allows Big Mario to shoot boomerangs and hammers (any extended sprite really)
;; if their respective values are set (Using PowerUp Sprite).
;;
;; This code can be used in levels (if you want to restrict powers for one or another level) or put as Gamemode 14 code.
;; It must be enabled in levels with Power-up sprite, otherwise it won't work.
;;
;; Requires 3 bytes of freeRAM.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Item box variables
;VanillaDisplay, if enabled, allows custom power display with a sprite tile. for more info on display see CustomItemStatusBar from Library.
;Following defines are mostly related with it's functionality.

	!VanillaDisplay = 0

;ItemDropYPos and ItemDropXPos are Y and X positions  where item is dropped. ItemDropYPos is lower than ItemYPos, which is how it is in vanilla SMW.
;ItemToDrop contains sprite numbers of power-ups themselves.

;drop positions
	!ItemDropXPos = $78
	!ItemDropYPos = $20

;sprite number of dropped item
ItemToDrop:
	db $00,$01,$02,$03,$04

;power-up values for each dropped item (probably unecessary)
;PowerValues:
;db $00,$01,$02,$03,$04

;DropItemButton - button used for the item drop (uses RAM $16)
;InstaDrop - this option makes power-up appear at the player's position just like HammerBrother's "Item Box to Player Position" patch. yeah, it's not actually instant like "Instant Item Box" patch. i'll probably implement that as well.
;DropOnHurt - custom item will instantly drop when you take damage. vanilla stuff. to disable, set to 0.
;everything else should be self-explanatory.

	!DropItemButton = $20

	!InstaDrop = 0
	!DropOnHurt = 1

;Misc and options:
;ExtendedOffset doesn't needs to be edited.
;HowManyOnScreen is a limit of how many projectiles can be on screen.
;E.G. you can't shoot any more if there's already 2 of them on screen, just like mario's fireballs. You can disable it with !LimitedSpawn setting
;Delay is a delay timer between each extended sprite spawn.
;CustomPalettes enables palette for player when having custom power. I limited it to one color change because of potential processor costs. just to be sure.

	!LimitedSpawn = 1

	!CustomPalettes = 0

	!Delay = $0C
	!HowManyOnScreen = $04
	!ExtendedOffset = $13		;From PIXI

;FreeRAM:
;Free RAM byte 1 is "Have custom power" flag and "Extended sprite to shoot" pointer.
;Free RAM byte 2 is "Shooting countdown timer", that doesn't let's you instantly throw projectile after one or another (it won't work with scratch rams)
;Free RAM byte 3 is custom power-up item box value (basically Free RAM byte 1 value for the item box)

	!FreeRam = $0DC4|!addr

;Sound Effect:
;Sound effect that plays when you shoot sprite

	!SoundEf = $06
	!SoundBank = $1DFC|!addr

;Sprites to shoot:
;This depends on your
;+!ExtendedOffset makes so the extended sprite spawn is a custom one. Removing it will make you shoot original sprites!

SpriteToShoot:
	db $00+!ExtendedOffset ; default hammer
	db $01+!ExtendedOffset ; default boomerang
	db $02+!ExtendedOffset ; default shuriken
	db $03+!ExtendedOffset ; default iceball
	db $04+!ExtendedOffset ; default bubble

;X/Y displacement:
;X: Is added to mario's placement to determie where sprite should be spawn. depends on facing.
;XHi: don't touch it, it's high byte thingy, related with offcamera positions. 
;Y: High or low spawn position 

XDisplace:
	db $FC,$04
	
XDisplaceHi:
	db $FF,$00

	!YDisplace = $08

;Extended sprites defines:
;Speeds for hammer and boomerang projectiles. Y and X.
;last one is "time before turning", which is used by boomerang.

XSpeedHammer:
	db $E8,$18

	!YSpeedHammer = $D8

XSpeedBoomerang:
	db $E0,$20

	!YSpeedBoomerang = $EA

	!TurnTimeBoom = $32

XSpeedShuriken:
	db $E0,$20

XSpeedIceball:
	db $FD,$03

XSpeedBubble:
	db $E8,$18

	!BubbleShootSnd = $03
	!BubbleShootBnk = $1DFC|!addr

;Defines down below are something you don't need to edit.
	
	!RAM_IsDucking 	= $73 
	!RAM_OnYoshi	= $187A|!addr

	!RAM_MarioXPos	= $94 
	!RAM_MarioXPosHi = $95 
	!RAM_MarioYPos	= $96 
	!RAM_MarioYPosHi = $97

	!RAM_ExSpriteYHi = $1729|!addr
	!RAM_ExSpriteXHi = $1733|!addr
	!RAM_ExSpriteYLo = $1715|!addr
	!RAM_ExSpriteXLo = $171F|!addr

	!RAM_MarioDir 	= $76 
	!RAM_Climbing	= $74

	!RAM_MariosPose = $13E0|!addr
	!Shooting_Pose = $3F

	!RAM_PoseTimer = $149C|!addr

;if !VanillaDisplay	;check if item box display is enabled (no point in displaying if it's hidden in the first place)
;nmi:
;JML StatusBarItemDisplay
;endif

;incsrc ExPowerSrc/ReserveItemHandle.asm

init:
STZ !FreeRam+1		;you can shoot things already!
RTL			;
    
main:
;JSR ReserveItemHandle	;handle custom reserved item

if !CustomPalettes
  LDA $149B|!addr	;if fire flower animation's playing
  ORA $1490|!addr	;V.1.2 - now also takes star power timer into account.
  BNE .NoCustomPal	;don't show custom palette yet

  LDA !FreeRam		;load custom palette
  BEQ .NoCustomPal	;
  DEC			;
  TAX			;
  JSL ChangePalette	;

.NoCustomPal
endif

LDA !FreeRam		;if doesn't have custom power
BEQ Return		;means player can't shoot things

LDA $19			;\If Mario
;CMP #$01		;|
DEC			;|is Big
BEQ GETPOWER		;|then continue
			;|but if he gets hit or gets another powerup
STZ !FreeRam		;/then reset the powerup RAM to Zero.          
RTL      		;

GETPOWER:
LDA $9D			;check 9D
ORA $13D4|!addr		;and pause flag
ORA $1426|!addr		;yes, it turns out uberASM also runs when message box's message is active
ORA $1493|!addr		;1.2.1 - no goal walking means shooting
BNE Return		;we all love and (don't) know

LDA !FreeRam+1		;if timer before shooting is zero
;CMP #$0D		;remnant from first release
;BCC NoAdjust		;since we have custom delay values, we don't need to compare and it'll decrease itself.

NoAdjust:	
BEQ CanShoot		;means you can shoot!
DEC !FreeRam+1		;otherwise tick

Return:
RTL			;and return

CanShoot:	
LDA !RAM_IsDucking	;If ducking or on yoshi (or both), you can't shoot these things
ORA !RAM_OnYoshi	;
ORA !RAM_Climbing	;and also no if climbing.
BNE Return		;

LDA $16			;\If holding down
AND #$40		;|the button
BEQ Return		;|don't shoot more projectiles
BIT $15			;|But if pressing once
BVC Return		;/fire one projectile

Generate:
If !LimitedSpawn
  STZ $09		;reset "how many sprites can be onscreen" counter before entering the loop
endif

LDY #$07		;

LDX !FreeRam		;which sprite we're spawning?
DEX			;0 means we don't have power, so values 1-FF work

Loop:
If !LimitedSpawn

  LDA SpriteToShoot,x	;if extended sprite is the same as we want to shoot
  CMP $170B|!addr,y	;
  BNE .nah		;oh, it's not? well then

  INC $09		;this is a "how many of those on screen" thing

  LDA $09		;if there are max of those on screen
  CMP #!HowManyOnScreen	;
  BCS Return		;no spam zone
  ;BRA .Next		;V1.2 - i noticed that sometimes you can shoot more than max. that's because we don't actually check all sprite slots in order to determine if we hit maximum of allowed projectiles.

.nah
  DEY			;
  BPL Loop		;

  LDY #$07		;if not max, then spawn new projectile, maybe
endif

.Loop2
LDA $170B|!addr,y	;check sprite slots
BEQ .Yes		;Success! slot is empty

.Next
DEY			;Failure! Try again!
BPL .Loop2		;
RTL			;

.Yes
STX $00			;00 will hold extended sprite to shoot index
LDA SpriteToShoot,x	;that sprite we'll shoot
STA $170B|!addr,y	;

LDA #!SoundEf		;make fireball sound
STA !SoundBank		;

LDA #!Delay		;Shooting delay
STA !FreeRam+1		;

LDA #!Shooting_Pose	;set pose
STA !RAM_MariosPose	;

LDA #$0F		;set time for it
STA !RAM_PoseTimer	;

LDX !RAM_MarioDir	;displace X spawn position, depending on mario's facing

LDA !RAM_MarioXPos	;
CLC : ADC XDisplace,x	;x
STA !RAM_ExSpriteXLo,y	;

LDA !RAM_MarioXPosHi	;x'high byte
ADC XDisplaceHi,x	;
STA !RAM_ExSpriteXHi,y	;

LDA !RAM_MarioYPos	;
CLC : ADC #!YDisplace	;y
STA !RAM_ExSpriteYLo,y	;

LDA !RAM_MarioYPosHi	;
ADC #$00		;Y's High Byte
STA !RAM_ExSpriteYHi,y	;

LDA $13F9|!addr		;set "behind layers" flag, depending on mario's
STA $1779|!addr,y	;originally it was set individually, but having it repeat multiple times is dum

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;"Pointers"
;Those are for setting other variables for extended sprites.
;For example initial speed. Boomerang for example also needs "facing" to be set and so on
;This allows advanced users to make their own power-up based projectiles and set their stuff in here.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LDA $00			;
JSL $0086DF		;execute pointers

ExtendedSpriteSpawnPointer:
dw Hammer
dw Boomerang
dw Shuriken
dw Iceball
dw Bubble

;don't forget to add more pointers if you want more projectiles settings.

Hammer:
LDA #!YSpeedHammer	;
STA $173D|!addr,y	;

LDA XSpeedHammer,x	;
STA $1747|!addr,y	;
RTL			;

Boomerang:
LDA #!YSpeedBoomerang	;speed
STA $173D|!addr,y	;

LDA XSpeedBoomerang,x	;even more speed
STA $1747|!addr,y	;

LDA !RAM_MarioDir	;
;EOR #$01		;
STA $1765|!addr,y	;It's a "Boomerang" facing	
                    
LDA #!TurnTimeBoom	;set timer until change direction
STA $176F|!addr,y	;

LDA #$00		;
STA $0E05|!addr,y	;
RTL			;

Shuriken:
LDA #$00		;reset Y-speed
STA $175B|!addr,y	;
STA $173D|!addr,y	;

LDA XSpeedShuriken,x	;
STA $1747|!addr,y	;
RTL			;

Iceball:
LDA #$30		;
STA $173D|!addr,y	;

LDA #$00		;
STA $175B|!addr,y	;

LDA XSpeedIceball,x	;
STA $1747|!addr,y	;
RTL			;

Bubble:
LDA #$00
STA $175B|!addr,y
STA $1765|!addr,y

LDA #$10
STA $176F|!addr,y

LDA XSpeedBubble,x
STA $1747|!addr,y

LDA #!BubbleShootSnd
STA !BubbleShootBnk
RTL