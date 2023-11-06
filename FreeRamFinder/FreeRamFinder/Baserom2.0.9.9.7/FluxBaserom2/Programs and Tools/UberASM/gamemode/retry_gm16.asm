init:
    stz $0D9F
    jsl retry_level_transition_init
    jsl retry_game_over_init
    rtl
