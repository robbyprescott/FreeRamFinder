;;; Goal point sphere
org $019C70 : db $C2 : org $07F448 : db $3A                                       ; Tile

org $028D42 : db $6A   ; Water splash frame 1 and 2, both vanilla $68
org $028D43 : db $6A   ; Should free up tiles 68-69, 78-79 in SP1

;;; Broken brick piece
org $028B84 : db $3C : org $028B8C : db $04 : org $029028 : db $00                ; Frame 1
org $028B85 : db $3D : org $028B8D : db $04 : org $029028 : db $00                ; Frame 2
org $028B86 : db $3D : org $028B8E : db $84 : org $029028 : db $00                ; Frame 3
org $028B87 : db $3C : org $028B8F : db $84 : org $029028 : db $00                ; Frame 4

; ^ Need 4 four to fix shard palette. Total. DATA_028B8C: .db $00,$00,$80,$80,$80,$C0,$40,$00
org $028B90
db $84,$C4,$44,$04

org $028D42 : db $6A   ; Frame 1, both vanilla $68
org $028D43 : db $6A   ; Frame 2

; Removed koopa turn around GFX01
; This will free up eight 8x8 tiles in SP2/GFX01: 84-85, 94-95, A4-A5, B4-B5

org $018BCC
    LDA #$00 ; vanilla $02
	
; ^ SJC: but will also need the next, too, which fixes messed up vertical net koopa turnaround frame

org $019C0B 
db $82,$A0 ; vanilla $84,$A4. Alt $82,$A2	
	
;;; Moving coin (haven't modified this yet). You might also have to change $029A5C
org $01C653 : db $E8 : org $07F41F : db $24                                       ; Frame 1
org $01C66D : db $EA : org $07F41F : db $24                                       ; Frame 2
org $01C66E : db $FA : org $07F41F : db $24                                       ; Frame 3
org $01C66F : db $EA : org $07F41F : db $24                                       ; Frame 4
org $029A4F : db $E8 : org $029A54 : db $04 : org $029A5F : db $02                ; Coin from ? block 1. Vanilla org $029A4F : db $E8 and org $029A5F : db $02 
org $029A6E : db $EA : org $029A54 : db $04 : org $029A9F : db $00                ; Coin from ? block 2
org $029A6F : db $FA : org $029A54 : db $04 : org $029A9F : db $00                ; Coin from ? block 3
org $029A70 : db $EA : org $029A54 : db $04 : org $029A9F : db $00                ; Coin from ? block 4

;;; Magikoopa's magic
org $01BD83 : db $6C : org $01BC34 : db $04 : org $01BD92 : db $00                ; Magic (circle), 1. Default $88, GFX page 2 ($05)
org $01BD83 : db $6C : org $01BC35 : db $06 : org $01BD92 : db $00                ; Magic (circle), 2
org $01BD83 : db $6C : org $01BC36 : db $08 : org $01BD92 : db $00                ; Magic (circle), 3
org $01BD83 : db $6C : org $01BC37 : db $0A : org $01BD92 : db $00                ; Magic (circle), 4
org $01BD88 : db $5C : org $01BC34 : db $04 : org $01BD92 : db $00                ; Magic (square), 1. Default $89
org $01BD88 : db $5C : org $01BC35 : db $06 : org $01BD92 : db $00                ; Magic (square), 2
org $01BD88 : db $5C : org $01BC36 : db $08 : org $01BD92 : db $00                ; Magic (square), 3
org $01BD88 : db $5C : org $01BC37 : db $0A : org $01BD92 : db $00                ; Magic (square), 4
org $01BD8D : db $6D : org $01BC34 : db $04 : org $01BD92 : db $00                ; Magic (triangle), 1. Default $98
org $01BD8D : db $6D : org $01BC35 : db $06 : org $01BD92 : db $00                ; Magic (triangle), 2
org $01BD8D : db $6D : org $01BC36 : db $08 : org $01BD92 : db $00                ; Magic (triangle), 3
org $01BD8D : db $6D : org $01BC37 : db $0A : org $01BD92 : db $00                ; Magic (triangle), 4

; on/off bounce

org $0291F6     ; Tile number (16x16)
    db $0A      ; $C2 to overwrite cloud coin -- though orb currently there

org $02878E     ; YXPPCCCT properties
    db $00      ; 06 is 00000110. (Palette B)


;;;;;;;;;;;;;;;;;;;;;;;;;


;org $028789 ; YXPPCCCT properties, palette stuff
;db $00	; Turn Block w/ item
;db $03	; Note Block
;db $00	; ?-Block
;db $00	; Side Turn Block
;db $01	; Glass Block
;db $07	; ON/OFF Block
;db $00	; Regular Turn Block
;db $04	; Yellow !-Block
;db $0A	; Green !-Block



; These work

;;;; Coin game cloud
org $02EF2E : db $60 : org $02EF3A : db $34             ; 34 changed from vanilla 30, uses palette A

org $01E251 : db $EB : org $01E25B : db $34 : org $01E263 : db $00                ; Key hole top, vanilla 30 instead of 34
org $01E256 : db $FB : org $01E25B : db $34 : org $01E263 : db $00                ; Key hole bottom


; unmodified next?

;;; Lakitu's cloud. Changing from 20 to 24 in itself does nothing?
org $01E985 : db $66 : org $07F485 : db $20                                       ; Cloud 1
org $01E986 : db $64 : org $07F485 : db $20                                       ; Cloud 2
org $01E987 : db $62 : org $07F485 : db $20                                       ; Cloud 3
org $01E988 : db $60 : org $07F485 : db $20                                       ; Cloud 4
org $01E976 : db $4D : org $01E97B : db $39                                       ; Face



; Monty mole dirt?


; Yoshi egg shard?? (Seems fine when normal spawn from block) https://www.smwcentral.net/?p=viewthread&t=99401&page=1&pid=1513513#p1513513

; Jumpoing out of water is fine


;;;;;;;;;;;;;;;;;;;;;;;;;

; Coin Game coin, use normal coin sprite, thanks Ampersam
org $029D4B : db $E8 : org $029D50 : db $34

; bob-omb star explosion

org $02811E 
db $18 ; vanilla 38 is second GFX page 

org $028114 
db $EF ; bob-omb star explosion tile, now uses general spin jump star thing, vanilla $BC

;falling spiny first and second frame

org $019BD1 : db $84 : org $07F412 : db $09                                       ; Egg 1, 1
org $019BD2 : db $84 : org $07F412 : db $09                                       ; Egg 1, 2
org $019BD3 : db $84 : org $07F412 : db $09                                       ; Egg 1, 3
org $019BD4 : db $84 : org $07F412 : db $09                                       ; Egg 1, 4

org $019BD5 : db $BC  ; vanilla $94 for all
org $019BD6 : db $BC 
org $019BD7 : db $BC 
org $019BD8 : db $BC 

;;; Puff of smoke
org $029745 : db $08                ; Frame 1, normally all $02 (palette A).
org $029745 : db $08                ; Frame 2
org $029745 : db $08                ; Frame 3
org $029745 : db $08                ; Frame 4
org $029745 : db $08                ; Frame 5
org $029745 : db $08                ; Frame 6
org $029745 : db $08                ; Frame 7

; Tile 12B unbreakable turnblock bounce. Instead of p-switch
; Need fix bounce sprite palette too?

org $0291F4
    db $40 

;;; 1UP
org $02AD59 : db $56 ; normal 56. Originally moved to make way for cluster sprites . 30 is alt
org $02AD6F : db $57 ; normal 57, Right. 31 is alt.

; Net door sprite remap

org $01BBD3
db $05 ; vanilla $09, $00001001 (palette C)

                                       
 
org $01E976   ; Lakitu's cloud smiley face GFX
db $BA ; DD on 1st GFX page, item box empty space. Vanilla $4D (GFX02). BA is also empty on GFX02. 

org $01E97B ; Lakitu smiley
db $39  ; YXPPCCCT,  $38, 1st GFX page


org $019B90
db $CA ; Vanilla CC. No more naked koopaling kicking animation when it flips an upside-shell back 

org $0189ED ;  Makes a sliding blue koopa use normal animation (not that weird vertical thing), freeing up tile $E6 in SP2/GFX01
db $86 ; Vanilla E6

org $019B92
db $86 ; this remaps the little exasperated/crying effect
       ; that sliding koopas do before they're about to get up
	   ; from 4E in SP1 to 86 in SP2

; Translucent block (12C)

org $0291F5
    db $E6    ; Tile number, normal EA on second GFX page

org $02878D
    db $00    ; first GFX page, 01 is second (GFX02 in SP4). Uses Mario palette row

;=================================;
; Note bounce sprite properties   ;
;=================================;
org $0291F2     ; Tile number (16x16)
    db $22      ; 6B is normal

org $02878A     ; YXPPCCCT properties
    db $02      ; $02 = first page, $03 = second page (normal)

;=================================;
; Yoshi's tongue properties       ;
;=================================;
org $01F488     ; Tile number (8x8) (middle of tongue)
    db $7E      ; Found in GFX 0D

org $01F48C     ; Tile number (8x8) (end of tongue)
    db $7F 

org $01F494     ; YXPPCCCT properties
    db $08      ; $08 = first page, $09 = second page

;=================================;
; Yoshi's throat properties       ;
;=================================;
org $01F08B     ; Tile number (8x8)
    db $38      ; normally found in GFX13

org $01F097     ; YXPPCCCT properties
    db $00      ; $00 = first page, $01 = second page

;=================================;
; Lava splashes properties        ;
;=================================;
org $029E82     ; Tile numbers (8x8)
    db $5B      ; Found in GFX 03
    db $4B
    db $5A
    db $4A

org $029ED5     ; YXPPCCCT properties
    db $04      ; $04 = first page, $05 = second page


; Podoboo lava trail:

org $028F2B    
db $5B,$4B,$5A,$4A               ; tile, default (SP4) db $D7,$C7,$D6,$C6

org $028F76                     ;Lava trail YX
db $04               ; 05, change to 04 for first GFX page


;;; Fishin' Boo (not actually remapped)

org $039160 : db $60 : org $03916A : db $04 : org $03920C : db $02                ; Cloud 1 ; change $03916A to $02, e.g.
org $039161 : db $60 : org $03916B : db $04 : org $03920C : db $02                ; Cloud 2
org $039162 : db $64 : org $03916C : db $0D : org $03920C : db $02                ; Head 1
org $039163 : db $8A : org $03916D : db $09 : org $03920C : db $02                ; Fishing rod
org $039164 : db $60 : org $03916E : db $04 : org $03920C : db $02                ; Cloud 3
org $039165 : db $60 : org $03916F : db $04 : org $03920C : db $02                ; Cloud 4


; I reverted next sections, where I had remapped the chain to use GFX13 / SP3 (6B?), not needing SP4

;;; Connecting "ball"/chain for gray platform, including triple platform
org $02D7AA : db $A2 : org $02D7BF : db $33     ; Remap to 43 (vastle plat)?? vanilla A2 and 33

org $02D844 ; platform itself + ball (restored)
db  $A2,$60,$61,$62 ; vanilla $A2,$60,$61,$62

;;; Rotatng Gray platform on chain
org $02D7AA : db $A2 : org $02D7BF : db $33                                       ; Chain


; Brown platform on chain

org $01C7EA : db $A2 : org $01C7EF : db $31   ; vanilla (restored)
org $01C871 : db $A2 : org $01C876 : db $31                                       ; Chain "ball" 2
org $01C8C7 : db $A2 : org $01C8CC : db $31                                       ; Chain "ball" 3
org $01C8D3 : db $A2 ; this A2 is unrelated to the tile one. There's a mistake in remap chart

;;;;; haven't altered these from vanilla yet:

;;; Brown chained platform ctd

org $01C9BB : db $60 : org $01C8FB : db $31                                       ; Platform 1
org $01C9BC : db $61 : org $01C8FB : db $31                                       ; Platform 2
org $01C9BD : db $61 : org $01C8FB : db $31                                       ; Platform 3
org $01C9BE : db $62 : org $01C8FB : db $31                                       ; Platform 4