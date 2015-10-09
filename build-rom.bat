@echo off

::SET ROM FILE NAME HERE::
set rom=demo

echo Assembling ROM...
rgbasm -o%rom%.obj %rom%.asm

echo Linking ROM...
rgblink -n%rom%.sym -o %rom%.gb %rom%.obj

echo Fixing headers...
rgbfix -v %rom%.gb

echo Done.

del %rom%.obj

pause
@echo on