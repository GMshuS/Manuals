@echo off
call "C:\CommonDev\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x64
echo VS2010 x64 编译环境已就绪
echo 可使用 cl.exe nmake.exe link.exe lib.exe
cmd /k