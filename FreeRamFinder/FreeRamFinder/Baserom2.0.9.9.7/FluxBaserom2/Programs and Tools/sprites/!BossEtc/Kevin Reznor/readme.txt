Usage:
    - Open "ReznorDefines.asm" (with a better editor than Notepad) and edit the values you want, then insert with PIXI.
    - In the level, insert as many Reznors as you want (max 8). Make sure they'll all spawn at about the same time, otherwise there could be some placement errors if one Reznor spawns after another one has been killed.
    - Sprite Memory should be 0E (also 10, if you use the "no sprite tile limits" patch. WARNING: if you set it to 10, the Reznors won't be placed correctly on the circle if you have more than 4 Reznors. I suggest you to always use 0E).
    - In SA-1, you can use Sprite Memory 0E or 10 (although with 10 there could be some missing tiles once in a while if there are too many Reznors on screen).
    - SP3 should be 25 for the correct graphics to be loaded.
    - You don't need the "Level Ender" sprite for the level to end after you kill all Reznors.
    - It can happen that, when killed, some of the dead Reznor remain floating on the screen. If this is the case, you can avoid it by setting !QuickKill to !true.
    - If you want to insert more Reznors with different defines, copy the 3 files needed in a different folder.

Uses Extra Bit: YES
    - If the extra bit is clear, beating all Reznors will make the level end.
    - If the extra bit is set, beating all Reznors will make a door appear.

Free RAM used:
    - $7C, $0DA1, $13E6 (1 byte each).
    - $0DD4 (1 byte) when !DivideSpeedBy2 is set to 1.
    - $13C8, $15E8, $0D9C (1 byte each) if !MinRadius and !MaxRadius are different.

Changelog:
    v1.0
      - First version.

    v1.1
      - Fixed some bugs (thanks to RussianMan for finding them).
      - Moved the defines in a separate file.
      - Full SA-1 support.
      - Removed the !ReznorCount define: the number of Renzors is computed during the init phase of the sprite, and the correct angles are loaded from a unique table based on this number.
      - Changed extra bit behavior: now it controls the end level type, instead of the rotation direction (since it can be inverted by using a negative !SpeedMultiplier).
      - Changed 0 / 1 to the more fancy !false / !true.
      - Fixed a bug involving retry patch < 2.06 when dying after triggering the end level timer.
      - Replaced the original aiming routine with the one included with PIXI, which is more accurate and saves space, and added a define for the fireball speed.
      - Replaced the original circle routine with the ones included with PIXI.
      - Changed how the position is updated to allow a more flexible position customization (you can now set the absolute 16 bit position instead of just an 8 bit offset). This also fixes a "glitch" that made the Reznors appear in weird positions when the radius was set to very high values.
      - Added !DoubleRadius define to allow huge circles.
      - Changed !DivideSpeedBy2 with !DivideSpeedBy, which allows to set any value from $01 to $FF.
      - Removed the bridge breaking routine call altogether.
      - Removed all the level mode 7 code.
      - Added smoke when you kill a Reznor with !AlsoKillPlatform == !true.

    v1.2
      - Added a palette file that can be imported with LM and that contains the classic Reznor palette.
      - Re-added the bridge breaking routine (it can be chosen if to trigger it and when to do it).
      - Re-added mode 7 code and made it compatible with the new code (via "CircleXY.asm" routine, by Puniry Ping).
      - Some minor code optimizations.
