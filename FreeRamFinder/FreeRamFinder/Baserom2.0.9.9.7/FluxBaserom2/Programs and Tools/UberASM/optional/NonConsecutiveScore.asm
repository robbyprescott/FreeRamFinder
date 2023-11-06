; Setting these will disable consecutive scores for the specific event
!StompKill  = 1
!StarKill   = 1
!DragonCoin = 1
!ShellKill  = 1

main:
if !StompKill
    stz $1697|!addr
endif
if !StarKill
    stz $18D2|!addr
endif
if !DragonCoin
    stz $1420|!addr
endif
if !ShellKill
    ldx.b #!sprite_slots-1
-   lda !14C8,x : cmp #$09 : bcc +
    stz !1626,x
+   dex : bpl -
endif
    rtl
