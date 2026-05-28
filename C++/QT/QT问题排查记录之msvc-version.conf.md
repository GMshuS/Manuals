# msvc-version.conf / QMAKE_MSC_VER 问题排查

## 错误信息

```
Project ERROR: msvc-version.conf loaded but QMAKE_MSC_VER isn't set
```

## 背景

Qt 的 `win32-msvc` mkspec 在加载 `msvc-version.conf` 时，要求 `QMAKE_MSC_VER` 必须先被设置。这个变量不是硬编码在某个配置文件里的，而是 qmake 在运行期通过预处理 MSVC 的 `_MSC_VER` 宏**自动检测**得到的。

## 文件位置

| 文件 | 路径 |
|------|------|
| `msvc-version.conf` | `<Qt>/mkspecs/common/msvc-version.conf` |
| `toolchain.prf` | `<Qt>/mkspecs/features/toolchain.prf` |
| `macros.cpp` | `<Qt>/mkspecs/features/data/macros.cpp` |
| `.qmake.stash` | 项目根目录（缓存文件） |

例如 Qt 5.14.2 msvc2017：
```
C:\Qt\Qt5.14.2\5.14.2\msvc2017\mkspecs\common\msvc-version.conf
```

## QMAKE_MSC_VER 的检测机制

### 检测链路

```
toolchain.prf (行 44-81)
  └── isEmpty($${target_prefix}.COMPILER_MACROS) { ... }
        └── msvc { ... }
              └── vars = $$qtVariablesFromMSVC($$QMAKE_CXX)
                    └── 运行 cl -nologo -E macros.cpp 2>NUL
                          └── 预处理 macros.cpp，展开 _MSC_VER 宏
                                └── 输出 QMAKE_MSC_VER = 1916
  └── eval() 加载到 qmake 变量
  └── 缓存到 .qmake.stash
```

### macros.cpp 的内容

```cpp
// <Qt>/mkspecs/features/data/macros.cpp
#ifdef _MSC_VER
QMAKE_MSC_VER = _MSC_VER           // 被 MSVC 展开为 QMAKE_MSC_VER = 1916
QMAKE_MSC_FULL_VER = _MSC_FULL_VER
#endif
```

### 实际执行命令

```
cl -nologo -E ...\mkspecs\features\data\macros.cpp 2>NUL
```

MSVC 预处理后输出（例如 VS2017 15.9）：
```
QMAKE_MSC_VER = 1916
QMAKE_MSC_FULL_VER = 191627049
```

### 缓存

检测结果缓存到 `.qmake.stash`，键名为 `QMAKE_CXX.QMAKE_MSC_VER`，避免每次运行 qmake 都重新检测。

## msvc-version.conf 的作用

根据 `QMAKE_MSC_VER` 的数值设置对应 MSVC 版本的编译选项：

| 范围 | _MSC_VER | VS 版本 | 主要设置 |
|------|----------|---------|---------|
| >1499 | 1500+ | VS2008 (VC9) | `-MP` 多核编译 |
| >1599 | 1600+ | VS2010 (VC10) | MSBUILD 生成器, AVX |
| >1699 | 1700+ | VS2012 (VC11) | C++11 支持 |
| >1799 | 1800+ | VS2013 (VC12) | `-FS`, `-Zc:rvalueCast` |
| >1899 | 1900+ | VS2015 (VC14) | `-Zc:strictStrings` |
| >1909 | 1910+ | **VS2017 (VC14.1)** | `-Zc:referenceBinding`, AVX-512, C++14/17 |
| >1919 | 1920+ | VS2019 (VC14.2) | C++2a |

## 常见原因与解决方案

### 原因 1：失效的 .qmake.stash 缓存

**现象**：首次 qmake 因环境问题检测失败，缓存了空的 `QMAKE_MSC_VER`。后续即使环境正确，也被缓存跳过检测。

**解决方案**：删除 `.qmake.stash`，重新运行 qmake：

```bash
del /f /q .qmake.stash
qmake ... -spec win32-msvc
```

### 原因 2：MSVC 环境未正确初始化

**现象**：`cl` 命令不可用或 PATH 不完整，`qtVariablesFromMSVC` 中 `$$system()` 返回非零退出码，触发 `qtCompilerError()` 错误。

**解决方案**：调用 `vcvarsall.bat` 而不是手动拼凑环境变量：

```bat
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" x86
```

### 原因 3：QMAKE_MSC_VER 作为 qmake 参数传入无效

**现象**：qmake 命令行传入 `QMAKE_MSC_VER=1916` 仍然报错。

**分析**：因为 `toolchain.prf` 在行 44 检查 `isEmpty($${target_prefix}.COMPILER_MACROS)`，这个缓存键如果已有值（即使是空的），就会加载缓存而不是重新检测。传入的参数无法覆盖缓存中的空值。

**解决方案**：必须删除 `.qmake.stash` 再重新运行。

## 批处理脚本实践

完整的 `build_qt_debug.bat` 示例：

```bat
@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

REM Setup MSVC environment via vcvarsall.bat
set "VS2017_DIR_1=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community"
set "VS2017_DIR_2=C:\CommonDev\Microsoft Visual Studio\2017\Community"

if exist "%VS2017_DIR_1%\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VS2017_DIR=%VS2017_DIR_1%"
) else if exist "%VS2017_DIR_2%\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VS2017_DIR=%VS2017_DIR_2%"
) else (
    echo [ERROR] vcvarsall.bat not found.
    exit /b 1
)

echo === Setting up MSVC 2017 x86 environment ===
call "%VS2017_DIR%\VC\Auxiliary\Build\vcvarsall.bat" x86

echo === Environment OK ===
cl 2>&1 | findstr "Microsoft"

echo === Running qmake (debug) ===
cd /d D:\Git\ClientSession-Qt-master
C:\Qt\Qt5.14.2\5.14.2\msvc2017\bin\qmake.exe ClientSession.pro -r -spec win32-msvc "CONFIG+=debug" QMAKE_MSC_VER=1916
if errorlevel 1 exit /b 1

echo === Running jom (debug) ===
C:\Qt\Qt5.14.2\Tools\QtCreator\bin\jom.exe -j4 -f Makefile.Debug
if errorlevel 1 exit /b 1

echo === Debug Build SUCCESS ===
```

## 版本号对照表

| 编译器版本 | _MSC_VER | QMAKE_MSC_VER | 对应 VS |
|-----------|---------|---------------|--------|
| MSVC++ 14.0 | 1900 | 1900 | VS2015 |
| MSVC++ 14.1 | 1910 | 1910 | VS2017 15.0 |
| MSVC++ 14.11 | 1911 | 1911 | VS2017 15.3 |
| MSVC++ 14.12 | 1912 | 1912 | VS2017 15.5 |
| MSVC++ 14.13 | 1913 | 1913 | VS2017 15.6 |
| MSVC++ 14.14 | 1914 | 1914 | VS2017 15.7 |
| MSVC++ 14.15 | 1915 | 1915 | VS2017 15.8 |
| MSVC++ 14.16 | **1916** | **1916** | **VS2017 15.9** |
| MSVC++ 14.20 | 1920 | 1920 | VS2019 16.0 |
| MSVC++ 14.30 | 1930 | 1930 | VS2022 17.0 |
