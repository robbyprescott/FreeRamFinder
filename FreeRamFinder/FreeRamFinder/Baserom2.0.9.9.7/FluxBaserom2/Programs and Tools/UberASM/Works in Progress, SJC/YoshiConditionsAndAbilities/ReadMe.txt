Nerf Yoshi v1 by JamesD28

This Uberasm allows you to nerf Yoshi, by removing/restricting his various abilities, and/or by setting a timer that will destroy the Yoshi upon hitting zero. This makes it so that Yoshi's abilities/perks have a cost to them, and forces the player to use their Yoshi more strategically. The Uberasm has a wide range of customizable effects, which both affect Yoshis abilities, and the speed the timer decrements, should you choose to set it. Basic notes about each effect/define are commented in the asm, but below you can see detailed descriptions and usage of every effect/mechanic.

If you want to further nerf the availability of Yoshi, you can give Yoshi a coin/life cost to obtain by using the Yoshi Purchase Block. Self-advertisement ftw.

---------- !freeram ----------
This is the main Yoshi timer, which is held at freeram address $7E1487. You may change this to another address, so long as it's freeram that's cleared on reset, titlescreen load and overworld load, but not level load (otherwise some effects may not work properly). It must also be a non-direct-page address (meaning not $7E0000-$7E00FF), or it will most likely crash. If Mario is riding Yoshi and just the "!default" define is enabled, this timer will decrement exactly once every second (at NTSC 60hz). Once this timer hits 0, Yoshi will either be killed or babyfied, and the timer will be reset.

---------- !tick ----------

This is the tick timer, which is held at freeram address $7E1488. Like the !freeram define, this address must be a non-direct-page address. This timer serves as a reference to the !freeram timer, and this is the address that is actually affected by each nerf mechanic. If Mario is riding Yoshi and just the "!default" define is enabled, this timer will decrement once every frame. This timer is set to $3C (60 in decimal), so at NTSC 60hz it hits 0 and decrements the !freeram timer once every second. A subroutine to check if this timer is 0 is run immediately after any time this is decremented. When other nerf mechanics are enabled and their conditions met, this timer gets decremented several times in a single frame. This has the effect of speeding up the rate at which the main !freeram timer gets decremented, and thus sacrifices time the player can spend on Yoshi for using the respective Yoshi mechanics. The amount of extra times this timer is decremented for each effect is predetermined, but if you know what you're doing then you could alter the code to customize this to your liking.

---------- !timer ----------

This is the define where you set how many seconds you want Mario to be able to ride Yoshi for. This value is set in decimal. Since the highest value for a byte is $FF, the maximum value you can give this timer is 255 seconds, or 4 1/4 minutes. This equals just under 400 SMW seconds.

---------- !reset ----------

If this define is set, the main timer will be reset upon bringing Yoshi into a sublevel. This could be good for a "Yoshi rush" type of level, where the timer is set to a low value and the player has to reach each sublevel before Yoshi is killed. It's also useful if you just want to be more lenient with how far Mario can take Yoshi, especially if you've got a longer level split into several rooms.

---------- !enterlevel ----------

If this define is set, Yoshi will instantly be killed/babyfied upon entering a level or sublevel. Useful if you want to have precise control over where Mario can and can't take adult Yoshi.

---------- !drawtimer ----------

This define draws the main Yoshi timer to the status bar. It is drawn between the level timer and the coin count, and is displayed as 2 digit hexadecimal. It may or may not work with any status bar patches, so I recommend disabling this if you use any. I may add a decimal counter or graphical display meter in a future update.

---------- !default ----------

This define enables the default decrement of the timer. When enabled, the tick timer will decrement once every frame while Mario is riding Yoshi. This is the most basic nerf, and with no other effects active it may not have much impact on Yoshi's utility, but it at the very least prevents the player from spending too long on Yoshi. Kaizo levels could possibly benefit from setting only this define and setting the timer to a low value, creating very fast Yoshi setups. If disabled, the "timer" is only decremented when other effects are active, and makes it more of a "health meter" than a timer.

---------- !double ----------

This define halves the rate that the tick timer is decremented for the !default define. When only the !default define is enabled, this has the effect of doubling the time that Mario can stay on Yoshi, and effectively increases the timer cap from 255 to 510 seconds. Note that this does not affect any other defines/effects, so other Yoshi actions will decrement the timer just as fast as if this define was disabled. Therefore, if you have a lot of these other effects activated, this define loses a lot of it's utility. It also doesn't affect the timer value itself, so if !drawtimer is enabled the player will see the original timer value, just decrementing at half the default rate.

---------- !coin ----------

This define regenerates the timer by 1 second whenever a coin is collected. This includes normal coins, dragon coins, coins from eating sprites, and the moving/flying coin sprites. Mario must be riding Yoshi while collecting the coin, or it won't regenerate the timer. This makes finding and collecting coins more rewarding than just for farming lives. The timer will only regenerate up to the timer value it was initially set to.

---------- !regenerate ----------

This define allows Yoshi's timer/health meter to fill back up if he is resting. For this define, resting means that Mario isn't riding Yoshi, and Yoshi isn't running away due to taking damage. In other words, the regenerate conditions are met if the player dismounts Yoshi normally by pressing A. The regeneration rate is 1 "point" every $3F frames, or slightly slower than 1 per second.

---------- !replenish ----------

If this define is enabled, the player can reset the timer to it's initial value in exchange for a life. The value set in this define is what the timer must be less than before the player can replenish it. This define is best used in conjunction with the !drawtimer define, so the player is aware if they need to replenish. Setting the replenish threshold equal to the timer value will allow the player to replenish it at any time, while setting it to a very low value will force the player to pay close attention to the timer if they want to save their Yoshi.

To replenish, the player should hold L, then press R. Holding R then pressing L doesn't work. If the timer was replenished, they'll hear the "correct" SFX. If they didn't have enough lives, they'll hear the "wrong" SFX. If the replenish threshold wasn't reached, they'll hear nothing. They'll also hear nothing if they didn't hold/press the correct buttons... you do plan on telling them how to do this, don't you?

---------- !run ----------

This define causes Yoshi's timer to decrease faster if he's running at his fastest possible speed. I use "fastest possible speed" here and not "P-speed" because this define also considers Yoshi's max speed cap set in the !slow define. See below for details on the !slow define.

---------- !slow ----------

This define restricts how fast the player can run while riding Yoshi. P-speed in the vanilla Super Mario World is +-$2F, so you should set the speed in this define to lower than that or it will have no effect. If the !run define is enabled, reaching the speed cap set here will decrement the timer. The player does not actually need to be running for this define to kick in; if the value is low enough it will even cap walking speeds, making Mario move very slowly on Yoshi. If nerfing Yoshi isn't good enough then why not just annoy the player into ditching him, eh? (Disclaimer: This is not good level design/gameplay advice)

---------- !loseyoshi ----------

This define has several effects depending on the value you set, based around losing Yoshi.

If the define is set to 1, the Yoshi timer will decrease faster when Yoshi runs away from taking damage. This incentivizes the player to remount their Yoshi as soon as possible, instead of letting him run back and forth until the player has an easy opportunity to remount.

If the define is set to 2, Yoshi will not run away and will instead be killed/babyfied instantly upon taking damage. Yoshi already gives Mario a free hitpoint, so killing the Yoshi in exchange makes for a more balanced mechanic.

If you also want to remove the free hitpoint Mario gets then set this define to 3. The Yoshi will be killed/babyfied, and Mario will take damage (or be killed if small). This forces the player to be very tactical with their Yoshi when enemies are nearby.

---------- !air ----------

This define causes Yoshi's timer to decrease faster when he's in the air. This doesn't just refer to flying or jumping, but any time he isn't in contact with the ground. It's worth noting that swimming also counts as being "in the air", so if this define is enabled then swimming will decrease the timer even if the !water define is disabled. This effect incentivizes the player to keep Yoshi on the ground and defeat more enemies, instead of jumping over everything.

---------- !mouth ----------

This define causes the timer to decrease faster if an item is on Yoshi's tongue. This includes both eatable sprites (e.g. Rex) and non-eatables that Yoshi holds in his mouth (e.g. keys). This incentivizes the player to find other ways to defeat enemies instead of using Yoshi to eat them all. Enemies also spend less time on the tongue the closer they are to Yoshi when he grabs them, so it also gives the player a reason to eat enemies when they're close rather than grab them from afar. Keep in mind that eatable enemies award a coin, so if the !coin define is enabled then this effect is somewhat mitigated for eatable enemies.

If you want to set a hard cap on how much Yoshi can eat, you can use KevinM's "Yoshi Disappears After Eating Too Much" UberASM, either in conjunction with this define or as a more precise alternative.

---------- !water ----------

This define has several effects depending on the value you set, based around Yoshi being in water.

If the define is set to 1, the Yoshi timer will decrease faster when Yoshi is in water. Remember that swimming is also treated as in the air, so if the !air define is enabled too then the Yoshi timer will decrease twice as fast when swimming compared to being on ground underwater.

If the define is set to 2, Yoshi will be killed/babyfied instantly upon contact with water. Does Yoshi look like the kind of creature who would swim?

---------- !star ----------

This define has several effects depending on the value you set, based around having star power.

If the define is set to 1, the Yoshi timer will decrease faster when riding Yoshi with star power.

If the define is set to 2, Yoshi will be killed/babyfied instantly if the player attempts to ride/mount him with star power. Other sprites get rekt by it, why should Yoshi be an exception?

---------- !nodoor ----------

A pretty self-explanatory define. If enabled, you won't be able to enter doors while riding Yoshi. What it actually does is disable the "Up" button for 1 frame, so you can still hold up and enter upwards pipes.

---------- !babyfication ----------

As hinted at several times in this readme, there's an alternative to Yoshi being killed when the timer hits 0 or "destroy Yoshi" conditions are met. If this define is enabled, Yoshi will turn into a baby Yoshi instead of dying. The Yoshi colour type is preserved, and the baby will try to spawn with the same speed the adult Yoshi had (for some reason this doesn't seem to work on sa-1). If the player is holding X when the Yoshi is babyfied then Mario will usually grab the baby. However, if the player isn't holding X then Mario has a tendency to kick baby Yoshi in a random direction.

---------- !weak ----------

This define has several effects depending on the value you set, based around Mario's powerup state.

If the define is set to 1, the Yoshi timer will decrease faster when riding Yoshi while Big, Cape or Fire Mario. This incentivizes the player to save their item in the item box for when they don't have a Yoshi, and it somewhat balances the power of having Yoshi with a Big/Cape/Fire Mario.

If the define is set to 2, Yoshi will be killed/babyfied instantly if the player attempts to ride/mount him while Big, Cape or Fire Mario. This incentivizes Mario to lose weight. It also incentivizes the player to reconsider if they want to use/collect a powerup. If this define is set to 2 while the !loseyoshi define is set to 3, it makes riding Yoshi a dangerous affair as Mario could only ride him while small, and losing the Yoshi would also mean death.

---------- MINOR DEFINES ----------

!SFX: The sound effect to play when Yoshi is killed. The default SFX is the "killed by spinjump" SFX.

!BabySFX: The sound effect to play when Yoshi is babyfied. The default SFX is the "Yoshi Spit" SFX.

!SFXBank: The bank that the sound effect values get stored to. The default is $1DF9, but if you change the SFX used then you may or may not also have to change this to $1DFC. The SFX you use have to use the same bank, unless you know how to change the code to make them use different banks.

---------- OTHER ----------

TickCheck: This is the subroutine to check if the tick timer is 0 and the main timer should be decremented. It is always run immediately after decrementing the tick timer.

Zerotimer: This is the code that runs when the Yoshi timer hits 0, but it's also used for defines which immediately kill/babyficate Yoshi under certain conditions.

Smoke: The routine which spawns smoke when Yoshi is killed/babyfied. It's actually just a slight modification of the PIXI "Spawn smoke" routine, so I take no credit for this. Credit goes to JackTheSpades and Tattletale for this.

SpawnBaby: The routine which spawns baby Yoshi if !babyfication is enabled. Again, it's a modification of PIXI's "Spawn sprite" routine.