macro call_library(i)
        PHB
        LDA.b #<i>>>16
        PHA
        PLB
        JSL <i>
        PLB
    endmacro
	
init:
	%call_library(backup_ow_sprites_init)
	rtl