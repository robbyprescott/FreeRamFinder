!MakeQuickLevelTeleportGlobal = 0  ; Allows you to quickly warp up or down a level by holding L or R and then pressing the opposite shoulder button, 
                                   ; or to warp to the level hub by holding either and pressing select.
                                   ; Ideal for the hack creation process and testing.
							
!DecreasePauseBufferTime = 1       ; Even if you have these next things enabled globally,
!IncreaseFireballLimit = 1         ; you can still disable them on a per-level basis.
!BabyYoshiFastGrow = 1             ; (Baby Yoshi's growth into big Yoshi will be much quicker.)

!DisplayPauseText = 0              ; If you press L or R when paused, will display the song title (or whatever you want), on a per-level basis.
                                   ; Edit the text in UberASM/library/Text/Text.asm, and set the corresponding song # in LM. 
                                   ; Note that this will kill your layer 3, like a message box. 
								   ; Even if enabled, though, you can still put DisableLRWhenPaused.asm to disable this in an individual level.
								   
!PSwitchBeepsWhenActivated = 1     ; P-switch is silent if 0. However, if so, 
                                   ; you can use PSwitchNormalSoundRestore.asm.							  

!FirstHubPage = $013A              ; Don't  
!LastHubPage = $013C               ; change these two.


macro call_library(i)
        PHB
        LDA.b #<i>>>16
        PHA
        PLB
        JSL <i>
        PLB
    endmacro

load:	
    if !DecreasePauseBufferTime = 1
	LDA #$01
	STA $0EAC
	endif
	
	if !BabyYoshiFastGrow = 0
	LDA #$01
	STA $0E09
	endif
	
	;if !HideScoreSprites = 1
	;LDA #$01
	;STA $0E0A
	;endif
	
    rtl
	
init:
    if !IncreaseFireballLimit
    %call_library(global_fireball_amount_init)
	endif
	%call_library(SlipperyBlocks_init)
	%call_library(double_hit_fix_init)
	%call_library(AllowFramePerfectSpinflyReflight_init)
	
	LDA #$5E ; Allows upside down slopes in other tilesets (0 and 7)
	STA $82
	LDA #$E5
	STA $83
	rtl
 
main:
    LDA $0DE0  
    BEQ ReturnScreenShake
    STZ $1887
ReturnScreenShake:
    JSL ScreenScrollingPipes_main
    JSL retry_in_level_main
	%call_library(PowerupOrPowerdownNoPause_main)
	%call_library(SlipperyBlocks_main)
	%call_library(double_hit_fix_main)
	%call_library(AllowFramePerfectSpinflyReflight_main)
	%call_library(JumpOutOfWaterWithItemSFXFix_main)
	%call_library(ExtendingBlocksTimer_main)
	%call_library(FreezeMarioOrb_main)
	
	if !DisplayPauseText
	LDA $13D4|!addr ; freeze flag
	BEQ .next
	JSL PauseMessage_Paused
	.next:
	endif
	
    if !MakeQuickLevelTeleportGlobal = 0
    REP #$20
    LDA $010B|!addr
    CMP #!FirstHubPage
    BCC FinalHub
    CMP #!LastHubPage+1
    BCS FinalHub
    SEP #$20
    endif
    JSL TeleportToHubOrLevelUponButtonPress_main
    FinalHub:
    if !MakeQuickLevelTeleportGlobal = 0
    SEP #$20
    endif
    
	if !PSwitchBeepsWhenActivated
	LDA $0E30
	BNE NextThing
	LDA $14AD
	CMP #$4A ; check if p-switch timer still above
	BCC Faster
	LDA $14  ; The lower the number, the faster the beep.
	AND #$1F ; #$00, #$01, #$03, #$07, #$0F, #$1F, #$3F, #$7F or #$FF
	BNE NextThing
	LDA #$23  ; Sound of Mario arrive at new tile on OW
	STA $1DFC
	BRA NextThing
   Faster:
	CMP #$1F  ; check if p-switch timer still above 
	BCC NextThing
	LDA $14
	AND #$0F		
	BNE NextThing
	LDA #$23  
	STA $1DFC
	endif
	NextThing:
	RTL

nmi:
    jsl retry_nmi_level
    rtl