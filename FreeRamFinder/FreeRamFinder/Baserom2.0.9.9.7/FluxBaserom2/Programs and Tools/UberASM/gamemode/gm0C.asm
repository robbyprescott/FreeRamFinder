macro call_library(i)
        PHB
        LDA.b #<i>>>16
        PHA
        PLB
        JSL <i>
        PLB
    endmacro
	
	init:
	%call_library(restore_ow_sprites_init)
    jsl retry_load_overworld_init
    ; Add optional Easy No OW, $0109 stuff
    rtl
