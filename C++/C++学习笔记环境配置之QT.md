我将为您撰写一份完整的VSCode中配置Qt开发环境的使用手册。让我先搜索一些最新的配置信息和插件推荐，确保内容准确且实用。
基于最新的搜索结果，我为您撰写一份完整的VSCode中配置Qt开发环境使用手册。这份手册将涵盖Qt官方最新推荐的配置方式，包括最新的Qt Extension Pack插件套件的使用。

---

VSCode中配置Qt开发环境完整手册

目录
1. [Qt的安装与配置](#1-qt的安装与配置)
2. [VSCode插件安装](#2-vscode插件安装)
3. [VSCode配置Qt的编译与调试](#3-vscode配置qt的编译与调试)
   - 3.1 CMake+MinGW方式编译
   - 3.2 CMake+MSVC方式编译
   - 3.3 qmake+MSVC+jom方式编译.pro项目
4. [VSCode中Qt实战](#4-vscode中qt实战)

---

# 1. Qt的安装与配置

## 1.1 下载与安装Qt

访问 [Qt官方下载页面](https://www.qt.io/download) 下载Qt在线安装器（Qt Online Installer）。

安装步骤：

1. 运行安装程序，登录Qt账号（或跳过）
2. 选择安装路径（建议不含中文和空格）
3. 关键步骤 - 组件选择：
- MinGW 编译器：MinGW 11.2.0 64-bit（CMake+MinGW 编译用）
- MSVC 编译器：MSVC 2019 64-bit / MSVC 2022 64-bit（CMake+MSVC/qmake 编译用）
- Qt Creator（可选，自带 UI 编辑器）
- CMake（Qt 自带，无需额外安装）
- jom（Qt 自带/自行安装，多核编译工具）

1.2 环境变量配置

将 Qt 工具路径添加到系统 PATH，方便 VSCode 调用：
1. 右键「此电脑」→「属性」→「高级系统设置」→「环境变量」；
2. 在系统变量中编辑 Path，添加以下路径（根据自己的安装目录修改）

```bash
# MinGW 编译器
D:\CommonDev\Qt\Tools\mingw1120_64\bin
# MSVC 依赖（需安装 Visual Studio）
C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build
# Qt 自带 CMake
D:\CommonDev\Qt\Tools\CMake_64\bin
# Qt 自带 jom（多核编译）
D:\CommonDev\Qt\Tools\QtCreator\bin
# Qt 运行库（根据编译器选择，示例为 MSVC 2019）
D:\CommonDev\Qt\6.11.0\msvc2019_64\bin
D:\CommonDev\Qt\6.11.0\mingw_64\bin
```

验证安装：

```bash
qmake --version    # 查看Qt版本
gcc --version      # 查看MinGW版本
cmake --version    # 查看CMake版本
```

---

# 2. VSCode插件安装

## 2.1 推荐插件清单

核心插件（必装）：

| 插件名称 |公司|作用 |
|----------|------|------|
| **C/C++** | Microsoft |C/C++ 代码提示、语法高亮、调试 |
| **CMake** | twxs |CMake 语法支持、项目配置 |
| **CMake Tools** | Microsoft |CMake 编译、构建、调试一体化 |
| **Qt Core** | Qt Group【Qt Extension Pack】 |为套件的其它工具Qt C++、 Qt UI、Qt QML等提供基础功能|
| **Qt C++** | Qt Group【Qt Extension Pack】 |QT C++工程开发辅助工具 |
| **Qt UI** | Qt Group【Qt Extension Pack】 |VSCode 内直接编辑 `.ui` 界面文件 |
| **Qt QML** | Qt Group【Qt Extension Pack】 |QML开发支持，包括语法高亮、代码补全等 |

安装方式：
1. 打开VSCode，按 `Ctrl+Shift+X` 打开扩展面板
2. 搜索 "Qt Extension Pack"，点击安装
3. 该扩展包会自动安装所有依赖插件（CMake Tools、C/C++等）

## 2.2 Qt Extension Pack 功能特性

根据Qt官方最新文档 ，该插件包提供：

- Qt项目创建向导：支持CMake和qmake项目模板
- Qt Designer集成：直接编辑.ui文件
- Qt Linguist支持：翻译文件(.ts)编辑
- 智能代码提示：基于clangd的C++ IntelliSense
- Qt文档查询：Shift+F1快速查看Qt文档
- 多套件支持：自动检测MinGW/MSVC套件

## 2.3 插件通用配置

**配置C/C++**  

**`.vscode/c_cpp_properties.json`**（代码提示）
```json
{
    "configurations": [
        {
            "name": "Win32",
            "includePath": [
                "${workspaceFolder}/**",
                /// QT头文件配置，“配置一”跟“配置二”按需使用
                // 配置一：MSVC头文件
                // "D:/CommonDev/Qt/6.11.0/msvc2022_64/include",
                // "D:/CommonDev/Qt/6.11.0/msvc2022_64/include/QtCore",
                // "D:/CommonDev/Qt/6.11.0/msvc2022_64/include/QtGui",
                // "D:/CommonDev/Qt/6.11.0/msvc2022_64/include/QtWidgets"
                // 配置二：MinGW头文件
                "D:/CommonDev/Qt/6.11.0/mingw_64/include",
                "D:/CommonDev/Qt/6.11.0/mingw_64/include/QtCore",
                "D:/CommonDev/Qt/6.11.0/mingw_64/include/QtGui",
                "D:/CommonDev/Qt/6.11.0/mingw_64/include/QtWidgets",
            ],
            "defines": [
                "_DEBUG",
                "UNICODE",
                "_UNICODE"
            ],
            // 使用MSVC编译器
            "compilerPath": "cl.exe",
            // 使用MinGW编译器
            // "compilerPath": "D:/Qt/Tools/mingw1120_64/bin/g++.exe",
            "cStandard": "c17",
            "cppStandard": "gnu++17",
            "intelliSenseMode": "windows-msvc-x64"
            
        }
    ],
    "version": 4
}
```

**配置CMake Tool**

- 基础配置

进入QT UI配置`Cmake Tools -> Settings`
|配置项|配置值|配置说明|
|---|---|----|
|Cmake: Cmake Path|D:/CommonDev/cmake-3.31.11-windows-x86_64/bin/cmake.exe|CMake的路径|
|Cmake: Build Directory|${workspaceFolder}/build|CMake的默认构建目录|
|Cmake: Generator|MSYS Makefiles|配置CMake的生成器（可选），还可以是：Visual Studio 17 2022、Unix Makefiles、MinGW Makefiles、Ninja等|

- 套件（kits）配置

配置文件`.vscode/cmake-kits.json`，新增MinGW、MSVC编译器套件的配置，配置好以后可以通过`CMake:select a kit`选择CMake要使用的套件。

```json
[
  {
    "name": "MinGW GCC x64 (Qt5.14.2)",
    "compilers": {
      "C": "C:/Qt/Qt5.14.2/Tools/mingw730_64/bin/gcc.exe",
      "CXX": "C:/Qt/Qt5.14.2/Tools/mingw730_64/bin/g++.exe"
    },
    "preferredGenerator": {
      "name": "MinGW Makefiles"
    },
    "environmentVariables": {
      "PATH": "C:/Qt/Qt5.14.2/Tools/mingw730_64/bin;${env:PATH}"
    }
  },
  {
    "name": "MinGW GCC x32 (Qt5.14.2)",
    "compilers": {
      "C": "C:/Qt/Qt5.14.2/Tools/mingw730_32/bin/gcc.exe",
      "CXX": "C:/Qt/Qt5.14.2/Tools/mingw730_32/bin/g++.exe"
    },
    "preferredGenerator": {
      "name": "MinGW Makefiles"
    },
    "environmentVariables": {
      "PATH": "C:/Qt/Qt5.14.2/Tools/mingw730_32/bin;${env:PATH}"
    }
  },
  {
    "name": "VS2017 MSVC x64",
    "compilers": {
      "C": "cl.exe",
      "CXX": "cl.exe"
    },
    "visualStudio": "Visual Studio 15 2017",
    "visualStudioArchitecture": "x64",
    "preferredGenerator": {
      "name": "Visual Studio 15 2017",
      "platform": "x64"
    }
  },
  {
    "name": "VS2017 MSVC x32",
    "visualStudio": "Visual Studio 15 2017",
    "visualStudioArchitecture": "Win32",
    "compilers": {
      "C": "cl.exe",
      "CXX": "cl.exe"
    },
    "preferredGenerator": {
      "name": "Visual Studio 15 2017",
      "platform": "Win32"
    }
  }
]
```

**配置QT Core**  

进入QT UI配置`QT Core -> Settings`
|配置项|配置值|配置说明|
|---|---|----|
|Qt-core: Qt Installation Root|D:/CommonDev/Qt|指定QT安装的根目录|
|Qt-core: Default Project Directory|D:/Projects/Projects4QT|创建QT项目的默认目录（可选）|

**配置QT UI**  

进入QT UI配置`QT UI -> Settings`
|配置项|配置值|配置说明|
|---|---|----|
|Qt-ui: Custom Widgets Designer Exe Path|D:/CommonDev/Qt/6.11.0/msvc2022_64/bin/designer.exe|QT Disigner的路径，这里以msvc编译为例|

## 2.4 配置编译环境

**配置VS编译器**

- **方式一：通过tasks.json执行初始化配置MSVC环境（推荐）**

优点：最干净，最专业的用法
方法：配置`.vscode/tasks.json`，添加环境变量`options->shell`
```json
{
    "version": "2.0.0",
    "inputs": [
        {
            "id": "buildType",
            "type": "pickString",
            "description": "构建类型定义",
            "options": [
                "debug",
                "release"
            ],
            "default": "debug"
        }
    ],
    "tasks": [
        // ====================== 构建任务 ======================
        // 构建64位程序
        {
            "label": "config-qmake-MSVC (x64)",
            "type": "shell",
            // 配置MSVC编译环境
            "options": {
                "shell": {
                    "executable": "cmd.exe",
                    "args": [
                        "/C",
                        "\"C:/CommonDev/Microsoft Visual Studio/2022/Community/VC/Auxiliary/Build/vcvars64.bat\"",
                        "&&"
                    ]
                }
            },
            "command": "C:/Qt/Qt5.14.2/5.14.2/msvc2017_64/bin/qmake",
            "args": [
                "${workspaceFolder}/ProDemo.pro",
                "-spec", "win32-msvc",
                "CONFIG+=${input:buildType}",
                "CONFIG+=qml_${input:buildType}",
                "DESTDIR=${workspaceFolder}/bin/x64/${input:buildType}",
                "OBJECTS_DIR=${workspaceFolder}/build/x64/${input:buildType}/obj",
                "MOC_DIR=${workspaceFolder}/build/x64/${input:buildType}/moc",
                "RCC_DIR=${workspaceFolder}/build/x64/${input:buildType}/rcc",
                "UI_DIR=${workspaceFolder}/build/x64/${input:buildType}/ui"
            ],
            "group": "build"
        },
        {
            "label": "build-jom-MSVC (x64)",
            "type": "shell",
            // 配置MSVC编译环境
            "options": {
                "shell": {
                    "executable": "cmd.exe",
                    "args": [
                        "/C",
                        "\"C:/CommonDev/Microsoft Visual Studio/2022/Community/VC/Auxiliary/Build/vcvars64.bat\"",
                        "&&"
                    ]
                }
            },
            "command": "C:/Qt/Qt5.14.2/Tools/QtCreator/bin/jom",
            "args": ["/J4"],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "dependsOn": "config-qmake-MSVC (x64)",
            "problemMatcher": ["$msCompile"]
        },
        // 构建32位程序
        {
            "label": "config-qmake-MSVC (x32)",
            "type": "shell",
            // 配置MSVC编译环境
            "options": {
                "shell": {
                    "executable": "cmd.exe",
                    "args": [
                        "/C",
                        "\"C:/CommonDev/Microsoft Visual Studio/2022/Community/VC/Auxiliary/Build/vcvars32.bat\"",
                        "&&"
                    ]
                }
            },
            "command": "C:/Qt/Qt5.14.2/5.14.2/msvc2017/bin/qmake",
            "args": [
                "${workspaceFolder}/ProDemo.pro",
                "-spec", "win32-msvc",
                "CONFIG+=${input:buildType}",
                "CONFIG+=qml_${input:buildType}",
                "DESTDIR=${workspaceFolder}/bin/x32/${input:buildType}",
                "OBJECTS_DIR=${workspaceFolder}/build/x32/${input:buildType}/obj",
                "MOC_DIR=${workspaceFolder}/build/x32/${input:buildType}/moc",
                "RCC_DIR=${workspaceFolder}/build/x32/${input:buildType}/rcc",
                "UI_DIR=${workspaceFolder}/build/x32/${input:buildType}/ui"
            ],
            "group": "build"
        },
        {
            "label": "build-jom-MSVC (x32)",
            "type": "shell",
            // 配置MSVC编译环境
            "options": {
                "shell": {
                    "executable": "cmd.exe",
                    "args": [
                        "/C",
                        "\"C:/CommonDev/Microsoft Visual Studio/2022/Community/VC/Auxiliary/Build/vcvars32.bat\"",
                        "&&"
                    ]
                }
            },
            "command": "C:/Qt/Qt5.14.2/Tools/QtCreator/bin/jom",
            "args": ["/J4"],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "dependsOn": "config-qmake-MSVC (x32)",
            "problemMatcher": ["$msCompile"]
        },
    ]
}
```

- **方式二：通过VS开发者命令行启动VSCode**

优点：不需要在tasks.json中添加配置；
缺点：操作繁琐，并且环境容易被VSCode的插件修改；
```bash
# 打开 "x64 Native Tools Command Prompt for VS 2022"【64位编译器】 或者 "x32 Native Tools Command Prompt for VS 2022"【32位编译器】
# 导航到项目目录
cd C:\path\to\your\project
code .
```

- **方式三：通过CMake Kits配置MSVC环境（CMake构建工程时可用）**

优点：不需要在tasks.json中添加配置；
缺点：只有CMake编译套件下可用；
方法：
```bash
# 在VSCode中，按“Ctrl+Shift+P”
# 输入“Select”，选择“CMake:Select a kit”
# 在弹出的列表中选择你要的VS编译器
```

**配置MinGW编译器**

- **方式一：通过在tasks.json的临时环境变量配置MinGW编译器（推荐）**

优点：最干净、最专业的做法。
方法：配置`.vscode/tasks.json`，添加环境变量options->env->Path

```json
{
    "version": "2.0.0",
    "inputs": [
        {
            "id": "buildType",
            "type": "pickString",
            "description": "选择构建类型",
            "options": [
                "Debug",
                "Release"
            ],
            "default": "Debug"
        }
    ],
    "tasks": [
        {
            "label": "Config-CMake-MinGW (x64)",
            "type": "shell",
            // 添加MinGW编译器环境变量
            // 注意：必须要在command之前设置环境变量，否则无效
            "windows": {
                "options": {
                    "env": {
                        "Path": "C:\\Qt\\Qt5.14.2\\Tools\\mingw730_64\\bin;C:\\Qt\\Qt5.14.2\\5.14.2\\mingw73_64\\bin;${env:Path}"
                    }
                }
            },
            "command": "C:/CommonDev/CMake/bin/cmake",
            "args": [
                "-B", "build/x64/${input:buildType}",
                "-G", "MinGW Makefiles",
                // 设置编译类型 Debug Or Release
                "-DCMAKE_BUILD_TYPE=${input:buildType}",
                // 设置C/C++编译器路径
                // "-DCMAKE_C_COMPILER=C:/Qt/Qt5.14.2/Tools/mingw730_64/bin/gcc.exe",
                // "-DCMAKE_CXX_COMPILER=C:/Qt/Qt5.14.2/Tools/mingw730_64/bin/g++.exe",
                // "-DCMAKE_MAKE_PROGRAM=C:/Qt/Qt5.14.2/Tools/mingw730_64/bin/mingw32-make.exe",
                // 设置输出路径
                "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=${workspaceFolder}/bin/x64/${input:buildType}",
                "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=${workspaceFolder}/libs/x64/${input:buildType}",
                "-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=${workspaceFolder}/libs/x64/${input:buildType}",
                // 设置依赖库搜索路径
                "-DCMAKE_PREFIX_PATH=C:/Qt/Qt5.14.2/5.14.2/mingw73_64"
            ],
            "problemMatcher": ["$gcc"],
            "group": "build"
        },
        {
            "label": "Build-CMake-MinGW (x64)",
            "type": "shell",
            // 添加MinGW编译器环境变量
            "windows": {
                "options": {
                    "env": {
                        "Path": "C:\\Qt\\Qt5.14.2\\Tools\\mingw730_64\\bin;C:\\Qt\\Qt5.14.2\\5.14.2\\mingw73_64\\bin;${env:Path}"
                    }
                }
            },
            "command": "C:/CommonDev/CMake/bin/cmake",
            "args": [
                "--build", "build/x64/${input:buildType}",
                "-j4"
            ],
            "dependsOn": "Config-CMake-MinGW (x64)",
            "problemMatcher": ["$gcc"],
            "group": { "kind": "build", "isDefault": true }
        }
}
```

- **方式二：通过CMake Kits配置MinGW编译器**

方法：
```bash
# 在VSCode中，按“Ctrl+Shift+P”
# 输入“Select”，选择“CMake:Select a kit”
# 在弹出的列表中选择你要的MinGW编译器
```
> 1. 在CMake Kits配置之前，你所选的MinGW编译器路径已经添加到PATH环境变量中，否则Gcc/G++会找不到运行的依赖库
> 2. 多个MinGW环境时（比如32位跟64位两个环境），需要设置CMake的CMAKE_C_COMPILER（C编译器）、CMAKE_CXX_COMPILER（C++编译器）、MAKE_MAKE_PROGRAM（make程序）三个编译变量，例如：
> - -DCMAKE_C_COMPILER=C:/Qt/Qt5.14.2/Tools/mingw730_64/bin/gcc.exe
> - -DCMAKE_CXX_COMPILER=C:/Qt/Qt5.14.2/Tools/mingw730_64/bin/g++.exe"
> - -DCMAKE_MAKE_PROGRAM=C:/Qt/Qt5.14.2/Tools/mingw730_64/bin/mingw32-make.exe

---

# 3. VSCode配置Qt的编译与调试

## 3.1 CMake+MinGW方式编译

适用场景：轻量级开发，跨平台兼容性好，无需安装Visual Studio。

### 3.1.1 项目
[CMakeDemo项目](Demos\VSCode学习笔记5配置C++语言(QT)\CMakeDemo\CMakeLists.txt)

### 3.1.2 插件与环境配置

**插件通用配置**
参考[插件通用配置](#23-插件通用配置)

**插件特殊配置**

无

**编译环境配置**

参考[编译环境配置](#24-编译环境配置)

### 3.1.3 配置VSCode任务

配置`.vscode/tasks.json`

```json
{
    "version": "2.0.0",
    "inputs": [
        // 构建类型选择
        {
            "id": "buildType",
            "type": "pickString",
            "description": "选择构建类型",
            "options": [
                "Debug",
                "Release"
            ],
            "default": "Debug"
        }
    ],
    "tasks": [
        // 配置任务，生成构建文件
        {
            "label": "CMake-Debug-MinGW-Config",
            "type": "shell",
            "command": "D:/CommonDev/Qt/Tools/CMake_64/bin/cmake.exe",
            "args": [
                "-B", "build/${input:buildType}",
                // 根据实际情况选择生成器，这里以MSYS编译，
                // 如果使用MinGW则改为"MinGW Makefiles",
                // 如果使用MSVC则改为"Visual Studio 16 2019","Visual Studio 17 2022"等
                "-G", "MSYS Makefiles",
                "-DCMAKE_BUILD_TYPE=${input:buildType}",
                "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=${workspaceFolder}/bin/${input:buildType}",
                "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=${workspaceFolder}/libs/${input:buildType}",
                "-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=${workspaceFolder}/libs/${input:buildType}"
            ],
            "problemMatcher": ["$gcc"],
            "group": "build"
        },
        // 构建任务，编译生成可执行文件
        {
            "label": "CMake-Release-MinGW-build",
            "type": "shell",
            "command": "D:/CommonDev/Qt/Tools/CMake_64/bin/cmake.exe",
            "args": [
                "--build", "build/${input:buildType}",
                "-j4"
            ],
            "problemMatcher": ["$gcc"],
            "dependsOn": "CMake-Debug-MinGW-Config",
            "group": { "kind": "build", "isDefault": true }
        }
    ]
}
```
### 3.1.4 配置调试
配置`.vscode/launch.json`（GDB调试配置）：

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug (MinGW)",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/bin/Debug/CMakeDemo.exe",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "externalConsole": false,
            "MIMode": "gdb",
            "miDebuggerPath": "D:/CommonDev/msys64/mingw64/bin/gdb.exe",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            // "preLaunchTask": "CMake: Build"
        }
    ]
}
```
### 3.1.5 快速部署
使用windeployqt快速部署应用，这个命令会把依赖库拷贝到运行目录下。
windeployqt与编译工具同目录，如：D:\CommonDev\Qt\6.11.0\msvc2022_64\bin
```bat
windeployqt.exe --debug D:\Projects\Projects4QT\ProDemo\bin\x64\Debug\ProDemo.exe
```

### 3.1.6 编译与调试流程
1. 配置项目：按 `F1` → `CMake: Configure`，选择MinGW套件
2. 选择变体：点击底部状态栏的 `[Debug]` 可切换为 `[Release]`
3. 构建项目：按 `F7` 或 `Ctrl+Shift+B` 或点击底部🔨图标
4. 调试运行：按 `F5` 启动调试，或 `Ctrl+F5` 直接运行

---

## 3.2 CMake+MSVC方式编译

适用场景：需要与Windows深度集成，或使用MSVC特定功能。

### 3.2.1 前置要求

- 安装 Visual Studio 2022 生成工具 或完整版VS2022 
- 安装时勾选 "使用C++的桌面开发"
- 确保Qt安装了对应版本的MSVC套件（如MSVC2022 64-bit）

### 3.2.2 新建项目

[MsvcDemo项目](Demos\VSCode学习笔记5配置C++语言(QT)\MsvcDemo\CMakeLists.txt)

### 3.2.2 插件与环境配置

**插件通用配置**
参考[插件通用配置](#23-插件通用配置)

**插件特殊配置**

无

**编译环境配置**

参考[编译环境配置](#24-编译环境配置)

### 3.2.4 配置VSCode任务

配置`.vscode/tasks.json`（MSVC编译）：

```json
{
    "version": "2.0.0",
    "inputs": [
        // 构建类型选择
        {
            "id": "buildType",
            "type": "pickString",
            "description": "选择构建类型",
            "options": [
                "Debug",
                "Release"
            ],
            "default": "Debug"
        }
    ],
    "tasks": [
        // CMake配置任务
        {
            "label": "CMake-MSVC-config",
            "type": "shell",
            // 注意：这里的命令路径需要根据你的实际安装位置进行调整
            "command": "D:/CommonDev/Qt/Tools/CMake_64/bin/cmake.exe",
            "args": [
                "-B", "build/${input:buildType}",
                "-G", "Visual Studio 17 2022",
                "-A", "x64",
                "-DCMAKE_BUILD_TYPE=${input:buildType}",
                // 输出目录配置，确保生成的可执行文件和库文件在指定位置
                "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=${workspaceFolder}/bin",
                "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=${workspaceFolder}/libs",
                "-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=${workspaceFolder}/libs",
                // QT库搜索路径，这一步是关键，确保CMake能找到Qt的MSVC的位置
                "-DCMAKE_PREFIX_PATH=D:/CommonDev/Qt/6.11.0/msvc2022_64/"
            ],
            "problemMatcher": ["$msCompile"],
            "group": { "kind": "build" }
        },
        // CMake构建任务
        {
            "label": "CMake-MSVC-build",
            "type": "shell",
            // 注意：这里的命令路径需要根据你的实际安装位置进行调整
            "command": "D:/CommonDev/Qt/Tools/CMake_64/bin/cmake.exe",
            "args": [
                "--build", "build/${input:buildType}",
                "--config", "${input:buildType}",
                "-j4"
            ],
            "problemMatcher": ["$msCompile"],
            "dependsOn": "CMake-MSVC-config",
            "group": { "kind": "build", "isDefault": true }
        },
        // 部署任务，使用windeployqt工具将Qt依赖项复制到输出目录
        {
            "label": "CMake-MSVC-deploy (debug)",
            "type": "shell",
            // 注意：这里的命令路径需要根据你的实际安装位置进行调整
            "command": "D:/CommonDev/Qt/6.11.0/msvc2022_64/bin/windeployqt.exe",
            "args": [
                "--debug", "${workspaceFolder}/bin/debug/MSVCDemo.exe"
            ],
            "problemMatcher": ["$msCompile"],
            "group": { "kind": "build"}
        }
    ]
}
```

### 3.2.5 VSCode调试配置

配置`.vscode/launch.json`（MSVC调试）：

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Qt MSVC Debug",
            // 调试器类型，使用 Visual Studio 的调试器
            "type": "cppvsdbg",
            "request": "launch",
            "program": "${workspaceFolder}/bin/Debug/MSVCDemo.exe",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}/bin/Debug",
            "environment": [],
            "externalConsole": false,
        }
    ]
}
```

### 3.2.6 编译部署流程

1. 从VS开发者命令行启动VSCode（确保环境变量正确）
2. `Ctrl+F7`运行“CMake-MSVC-build”任务，编译输出可执行文件
3. 运行“CMake-MSVC-deploy (debug)”任务，进行部署，拷贝debug版本依赖库
4. 按`F5` 调试

---

## 3.3 qmake+MSVC+jom方式编译.pro项目

适用场景：维护旧版Qt项目（Qt5及以前），或使用.pro项目文件。

### 3.3.1 新建项目
[ProDemo项目](Demos\VSCode学习笔记5配置C++语言(QT)\ProDemo\CMakeLists.txt)

### 3.3.2 插件与环境配置

**插件通用配置**
参考[插件通用配置](#23-插件通用配置)

**插件特殊配置**

无

**编译环境配置**

参考[编译环境配置](#24-编译环境配置)

### 3.3.3 配置VSCode任务

配置`.vscode/tasks.json`

```json
{
    "version": "2.0.0",
    "tasks": [
        // ====================== 64 位 Debug (Qt 6 专用) ======================
        {
            "label": "qmake: x64 Debug",
            "type": "shell",
            "command": "D:/CommonDev/Qt/6.11.0/msvc2022_64/bin/qmake.exe",  // 若要编译32位，需要使用32位的qmake.exe
            "args": [
                "${workspaceFolder}/ProDemo.pro",
                "-spec", "win32-msvc",  // Qt6 windows平台统一用 win32-msvc
                "CONFIG+=debug",
                "CONFIG+=qml_debug",
                "DESTDIR=${workspaceFolder}/bin/x64/Debug", // 可执行文件输出目录
                "OBJECTS_DIR=${workspaceFolder}/build/x64/Debug/obj",
                "MOC_DIR=${workspaceFolder}/build/x64/Debug/moc",
                "RCC_DIR=${workspaceFolder}/build/x64/Debug/rcc",
                "UI_DIR=${workspaceFolder}/build/x64/Debug/ui"
            ],
            "group": "build"
        },
        {
            "label": "jom: Build x64 Debug",
            "type": "shell",
            "command": "D:/CommonDev/Qt/Tools/QtCreator/bin/jom.exe",   // 注意：Qt 6.11.0 之后，官方推荐使用 jom 来替代 nmake 进行构建，因为 jom 支持并行编译，可以显著缩短编译时间。
            "args": ["/J4"],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "dependsOn": "qmake: x64 Debug",
            "problemMatcher": ["$msCompile"]
        },

        // ====================== 64 位 Release ======================
        {
            "label": "qmake: x64 Release",
            "type": "shell",
            "command": "D:/CommonDev/Qt/6.11.0/msvc2022_64/bin/qmake.exe",
            "args": [
                "${workspaceFolder}/ProDemo.pro",
                "-spec", "win32-msvc",  // Qt6 windows平台统一用 win32-msvc
                "CONFIG+=release",  // 指定 release 模式
                "CONFIG-=debug",    // 注意：要确保 release 配置中没有 debug 选项，否则会导致编译失败
                "DESTDIR=${workspaceFolder}/bin/x64/Release", // 可执行文件输出目录
                "OBJECTS_DIR=${workspaceFolder}/build/x64/Release/obj", // 中间文件输出目录
                "MOC_DIR=${workspaceFolder}/build/x64/Release/moc", // 中间文件输出目录
                "RCC_DIR=${workspaceFolder}/build/x64/Release/rcc", // 中间文件输出目录
                "UI_DIR=${workspaceFolder}/build/x64/Release/ui" // 中间文件输出目录
            ],
            "group": "build"
        },
        {
            "label": "jom: Build x64 Release",
            "type": "shell",
            "command": "D:/CommonDev/Qt/Tools/QtCreator/bin/jom/jom.exe",   // 注意：Qt 6.11.0 之后，官方推荐使用 jom 来替代 nmake 进行构建，因为 jom 支持并行编译，可以显著缩短编译时间。
            "args": ["/J4"],
            "group": "build",
            "dependsOn": "qmake: x64 Release",
            "problemMatcher": ["$msCompile"]
        },

        // ====================== 清理 ======================
        {
            "label": "nmake: Clean",
            "type": "shell",
            "command": "nmake",
            "args": ["clean"],
            "group": "build"
        }
    ]
}
```

### 3.3.4 调试配置

配置`.vscode/launch.json`（MSVC调试）

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "qmake Debug (MSVC)",
            "type": "cppvsdbg",
            "request": "launch",
            "program": "${workspaceFolder}/debug/MyProject.exe",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "console": "integratedTerminal",
            "preLaunchTask": "jom: Build Debug"
        }
    ]
}
```

### 3.3.5 构建部署流程

1. 从VS开发者命令行启动VSCode（确保环境变量正确）
2. `Ctrl+F7`运行“CMake-MSVC-build”任务，编译输出可执行文件
3. 运行“CMake-MSVC-deploy (debug)”任务，进行部署，拷贝debug版本依赖库
4. 按`F5` 调试

---

# 4. VSCode中Qt实战

### 4.1 创建新Qt项目（使用Qt Extension Pack）

步骤：

1. 按 `F1` → `Qt: New Project`
2. 选择项目模板：
   - Qt Widgets Application：传统桌面应用
   - Qt Quick Application：QML现代UI应用
   - Qt Console Application：控制台应用
3. 输入项目名称和路径
4. 选择套件（如 `mingw_64` 或 `msvc2022_64`）
5. 选择构建系统（推荐 CMake）
6. 选择是否包含UI文件（.ui）

### 4.2 打开Qt Designer编辑UI

方式一：右键菜单
- 在资源管理器中右键点击 `.ui` 文件
- 选择 "Open in Qt Designer"

方式二：命令面板
- 按 `F1` → `Qt: Open Qt Designer`
- 或在编辑.ui文件时点击右上角按钮

4.3 使用Qt Linguist处理翻译

1. 在项目中创建 `.ts` 文件（翻译文件）
2. 右键点击 `.ts` 文件 → "Open in Qt Linguist"
3. 在Qt Linguist中完成翻译后保存
4. 在CMakeLists.txt中添加：
   
```cmake
   find_package(Qt6 REQUIRED COMPONENTS LinguistTools)
   qt_add_translations(MyQtApp TS_FILES translations/myapp_zh_CN.ts)
   ```

4.4 常见问题解决

问题现象	解决方案	
Qt头文件报错（红色波浪线）	确保CMake配置成功生成`compile_commands.json`，或手动配置`c_cpp_properties.json`的`includePath`	
qDebug无输出	在CMakeLists.txt中设置`WIN32_EXECUTABLE FALSE`	
找不到Qt库（运行时报错）	确保环境变量PATH包含Qt的bin目录，或使用Qt Deployment工具	
调试时无法命中断点	检查是否使用Debug模式编译，确认调试器路径正确	
CMake无法找到Qt	设置`CMAKE_PREFIX_PATH`环境变量指向Qt安装目录	

4.5 部署发布

Windows部署（使用windeployqt）：

```bash
# 构建Release版本后
cd build/Release
windeployqt MyQtApp.exe --release --qmldir ../../src/qml
# 该命令会自动复制所需Qt库到程序目录
```

VSCode任务配置：

```json
{
    "label": "Deploy Qt App",
    "type": "shell",
    "command": "windeployqt",
    "args": [
        "${workspaceFolder}/build/Release/MyQtApp.exe",
        "--release",
        "--dir",
        "${workspaceFolder}/deploy"
    ],
    "group": "build"
}
```

---

附录：推荐配置速查表

场景	推荐配置	
个人学习/轻量开发	Qt + MinGW + CMake	
企业开发/Windows深度集成	Qt + MSVC + CMake	
维护旧项目	Qt + MSVC + qmake + jom	
跨平台项目	Qt + CMake + Ninja	
Python Qt开发	PySide6 + VSCode Qt Python扩展	

---

参考文档：
- [Qt Extension for VS Code 官方文档](https://doc.qt.io/vscodeext/index.html)
- [CMake Tools 官方文档](https://github.com/microsoft/vscode-cmake-tools/blob/main/docs/README.md)

---

这份手册基于Qt官方最新发布的VSCode扩展（2024-2025年更新）编写，涵盖了从基础安装到高级配置的全流程。如需针对特定场景（如Linux/macOS环境、PySide6开发等）的扩展说明，请告知！