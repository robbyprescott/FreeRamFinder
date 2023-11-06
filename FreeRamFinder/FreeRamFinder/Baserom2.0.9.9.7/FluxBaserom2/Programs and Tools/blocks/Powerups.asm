; These are designed to not give you an item reserve powerup if you already have a powerup,
; but rather to just change your powerup to whatever new powerup block you touch.
; By SJandCharlieTheCat. Uses HammerBro's routines.


!Freeze = 1 ; Change to 0 to skip freeze during powerup animation

;!ItemBoxReserve = 1 ; If you already have the powerup, will place a copy in item reserve

db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

Shared:	 
     LDA #$09					;\Spawn score sprite
	 %SpawnScoreSprite()				;/
	 %PositionScoreSprite()				;>Position the score sprite.     
	 %erase_block()
SharedEnd:	 
	 RTL
MarioCorner:
MarioBody:
MarioHead:
WallFeet:
WallBody:
MarioBelow:
MarioAbove:
MarioSide:
     LDA $1693
     CPY #$00 	
     CMP #$4B ; check Map16 act-as
     BNE Fire
     
	 ;if !ItemBoxReserve = 1
	 LDA $19
     CMP #$01 ; Mushroom
     BEQ Reserve
	 ;endif

	 LDA #$0A        
     STA $1DF9 
	 
	 ;LDA #$01 ; Apparently don't even need this in light of the following
     ;STA $19  ; (In fact, *shouldn't* use them together.
	 if !Freeze = 1
	 LDA #$02				;\ Mushroom animation
	 STA $71				;|
	 LDA #$2F				;|
	 STA $1496				;|
	 STA $9D				;/
	 endif
     BRA Shared
Reserve:
     LDA #$0A   ; mushroom     
     STA $1DF9 
     LDA #$01	;Load #$01 = Mushroom ; #$02 Fire Flower ; #$04 Cape 
     STA $0DC2	;Store to the Item Box
     LDA #$0B	;\ Generic item reserve sound 
     STA $1DFC	;/ plays in addition to powerup sound
     BRA Shared	 ; not SharedEnd
Fire:
     LDA $1693
     CPY #$00 	
     CMP #$4C ; check Map16 act-as   
     BNE Feather
     ;LDA $19
     ;CMP #$03
     ;BEQ End2
	 LDA #$03 ; Flower
     STA $19
	 if !Freeze = 1
     LDA #$0A
     STA $1DF9 
	 LDA #$04				;\Fire flower animation
	 STA $71				;|
	 LDA #$20				;|
	 STA $149B|!addr		;|
	 STA $9D				;|
	 endif
	 BRA Shared
ReserveFire:	 
Feather:
     LDA $1693
     CPY #$00 	
     CMP #$4D ; check Map16 act-as
     BNE Star	 
     ;LDA $19
     ;CMP #$02
     ;BEQ End3
     LDA #$02 ; Feath
     STA $19
	 if !Freeze = 1
	 PHY					;\Puff of smoke when turning into cape mario.
	 JSL $01C5AE				;|
	 PLY					;/
	 endif
     LDA #$0D        ; Sound effect
     STA $1DF9       ; SFX Bank
     BRA Shared 
Star:
     LDA $1693
     CPY #$00 	
     CMP #$4E ; check Map16 act-as
     BNE OneUp	 
     LDA #$0A	;
     STA $1DF9	;Powerup
     LDA #$FF	;Give Mario full star time
     STA $1490	;Make Mario Invincable
     LDA #$05	; Star music, not #$0D
     STA $1DFB	
	 LDA #$09
	 %SpawnScoreSprite()				;/
	 %PositionScoreSprite()				;>Position the score sprite.     
	 %erase_block()
     BRA Return
OneUp: 
	 LDA $1693
     CPY #$00 	
     CMP #$4F ; check Map16 act-as
	 BNE Return
     ;INC $18E4	 ; you don't need any of this if you have LDA #$0D stuff
     ;LDA #$05	; One-up
     ;STA $1DFC
     LDA #$0D					;\Spawn score sprite
	 %SpawnScoreSprite()				;/
	 %PositionScoreSprite()				;>Position the score sprite.     
	 %erase_block()
SpriteV:
SpriteH:
Fireball:
Cape:
Return:
RTL

print "Various powerups, and one-up. I was too lazy to make anything other than the mushroom give you an item reserve backup when you get a secohnd one. (Lemme know and I can tell you how to fix it.) The different powerups are actually all just a single block, set to give you the correct powerup depending on the act-as. Apologies for any jank. If you want to be able to get a ton of one-ups in a row with no delay in the sound, there's an Uber for that: OneUpSoundDelayQueueRemove.asm."