; Thanks AmperSam

org $00F44B : db $0A ; width of the enterable region of the door (up to 0x10, default 0x08)
org $00F447 : db $05 ; offset the enterable region, which is half of above (default 0x04)