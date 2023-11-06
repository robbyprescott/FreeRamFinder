Overworld Author Display UberASM by KevinM
This UberASM patch will display a different text on the overworld's border depending on which level Mario is standing on. Typical use case would be to display the level's author for collaboration hacks.

How to insert:
- Merge the included UberASM folder with your current one, overwriting what's in it. (Unless you've added something to gm0D.asm, which you probably haven't.)
- Change !OverworldAuthorNames to 1 in gm0E.asm in UberASM Tool's "gamemode" folder.
- Run UberASM Tool!

How to customize:
- Some options are in the "author_display.asm" file. You can change the text positioning and graphical properties, as well as the free RAM that's used.
- The actual text is in "author_display_config/author_display_names.asm". Each line corresponds to a level, and every line must have the same length. If you need more letters, make sure to increase the length of every line by padding with spaces if needed. In any case, try to use as few letters as possible to avoid wasting space and reduce how many tiles are uploaded to VRAM (for example, if all lines end with a bunch of spaces, it's a good idea to remove them).
