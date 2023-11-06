; No reset when kicked

org $01AA0E
db $03 ; Vanilla 05. Change to 03 to prevent Bob-omb, Goomba, Mechakoopa's stun timers from being reset when kicked

;CODE_01AA0B:        B5 C2         LDA RAM_SpriteState,X     
;CODE_01AA0D:        D0 05         BNE SetStunnedTimer       
;CODE_01AA0F:        9E 40 15      STZ.W $1540,X ; table, stun timer            
;CODE_01AA12:        80 19         BRA SetAsStunned          


; see $01AA29, How long to stun the four above sprites for when kicked/hit