@echo off

SET src=%1
SET fld=%2
if "--%2%--" equ "----" (
	SET fld=Debug
)

del %src%.exe %src%.asm 2>nul
echo %fld%\fcc %src%.fcc
%fld%\fcc %src%.fcc > %src%.asm
echo fasm %src%.asm
fasm %src%.asm
