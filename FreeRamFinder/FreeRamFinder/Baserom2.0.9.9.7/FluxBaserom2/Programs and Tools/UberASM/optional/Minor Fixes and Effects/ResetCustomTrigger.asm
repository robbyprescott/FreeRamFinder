load:
    REP #$20 
    LDA $7FC0FC ; The specified trigger here is Custom 00.
	            ; $7FC0F8 is one-shot
    AND #$FFFE  ; #$03 triggers 00 and 01. #$01 triggers just 00. 
                ; All following #%0000000 format, from right to left. 
                ; For example, 4 slots would be #%00001111, or #$0F. 
                ; #$1F for 5 slots, etc.
    STA $7FC0FC
    SEP #$20
	RTL