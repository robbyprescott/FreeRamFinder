280	0	Solid for sprites, but allows Mario to pass. Fireballs won't pass.
281	0	Solid for Mario, but allows sprites to pass. If you don't like the look of the normal yellow sprite-pass block, I've also included a block graphic in the same style as the red light switch, set to act the same as this (see 6C8).
284	0	Kills all sprites which interact with blocks - even if you're riding Yoshi, and even if Yoshi has a sprite in his mouth. The version at block number 295 will also kill Mario; and the version at 45F will simply be solid for Mario. Note that if you destroy a vanilla spring, it will warp Mario. This is an unavoidable behavior of all sprite killers, unless you apply the included optional patch.
285	0	Solid for Mario, but will be shattered by kicked shells and throwblocks. Kicked shells won't bounce back when they hit it, although you can change this in the settings.
286	0	Solid if anything goes right
287	0	Solid if anything goes left
28a	0	Spawns you on Yoshi when touched.
28f	0	InvisibleKaizoBlockNeverReappearsAfterDeath.asm. Use ConditionalMap16 flag 1. See instructions for more.
291	0	Kills Mario instantly, even if on Yoshi.
294	0	Hurts Mario, but allows sprites to pass. By default, it's set so that a vine will eat through the blocks. You can change this, though.
295	0	Kills all sprites which interact with blocks - even if you're riding Yoshi, and even if Yoshi has a sprite in his mouth. The version at block number 295 will also kill Mario; and the version at 45F will simply be solid for Mario. Note that if you destroy a vanilla spring, it will warp Mario. This is an unavoidable behavior of all sprite killers, unless you apply the included optional patch.
297	0	Solid if anything goes up
299	0	A block that acts like a stationary Swooper.
29e	0	A normal solid grab-block, except you don't have to stop and press Y in order to grab it. Instead, you'll automatically pick it up simply if you're HOLDING Y. However, looks like the spawned throwblock also has an infinite timer.
29f	0	Will spawn a throwblock into your hands whenever you grab it (as many times as you want). As the name suggests, if you use it with the ThrowblockSpawnerOnlyAllowsOneThrowblockOnscreen.asm UberASM, it won't allow you to spawn more than one throwblock at a time from these (or allow more than one throwblock anywhere else on screen).
2a0	0	A regular on-off block, solid when the switch is on
2a1	0	A regular on-off block, which only becomes solid when the switch is turned off.
2a2	0	An on-off death block, solid when the switch is on
2a3	0	An on-off death block, solid when the switch is on.
2a4	0	This is one half of a pair of custom on/off switches. Unlike normal switches, after you hit this one, it'll become a brick block and you'll be unable to flip it again, UNTIL the OTHER switch is flipped (and vice versa). Is also set to be activated by Mario fireballs, too, but you can change this.
2a5	0	This is one half of a pair of custom on/off switches. Unlike normal switches, after you hit this one, it'll become a brick block and you'll be unable to flip it again, UNTIL the OTHER switch is flipped (and vice versa). Is also set to be activated by Mario fireballs, too, but you can change this.
2a6	0	A collectible one-use ON/OFF switch.
2a7	0	This block is solid for Mario, but acts like a 1F0 for sprites and fireballs. Fireballs won't bounce on it, and it can be used to immobilize enemies.
2a9	0	A block that acts like a mid-air suspended Spiny. If Yoshi's going to eat it, this will need sprite GFX02 in SP4.
2ac	0	This functions as a true half-tile death block for Mario from below. Should also have half-block solid interaction for sprites, but not extensively tested.
2ad	0	This block is simply erased when Mario touches it. It's used for several purposes in the baserom: a 1F0 that disappears after you touch it; disappearing indicators, etc.
2ae	0	Bounces a moving throwblock.
2b0	0	Question block that spawns a baby Yoshi.
2b1	0	Question block that spawns a key.
2b2	0	Question block that spawns a p-balloon. Requires GFX02 (or 0E) in SP4. (GFX flipped at spawn, though.)
2b3	0	Question block that spawns a blue p-switch.
2b4	0	Question block that spawns a spring.
2b5	0	Question block that spawns an active throwblock.
2b6	0	Works like a normal question mark block, but can set this to spawn any block ABOVE the original block when hit. You can also set the original to turn into something other than a brown used block.
2b7	0	This is like normal water, except it automatically has buoyancy for sprites, without having to enable this in Lunar Magic. Note that some sprites, like the floating spike ball (A4), apparently still require buoyancy to be enabled in Lunar Magic itself.
2b8	0	Question block that spawns a vine always.
2b9	0	A Donut Lift, which will FALL shortly after being stepped on, or not + reset its timer if you step off quickly enough.
2ba	0	Automatically shatters and bounces you up a bit when you touch it from above.
2be	0	A simple wall-jump block
2bf	0	If hit by a magikoopa's magic, will spawn whichever sprite you set it to.
2c0	0	Question block that spawns a shell. Curremtly set to yellow shell.
2c1	0	Question block that spawns a stunned bob-omb. Requires GFX02 in SP4.
2c2	0	Question block that spawns a stunned galoomba.
2c3	0	Question block that spawns a stunned buzzy beetle shell. Requires GFX04 in SP4.
2c4	0	Question block that spawns a stunned mechakoopa. Requires GFX23 in SP3.
2c6	0	Works like a normal question mark block, but can set this to spawn any block ABOVE the original block when hit. You can also set the original to turn into something other than a brown used block. Note that it'll kill Mario if he hits it from below (certainly if act-as is 12F, etc.).
2c8	0	A door toggled by the on/off switch, or whatever other trigger you want. (With an UberASM, you could also set this to appear when all sprites on-screen are destroyed, etc.)
2c9	0	Sprite only triangle, will bounce kicked sprites if they're going rightward
2ca	0	Sprite only triangle, will bounce kicked sprites if they're going rightward
2cb	0	See SpecialBlocks.jpg chart for what all these blocks do.
2cc	0	See SpecialBlocks.jpg chart for what all these blocks do.
2cd	0	See SpecialBlocks.jpg chart for what all these blocks do.
2ce	0	See SpecialBlocks.jpg chart for what all these blocks do.
2cf	0	See SpecialBlocks.jpg chart for what all these blocks do.
2d0	0	Yoshi can't pass through this block, whether you're mounted on him or whether you try to yeet him through the block
2d1	0	This block is only solid for Yoshi or for Mario when he's riding Yoshi.
2d4	0	A noteblock that also bounces sprites up.
2d5	0	A noteblock that can only be bounced on once before poofing. Accurate physics.
2d6	0	Makes the level have ice physics while touching it.
2d9	0	Solid for sprites ONLY (block-interactable sprites) when they go left, but allows right
2da	0	Solid for sprites ONLY (block-interactable sprites) when they go right, but allows left
2db	0	See SpecialBlocks.jpg chart for what all these blocks do.
2dc	0	See SpecialBlocks.jpg chart for what all these blocks do.
2dd	0	See SpecialBlocks.jpg chart for what all these blocks do.
2de	0	See SpecialBlocks.jpg chart for what all these blocks do.
2df	0	See SpecialBlocks.jpg chart for what all these blocks do.
2e0	0	Gives instant p-speed
2e1	0	This stops p-speed if you have it
2e3	0	This block can grow up to 5 tiles downwards when hit from below or the side. Don't use in true vertical levels! If you had planned on doing this, use the tall horizontal level mode to emulate a vertical level instead.
2e4	0	This block can grow up to 5 tiles right when hit from below or the side. Don't use in true vertical levels! If you had planned on doing this, use the tall horizontal level mode to emulate a vertical level instead.
2e7	0	Growing vine block, vine moves downward when hit. Customizable speed.
2e8	0	Growing vine block, vine moves rightward when hit. Customizable speed.
2eb	0	See SpecialBlocks.jpg chart for what all these blocks do.
2ec	0	See SpecialBlocks.jpg chart for what all these blocks do.
2ed	0	See SpecialBlocks.jpg chart for what all these blocks do.
2ee	0	See SpecialBlocks.jpg chart for what all these blocks do.
2ef	0	See SpecialBlocks.jpg chart for what all these blocks do.
2f2	0	This block can grow up to 5 tiles upwards when hit from below or the side. Don't use in true vertical levels! If you had planned on doing this, use the tall horizontal level mode to emulate a vertical level instead.
2f5	0	This block can grow up to 5 tiles left when hit from below or the side. Don't use in true vertical levels! If you had planned on doing this, use the tall horizontal level mode to emulate a vertical level instead.
2f6	0	Growing vine block, vine moves upward when hit. Customizable speed.
2f9	0	Growing vine block, vine moves leftward when hit. Customizable speed.
2fb	0	See SpecialBlocks.jpg chart for what all these blocks do.
2fc	0	See SpecialBlocks.jpg chart for what all these blocks do.
2fd	0	See SpecialBlocks.jpg chart for what all these blocks do.
2fe	0	See SpecialBlocks.jpg chart for what all these blocks do.
2ff	0	See SpecialBlocks.jpg chart for what all these blocks do.
304	0	Speeds UP certain block-interactable sprites (i.e. a kicked shell) to the defined speed.
305	0	Speeds-down certain block-interactable sprites (i.e. a kicked shell) to the defined speed.
309	0	A cement block that can be picked up, carried around, and thrown. It will turn back into the block when thrown against a wall or carried into an enemy, or when the configurable carry timer runs out. Make sure is sprite file 101 is in SP2 for the GFX to display properly.
30b	0	This block is designed so that if you upthrow a sprite like a shell or throwblock at two of these blocks together, the sprite won't get caught between the two and lose its angular momentum, falling straight down. Do NOT place this block such that sprites can be thrown at it horizontally, or else they'll simply pass through it.
312	0	SSP_Tiles/caps/enterable/default/top_vertical_pipe_cap_L.asm
313	0	SSP_Tiles/caps/enterable/default/top_vertical_pipe_cap_R.asm
31a	0	SSP_Tiles/caps/enterable/default/top_vertical_pipe_cap_small.asm
31e	0	SSP_Tiles/caps/exit_only/top_vertical_pipe_cap_L_exit.asm
31f	0	SSP_Tiles/caps/exit_only/top_vertical_pipe_cap_R_exit.asm
32e	0	SSP_Tiles/caps/exit_only/bottom_vertical_pipe_cap_L_exit.asm
32f	0	SSP_Tiles/caps/exit_only/bottom_vertical_pipe_cap_R_exit.asm
331	0	SSP_Tiles/pass_if_in_pipe.asm
33a	0	SSP_Tiles/turn_down-left_small.asm
33b	0	SSP_Tiles/turn_left-up_small.asm
33e	0	SSP_Tiles/caps/exit_only/left_horizontal_pipe_cap_B_exit.asm
33f	0	SSP_Tiles/caps/exit_only/right_horizontal_pipe_cap_B_exit.asm
343	0	SSP_Tiles/turn_down-left.asm
344	0	SSP_Tiles/turn_left-up.asm
348	0	SSP_Tiles/caps/enterable/default/left_horizontal_pipe_cap_small.asm
34a	0	SSP_Tiles/turn_right-down_small.asm
34b	0	SSP_Tiles/turn_up-right_small.asm
34d	0	SSP_Tiles/caps/enterable/default/right_horizontal_pipe_cap_small.asm
350	0	SSP_Tiles/caps/enterable/default/left_horizontal_pipe_cap_B.asm
357	0	SSP_Tiles/caps/enterable/default/right_horizontal_pipe_cap_B.asm
35e	0	SSP_Tiles/caps/exit_only/top_vertical_pipe_cap_small_exit.asm
35f	0	SSP_Tiles/caps/exit_only/bottom_vertical_pipe_cap_small_exit.asm
363	0	SSP_Tiles/turn_right-down.asm
364	0	SSP_Tiles/turn_up-right.asm
36a	0	SSP_Tiles/caps/enterable/default/bottom_vertical_pipe_cap_small.asm
378	0	See SpecialBlocks.jpg chart for what all these blocks do.
379	0	This block will not only change the music to the next song (or a defined song) when you touch it, but if used in conjunction with the ChangeMusicOnRAMTrigger Uber, will KEEP playing the new song after you've changed it, even after death/retry (whereas it normally will revert to the level's main song).
37a	0	Exits level without doing anything when touched. You can set it to trigger exits/events, though.
37b	0	Brings the player back to the title screen when touched.
37c	0	Teleports you to whatever level the screen exit for the current screen is set to.
37d	0	Teleports you to the next level UP when touched. Can be changed to down.
37e	0	See SpecialBlocks.jpg chart for what all these blocks do.
37f	0	See SpecialBlocks.jpg chart for what all these blocks do.
382	0	SSP_Tiles/caps/enterable/default/bottom_vertical_pipe_cap_L.asm
383	0	SSP_Tiles/caps/enterable/default/bottom_vertical_pipe_cap_R.asm
388	0	See SpecialBlocks.jpg chart for what all these blocks do.
389	0	See SpecialBlocks.jpg chart for what all these blocks do.
38a	0	Spawns a specified sprite a few tiles above the block when you touch it. Customizable
38b	0	Silent midway checkpoint.
38c	0	Increments exit counts +1 when touched. See file for more info.
38d	0	See SpecialBlocks.jpg chart for what all these blocks do.
38e	0	See SpecialBlocks.jpg chart for what all these blocks do.
394	0	Gives you two coins. Half-block version, only when you touch coin itself.
395	0	Gives you two coins. Half-block version, only when you touch coin itself.
3a6	0	SSP_Tiles/caps/enterable/enter_horiz_midair/left_horizontal_pipe_cap_B.asm
3a7	0	SSP_Tiles/caps/enterable/enter_horiz_midair/right_horizontal_pipe_cap_B.asm
3a8	0	Two-tile wide invisible kaizo block, left tile.
3a9	0	Two-tile wide invisible kaizo block, right tile.
3aa	0	Left tile of the two-tile wide shatter block. Will be shattered by kicked sprites, Mario below, or big Mario spin-jump from above. Don't use in true vertical levels! If you had planned on doing this, use the tall horizontal level mode to emulate a vertical level instead.
3ab	0	Right tile of the two-tile wide shatter block. Will be shattered by kicked sprites, Mario below, or big Mario spin-jump from above. Don't use in true vertical levels! If you had planned on doing this, use the tall horizontal level mode to emulate a vertical level instead.
3ad	0	This midway teleports you to where the current screen exit is set to take you. There are a couple things you need to do to get this to work. You need to use the TeleportDelay UberASM with this, and ConditionalMap16 flag 3. See instructions.
3b6	0	SSP_Tiles/caps/enterable/enter_horiz_midair/left_horizontal_pipe_cap_small.asm
3b7	0	SSP_Tiles/caps/enterable/enter_horiz_midair/right_horizontal_pipe_cap_small.asm
3d1	0	Various powerups, and one-up. I was too lazy to make anything other than the mushroom give you an item reserve backup when you get a secohnd one. (Lemme know and I can tell you how to fix it.) The different powerups are actually all just a single block, set to give you the correct powerup depending on the act-as. Apologies for any jank. If you want to be able to get a ton of one-ups in a row with no delay in the sound, there's an Uber for that: OneUpSoundDelayQueueRemove.asm.
3d2	0	Various powerups, and one-up. I was too lazy to make anything other than the mushroom give you an item reserve backup when you get a secohnd one. (Lemme know and I can tell you how to fix it.) The different powerups are actually all just a single block, set to give you the correct powerup depending on the act-as. Apologies for any jank. If you want to be able to get a ton of one-ups in a row with no delay in the sound, there's an Uber for that: OneUpSoundDelayQueueRemove.asm.
3d3	0	Various powerups, and one-up. I was too lazy to make anything other than the mushroom give you an item reserve backup when you get a secohnd one. (Lemme know and I can tell you how to fix it.) The different powerups are actually all just a single block, set to give you the correct powerup depending on the act-as. Apologies for any jank. If you want to be able to get a ton of one-ups in a row with no delay in the sound, there's an Uber for that: OneUpSoundDelayQueueRemove.asm.
3d4	0	Various powerups, and one-up. I was too lazy to make anything other than the mushroom give you an item reserve backup when you get a secohnd one. (Lemme know and I can tell you how to fix it.) The different powerups are actually all just a single block, set to give you the correct powerup depending on the act-as. Apologies for any jank. If you want to be able to get a ton of one-ups in a row with no delay in the sound, there's an Uber for that: OneUpSoundDelayQueueRemove.asm.
3d5	0	This will kill any powerups you have, including star power, but without 'hurting' you.
3d6	0	Various powerups, and one-up. I was too lazy to make anything other than the mushroom give you an item reserve backup when you get a secohnd one. (Lemme know and I can tell you how to fix it.) The different powerups are actually all just a single block, set to give you the correct powerup depending on the act-as. Apologies for any jank. If you want to be able to get a ton of one-ups in a row with no delay in the sound, there's an Uber for that: OneUpSoundDelayQueueRemove.asm.
3d7	0	The top of the 1x2 key block.
3d8	0	The top of the 1x3 key block.
3d9	0	Sprites in this block will behave like they're in water, moving and falling slowly. Splash GFX disabled by default. Note that some sprites, like the floating spike ball (A4), apparently still require buoyancy to be enabled in Lunar Magic itself. (Though certain types of buoyancy may actually counteract the effects of this block, at least with certain patches.
3e0	0	A regular on-off block, which is solid when the p-switch is NOT activated
3e1	0	A regular on-off block, which only becomes solid when the p-switch is activated
3e2	0	This block spawns a sprite, automatically carried, with the block erasing itself afterwards. Note that the bobomb and mechakoopa require the correct sprite GFX to display properly.
3e3	0	This block spawns a sprite, automatically carried, with the block erasing itself afterwards. Note that the bobomb and mechakoopa require the correct sprite GFX to display properly.
3e4	0	This block spawns a sprite, automatically carried, with the block erasing itself afterwards. Note that the bobomb and mechakoopa require the correct sprite GFX to display properly.
3e5	0	This block spawns a sprite, automatically carried, with the block erasing itself afterwards. Note that the bobomb and mechakoopa require the correct sprite GFX to display properly.
3e6	0	This block spawns a sprite, automatically carried, with the block erasing itself afterwards. Note that the bobomb and mechakoopa require the correct sprite GFX to display properly.
3e7	0	The bottom of the 1x2 key block.
3e8	0	The middle of the 1x3 key block.
3ed	0	Death block, but will be destroyed by a Mario fireball.
3ee	0	Solid for sprites ONLY (block-interactable sprites) when they go down, but allows up
3f0	0	A block that bounces sprites up, but doesn't affect Mario.
3f1	0	When touched from above, this block shoots the player up into the air a defined height.
3f2	0	This block spawns a sprite, automatically carried, with the block erasing itself afterwards. Note that the bobomb and mechakoopa require the correct sprite GFX to display properly.
3f3	0	This block spawns a sprite, automatically carried, with the block erasing itself afterwards. Note that the bobomb and mechakoopa require the correct sprite GFX to display properly.
3f4	0	This block spawns a sprite, automatically carried, with the block erasing itself afterwards. Note that the bobomb and mechakoopa require the correct sprite GFX to display properly.
3f5	0	This block spawns a sprite, automatically carried, with the block erasing itself afterwards. Note that the bobomb and mechakoopa require the correct sprite GFX to display properly.
3f6	0	A block that shatters when hit by a Thwomp.
3f8	0	The bottom of the 1x3 key block.
3fd	0	When hit by a Mario fireball, will change into an ice block (with ice physics). Can be used to change into any other block, though.
3fe	0	Solid for sprites ONLY (block-interactable sprites) when they go up, but allows down
402	0	An on-off switch which, unlike the normal one, will toggle a different RAM address ($7FC0FC) than the normal $14AF switch.
403	0	An on-off switch which, unlike the normal one, will toggle a different RAM address ($7FC0FC) than the normal $14AF switch.
404	0	An on-off block which only becomes solid when the switch is turned on, but which is triggered by a different switch and RAM address ($7FC0FC) than the normal $14AF switch.
405	0	An on-off block which only becomes solid when the switch is turned off, but which is triggered by a different switch and RAM address ($7FC0FC) than the normal $14AF switch.
407	0	A single-use p-switch. Can't be picked up.
409	0	An on/off switch only activated by sprites. Customizable. (Add check for kicked sprites.)
40a	0	An on/off switch only activated by sprites. Customizable. (Add check for kicked sprites.)
40b	0	A tiny wall ledge that will only let you stand on it as long as you're holding the correct d-pad direction against the wall.
40c	0	A one-way for Mario that only allows him to go up through it, and will kill him if he tries to go down.
40d	0	A one-way for Mario that only allows him to go down through it, and will kill him if he tries to go up.
410	0	Permanently moves the camera leftward (or at least until you use another block to stabilize it). Note that how MUCH the camera is moved to the left actually depends on how long Mario touches these blocks. So if you want the camera to be shifted to the FURTHEST left, one way to do this is to force Mario to quickly pass through a lot of these blocks. (You can also use an Uber I included that will automatically do this at level load.)
411	0	Permanently moves the camera rightward (or at least until you use another block to stabilize it). Note that how MUCH the camera is moved to the right actually depends on how long Mario touches these blocks. So if you want the camera to be shifted to the FURTHEST right, one way to do this is to force Mario to quickly pass through a lot of these blocks. (You can also use an Uber I included that will automatically do this at level load.)
412	0	This forces the camera to follow Mario's upward movement when you pass through it, useful for frame-perfect jumps and other times that the camera doesn't scroll up automaticlly
413	0	Disables vertical camera movement.
414	0	Re-enables vertical camera movement.
415	0	Disables horizontal camera movement.
416	0	Enables horizontal camera movement.
41b	0	A tiny wall ledge that will only let you stand on it as long as you're holding the correct d-pad direction against the wall.
41c	0	A one-way for Mario that only allows him to go right through it, and will kill him if he tries to go left.
41d	0	A one-way for Mario that only allows him to go left through it, and will kill him if he tries to go right.
420	0	Right-moving conveyor. Direction controlled by on/off switch.
42a	0	This block is solid for Mario, but acts like a 1F0 for sprites and fireballs. Fireballs won't bounce on it, and it can be used to immobilize enemies.
430	0	Left-moving conveyor. Direction controlled by on/off switch.
43a	0	This block is solid for Mario, but acts like a 1F0 for sprites and fireballs. Fireballs won't bounce on it, and it can be used to immobilize enemies.
43c	0	A spike with pixel perfect interaction. Unfortunately can't be used as a Mario solid. Set to insta-kill Mario by default, but you can change this.
43d	0	A spike with pixel perfect interaction. Unfortunately can't be used as a Mario solid. Set to insta-kill Mario by default, but you can change this.
43e	0	A spike with pixel perfect interaction. Unfortunately can't be used as a Mario solid. Set to insta-kill Mario by default, but you can change this.
43f	0	A spike with pixel perfect interaction. Unfortunately can't be used as a Mario solid. Set to insta-kill Mario by default, but you can change this.
443	0	The left of the 2x1 key block.
444	0	The right of the 2x1 key block.
446	0	This block can be destroyed from above by Yoshi's ground pound.
454	0	An on/off coin, toggled by the normal on/off switch. (Starts off.)
45e	0	Solid for Mario unless he has the defined number of coins.
45f	0	Kills all sprites which interact with blocks - even if you're riding Yoshi, and even if Yoshi has a sprite in his mouth. The version at block number 295 will also kill Mario; and the version at 45F will simply be solid for Mario. Note that if you destroy a vanilla spring, it will warp Mario. This is an unavoidable behavior of all sprite killers, unless you apply the included optional patch.
470	0	Reuseable blue P-switch. Press it from above to active it. Watch out for a Yoshi glitch. See file for more.
471	0	Reuseable upside-down blue P-switch. Press it from below to active it. Watch out for a Yoshi glitch. See file for more.
472	0	Displays + starts (or stops) the timer when used with various TimerOnly Ubers.
473	0	A block that acts like a stationary Swooper.
475	0	Simple number indicator, though can also be used with Uber in conjunction with statonary shell blocks.
476	0	Simple number indicator, though can also be used with Uber in conjunction with statonary shell blocks.
477	0	Simple number indicator, though can also be used with Uber in conjunction with statonary shell blocks.
478	0	Simple number indicator, though can also be used with Uber in conjunction with statonary shell blocks.
480	0	ORB.
481	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
482	0	Activates the spotlight.
485	0	Kinda jank. Emulates an immobile shell, with a limited number of bounces on each one (see the number above). Can be used with number indicator (though if so must use Uber to actually have indicator change). Side hitbox currently a little too severe, so I've added a define to turn off if you want. (If so, will only kill from below, and act as solid from side). WIP by SJC.
486	0	Kinda jank. Emulates an immobile shell, with a limited number of bounces on each one (see the number above). Can be used with number indicator (though if so must use Uber to actually have indicator change). Side hitbox currently a little too severe, so I've added a define to turn off if you want. (If so, will only kill from below, and act as solid from side). WIP by SJC.
487	0	Kinda jank. Emulates an immobile shell, with a limited number of bounces on each one (see the number above). Can be used with number indicator (though if so must use Uber to actually have indicator change). Side hitbox currently a little too severe, so I've added a define to turn off if you want. (If so, will only kill from below, and act as solid from side). WIP by SJC.
48a	0	You have a limited number of jumps you can do off of this block before it poofs.
48b	0	You have a limited number of jumps you can do off of this block before it poofs.
48c	0	You have a limited number of jumps you can do off of this block before it poofs.
48d	0	You can only jump off this block once before it poofs.
48f	0	A solid mushroom block that can be picked up and thrown, etc. Make sure that sprite file 02 is in SP4 for the GFX to display properly.
494	0	A semi-solid cloud/rope that can be passed through by tapping down, playing a sound effect.
499	0	Spawns you on Yoshi when touched.
4a5	0	This shatter block can't be broken by small Mario, but only big Mario. Further, by default, it's set to actually instantly KILL small Mario if he touches it from above (though you can change this). This is to prevent cheese in the common kaizo setup where you have to spin-jump off of turnblocks as big Mario.
4a9	0	Spawns you on Yoshi when touched.
4aa	0	A turnblock that spins forever after being activated.
4b2	0	A door that you need a key to open.
4b5	0	This block turns shells and koopas touching it into disco shells.
4b9	0	Spawns you on Yoshi when touched.
4ba	0	A normal grab-block, except there will be no timer for the carried sprite to make it disappear after a while. Can also be set to spawn other carryable things.
4c8	0	This sprite-killing block only removes the (Lakitu) cloud if the player touches it while riding it.
4ca	0	This will only be solid for certain sprites, but will allow others to go through. Set the exceptions in the file. (Currently only allows sprites 00 and 01 to pass: naked koopas.)
4cf	0	A Donut Lift, which will RISE shortly after being stepped on, or not + reset its timer if you step off quickly enough.
52b	0	Turns on scrollable music playlist when hit. Works with MusicPlaylist.asm UberASM.
52e	0	Launches the player straight up if jump is pressed. Requires the relevant UberASM.
52f	0	A cannon launches the player down if jump pressed. Requires the relevant UberASM.
531	0	A block that the player will stick to while standing on, being unable to move left or right, and can only escape by jumping.
53e	0	Cancels out Mario's cannon mode, but not instantly.
53f	0	Stops cannon Mario instantly/centered.
545	0	A block that will change a kicked sprite's state from kicked to stationary / carryable.
54e	0	A cannon launches the player left if jump pressed. Requires the relevant UberASM.
54f	0	A cannon launches the player right if jump pressed. Requires the relevant UberASM.
551	0	This is a block that the player and enemies will stick to when they jump into it from below.
552	0	Kills all on-screen sprites, except things like message boxes. Also will need to modify it to kill custom sprites.
5a9	0	A vanilla horizontal exit pipe, except that you can enter it while in midair (you don't need to be standing on anything solid).
5c0	0	Allows for an instant dropoff from a gradual or normal slope, without having to place another tile with a flat top first.
5e0	0	See SpecialBlocks.jpg chart for what all these blocks do.
5e1	0	See SpecialBlocks.jpg chart for what all these blocks do.
5e2	0	See SpecialBlocks.jpg chart for what all these blocks do.
5e3	0	See SpecialBlocks.jpg chart for what all these blocks do.
5e4	0	See SpecialBlocks.jpg chart for what all these blocks do.
5e5	0	See SpecialBlocks.jpg chart for what all these blocks do.
5e6	0	See SpecialBlocks.jpg chart for what all these blocks do.
5e7	0	See SpecialBlocks.jpg chart for what all these blocks do.
5e8	0	This block is simply erased when Mario touches it. It's used for several purposes in the baserom: a 1F0 that disappears after you touch it; disappearing indicators, etc.
5ea	0	Slope that automatically forces Mario to slide. You can set this to disable jumping while sliding on it, too.
5eb	0	Slope that automatically forces Mario to slide. You can set this to disable jumping while sliding on it, too.
5ef	0	On/off switch which can be activated by cape while wall-running. (A patch otherwise disabled this.) Can set to other act-as, too. You can copy the relevant code to other blocks if needed, too.
5f0	0	See SpecialBlocks.jpg chart for what all these blocks do.
5f1	0	See SpecialBlocks.jpg chart for what all these blocks do.
5f2	0	See SpecialBlocks.jpg chart for what all these blocks do.
5f3	0	See SpecialBlocks.jpg chart for what all these blocks do.
5f4	0	See SpecialBlocks.jpg chart for what all these blocks do.
5f5	0	See SpecialBlocks.jpg chart for what all these blocks do.
5f6	0	See SpecialBlocks.jpg chart for what all these blocks do.
5f7	0	See SpecialBlocks.jpg chart for what all these blocks do.
5ff	0	You can set these blocks to any act-as (on first two Map16 pages), and they'll be activated automatically by wall-running on them.
600	0	See SpecialBlocks.jpg chart for what all these blocks do.
601	0	See SpecialBlocks.jpg chart for what all these blocks do.
610	0	See SpecialBlocks.jpg chart for what all these blocks do.
611	0	See SpecialBlocks.jpg chart for what all these blocks do.
61f	0	This block automatically initiates the castle or ghost house intro sequence when Mario's placed on it in a very specific positon on-screen. See the included example levels.
620	0	See SpecialBlocks.jpg chart for what all these blocks do.
621	0	See SpecialBlocks.jpg chart for what all these blocks do.
630	0	See SpecialBlocks.jpg chart for what all these blocks do.
631	0	See SpecialBlocks.jpg chart for what all these blocks do.
640	0	See SpecialBlocks.jpg chart for what all these blocks do.
641	0	See SpecialBlocks.jpg chart for what all these blocks do.
642	0	See SpecialBlocks.jpg chart for what all these blocks do.
643	0	See SpecialBlocks.jpg chart for what all these blocks do.
644	0	See SpecialBlocks.jpg chart for what all these blocks do.
649	0	This functions as a true solid half-tile (ceiling) block for Mario and sprites. Not extensively tested.
650	0	See SpecialBlocks.jpg chart for what all these blocks do.
651	0	See SpecialBlocks.jpg chart for what all these blocks do.
652	0	See SpecialBlocks.jpg chart for what all these blocks do.
653	0	See SpecialBlocks.jpg chart for what all these blocks do.
654	0	See SpecialBlocks.jpg chart for what all these blocks do.
655	0	See SpecialBlocks.jpg chart for what all these blocks do.
659	0	This functions as a true solid half-tile (ground) block for Mario and sprites. Not extensively tested.
660	0	See SpecialBlocks.jpg chart for what all these blocks do.
661	0	See SpecialBlocks.jpg chart for what all these blocks do.
662	0	See SpecialBlocks.jpg chart for what all these blocks do.
663	0	See SpecialBlocks.jpg chart for what all these blocks do.
664	0	See SpecialBlocks.jpg chart for what all these blocks do.
665	0	See SpecialBlocks.jpg chart for what all these blocks do.
670	0	See SpecialBlocks.jpg chart for what all these blocks do.
671	0	See SpecialBlocks.jpg chart for what all these blocks do.
672	0	See SpecialBlocks.jpg chart for what all these blocks do.
673	0	See SpecialBlocks.jpg chart for what all these blocks do.
674	0	See SpecialBlocks.jpg chart for what all these blocks do.
675	0	See SpecialBlocks.jpg chart for what all these blocks do.
678	0	Gives you two coins.
692	0	Powerup for SMALL fire Mario. Use with small fire Mario UberASM, if you want this to only activate when you get it.
696	0	This is probably broken.
699	0	Emulates layer 3 tide pushing you left. Speeds and other options customizable.
6ac	0	Mormal death block, but turns into a coin when a p-switch is active.
6b0	0	One-way block for Mario only, which allows him to go left (but not back right).
6b1	0	One-way block for Mario only, which allows him to go right (but not back left).
6b2	0	Forces you to briefly a drop carried item when touched.
6b7	0	Invisible kaizo block, only activated by kicked sprites.
6ba	0	The left of the 3x1 key block.
6bb	0	The middle of the 3x1 key block.
6bc	0	The right of the 3x1 key block.
6c1	0	One-way block for Mario only, which allows him to go down (but not back up).
6c2	0	Forces you to drop a carried item, and you can't pick it up again.
6c8	0	This was supposed to be the original main block that not only doesn't let Yoshi pass, but forces you to dismount him when you touch it. However, it has a hilarious unintended effect where, when you touch it with Yoshi, you did indeed dismount him, but are also vertically screen-wrapped (kind of similar to the p-switch and sprite killer glitch) and then yeeted to the right at an even greater speed than cannon speed. I kept it because it's actually kind of cool and hilarious.
6dc	0	Can only be unlocked when you have a key in Yoshi's mouth. (This is the top block of a two-block pair.) Don't use in true vertical levels! If you had planned on doing this, use the tall horizontal level mode to emulate a vertical level instead.
6ec	0	Can only be unlocked when you have a key in Yoshi's mouth. (This is the bottom block of a two-block pair.) Don't use in true vertical levels! If you had planned on doing this, use the tall horizontal level mode to emulate a vertical level instead.
10fc	0	The top-left part of a 32x32 switch palace switch. By default this will NOT activate the normal switch palace switch stuff (not even the message). Instead, hitting it will simply press the switch down and activate an arbitrary RAM address ($0E1D), which you can then use for other purposes (including, for example, DelayBeforeRunningCodeTemplate.asm); or you can also set it to activate a specific color switch, too.
10fd	0	The top-right part of a 32x32 switch palace switch. By default this will NOT activate the normal switch palace switch stuff (not even the message). Instead, hitting it will simply press the switch down and activate an arbitrary RAM address ($0E1D), which you can then use for other purposes (including, for example, DelayBeforeRunningCodeTemplate.asm); or you can also set it to activate a specific color switch, too.
2d49	0	Complicated block. See instructions.
2d4a	0	Complicated block. See instructions.
2d4b	0	Complicated block. See instructions.
2d4c	0	Complicated block. See instructions.
2d4d	0	Complicated block. See instructions.
2d4e	0	Complicated block. See instructions.
2d4f	0	Complicated block. See instructions.
2d50	0	Complicated block. See instructions.
2d51	0	Complicated block. See instructions.
2d52	0	Complicated block. See instructions.
2d53	0	Complicated block. See instructions.
2d54	0	Complicated block. See instructions.
2d55	0	Complicated block. See instructions.
2d56	0	Complicated block. See instructions.
2d57	0	Complicated block. See instructions.
2d58	0	Complicated block. See instructions.
2d59	0	Complicated block. See instructions.
2d5a	0	Complicated block. See instructions.
2d5b	0	Complicated block. See instructions.
2d5c	0	Complicated block. See instructions.
2d5d	0	Complicated block. See instructions.
2d5e	0	Complicated block. See instructions.
2d5f	0	Complicated block. See instructions.
2d60	0	Complicated block. See instructions.
2d61	0	Complicated block. See instructions.
2d62	0	Complicated block. See instructions.
2d63	0	Complicated block. See instructions.
2d64	0	Complicated block. See instructions.
2d65	0	Complicated block. See instructions.
2d66	0	Complicated block. See instructions.
2d67	0	Complicated block. See instructions.
2d68	0	Complicated block. See instructions.
2d69	0	Complicated block. See instructions.
7d00	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d01	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d02	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d03	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d04	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d05	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d06	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d07	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d08	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d09	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d0a	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d0b	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d0c	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d0d	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d0e	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d0f	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d10	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d11	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d12	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d13	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d14	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d15	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d16	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d17	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d18	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d19	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d1a	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d1b	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d1c	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d1d	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d1e	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d1f	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d20	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d21	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d22	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d23	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d24	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d25	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d26	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d27	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d28	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d29	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d2a	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d2b	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d2c	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d2d	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d2e	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d2f	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d30	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d31	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d32	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d33	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d34	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d35	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d36	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d37	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d38	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d39	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d3a	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d3b	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d3c	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d3d	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d3e	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d3f	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d40	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d41	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d42	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d43	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d44	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d45	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d46	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d47	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d48	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d49	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d4a	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d4b	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d4c	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d4d	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d4e	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d4f	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d50	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d51	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d52	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d53	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d54	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d55	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d56	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d57	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d58	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d59	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d5a	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d5b	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d5c	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d5d	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d5e	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d5f	0	Must use in conjunction with MessageBoxTranslevel Uber. Set message number in that.
7d65	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d66	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d67	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d68	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d69	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d6a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d6b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d6c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d6d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d6e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d6f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d70	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d71	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d72	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d73	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d74	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d75	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d76	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d77	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d78	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d79	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d7a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d7b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d7c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d7d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d7e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d7f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d80	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d81	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d82	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d83	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d84	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d85	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d86	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d87	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d88	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d89	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d8a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d8b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d8c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d8d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d8e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d8f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d90	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d91	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d92	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d93	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d94	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d95	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d96	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d97	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d98	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d99	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d9a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d9b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d9c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d9d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d9e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7d9f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7da0	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7da1	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7da2	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7da3	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7da4	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7da5	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7da6	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7da7	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7da8	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7da9	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7daa	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dab	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dac	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dad	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dae	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7daf	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7db0	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7db1	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7db2	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7db3	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7db4	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7db5	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7db6	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7db7	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7db8	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7db9	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dba	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dbb	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dbc	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dbd	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dbe	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dbf	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dc0	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dc1	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dc2	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dc3	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dc4	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dc5	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dc6	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dc7	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dc8	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dc9	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dca	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dcb	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dcc	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dcd	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dce	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dcf	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dd0	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dd1	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dd2	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dd3	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dd4	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dd5	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dd6	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dd7	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dd8	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dd9	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dda	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ddb	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ddc	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ddd	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dde	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ddf	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7de0	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7de1	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7de2	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7de3	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7de4	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7de5	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7de6	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7de7	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7de8	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7de9	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dea	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7deb	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dec	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ded	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dee	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7def	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7df0	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7df1	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7df2	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7df3	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7df4	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7df5	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7df6	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7df7	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7df8	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7df9	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dfa	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dfb	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dfc	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dfd	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dfe	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7dff	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e01	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e02	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e03	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e04	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e05	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e06	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e07	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e08	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e09	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e0a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e0b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e0c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e0d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e0e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e0f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e10	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e11	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e12	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e13	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e14	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e15	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e16	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e17	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e18	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e19	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e1a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e1b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e1c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e1d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e1e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e1f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e20	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e21	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e22	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e23	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e24	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e25	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e26	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e27	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e28	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e29	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e2a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e2b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e2c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e2d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e2e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e2f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e30	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e31	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e32	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e33	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e34	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e35	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e36	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e37	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e38	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e39	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e3a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e3b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e3c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e3d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e3e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e3f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e40	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e41	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e42	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e43	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e44	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e45	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e46	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e47	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e48	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e49	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e4a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e4b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e4c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e4d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e4e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e4f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e50	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e51	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e52	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e53	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e54	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e55	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e56	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e57	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e58	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e59	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e5a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e5b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e5c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e5d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e5e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e5f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e65	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e66	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e67	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e68	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e69	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e6a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e6b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e6c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e6d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e6e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e6f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e70	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e71	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e72	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e73	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e74	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e75	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e76	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e77	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e78	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e79	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e7a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e7b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e7c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e7d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e7e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e7f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e80	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e81	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e82	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e83	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e84	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e85	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e86	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e87	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e88	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e89	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e8a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e8b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e8c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e8d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e8e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e8f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e90	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e91	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e92	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e93	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e94	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e95	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e96	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e97	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e98	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e99	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e9a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e9b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e9c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e9d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e9e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7e9f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ea0	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ea1	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ea2	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ea3	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ea4	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ea5	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ea6	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ea7	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ea8	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ea9	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eaa	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eab	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eac	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ead	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eae	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eaf	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eb0	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eb1	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eb2	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eb3	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eb4	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eb5	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eb6	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eb7	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eb8	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eb9	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eba	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ebb	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ebc	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ebd	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ebe	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ebf	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ec0	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ec1	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ec2	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ec3	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ec4	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ec5	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ec6	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ec7	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ec8	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ec9	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eca	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ecb	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ecc	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ecd	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ece	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ecf	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ed0	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ed1	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ed2	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ed3	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ed4	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ed5	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ed6	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ed7	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ed8	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ed9	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eda	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7edb	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7edc	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7edd	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ede	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7edf	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ee0	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ee1	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ee2	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ee3	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ee4	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ee5	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ee6	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ee7	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ee8	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ee9	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eea	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eeb	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eec	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eed	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eee	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eef	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ef0	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ef1	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ef2	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ef3	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ef4	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ef5	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ef6	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ef7	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ef8	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7ef9	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7efa	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7efb	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7efc	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7efd	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7efe	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7eff	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f00	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f01	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f02	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f03	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f04	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f05	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f06	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f07	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f08	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f09	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f0a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f0b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f0c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f0d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f0e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f0f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f10	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f11	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f12	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f13	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f14	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f15	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f16	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f17	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f18	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f19	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f1a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f1b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f1c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f1d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f1e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f1f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f20	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f21	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f22	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f23	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f24	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f25	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f26	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f27	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f28	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f29	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f2a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f2b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f2c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f2d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f2e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f2f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f30	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f31	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f32	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f33	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f34	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f35	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f36	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f37	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f38	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f39	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f3a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f3b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f3c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f3d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f3e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f3f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f40	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f41	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f42	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f43	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f44	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f45	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f46	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f47	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f48	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f49	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f4a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f4b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f4c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f4d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f4e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f4f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f50	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f51	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f52	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f53	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f54	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f55	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f56	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f57	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f58	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f59	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f5a	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f5b	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f5c	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f5d	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f5e	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f5f	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f60	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f61	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f62	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f63	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f64	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f65	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f66	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f67	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
7f68	0	A teleport block, that teleports the player when the Cursor sprite clicks over it.
045		0		This is actually a custom recreation of the vanilla berry. If you eat 10 of them as adult Yoshi, it'll still give you the cloud coin. However, double-eat glitch is disabled by default for this and for everything else, too (but can be re-enabled). This berry also has a couple of possible jank issues that are side effects of some of the custom Yoshi codes in the baserom: if baby Yoshi, adult Yoshi, and berries are all on-screen at the same time, berries can be broken. In certain instances, if Mario touches one of these while baby Yoshi is eating another one, afterwards it can kill the berry animation and then cause visual jank if you try to eat them. (Re-enabling double-eat glitch might fix this.)
046		0		This is actually a custom recreation of the vanilla berry. If you eat 2 of them as adult Yoshi, it'll still give you the cloud coin. However, double-eat glitch is disabled by default for this and for everything else, too (but can be re-enabled). This berry also has a couple of possible jank issues that are side effects of some of the custom Yoshi codes in the baserom: if baby Yoshi, adult Yoshi, and berries are all on-screen at the same time, berries can be broken. In certain instances, if Mario touches one of these while baby Yoshi is eating another one, afterwards it can kill the berry animation and then cause visual jank if you try to eat them. (Re-enabling double-eat glitch might fix this.)
047		0		This is actually a custom recreation of the vanilla berry. If you eat 10 of them as adult Yoshi, it'll still add 20 to the timer. However, double-eat glitch is disabled by default for this and for everything else, too (but can be re-enabled). This berry also has a couple of possible jank issues that are side effects of some of the custom Yoshi codes in the baserom: if baby Yoshi, adult Yoshi, and berries are all on-screen at the same time, berries can be broken. In certain instances, if Mario touches one of these while baby Yoshi is eating another one, afterwards it can kill the berry animation and then cause visual jank if you try to eat them. (Re-enabling double-eat glitch might fix this.)
40E     0       Currently just indicator arrows, but same GFX as actual Mario-shooting barrel things.
42A     0       This is solid for Mario, but acts like one of the horizontal line-guide tiles (93, with the line at the bottom of the tile) for sprites. Useful if you don't want to have to use the spotlight block sprite instead.
43A     0       This is solid for Mario, but acts like one of the horizontal line-guide tiles (92, with the line at the top of the tile) for sprites. Useful if you don't want to have to use the spotlight block sprite instead.
440		0		This is actually a custom recreation of the vanilla berry. If you eat 10 of them as adult Yoshi, it'll still give you the cloud coin. However, double-eat glitch is disabled by default for this and for everything else, too (but can be re-enabled). This berry also has a couple of possible jank issues that are side effects of some of the custom Yoshi codes in the baserom: if baby Yoshi, adult Yoshi, and berries are all on-screen at the same time, berries can be broken. In certain instances, if Mario touches one of these while baby Yoshi is eating another one, afterwards it can kill the berry animation and then cause visual jank if you try to eat them. (Re-enabling double-eat glitch might fix this.)
441		0		This is actually a custom recreation of the vanilla berry. If you eat 2 of them as adult Yoshi, it'll still give you the cloud coin. However, double-eat glitch is disabled by default for this and for everything else, too (but can be re-enabled). This berry also has a couple of possible jank issues that are side effects of some of the custom Yoshi codes in the baserom: if baby Yoshi, adult Yoshi, and berries are all on-screen at the same time, berries can be broken. In certain instances, if Mario touches one of these while baby Yoshi is eating another one, afterwards it can kill the berry animation and then cause visual jank if you try to eat them. (Re-enabling double-eat glitch might fix this.)
442		0		This is actually a custom recreation of the vanilla berry. If you eat 10 of them as adult Yoshi, it'll still add 20 to the timer. However, double-eat glitch is disabled by default for this and for everything else, too (but can be re-enabled). This berry also has a couple of possible jank issues that are side effects of some of the custom Yoshi codes in the baserom: if baby Yoshi, adult Yoshi, and berries are all on-screen at the same time, berries can be broken. In certain instances, if Mario touches one of these while baby Yoshi is eating another one, afterwards it can kill the berry animation and then cause visual jank if you try to eat them. (Re-enabling double-eat glitch might fix this.)
445     0       I haven't finished this yet.
447     0       I haven't finished this yet.
484     0       Not sure if I set this up yet.
495     0       Gives Yoshi wings if you're already on him. Not sure if I set this up yet.
496		0		This kills Yoshi flight.
497		0		Reserved for use with custom recreated layer 3 tide (UberASM), whose direction can be changed upon a trigger.
498		0		Reserved for use with custom recreated layer 3 tide (UberASM), whose direction can be changed upon a trigger.
4AF     0       This is just empty GFX. Use it with a custom no-GFX keyhole sprite, if you need to use the normal keyhole sprite's GFX spot for something else.
53D     0       I haven't finished this yet.
54D     0       I haven't finished this yet.
6AD     0       Currently broken.
6AE     0       Currently broken.
6B4     0       On/off noteblock. I haven't finished this yet.
6B5     0       This is just a normal invisible solid (130) block. This is necessary to allow the rope-activated gates to work.