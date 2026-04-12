@echo off
color 0A
title VS编译环境 - 自动检测
cls

echo ==============================================
echo          VS 开发环境自动配置工具
echo ==============================================
echo.

:: 自动搜索最新版VS环境
set "VSCMD_START_DIR=%CD%"

:: 检测 VS 2017-2022
if exist "%ProgramFiles%\Microsoft Visual Studio\Installer\vswhere.exe" (
    for /f "usebackq tokens=*" %%i in (`"%ProgramFiles%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
        set "VS_PATH=%%i"
    )
    if defined VS_PATH (
        if exist "%VS_PATH%\VC\Auxiliary\Build\vcvars64.bat" (
            echo 检测到 VS 2017/2019/2022
            call "%VS_PATH%\VC\Auxiliary\Build\vcvars64.bat"
            goto :success
        )
    )
)

:: 检测 VS 2015
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" (
    echo 检测到 VS 2015
    call "%ProgramFiles(x86)%\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" amd64
    goto :success
)

:: 检测 VS 2013
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" (
    echo 检测到 VS 2013
    call "%ProgramFiles(x86)%\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" amd64
    goto :success
)

:: 检测 VS 2010（你的版本！）
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" (
    echo 检测到 VS 2010
    call "%ProgramFiles(x86)%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" amd64
    goto :success
)
if exist "%ProgramFiles%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" (
    echo 检测到 VS 2010
    call "%ProgramFiles%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" amd64
    goto :success
)

:: 没找到
echo.
echo 错误：未找到任何版本的 Visual Studio
echo.
pause
exit

:success
cls
echo ==============================================
echo        VS 编译环境配置成功！
echo ==============================================
echo.
echo  可直接使用命令：
echo  cl.exe      - C/C++ 编译器
echo  nmake.exe   - Make 构建工具
echo  link.exe    - 链接器
echo  lib.exe     - 库工具
echo.
echo ==============================================
echo.
cmd /k