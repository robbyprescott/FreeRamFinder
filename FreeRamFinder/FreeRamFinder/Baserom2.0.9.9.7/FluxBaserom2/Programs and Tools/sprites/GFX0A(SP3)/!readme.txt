Custom Lemmy/Wendy boss v1.0
  By Fernap, based on the disassembly by yoshicookiezeus
------------------------------------------------------------------------------

- This can be inserted into your ROM with Pixi just like any other sprite
  (use the CustomLemmyWendy.json to add it to your list.txt file).
  However, there are quite a few files to keep together, so it might be
  easiest to keep them all in a subfolder under Pixi's sprites/ folder.

- The sprite can be placed in a level anywhere that it's within spawn distance
  of Mario.  It will take care of setting its position automatically based
  on its configuration.  Note that it won't actually despawn until the fight
  is over, even if it moves offscreen.

- There are a lot of possible configuration options.  These can be set in
  CustomLemmyWendyConfig.asm.  More detail is given there about how each
  option works.

- The config file first includes a file with graphics data, either
  LemmyGfx.asm or WendyGfx.asm for the standard Lemmy or Wendy graphics.
  (You can also use your own graphics!  See there for how to do so.)
  To use these, you need to have SP3=0A in Lunar Magic.  If you want
  Yoshi available without glitched graphics, you'll need to move some tiles
  around in GFX0A.bin (or a copy thereof).  His tongue is normally at tiles
  0x166 and 0x176 (which are used for Wendy), and his fireballs are normally
  at tiles 0x104-5/0x114-5 and 0x12b-c/0x13b-c (which are used for Lemmy).
  You'll need to move whichever tiles you need to keep to elsewhere in the
  .bin file and update the corresponding entries in either LemmyGfx.asm
  or WendyGfx.asm -- see there for more information about how to do so.

- If you have the boss configured to end the level upon defeat, there's
  a good chance that overworld music won't be playing when you return
  to it (unless you've already beaten the level, or it happens to have
  one of a few specific translevel numbers).  To always have music playing,
  you can apply the patch titled OverworldMusicFix.asm with asar.  See
  https://www.smwcentral.net/?p=memorymap&game=smw&region=rom&address=048E2E
  for more info (thanks to KevinM for the tip!).

- Questions/problems/comments?  Feel free to let me know!
