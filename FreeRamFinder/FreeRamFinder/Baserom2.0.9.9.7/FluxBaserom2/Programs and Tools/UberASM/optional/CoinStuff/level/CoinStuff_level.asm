macro call_library(i)
        PHB
        LDA.b #<i>>>16
        PHA
        PLB
        JSL <i>
        PLB
    endmacro
	
init:
%call_library(CoinCounter_init)
%call_library(DoThingWhenEnoughCoins_init)
    rtl

main:
%call_library(CoinCounter_main)
%call_library(DoThingWhenEnoughCoins_main)
    rtl
