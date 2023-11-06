Mode 7 usage instruction
Mode 7 is one of the modes the SNES can be in, and it's triggered when the level header is 09. It allows the Reznors to draw and rotate the Reznor spinning sign, and to draw the bridge.
By default you can't use it with this sprite: I removed the code since it wasted resources, if mode 7 wasn't used, and also it wasn't compatible with PIXI's circle routines.
Now I added it back, but to use it you have to do two things:
    - In "ReznorDefines.asm", set !Mode7 = !true.
    - (If on non-SA1 rom) Copy the file "CircleXY.asm", found in the same folder as this text file, in the "routines" PIXI folder (which already contains files like "CircleX.asm" and "CircleY.asm").
Now you're good to go! The sprite will work as normal even in normal modes.
The easiest way to set up the mode 7 boss fight is to go to a level with the vanilla Reznor fight, set level header to 00 (you'll see a lot of messed up graphics), remove the vanilla Reznors, add how many custom Reznors as you want, set the level header back to 09.
Note that in mode 7 there's not much you can do, a lot of it is hardcoded (always 2 screens, with the bridge and the lava). At least the spinning sign will always be drawn where you set the Reznors to be, and with the same rotation speed. Also you can set !BreakBridge = !true to have the usual bridge breaking effect.
Pay attention when editing the circle position in mode 7, since the max amount of screens is 2 (so the XPosHi shouldn't be higher than $01) and the vertical positioning is always on the top (so the YPosHi should be 00).

NOTE: on SA-1 the fight works, but for some reason the sign rotates in the wrong way. Also, the graphics loaded are wrong (this also happens for vanilla Reznors).
