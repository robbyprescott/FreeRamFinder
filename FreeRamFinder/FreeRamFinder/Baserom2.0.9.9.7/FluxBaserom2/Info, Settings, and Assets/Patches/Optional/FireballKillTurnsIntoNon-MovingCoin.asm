; SJC: I made and included a per-level Uber version of this

; Don't patch this is you're patching FireballKillDoesntSpawnCoinAtAll.asm
; https://www.smwcentral.net/?p=section&a=details&id=28895

;This patch makes fireball kills spawn a spinning coin sprite instead of spawning normal sprite $21 (moving coin)
;By RussianMan.

!bank = $800000
!addr = $0000
!D8 = $D8
!E4 = $E4
!14D4 = $14D4
!14E0 = $14E0
!14C8 = $14C8
if read1($00FFD5) == $23
sa1rom
!bank = $000000
!addr = $6000
!D8 = $3216
!E4 = $322C
!14D4 = $3258
!14E0 = $326E
!14C8 = $3242
endif

org $02A124
autoclean JML TurnIntoSpinningCoin

freecode
TurnIntoSpinningCoin:
LDA #$03			;restore sound effect
STA $1DF9|!addr			;

STZ !14C8,x			;the sprite is dead, really dead

SpawnSpinningCoin:
LDY #$03			;all spinning coin sprite slots

.Loop
LDA $17D0|!addr,y		;
BEQ .Spawn			;
DEY				;
BPL .Loop			;

DEC $1865|!addr			;if no slot is free, replace one of them
BPL .UseDisAddr			;

LDA #$03			;
STA $1865|!addr			;

.UseDisAddr
LDY $1865|!addr			;

.Spawn
LDA #$01			;
STA $17D0|!addr,y		;
DEC				;process on layer 1
STA $17E4|!addr,y		;

JSL $05B34A|!bank		;add a single coin

LDA !D8,x			;set position, Y
STA $17D4|!addr,y		;

LDA !14D4,x			;high byte
STA $17E8|!addr,y		;

LDA !E4,x			;set position, X
STA $17E0|!addr,y		;

LDA !14E0,x			;high byte
STA $17EC|!addr,y		;

LDA #$D0			;coin timer
STA $17D8|!addr,y		;
JML $02A143|!bank		;next slot and stuff