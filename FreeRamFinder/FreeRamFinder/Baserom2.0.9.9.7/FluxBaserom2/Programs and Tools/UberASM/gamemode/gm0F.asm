!RAM_PalUpdateFlag = $7FA00B

	macro call_library(i)
        PHB
        LDA.b #<i>>>16
        PHA
        PLB
        JSL <i>
        PLB
    endmacro
	
init:
    jsl retry_fade_to_level_init
	%call_library(backup_ow_sprites_init)
	
main:
    jsl retry_fade_to_level_main
	
	LDA $15E8 ; to keep custom palette through fades when using per-level palettes
	BEQ Return
    LDA #$01			; can't STZ long address
	STA !RAM_PalUpdateFlag
	Return:
    rtl
