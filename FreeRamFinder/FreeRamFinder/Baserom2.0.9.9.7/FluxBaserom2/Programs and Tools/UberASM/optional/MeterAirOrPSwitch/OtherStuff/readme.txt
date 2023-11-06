Generic player-following meter v1.0 by Fernap

(originally requested by RZRider)
-----------------------------------------

- If you need to have a meter and another UberASM together in the same
  level (including a second meter), chances are you're following
  the advice at https://www.smwcentral.net/?p=faq&page=1515827-uberasm .
  However, due to the way UberASM treats the library/ folder, you'll
  need to make a couple adjustments.

    1) In your main UberASM folder, create a new subfolder called
       "include", and put a copy of MeterBase.asm into it.
    2) Leave whatever meter type file you're using (AirMeter.asm or
       PSwitchMeter.asm) in the library/ folder, but change the line
       that says
         incsrc "MeterBase.asm"
       to read
         incsrc "../include/MeterBase.asm"

  Then just add %call_library(AirMeter_init) and %call_library(AirMeter_main)
  like normal (for whichever version you're using).  If you're using
  more than one meter in the same level, you'll also need to make sure
  to change the !ID defines so that different meters in the same
  level have different !ID values.
  
-----------------------------------------

Basic setup:

1) First, you'll need to insert the sprite component with Pixi: copy
   MeterSprite.asm and MeterSprite.json into Pixi's sprites/ folder,
   and then add it to Pixi's list.txt file (keep a note of what sprite number
   you've inserted it as).  Note that you won't directly add the meter
   sprite into any levels with Lunar Magic; the spawning is handled by
   the UberASM component.

2) Next, copy MeterBase.asm into UberASM's level/ folder and edit the first
   line that reads:

      !MeterSpriteNum = $00     ; sprite number inserted as with Pixi

   to match the number you've inserted it as.

3) Also, copy whichever of PSwitchMeter.asm and AirMeter.asm you plan
   to use (or both) into UberASM's level/ folder and add the appropriate
   file to UberASM's list.txt file for the level(s) you're using.
   You can adjust various settings for the different meter types
   in their respective UberASM file -- see there for more information.

4) Finally, you'll need to set up the graphics for the meter sprite.
   This package comes with two sets of tiles that you can use:
   MeterGfxVert.bin and MeterGfxHoriz.bin for a vertical or horizontal
   meter, respectively.  Find some space for the tiles in SP3/4 for your
   level (you can use SP1/2 also if you change the !UseSecondGfxPage
   define in the UberASM file) and place them there.  You'll need
   to edit the MeterTiles: table in this UberASM file so that it's
   using the tiles you've placed them into.  See there for the order to
   specify them.

5) And just remember to to re-run Pixi and UberASM after any changes
   made, and you should be all set up.

Notes:

- Be aware that the meter sprite uses up one sprite slot.

- The meter needs (size + 2) tiles to fully render.  Depending on the size
  setting and your level's sprite memory settings, this can cause issues.
  Try changing your sprite memory setting or consider using the no-more-
  sprite-tile-limits patch if you're having problems (see
  https://www.smwcentral.net/?p=section&a=details&id=24816 ).

- If you need to combine the meter and another UberASM in the same
  level (including if you want to use more than one meter in the
  same level), there are a couple extra steps.  See below for more
  information.

- The MeterTemplate.asm file is there to help if you're planning on
  making your own custom meter (see below for more detail).  You
  can safely remove it if you're not doing this.

--------------------------------------------------------------------------------

Advanced setup:

- If you want to have different options for the same meter type in
  different levels, you'll simply need to keep a separate instance of
  each in your UberASM levels/ folder, with each one inserted as
  appropriate into their respective level(s).

--------------------------------------------------------------------------------

Custom meters:

- To code a custom meter type, you can start from the MeterTemplate.asm
  file, which has all the necessary defines.  You'll need to fill in the
  GetNewValue routine, which updates the current value for the meter.
  There are also two helper routines available (AddValue and SubtractValue,
  defined in MeterBase.asm) that automatically clip their results.  See
  there for usage info.
