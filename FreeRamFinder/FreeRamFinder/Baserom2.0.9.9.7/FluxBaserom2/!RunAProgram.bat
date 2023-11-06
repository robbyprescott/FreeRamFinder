ECHO OFF
CLS
:MENU
ECHO.
ECHO ....................................................
ECHO . Select the number for an option, then press ENTER.
ECHO ....................................................
ECHO.
ECHO 1 - Run GPS
ECHO 2 - Run Pixi
ECHO 3 - Run UberASM
ECHO 4 - Run AddMusicK
ECHO 5 - Recreate rom from scratch (see instructions first)
ECHO 6 - EXIT
ECHO.
SET /P M=Choose and press ENTER: 
IF %M%==1 GOTO GPS
IF %M%==2 GOTO PIXI
IF %M%==3 GOTO UBER
IF %M%==4 GOTO AMK
IF %M%==5 GOTO RECREATE
IF %M%==6 GOTO EOF
:GPS
call "runGPS.bat" <nul
GOTO MENU
:PIXI
call "runPIXI.bat" <nul
GOTO MENU
:UBER
call "runUberASM.bat" <nul
GOTO MENU
:AMK
call "runAMK.bat" <nul
GOTO MENU
:RECREATE
setlocal
set AREYOUSURE=N
:PROMPT
SET /P AREYOUSURE=Have you read the CustomRomInstructions.txt for recreating the rom and want to proceed, Y/[N]? 
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END
echo 
call "runPIXI.bat" <nul
cd..\
call runAMK.bat <nul
cd..\
cd..\
call runUberASM.bat <nul
call runGPS.bat <nul
pause>nul
:END
GOTO MENU
endlocal
