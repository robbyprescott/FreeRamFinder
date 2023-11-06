Version 2.0.9.9.7

SETTING IT UP:

- Apply FluxBase2.bps to a clean, non-headered rom with FLIPS, making FluxBase2.smc. 
  (It's important that the extension is .smc, not .sfc.)
- Never move FluxBase2.smc from the parent /FluxBaserom2/ directory,
  and don't change this filename until you're ready to send your rom out.
  If you rename it before you're done, programs like UberASM won't recognize it when you run them.)
  
- Now take/make a copy of your original clean vanilla SMW rom, open it in Lunar Magic and add the header.
- Make sure it's named smwOrig.smc, and put it in the /sysLMRestore/ folder. 
  (I usually set that folder to be hidden by default, just to keep things tidy.)

GENERAL INFO:

- When you're ready to run a program like UberASM, AddMusick, or whatever,
- just click on !RunAProgram.bat and follow the instructions.
- You can also run them from their own folders, too; but again, you never have to move the actual rom.

- This baserom was made in Lunar Magic 3.31, so you might want to re-run PIXI
  before anything else if you're using LM 3.33.

- It's hard to exaggerate how many resources are included with this baserom.
- In fact, before you add something new, you might even want to find out if it's ALREADY included. 
  (Especially since a lot of things has been specifically tweaked for the baserom.) 
- Ask on the baserom's Discord for a quick answer.
- Be sure to check /optional/ in the UberASM folder for an absolute ton of stuff.

- Levels 9D - BF are other example or tutorial levels.
- Access them through the OW level hub.
- However, a number of them require additional UberASMs first. (See list.txt.)

- Speaking of, I've personally written a ton of ASM for this. 
- I'm only barely ASM-competent, and have relied on the help of others a ton.
- I've also unabashedly focused more on QUANTITY of ASM over tidiness.
- In other words, a lot of my code is unacceptably messy, or even lazy.
- There's a logical reason for this: this baserom is insanely comprehensive,
  and the messy codes function as tangible placeholders for everything I want in it.
- I think the main downside of my laziness is that I left out a lot of pause and freeze checks, goal tape checks, etc.
- If it's something important, make sure it can't be triggered when paused.
- I (or one of the baserom helpers) will help you try to clean up whatever.

FEATURES AND TROUBLESHOOTING:

- You can always start+select out of a level.
- You can also press L+R+select on the OW to return to the title screen.
- All room transitions are checkpoints by default. You can change this in RetrySettings(Additional), or tables.asm.
- Some other global settings can be changed in /UberASM/gamemode/gm14.asm.
- For example, pause song display is enabled there.
  (See further instructions there.)

- Some GFX and palettes will appear janky in LM (e.g. podoboos), but are fine in-level.

- If you find yourself being warped to unexpected levels after death, 
- this is a side effect of retry and/or its baserom settings. To solve,
- select 'Use separate settings for Midway Entrance,'
- or disable the No Yoshi intro.

- Be patient when running GPS. You have to wait for "all blocks have been applied" before closing.
- For the best experience, set hidden files and folders to NOT be displayed.

THINGS I STILL NEED TO DO:

- Need to finish customizable FluxClean rom template.
- Need to finish (well, actually start) the custom sprite chart w/ pictures and descriptions.
  (For now, though, at least the PIXI list usually specifies which GFX file is needed.)
- Here's a list of vanilla sprites whose behavior can be affected by the extra bit:
  https://docs.google.com/spreadsheets/d/1oi7fucDp0uNwoAWoWvATsvE0rutjfwyxd4IK_H2nB5o/edit#gid=0

INCOMPATIBILITIES:

- You'll need to uninstall the controller read optimization from UberASM global code if you apply the DMA Queue and Block Change Optimize patch.