init:
    stz $0D9F
    jsl retry_level_transition_init
    rtl
