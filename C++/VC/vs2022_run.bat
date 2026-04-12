@echo off
:: 把下面路径改成你自己的 vcvars64.bat 路径
call "C:\CommonDev\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
echo ========== VS 编译环境已启用 ==========
echo 可直接使用：cl.exe  nmake.exe  lib.exe  link.exe
cd /d %userprofile%\desktop
cmd /k