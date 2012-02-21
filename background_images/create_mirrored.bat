@echo off
setlocal

rem create_mirrored.bat
rem Feb-9-2012
rem
rem This batch file uses ImageMagick's convert.exe to create mirrored
rem background images suitable for dual monitors.
rem
rem This is good for a set of scenic backgrounds.  On Windows 7, set the 
rem Picture Position to Tile

rem an optional special effect
rem set DITHER=-channel All -random-threshold 0x100%%

mkdir mirrored 2> nul
mkdir combined 2> nul

rem create a mirrored image
dir *.jpg /b | mawk -F. "{print 'convert '$0' -flop %DITHER% mirrored\\mirrored_'$0}" | cmd

rem append mirrored image to the left of the original image
dir *.jpg /b | grep -v flop | mawk -F. "{print 'convert '$0' mirrored\\mirrored_'$0' +append combined\\combined_'$0}" | cmd

@echo.
@echo.
@echo Please review the .\combined folder for the results.
@echo.

:END
endlocal

