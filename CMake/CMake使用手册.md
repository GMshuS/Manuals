# CMake 使用手册

---

## CMake的安装与配置

### 1. 各平台安装方法

#### Windows
| 方式 | 步骤 |
|------|------|
| 官网下载 | 访问 https://cmake.org/download/ 下载安装包，运行安装程序 |
| Chocolatey | `choco install cmake` |
| Winget | `winget install Kitware.CMake` |

#### Linux
| 发行版 | 命令 |
|--------|------|
| Ubuntu/Debian | `sudo apt-get install cmake` |
| CentOS/RHEL | `sudo yum install cmake` 或 `sudo dnf install cmake` |
| Arch Linux | `sudo pacman -S cmake` |
| 源码编译 | 下载源码后执行 `./bootstrap && make && sudo make install` |

#### macOS
```bash
# Homebrew
brew install cmake

# MacPorts
sudo port install cmake
```

### 2. 环境配置

```bash
# 验证安装
cmake --version

# 查看帮助
cmake --help

# 设置环境变量（可选）
export CMAKE_HOME=/usr/local/cmake
export PATH=$CMAKE_HOME/bin:$PATH
```

### 3. 常用配置选项

| 配置项 | 说明 |
|--------|------|
| `CMAKE_INSTALL_PREFIX` | 安装路径前缀 |
| `CMAKE_BUILD_TYPE` | 构建类型（Debug/Release等） |
| `CMAKE_C_COMPILER` | C编译器路径 |
| `CMAKE_CXX_COMPILER` | C++编译器路径 |
| `CMAKE_MAKE_PROGRAM` | Make工具路径 |

---

## CMake的使用

### 1 命令参数详解

| 命令/参数 | 说明 | 示例 |
|-----------|------|------|
| `-S <source_dir>` | 指定源代码目录 | `cmake -S .` |
| `-B <build_dir>` | 指定构建目录 | `cmake -B build` |
| `--build <dir>` | 执行构建 | `cmake --build build` |
| `--install <dir>` | 执行安装 | `cmake --install build` |
| `-G <generator_name>` | 指定生成器 | `-G "Unix Makefiles"` |
| `-T <toolset>` | 指定工具集 | `-T v142` |
| `-A <platform>` | 指定平台架构 | `-A x64` |
| `-D <var>=<value>` | 定义缓存变量 | `-DCMAKE_BUILD_TYPE=Release` |
| `-P <file>` | 执行脚本模式 | `cmake -P script.cmake` |
| `-E <command>` | 执行命令行工具 | `cmake -E copy file1 file2` |
| `--warn-uninitialized` | 警告未初始化变量 | - |
| `--warn-unused-cli` | 警告未使用的CLI变量 | - |
| `--debug-output` | 输出调试信息 | - |
| `--trace` | 跟踪每行命令执行 | - |
| `--version` | 显示版本信息 | - |
| `--help` | 显示帮助信息 | - |
| `--help-manual <name>` | 显示手册 | `--help-manual cmake-generator` |

> **注意：**
> 1. `-D` 无空格：错误 `-D CMAKE_BUILD_TYPE=Release`，正确 `-DCMAKE_BUILD_TYPE=Release`
> 2. VS 必须指定 `-A x64`，否则默认 32 位
> 3. `--build` 跨平台通用，不用区分 `make`/`msbuild`
> 4. 修改参数后必须重新执行 `cmake`

##### 1.1 CMake 命令核心语法
CMake 命令分 **3 种核心用法**：
```bash
# 1. 生成构建文件（最常用）
cmake -B 源码目录 [选项]

# 2. 跨平台编译（替代 make/msbuild，推荐！）
cmake --build 构建目录 [选项]

# 3. 安装程序（替代 make install，CMake 3.15+ 支持）
cmake --install 构建目录 [选项]
```

##### 1.2 最常用核心参数（必背）
**-D <变量>=<值>**
定义 CMake 缓存变量（90% 的配置都靠它）
- 作用：设置编译类型、路径、开关、版本等
- 无空格，大小写敏感
```bash
# 示例：设置 Release 模式
cmake .. -DCMAKE_BUILD_TYPE=Release
```

**-S <源码路径>**
指定项目源码目录（无需手动切换目录）
```bash
# 直接指定源码为上级目录
cmake -S .. -B build
```

**-B <构建路径>**
自动创建构建目录（一键 out-of-source 构建，最强用法）
- 替代 `mkdir build && cd build`
```bash
# 自动创建 build 目录，生成构建文件
cmake -S . -B build
```

**--build <构建目录>**
跨平台编译命令（不用管是 Makefile/VS/Xcode）
```bash
# 编译 build 目录的项目
cmake --build build
```

**--install <构建目录>**
跨平台安装命令（CMake 3.15+）
```bash
cmake --install build --prefix /usr/local/myapp
```

**-G <生成器名称>**
**指定生成的构建文件类型**（核心跨平台参数）
```bash
# Linux/macOS 默认
cmake .. -G "Unix Makefiles"

# Windows VS2022
cmake .. -G "Visual Studio 17 2022"
```

#### 1.3 生成器专用参数（Windows/VS 必备）
**-A <架构>**
指定编译架构（VS 专用）
```bash
# 64 位（推荐）
cmake .. -G "Visual Studio 17 2022" -A x64

# 32 位
cmake .. -G "Visual Studio 17 2022" -A Win32
```

**-T <工具集>**
指定 VS 编译器工具集
```bash
# VS2022 默认工具集 v143
cmake .. -G "Visual Studio 17 2022" -T v143

# Clang 编译
cmake .. -G "Visual Studio 17 2022" -T ClangCL
```

---

#### 1.4 编译配置参数（`-D` 变量大全）
**内置构建类型**
```bash
# Debug 模式（带调试信息）
cmake .. -DCMAKE_BUILD_TYPE=Debug

# Release 模式（优化）
cmake .. -DCMAKE_BUILD_TYPE=Release

# RelWithDebInfo（优化+调试）
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo

# MinSizeRel（最小体积）
cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel
```

**C/C++ 标准**
```bash
# C++17
-DCMAKE_CXX_STANDARD=17
# 强制启用标准（不兼容则报错）
-DCMAKE_CXX_STANDARD_REQUIRED=ON
```

**编译选项**
```bash
# C++ 警告 + 优化
-DCMAKE_CXX_FLAGS="-Wall -O2"

# VC 资源文件编译选项（对应之前的 .rc 文件）
-DCMAKE_RC_FLAGS="/nologo"
```

**开关配置**
```bash
# 启用测试
-DBUILD_TESTING=ON
# 禁用共享库
-DBUILD_SHARED_LIBS=OFF
```

#### 1.5 路径与安装参数
**CMAKE_INSTALL_PREFIX**
指定安装路径（默认 `/usr/local` 或 `C:\Program Files`）
```bash
# Linux
cmake .. -DCMAKE_INSTALL_PREFIX=/opt/myapp

# Windows
cmake .. -DCMAKE_INSTALL_PREFIX=D:\MyApp
```

**CMAKE_PREFIX_PATH**
指定第三方库搜索路径（OpenCV/Qt 必备）
```bash
cmake .. -DCMAKE_PREFIX_PATH=D:\opencv\build
```

**CMAKE_SYSROOT**
交叉编译根文件系统
```bash
-DCMAKE_SYSROOT=/home/arm-rootfs
```

#### 1.6 交叉编译参数（嵌入式必备）
**CMAKE_TOOLCHAIN_FILE**
指定交叉编译工具链文件
```bash
cmake .. -DCMAKE_TOOLCHAIN_FILE=./toolchain.cmake
```

#### 1.7 调试与日志参数
**--trace**
跟踪 CMake 执行流程（排查语法错误）
```bash
cmake .. --trace
```

**CMAKE_VERBOSE_MAKEFILE=ON**
显示完整编译命令（排查链接/头文件错误）
```bash
cmake .. -DCMAKE_VERBOSE_MAKEFILE=ON
```

**--debug-output**
输出调试日志
```bash
cmake .. --debug-output
```

#### 1.8 缓存与重置参数
**-U <变量>**
删除缓存变量
```bash
cmake .. -UCMAKE_BUILD_TYPE
```

**-C <缓存文件>**
预加载配置文件
```bash
cmake .. -C config.cmake
```

#### 1.9 编译/安装高级参数
**--config <模式>**
多配置生成器（VS/Xcode）指定编译模式
```bash
# 编译 Release 版本（VS 专用）
cmake --build build --config Release
```

**-j <线程数>**
多核编译加速
```bash
cmake --build build -j8
```

**--prefix**
安装时指定路径（覆盖 CMAKE_INSTALL_PREFIX）
```bash
cmake --install build --prefix D:\MyApp
```

### 2. CMake核心流程

```
┌─────────────────────────────────────────────────────────────┐
│                    CMake 核心工作流程                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. 配置阶段 (Configure)                                    │
│     └─> 读取 CMakeLists.txt                                 │
│     └─> 检查系统环境、编译器、依赖库                         │
│     └─> 生成构建系统文件 (Makefile/VS项目等)                 │
│                                                             │
│  2. 构建阶段 (Build)                                        │
│     └─> 调用原生构建工具 (make/ninja/msbuild)               │
│     └─> 编译源代码                                          │
│     └─> 链接生成目标文件                                     │
│                                                             │
│  3. 安装阶段 (Install)                                      │
│     └─> 复制文件到指定目录                                   │
│     └─> 生成安装包                                          │
│                                                             │
│  4. 测试阶段 (Test)                                         │
│     └─> 运行 CTest 测试                                     │
│     └─> 生成测试报告                                        │
│                                                             │
│  5. 打包阶段 (Package)                                      │
│     └─> 使用 CPack 生成安装包                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**典型工作流程：**
```bash
# 1. 项目根目录创建 CMakeLists.txt（文件名严格区分大小写）

# 2. 创建构建目录：存放makefile等编译配置文件
mkdir build

# 3. 配置项目：指定源码目录+构建目录+编译模式
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release

# 4. 项目构建：进行编译，输出可执行文件或者动态库文件
cmake --build build

# 5. 运行测试
ctest

# 6. 安装
cmake --install .

# 7. 打包
cpack
```

---

## CMakeLists.txt文件详解

### 1. CMakeLists.txt文件的格式

```cmake
# 注释以#开头

# 1. 声明最低CMake版本
cmake_minimum_required(VERSION 3.16)

# 2. 声明项目名称和语言
project(MyProject 
    VERSION 1.0.0
    DESCRIPTION "My Project Description"
    LANGUAGES C CXX
)

# 3. 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 4. 添加编译选项
add_compile_options(-Wall -Wextra)

# 5. 添加子目录
add_subdirectory(src)

# 6. 添加可执行文件/库
add_executable(main src/main.cpp)
add_library(mylib STATIC src/lib.cpp)

# 7. 包含目录
target_include_directories(main PRIVATE include/)

# 8. 链接库
target_link_libraries(main PRIVATE mylib)

# 9. 安装规则
install(TARGETS main DESTINATION bin)

# 10. 测试
enable_testing()
add_test(NAME mytest COMMAND main)
```
---

### 2. 基本语法结构

**2.1 项目配置命令**

命令	作用	参数说明	
`cmake_minimum_required(VERSION x.y)`	指定最低 CMake 版本	VERSION: 必需的最低版本号	
`project(name [VERSION ver] [LANGUAGES lang])`	定义项目	name: 项目名称；VERSION: 项目版本；LANGUAGES: 使用的语言（C, CXX, CUDA等）	

```cmake
# 示例
cmake_minimum_required(VERSION 3.15)
project(Calculator 
    VERSION 2.1.0 
    DESCRIPTION "A simple calculator"
    LANGUAGES CXX
)
```

**2.2 变量操作命令**

命令	作用	参数说明	
`set(VAR value)`	设置变量	VAR: 变量名；value: 值（可以是列表）	
`unset(VAR)`	删除变量	VAR: 要删除的变量名	
`list(APPEND list value)`	向列表追加元素	list: 列表变量名；value: 要追加的值	

```cmake
# 设置单个值
set(SRC_DIR src)

# 设置列表（分号分隔，可用空格代替）
set(SOURCES 
    src/main.cpp 
    src/utils.cpp 
    src/calc.cpp
)

# 追加元素
list(APPEND SOURCES src/new_file.cpp)

# 变量引用使用 ${VAR}
message("Source directory: ${SRC_DIR}")

# 设置缓存变量（可在命令行覆盖）
set(BUILD_TESTS OFF CACHE BOOL "Build test programs")

# 设置环境变量
set(ENV{PATH} "$ENV{PATH}:/new/path")
```

**2.3 目标构建命令**

**2.3.1 添加可执行文件**

```cmake
add_executable(target_name [source1] [source2 ...])
```

参数	说明	
target_name	目标名称（必须是全局唯一的）	
source	源文件列表	

```cmake
# 方式1：直接列出源文件
add_executable(app main.cpp utils.cpp)

# 方式2：使用变量
add_executable(app ${SOURCES})

# 方式3：后续添加源文件
add_executable(app main.cpp)
target_sources(app PRIVATE utils.cpp helper.cpp)
```

**2.3.2 添加库**

```cmake
add_library(target_name [STATIC | SHARED | MODULE] [source...])
```

参数	说明	
STATIC	静态库（.a / .lib）	
SHARED	动态库（.so / .dll / .dylib）	
MODULE	插件模块（运行时动态加载）	
不指定	由 `BUILD_SHARED_LIBS` 变量决定	

```cmake
# 静态库
add_library(math STATIC math.cpp algebra.cpp)

# 动态库
add_library(utils SHARED utils.cpp file_io.cpp)

# 对象库（不链接，仅编译）
add_library(objlib OBJECT obj1.cpp obj2.cpp)

# 接口库（无源文件，仅传递属性）
add_library(my_flags INTERFACE)
target_compile_options(my_flags INTERFACE -O3)
```

---

**2.4 目标属性设置**

**2.4.1 target_include_directories（头文件路径）**

```cmake
target_include_directories(target 
    <INTERFACE|PUBLIC|PRIVATE> [dir1...]
    [<INTERFACE|PUBLIC|PRIVATE> [dir2...] ...]
)
```

可见性	说明	
PRIVATE	仅当前目标使用，不传递给依赖者	
INTERFACE	仅传递给依赖者，当前目标不使用	
PUBLIC	当前目标和依赖者都使用	

```cmake
target_include_directories(my_lib 
    PUBLIC 
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        /usr/local/include
)

# 使用生成器表达式（条件判断）
target_include_directories(app PRIVATE 
    $<$<CONFIG:Debug>:${CMAKE_SOURCE_DIR}/debug_include>
    $<$<CONFIG:Release>:${CMAKE_SOURCE_DIR}/release_include>
)
```

**2.4.2 target_compile_definitions（宏定义）**

```cmake
target_compile_definitions(target 
    <INTERFACE|PUBLIC|PRIVATE> [def1...]
)
```

```cmake
target_compile_definitions(my_app 
    PRIVATE 
        DEBUG_MODE
        VERSION="1.0.0"
        $<$<BOOL:${USE_OPENMP}>:USE_OPENMP>
)
```

**2.4.3 target_compile_options（编译选项）**

```cmake
target_compile_options(target 
    <INTERFACE|PUBLIC|PRIVATE> [option1...]
)
```

```cmake
target_compile_options(my_lib 
    PRIVATE 
        -Wall 
        -Wextra 
        -Werror
        $<$<CXX_COMPILER_ID:MSVC>:/W4>
        $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-Wpedantic>
)
```

**2.4.4 target_link_libraries（链接库）**

```cmake
target_link_libraries(target 
    <PRIVATE|PUBLIC|INTERFACE> [lib1...]
    [<PRIVATE|PUBLIC|INTERFACE> [lib2...] ...]
)
```

```cmake
# 链接系统库
target_link_libraries(my_app 
    PRIVATE 
        pthread
        m           # 数学库
        dl          # 动态加载库
)

# 链接第三方库
find_package(Boost REQUIRED COMPONENTS filesystem)
target_link_libraries(my_app 
    PRIVATE 
        Boost::filesystem
)

# 链接自定义库
target_link_libraries(app PRIVATE math utils)

# 全特性示例
target_link_libraries(my_app
    PUBLIC 
        my_lib           # 自己编译的库
    PRIVATE 
        OpenSSL::SSL     # 包找到的库
        ${CMAKE_THREAD_LIBS_INIT}  # 变量形式的库
)
```

**2.5 目录操作**

```cmake
# 添加子目录（必须包含 CMakeLists.txt）
add_subdirectory(source_dir [binary_dir] [EXCLUDE_FROM_ALL])

# 示例
add_subdirectory(src)           # 构建 src 目录
add_subdirectory(extern/googletest EXCLUDE_FROM_ALL)  # 不构建 install 目标

# 获取当前目录
set(CURRENT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(CURRENT_BIN ${CMAKE_CURRENT_BINARY_DIR})

# 包含其他 cmake 文件
include(cmake/utils.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/FindMyLib.cmake)
```

---

**2.6 安装与打包**

```cmake
# 安装目标
install(TARGETS my_app my_lib
    RUNTIME DESTINATION bin           # 可执行文件
    LIBRARY DESTINATION lib           # 动态库
    ARCHIVE DESTINATION lib             # 静态库
    INCLUDES DESTINATION include      # 头文件
)

# 安装文件
install(FILES 
    ${HEADERS}
    DESTINATION include/my_project
)

# 安装目录
install(DIRECTORY include/ 
    DESTINATION include
    FILES_MATCHING PATTERN "*.h"
)

# 配置 CPack
set(CPACK_GENERATOR "DEB;RPM;TGZ")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
include(CPack)
```

### 3. 控制流命令

**3.1 条件判断**

```cmake
if(condition)
    # ...
elseif(other_condition)
    # ...
else()
    # ...
endif()
```

常用条件：

```cmake
# 变量检查
if(VAR)                     # VAR 已定义且不为空/0/OFF/FALSE/NOTFOUND
if(NOT VAR)
if(DEFINED VAR)             # VAR 是否已定义
if(VAR STREQUAL "value")    # 字符串比较
if(VAR MATCHES "regex")     # 正则匹配

# 数值比较
if(VAR EQUAL 10)            # 等于
if(VAR LESS 10)             # 小于
if(VAR GREATER 10)          # 大于

# 文件检查
if(EXISTS path)
if(IS_DIRECTORY path)
if(IS_ABSOLUTE path)

# 编译器检查
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")

# 逻辑运算
if(A AND B)
if(A OR B)
```

示例：

```cmake
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O0")
    add_definitions(-DDEBUG)
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -DNDEBUG")
else()
    message(WARNING "Unknown build type: ${CMAKE_BUILD_TYPE}")
endif()
```

**3.2 循环**

```cmake
# foreach 循环
foreach(var IN ITEMS item1 item2 item3)
    message("Item: ${var}")
endforeach()

# 范围循环
foreach(i RANGE 1 10 2)  # 从1到10，步长2
    message("i = ${i}")
endforeach()

# 列表循环
set(MY_LIST a b c)
foreach(item IN LISTS MY_LIST)
    # ...
endforeach()

# while 循环
set(i 0)
while(i LESS 10)
    math(EXPR i "${i} + 1")
    message("i = ${i}")
endwhile()
```

**3.3 函数与宏**

```cmake
# 定义函数（创建新的作用域）
function(my_function arg1 arg2)
    # ${arg1}, ${arg2} 访问参数
    # ${ARGC} 参数个数
    # ${ARGV} 所有参数列表
    # ${ARGN} 超出命名参数的部分
    
    set(result "processed_${arg1}" PARENT_SCOPE)  # 修改父作用域变量
endfunction()

# 定义宏（文本替换，无新作用域）
macro(my_macro arg)
    message("Macro called with ${arg}")
endmacro()

# 使用
my_function(input1 input2)
my_macro(hello)
```

### 4. 查找依赖包

```cmake
# 查找包
find_package(PackageName [version] [EXACT] [QUIET] [REQUIRED]
    [COMPONENTS comp1 comp2 ...]
    [OPTIONAL_COMPONENTS comp1 ...]
)

# 示例
find_package(Boost 1.70 REQUIRED COMPONENTS system filesystem)
find_package(OpenCV QUIET)  # 安静模式，找不到不报错
find_package(Threads REQUIRED)  # 查找线程库

# 使用找到的包
if(Boost_FOUND)
    target_link_libraries(my_app PRIVATE Boost::system Boost::filesystem)
endif()

# 自定义查找模块
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
find_package(MyCustomLib REQUIRED)
```

### 5. 完整实例

实例1：简单单文件项目

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.10)
project(Hello VERSION 1.0)

set(CMAKE_CXX_STANDARD 17)

add_executable(hello main.cpp)
```

实例2：多目录 C++ 项目

```
project/
├── CMakeLists.txt
├── include/
│   └── calculator/
│       └── calc.h
├── src/
│   ├── CMakeLists.txt
│   ├── main.cpp
│   └── calc.cpp
└── tests/
    └── CMakeLists.txt
```

根 CMakeLists.txt：

```cmake
cmake_minimum_required(VERSION 3.14)
project(CalcProject VERSION 1.2.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 导出编译命令（用于 clangd 等）
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# 选项
option(BUILD_TESTS "Build tests" ON)
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)

# 包含目录（所有子目标可见）
include_directories(${CMAKE_SOURCE_DIR}/include)

# 添加子目录
add_subdirectory(src)

if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

# 安装配置
install(DIRECTORY include/ DESTINATION include)
```

src/CMakeLists.txt：

```cmake
# 创建库
add_library(calc calc.cpp)
target_include_directories(calc 
    PUBLIC 
        ${CMAKE_SOURCE_DIR}/include
)

# 创建可执行文件
add_executable(calc_app main.cpp)
target_link_libraries(calc_app PRIVATE calc)

# 安装目标
install(TARGETS calc calc_app
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
)
```

实例3：现代 CMake 最佳实践

```cmake
cmake_minimum_required(VERSION 3.15)
project(MyProject VERSION 1.0.0)

# 使用预设的编译配置
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_EXTENSIONS OFF)  # 不使用编译器扩展（如 gnu++20）

# 生成位置无关代码（对于动态库必需）
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# 创建接口库统一配置
add_library(project_warnings INTERFACE)
target_compile_options(project_warnings INTERFACE
    $<$<CXX_COMPILER_ID:MSVC>:/W4 /WX>
    $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-Wall -Wextra -Wpedantic -Werror>
)

add_library(project_options INTERFACE)
target_compile_features(project_options INTERFACE cxx_std_20)

# 主库
add_library(my_core 
    src/core.cpp
    src/utils.cpp
)
target_include_directories(my_core 
    PUBLIC 
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${CMAKE_SOURCE_DIR}/src
)
target_link_libraries(my_core 
    PUBLIC 
        project_options
    PRIVATE 
        project_warnings
        Threads::Threads
)

# 可执行文件
add_executable(my_app src/main.cpp)
target_link_libraries(my_app PRIVATE my_core)

# 测试
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
    include(CTest)
    if(BUILD_TESTING)
        add_subdirectory(tests)
    endif()
endif()
```

>CMake 的现代用法（Modern CMake，3.0+）强调基于目标的配置（target-based），而非传统的全局变量设置。这种方式更清晰、更模块化，是推荐的最佳实践。

---

## 变量系统（包括变量、内置变量与常量）

### 1. 变量（Variables）

#### 1.1 变量的类型

CMake 变量本质上是字符串，但根据使用方式可分为：

类型	说明	示例	
普通变量	存储单个值或列表	`set(VAR "value")`	
列表变量	分号分隔的字符串	`set(LIST a;b;c)` 或 `set(LIST a b c)`	
缓存变量	持久化存储，用户可配置	`set(CACHE_VAR "value" CACHE STRING "描述")`	
环境变量	访问系统环境变量	`$ENV{PATH}`	
目录变量	设置目录属性	`set_directory_properties()`	

#### 1.2 变量定义与引用

```cmake
# ========== 定义变量 ==========

# 1. 普通变量（当前作用域）
set(MY_VAR "Hello World")
set(VERSION 1.2.3)

# 2. 列表变量（分号分隔）
set(SRC_FILES main.cpp utils.cpp helper.cpp)
# 等价于：set(SRC_FILES "main.cpp;utils.cpp;helper.cpp")

# 3. 缓存变量（持久化，可在命令行修改）
set(BUILD_TESTS ON CACHE BOOL "Build test programs")
set(CMAKE_INSTALL_PREFIX "/usr/local" CACHE PATH "Install path")

# 4. 强制设置缓存变量（覆盖已有值）
set(FORCE_VAR "value" CACHE STRING "描述" FORCE)

# ========== 引用变量 ==========

# 基本引用
message(${MY_VAR})           # 输出: Hello World

# 在字符串中引用（双引号内）
message("Version: ${VERSION}")  # 输出: Version: 1.2.3

# 未定义变量展开为空字符串
message(${UNDEFINED_VAR})    # 输出空行

# 引用环境变量
message($ENV{HOME})

# 引用缓存变量（与普通变量语法相同）
message(${BUILD_TESTS})
```

#### 1.3 变量的作用域

```cmake
# ========== 作用域规则 ==========

# 1. 函数作用域（Function Scope）
function(my_func)
    set(LOCAL_VAR "I'm local")      # 仅在函数内可见
    set(PARENT_VAR "Visible outside" PARENT_SCOPE)  # 提升到父作用域
endfunction()

# 2. 目录作用域（Directory Scope）
# 每个 CMakeLists.txt 有自己的变量空间
# add_subdirectory() 会创建子目录作用域

# 3. 缓存作用域（Cache Scope）
# 缓存变量全局可见，跨所有作用域

# ========== 作用域示例 ==========

set(GLOBAL_VAR "global")

function(test_scope)
    message("In function, GLOBAL_VAR = ${GLOBAL_VAR}")  # 可见: global
    
    set(GLOBAL_VAR "modified")           # 修改的是函数内副本
    message("After set (local): ${GLOBAL_VAR}")  # modified
    
    set(GLOBAL_VAR "really modified" PARENT_SCOPE)  # 真正修改父作用域
endfunction()

test_scope()
message("Outside function: ${GLOBAL_VAR}")  # really modified

# ========== 列表操作 ==========

set(MY_LIST a b c)

# 追加元素
list(APPEND MY_LIST d e)        # a;b;c;d;e

# 获取长度
list(LENGTH MY_LIST len)        # len = 5

# 获取元素
list(GET MY_LIST 0 first)       # first = a
list(GET MY_LIST -1 last)        # last = e

# 查找元素
list(FIND MY_LIST c index)      # index = 2

# 移除元素
list(REMOVE_ITEM MY_LIST b)       # a;c;d;e

# 插入/替换
list(INSERT MY_LIST 1 x)          # a;x;c;d;e
list(REMOVE_AT MY_LIST 0)         # x;c;d;e
```

---

### 2. 内置变量（Built-in Variables）

#### 2.1 项目信息变量

变量名	作用	典型值	
`PROJECT_NAME`	当前项目名称	`MyProject`	
`PROJECT_VERSION`	项目版本	`1.0.0`	
`PROJECT_DESCRIPTION`	项目描述	`A sample project`	
`PROJECT_HOMEPAGE_URL`	项目主页	`https://example.com`	
`CMAKE_PROJECT_NAME`	最顶层项目名称	`TopLevelProject`	

```cmake
cmake_minimum_required(VERSION 3.15)
project(MyApp 
    VERSION 2.1.0 
    DESCRIPTION "My Application"
    LANGUAGES CXX)

message("Project: ${PROJECT_NAME}")
message("Version: ${PROJECT_VERSION}")
message("Major: ${PROJECT_VERSION_MAJOR}")    # 2
message("Minor: ${PROJECT_VERSION_MINOR}")    # 1
message("Patch: ${PROJECT_VERSION_PATCH}")    # 0
message("Tweak: ${PROJECT_VERSION_TWEAK}")    # 空（如果未指定）
```

#### 2.2 目录与路径变量

变量名	作用	说明	
`CMAKE_SOURCE_DIR`	源码顶层目录	最外层 CMakeLists.txt 所在目录	
`CMAKE_BINARY_DIR`	构建顶层目录	运行 cmake 的目录	
`CMAKE_CURRENT_SOURCE_DIR`	当前处理的源码目录	当前 CMakeLists.txt 所在目录	
`CMAKE_CURRENT_BINARY_DIR`	当前处理的构建目录	对应构建目录	
`CMAKE_CURRENT_LIST_DIR`	当前文件所在目录	包含当前正在处理的文件的目录	
`CMAKE_CURRENT_LIST_FILE`	当前文件的完整路径	当前正在处理的 cmake 文件	
`CMAKE_MODULE_PATH`	模块搜索路径列表	自定义 FindXXX.cmake 路径	
`CMAKE_PREFIX_PATH`	安装前缀搜索路径	查找包的路径	

```cmake
# 路径变量示例
message("源码目录: ${CMAKE_SOURCE_DIR}")
message("构建目录: ${CMAKE_BINARY_DIR}")
message("当前源码: ${CMAKE_CURRENT_SOURCE_DIR}")
message("当前构建: ${CMAKE_CURRENT_BINARY_DIR}")

# 添加模块搜索路径
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules")

# 查找包时搜索的路径
list(APPEND CMAKE_PREFIX_PATH "/opt/mylib" "/usr/local")
find_package(MyLib REQUIRED)
```

#### 2.3 系统与平台变量

变量名	作用	典型值	
`CMAKE_SYSTEM_NAME`	目标系统名称	`Linux`, `Windows`, `Darwin`	
`CMAKE_SYSTEM_VERSION`	目标系统版本	`5.15.0`, `10.0.19044`	
`CMAKE_SYSTEM_PROCESSOR`	目标处理器架构	`x86_64`, `arm64`, `AMD64`	
`CMAKE_HOST_SYSTEM_NAME`	主机系统名称	`Linux`	
`CMAKE_HOST_SYSTEM_PROCESSOR`	主机处理器	`x86_64`	
`WIN32`	Windows 平台（含 Win64）	`1` 或未定义	
`UNIX`	Unix/Linux/macOS	`1` 或未定义	
`APPLE`	Apple 平台	`1` 或未定义	
`MINGW`	MinGW 环境	`1` 或未定义	
`MSVC`	Microsoft Visual C++	`1` 或未定义	
`CMAKE_CROSSCOMPILING`	是否交叉编译	`TRUE`/`FALSE`	

```cmake
# 平台检测示例
if(WIN32)
    message("Windows平台")
    if(MSVC)
        message("使用MSVC编译器")
        add_compile_options(/W4 /WX)
    elseif(MINGW)
        message("使用MinGW")
    endif()
elseif(APPLE)
    message("macOS平台")
    set(CMAKE_MACOSX_RPATH ON)
elseif(UNIX)
    message("Linux/Unix平台")
endif()

# 架构检测
if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm|ARM")
    message("ARM架构")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64")
    message("x86_64架构")
endif()
```

#### 2.4 编译相关变量

变量名	作用	说明	
`CMAKE_C_COMPILER`	C 编译器	`gcc`, `clang`, `cl.exe`	
`CMAKE_CXX_COMPILER`	C++ 编译器	`g++`, `clang++`	
`CMAKE_C_COMPILER_ID`	C 编译器标识	`GNU`, `Clang`, `MSVC`, `AppleClang`	
`CMAKE_CXX_COMPILER_ID`	C++ 编译器标识	同上	
`CMAKE_C_COMPILER_VERSION`	C 编译器版本	`11.2.0`	
`CMAKE_CXX_COMPILER_VERSION`	C++ 编译器版本	`11.2.0`	
`CMAKE_BUILD_TYPE`	构建类型	`Debug`, `Release`, `RelWithDebInfo`, `MinSizeRel`	
`CMAKE_C_FLAGS`	C 编译标志	全局 C 编译选项	
`CMAKE_CXX_FLAGS`	C++ 编译标志	全局 C++ 编译选项	
`CMAKE_EXE_LINKER_FLAGS`	可执行文件链接标志	链接器选项	
`CMAKE_SHARED_LINKER_FLAGS`	共享库链接标志	链接器选项	
`CMAKE_STATIC_LINKER_FLAGS`	静态库链接标志	链接器选项	

```cmake
# 编译器检测与配置
message("C++编译器: ${CMAKE_CXX_COMPILER}")
message("编译器ID: ${CMAKE_CXX_COMPILER_ID}")
message("编译器版本: ${CMAKE_CXX_COMPILER_VERSION}")

# 根据编译器设置选项
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wpedantic")
    set(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
    set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4 /permissive-")
endif()

# 构建类型特定配置
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    message("Debug模式: 启用调试信息")
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    message("Release模式: 启用优化")
endif()
```

#### 2.5 语言标准变量

变量名	作用	说明	
`CMAKE_C_STANDARD`	C 语言标准	`90`, `99`, `11`, `17`, `23`	
`CMAKE_CXX_STANDARD`	C++ 语言标准	`98`, `11`, `14`, `17`, `20`, `23`	
`CMAKE_C_STANDARD_REQUIRED`	是否强制使用标准	`ON`/`OFF`	
`CMAKE_CXX_STANDARD_REQUIRED`	是否强制使用标准	`ON`/`OFF`	
`CMAKE_C_EXTENSIONS`	是否启用编译器扩展	`ON`/`OFF`	
`CMAKE_CXX_EXTENSIONS`	是否启用编译器扩展	`ON`/`OFF`	

```cmake
# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)  # 强制要求，不支持则报错
set(CMAKE_CXX_EXTENSIONS OFF)        # 禁用 GNU 扩展，使用标准 C++

# 针对特定目标设置（覆盖全局设置）
add_executable(myapp main.cpp)
set_property(TARGET myapp PROPERTY CXX_STANDARD 20)
```

#### 2.6 安装与输出变量

变量名	作用	典型值	
`CMAKE_INSTALL_PREFIX`	安装根目录	`/usr/local`, `C:/Program Files/MyApp`	
`CMAKE_INSTALL_BINDIR`	可执行文件目录	`bin`	
`CMAKE_INSTALL_LIBDIR`	库文件目录	`lib`, `lib64`	
`CMAKE_INSTALL_INCLUDEDIR`	头文件目录	`include`	
`CMAKE_INSTALL_DATADIR`	数据文件目录	`share`	
`CMAKE_ARCHIVE_OUTPUT_DIRECTORY`	静态库输出目录	构建目录下的路径	
`CMAKE_LIBRARY_OUTPUT_DIRECTORY`	动态库输出目录	构建目录下的路径	
`CMAKE_RUNTIME_OUTPUT_DIRECTORY`	可执行文件输出目录	构建目录下的路径	
`CMAKE_DEBUG_POSTFIX`	Debug 后缀	`d`, `_debug`	

```cmake
# 安装路径配置
set(CMAKE_INSTALL_PREFIX "/opt/myapp")
set(CMAKE_INSTALL_BINDIR "bin")
set(CMAKE_INSTALL_LIBDIR "lib64")

# GNU 标准安装目录
include(GNUInstallDirs)

# 输出目录配置（统一构建输出）
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Debug 版本添加后缀
set(CMAKE_DEBUG_POSTFIX "d")

# 安装规则
install(TARGETS mylib
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}   # 静态库
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}   # 动态库
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}   # 可执行文件
)
install(FILES myheader.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/mylib)
```

#### 2.7 查找包相关变量

变量名	作用	说明	
`CMAKE_FIND_ROOT_PATH`	交叉编译查找根路径	目标系统根目录	
`CMAKE_FIND_LIBRARY_PREFIXES`	库文件名前缀	`lib` (Unix)	
`CMAKE_FIND_LIBRARY_SUFFIXES`	库文件名后缀	`.so`, `.a`, `.lib`	
`CMAKE_INCLUDE_PATH`	头文件搜索路径	额外的 include 路径	
`CMAKE_LIBRARY_PATH`	库文件搜索路径	额外的 lib 路径	
`CMAKE_PROGRAM_PATH`	程序搜索路径	额外的 bin 路径	

---

### 3. 内置常量（Built-in Constants）

CMake 没有传统意义上的"常量"，但有一些预定义值和枚举值在特定上下文中作为常量使用。

#### 3.1 布尔常量

常量值	含义	说明	
`ON`, `YES`, `TRUE`, `Y`	真值	布尔上下文中视为真	
`OFF`, `NO`, `FALSE`, `N`	假值	布尔上下文中视为假	
`IGNORE`, `NOTFOUND`	假值/未找到	查找包时表示未找到	
空字符串 `""`	假值	布尔上下文中视为假	

```cmake
# 布尔值使用
set(ENABLE_FEATURE ON)
if(ENABLE_FEATURE)
    message("功能已启用")
endif()

# 这些值在 if() 中都被视为真
if(ON OR YES OR TRUE OR Y OR 1 OR "非空字符串")
    message("条件为真")
endif()

# 这些值被视为假
if(NOT (OFF OR NO OR FALSE OR N OR 0 OR "" OR IGNORE OR NOTFOUND))
    message("不会执行")
endif()
```

#### 3.2 构建类型常量

常量值	作用	典型编译选项	
`Debug`	调试版本	`-g -O0`	
`Release`	发布版本	`-O3 -DNDEBUG`	
`RelWithDebInfo`	带调试信息的发布版	`-O2 -g -DNDEBUG`	
`MinSizeRel`	最小体积版本	`-Os -DNDEBUG`	

```cmake
# 设置默认构建类型
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

# 限制可选值
set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS 
    Debug Release RelWithDebInfo MinSizeRel)

# 特定构建类型的编译选项
set(CMAKE_C_FLAGS_DEBUG "-g -O0 -DDEBUG")
set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG -s")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG")
set(CMAKE_C_FLAGS_MINSIZEREL "-Os -DNDEBUG")
```

#### 3.3 语言标准常量

常量值	适用语言	说明	
`90`, `99`, `11`, `17`, `23`	C	C 语言标准版本	
`98`, `11`, `14`, `17`, `20`, `23`	C++	C++ 语言标准版本

#### 3.4 系统路径常量

常量值	含义	说明	
`CMAKE_CURRENT_LIST_DIR`	当前文件目录	当前处理的 cmake 文件所在目录	
`CMAKE_CURRENT_SOURCE_DIR`	当前源码目录	当前 CMakeLists.txt 目录	
`CMAKE_CURRENT_BINARY_DIR`	当前构建目录	当前对应的构建目录	

---

### 4. 完整示例：综合运用

```cmake
cmake_minimum_required(VERSION 3.16)
project(AdvancedDemo 
    VERSION 1.2.3 
    LANGUAGES CXX)

# ========== 变量定义 ==========
set(MY_SOURCES 
    src/main.cpp 
    src/utils.cpp 
    src/core.cpp
)

set(ENABLE_TESTS ON CACHE BOOL "Build unit tests")
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ========== 内置变量使用 ==========
message(STATUS "项目: ${PROJECT_NAME} v${PROJECT_VERSION}")
message(STATUS "源码目录: ${CMAKE_SOURCE_DIR}")
message(STATUS "构建目录: ${CMAKE_BINARY_DIR}")
message(STATUS "系统: ${CMAKE_SYSTEM_NAME} ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "编译器: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "构建类型: ${CMAKE_BUILD_TYPE}")

# ========== 平台检测 ==========
if(WIN32)
    add_definitions(-DWIN32_LEAN_AND_MEAN)
elseif(APPLE)
    set(CMAKE_MACOSX_RPATH ON)
elseif(UNIX)
    find_package(Threads REQUIRED)
endif()

# ========== 编译配置 ==========
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wall -Wextra -Wpedantic)
elseif(MSVC)
    add_compile_options(/W4 /permissive-)
endif()

# ========== 目标定义 ==========
add_executable(${PROJECT_NAME} ${MY_SOURCES})

target_include_directories(${PROJECT_NAME} PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# ========== 安装配置 ==========
include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# ========== 测试配置 ==========
if(ENABLE_TESTS AND BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()
```

> 理解这些变量系统是掌握 CMake 的关键，建议根据项目需求合理使用缓存变量进行配置，利用内置变量实现跨平台兼容，并通过生成器表达式实现精细的构建控制。

---

## CMake 项目实战【全量代码在CMakeDemo中】

以下是一个完整的、可直接运行的 CMake 项目示例，涵盖您列出的所有实用场景。项目结构清晰，每个功能都有对应的 CMakeLists.txt 和源代码示例。

**项目结构说明**
```
cmake_demo/
├── CMakeLists.txt          # 根配置文件
├── app/                    # 可执行文件目录
│   ├── CMakeLists.txt
│   └── main.cpp
├── src/                    # 主源代码目录
│   ├── CMakeLists.txt
│   ├── hello.cpp
│   ├── hello.h
│   ├── calc.cpp
│   └── calc.h
├── libs/                   # 库文件目录
│   ├── static/             # 静态库
│   │   ├── CMakeLists.txt
│   │   ├── mystatic.cpp
│   │   └── mystatic.h
│   └── shared/             # 动态库
│       ├── CMakeLists.txt
│       ├── myshared.cpp
│       └── myshared.h
├── thirdparty/             # 第三方库演示
│   └── CMakeLists.txt
├── tests/                  # 单元测试目录
│   ├── CMakeLists.txt
│   └── test_calc.cpp
├── cmake/                  # CMake模块目录
│   ├── toolchains/
│   │   ├── arm-linux-gnueabihf.cmake
│   │   └── macos-universal.cmake
│   └── FindMyLib.cmake     # 查找第三方库模块
└── docs/                   # 文档
```

### 1. 根目录 CMakeLists.txt（综合配置）  
这里处理项目定义、编译器设置、操作系统判断、输出目录、CTest 和 CPack。
```cmake
cmake_minimum_required(VERSION 3.15)
project(CMakeDemo VERSION 1.0.0 LANGUAGES CXX)

# 设置C++标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 1. 指定输出目录
# 可执行文件、动态库、静态库分别输出到不同目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# 2. Debug/Release条件编译
# CMake 默认通过 CMAKE_BUILD_TYPE 控制 (Unix) 或通过 VS 配置管理器控制 (Windows)
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_definitions(-DDEBUG_MODE)
    if(NOT MSVC)
        add_compile_options(-g -O0)
    endif()
else()
    add_definitions(-DNDEBUG)
    if(NOT MSVC)
        add_compile_options(-O2)
    endif()
endif()

# 3. 不同编译器特性化设置
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    add_compile_options(-Wall -Wextra -Wpedantic)
    if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
        add_compile_options(-flto)
    endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    # Visual Studio 特定标志
    add_compile_options(/W4 /WX-) # 警告级别4，不将警告视为错误
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    add_compile_options(-Weverything -Wno-c++98-compat)
endif()

# 4. 不同操作系统特性化设置
if(WIN32)
    message(STATUS "Building for Windows")
    add_definitions(-DWIN32_LEAN_AND_MEAN -D_WIN32_WINNT=0x0601)
    add_compile_options(/MP)  # 多核编译
elseif(APPLE)
    message(STATUS "Building for macOS")
    add_definitions(-DMACOSX)
    # 设置macOS部署目标
    set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15" CACHE STRING "Minimum macOS version")
elseif(UNIX AND NOT APPLE)
    message(STATUS "Building for Linux/Unix")
    add_definitions(-DLINUX)
    # Linux特定设置
    set(THREADS_PREFER_PTHREAD_FLAG ON)
    find_package(Threads REQUIRED)
endif()

# 5. 引入第三方库 (模拟)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
# 假设我们有一个 FindFakeLib.cmake 或者直接使用 find_package
# 这里演示手动指定包含目录和库（常见于没有提供 Config 文件的第三方库）
set(THIRD_PARTY_ROOT ${CMAKE_SOURCE_DIR}/third_party)
include_directories(${THIRD_PARTY_ROOT}/include)
# 实际项目中通常使用: find_package(FakeLib REQUIRED)

# 6. 包含子目录
add_subdirectory(src)
add_subdirectory(libs/static)
add_subdirectory(libs/shared)
add_subdirectory(app)
add_subdirectory(tests)

# 7. 单元测试集成（CTest）
# enable_testing()
# include(CTest)

# 8. 安装与部署
install(DIRECTORY ${CMAKE_SOURCE_DIR}/docs/
        DESTINATION share/cmake_demo/docs
        FILES_MATCHING PATTERN "*.md")

# 9. 打包配置（CPack）
set(CPACK_PACKAGE_NAME "CMakeDemo")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_VENDOR "YourCompany")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A CMake demo project")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE.txt")

if(WIN32)
    set(CPACK_GENERATOR "ZIP;NSIS")
elseif(APPLE)
    set(CPACK_GENERATOR "ZIP;DragNDrop")
else()
    set(CPACK_GENERATOR "ZIP;TGZ;DEB")
endif()

include(CPack)
```

### 2. 多源文件、多目录可执行文件生成

**src/CMakeLists.txt**
```cmake
# 收集所有源文件
set(SRC_FILES
    hello.cpp
    calc.cpp
)

# 创建库（内部使用）
add_library(core_lib STATIC ${SRC_FILES})

# 设置包含目录
target_include_directories(core_lib
    PUBLIC 
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include>
)

# 添加编译定义
target_compile_definitions(core_lib PRIVATE BUILDING_CORE=1)
```

**app/CMakeLists.txt**
```cmake
# 添加可执行文件
add_executable(${PROJECT_NAME}
    main.cpp
)

# 链接内部库
target_link_libraries(${PROJECT_NAME}
    PRIVATE
        core_lib
        mystatic
        myshared
)

# 设置可执行文件的属性
set_target_properties(${PROJECT_NAME} PROPERTIES
    OUTPUT_NAME "cmake_demo"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/bin/debug"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/bin/release"
)

# 安装可执行文件
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    BUNDLE DESTINATION Applications
)
```

### 3. 静态库生成与调用

**libs/static/CMakeLists.txt**
```cmake
# 创建静态库
add_library(mystatic STATIC
    mystatic.cpp
)

# 设置库的版本
set_target_properties(mystatic PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    PUBLIC_HEADER "mystatic.h"
)

# 包含目录
target_include_directories(mystatic
    PUBLIC 
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include>
)

# 安装静态库
install(TARGETS mystatic
    ARCHIVE DESTINATION lib
    PUBLIC_HEADER DESTINATION include
)
```

**libs/static/mystatic.h**
```cpp
class CStaticLib
{
    print_message();
};
```

**libs/static/mystatic.cpp**
```cpp
#include "mystatic.h"
#include <iostream>

void CStaticLib::print_message() {
    #ifdef DEBUG
    std::cout << "[DEBUG] Static library message" << std::endl;
    #else
    std::cout << "Static library message" << std::endl;
    #endif
}
```

### 4. 动态库生成与调用

**libs/shared/CMakeLists.txt**
```cmake
# 创建动态库（共享库）
add_library(myshared SHARED
    myshared.cpp
)

# 设置动态库属性
set_target_properties(myshared PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    PUBLIC_HEADER "myshared.h"
    # Windows下设置导出符号
    WINDOWS_EXPORT_ALL_SYMBOLS ON
)

# 定义导出宏
target_compile_definitions(myshared
    PRIVATE BUILDING_MYSHARED=1
    PUBLIC MYSHARED_EXPORTS
)

# 包含目录
target_include_directories(myshared
    PUBLIC 
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include>
)

# 安装动态库
install(TARGETS myshared
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
    PUBLIC_HEADER DESTINATION include
)
```

### 5. 引入第三方库的几种方式

**thirdparty/CMakeLists.txt**
```cmake
# 方式1: 使用find_package查找系统库（引入 Boost）
find_package(Boost REQUIRED COMPONENTS system filesystem)
add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE Boost::system Boost::filesystem)

# 方式2: 手动指定路径
# ============== 1. 定义第三方库路径 ==============
set(MY_LIB_DIR ${PROJECT_SOURCE_DIR}/thirdparty/my_lib)
# ============== 2. 添加可执行文件 ==============
add_executable(${PROJECT_NAME} main.cpp)
# ============== 3. 指定头文件路径 ==============
target_include_directories(${PROJECT_NAME}
    PRIVATE
    ${MY_LIB_DIR}/include
)
# ============== 4. 指定库文件路径 + 链接 ==============
target_link_directories(${PROJECT_NAME}
    PRIVATE
    ${MY_LIB_DIR}/lib
)
# 链接库（直接写库名，CMake自动识别后缀）
target_link_libraries(${PROJECT_NAME}
    PRIVATE
    my_lib
)

# 方式3: FetchContent下载远程库
include(FetchContent)
FetchContent_Declare(
  json
  GIT_REPOSITORY https://github.com/nlohmann/json.git
  GIT_TAG v3.11.2
)
FetchContent_MakeAvailable(json)
```

### 6. 条件编译示例

**src/hello.h**
```cpp
#pragma once
#include <string>

class Hello {
public:
    void sayHello();
    
    #ifdef ENABLE_FEATURE_X
    void featureX();
    #endif
    
    #if defined(WIN32)
    void windowsSpecific();
    #elif defined(LINUX)
    void linuxSpecific();
    #elif defined(MACOSX)
    void macSpecific();
    #endif
};
```

### 7. 单元测试集成（CTest）

**tests/CMakeLists.txt**
```cmake
# 启用测试
enable_testing()

# 添加测试可执行文件
add_executable(test_calc
    test_calc.cpp
)

# 链接被测试的库
target_link_libraries(test_calc
    PRIVATE
        core_lib
)

# 添加测试用例
add_test(NAME TestCalcAddition
    COMMAND test_calc
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/tests
)

# 设置测试属性
set_tests_properties(TestCalcAddition
    PROPERTIES
        TIMEOUT 10
        LABELS "unit;fast"
)

# 包含Google Test（如果可用）
find_package(GTest QUIET)
if(GTest_FOUND)
    add_executable(google_tests google_tests.cpp)
    target_link_libraries(google_tests GTest::gtest GTest::gtest_main)
    add_test(NAME GoogleTests COMMAND google_tests)
endif()

# 覆盖率支持（如果使用gcc/clang）
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang" AND CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(test_calc PRIVATE --coverage)
    target_link_libraries(test_calc PRIVATE --coverage)
endif()
```

## 8. 使用不同的生成器
```bash
# Visual Studio 2022 (Windows):
cmake -B build_vs -G "Visual Studio 17 2022" -A x64

# Visual Studio 2019 (Windows):
cmake -B build_vs -G "Visual Studio 16 2019" -A x64

# Ninja (速度快，推荐):
cmake -B build_ninja -G "Ninja"

# Unix Makefiles (Linux/Mac 默认):
cmake -B build_unix -G "Unix Makefiles"

# MinGW Makefiles (Windows + GCC)
cmake -B build_mingw -G "MinGW Makefiles"

# Xcode（macOS）
cmake -B build_xcode -G "Xcode"
```

### 9. 完整的使用示例

**构建和运行**
```bash
# 创建构建目录
mkdir build && cd build

# 配置项目
cmake .. -DCMAKE_BUILD_TYPE=Debug -DENABLE_FEATURE_X=ON

# 编译
cmake --build . --parallel 4

# 运行测试
ctest --output-on-failure

# 安装
cmake --install . --prefix ../install

# 打包
cpack -G ZIP
```

### 10. 实用函数和宏
在根目录CMakeLists.txt中添加：

```cmake
# 自定义函数：添加可执行文件并设置通用属性
function(add_my_executable target_name)
    add_executable(${target_name} ${ARGN})
    
    # 设置通用属性
    set_target_properties(${target_name} PROPERTIES
        CXX_STANDARD 17
        CXX_STANDARD_REQUIRED ON
        CXX_EXTENSIONS OFF
    )
    
    # 添加警告
    if(MSVC)
        target_compile_options(${target_name} PRIVATE /W4)
    else()
        target_compile_options(${target_name} PRIVATE -Wall -Wextra)
    endif()
endfunction()

# 自定义函数：添加库
function(add_my_library lib_name lib_type)
    add_library(${lib_name} ${lib_type} ${ARGN})
    
    # 设置包含目录
    target_include_directories(${lib_name}
        PUBLIC 
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    )
endfunction()

# 使用自定义函数
add_my_executable(myapp app/main.cpp)
add_my_library(mylib STATIC src/mycode.cpp)
```
---
## Windows 和 Linux交叉编译
在 Windows 和 Linux 之间实现 CMake 交叉编译，核心是通过工具链文件（Toolchain File）配置目标平台参数。以下是完整的实现方案：

### 1. 核心原理
CMake 交叉编译通过 `CMAKE_TOOLCHAIN_FILE` 指定目标系统信息。关键变量包括：
- `CMAKE_SYSTEM_NAME`：目标系统（Linux/Windows）
- `CMAKE_SYSTEM_PROCESSOR`：目标处理器架构
- `CMAKE_C_COMPILER`/`CMAKE_CXX_COMPILER`：交叉编译器路径
- `CMAKE_FIND_ROOT_PATH`：目标系统根目录

### 2. Windows → Linux 交叉编译

#### 2.1 方法一：使用 MSYS2/MinGW-w64（推荐）
- **安装交叉编译器**
   ```bash
   # 在 MSYS2 中安装
   pacman -S mingw-w64-x86_64-linux-gnu-gcc
   ```

- **创建工具链文件** `linux-toolchain.cmake`：
   ```cmake
   set(CMAKE_SYSTEM_NAME Linux)
   set(CMAKE_SYSTEM_PROCESSOR x86_64)  # 或 arm、aarch64
   set(CMAKE_C_COMPILER x86_64-linux-gnu-gcc)
   set(CMAKE_CXX_COMPILER x86_64-linux-gnu-g++)
   
   # 设置查找规则
   set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
   set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
   set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
   set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
   ```

- **配置和构建**：
   ```bash
   cmake -S . -B build-linux -DCMAKE_TOOLCHAIN_FILE=linux-toolchain.cmake
   cmake --build build-linux
   ```

#### 2.2 方法二：使用 WSL2（更简单）
在 WSL2 中直接使用原生 Linux 环境编译：
```bash
# 在 WSL 中安装编译工具
sudo apt update
sudo apt install build-essential cmake g++
# 正常编译
cmake -B build && cmake --build build
```

#### 2.3 方法三：使用 Docker
创建 Dockerfile 构建 Linux 可执行文件。

### 3. Linux → Windows 交叉编译

#### 3.1 使用 MinGW-w64 工具链
- **安装交叉编译器**：
   ```bash
   # Ubuntu/Debian
   sudo apt install mingw-w64
   # 或指定架构
   sudo apt install gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64
   ```

- **创建工具链文件** `windows-toolchain.cmake`：
   ```cmake
   set(CMAKE_SYSTEM_NAME Windows)
   set(CMAKE_SYSTEM_PROCESSOR x86_64)  # 或 i686
   
   # 32位 Windows
   set(CMAKE_C_COMPILER i686-w64-mingw32-gcc)
   set(CMAKE_CXX_COMPILER i686-w64-mingw32-g++)
   set(CMAKE_RC_COMPILER i686-w64-mingw32-windres)
   
   # 64位 Windows（使用 x86_64 前缀）
   # set(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc)
   # set(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++)
   
   set(CMAKE_FIND_ROOT_PATH /usr/x86_64-w64-mingw32)
   
   set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
   set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
   set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
   ```

- **配置和构建**：
   ```bash
   cmake -S . -B build-windows -DCMAKE_TOOLCHAIN_FILE=windows-toolchain.cmake
   cmake --build build-windows
   ```

### 4. 关键注意事项
- **构建目录必须为空**：交叉编译配置只在初次生成构建系统时生效，已有构建目录需清空或使用新目录。

- **必须设置 CMAKE_SYSTEM_PROCESSOR**：CMake 不会自动设置此变量，交叉编译时必须手动指定。

- **库依赖处理**：交叉编译时 `find_package` 需要特殊配置：
   ```cmake
   if(CMAKE_CROSSCOMPILING)
       set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
       set(OPENSSL_ROOT_DIR ${CMAKE_FIND_ROOT_PATH}/usr)
       find_package(OpenSSL REQUIRED)
   endif()
   ```

- **条件编译处理**：在 CMakeLists.txt 中检测平台差异：
   ```cmake
   if(WIN32)
       # Windows 特定配置
   elseif(UNIX AND NOT APPLE)
       # Linux 特定配置
   endif()
   ```

### 5. 最佳实践

- **参数化工具链文件**：允许通过命令行覆盖默认值：
   ```cmake
   if(NOT DEFINED CROSS_COMPILER_PREFIX)
       set(CROSS_COMPILER_PREFIX x86_64-linux-gnu)
   endif()
   set(CMAKE_C_COMPILER ${CROSS_COMPILER_PREFIX}-gcc)
   ```

- **编译器检测**：验证交叉编译器是否存在：
   ```cmake
   find_program(CROSS_CC ${CMAKE_C_COMPILER})
   if(NOT CROSS_CC)
       message(FATAL_ERROR "交叉编译器未找到: ${CMAKE_C_COMPILER}")
   endif()
   ```

- **多平台构建**：为不同平台创建独立的构建目录：
   ```bash
   # Linux 构建
   cmake -S . -B build-linux -DCMAKE_TOOLCHAIN_FILE=linux.cmake
   
   # Windows 构建  
   cmake -S . -B build-windows -DCMAKE_TOOLCHAIN_FILE=windows.cmake
   
   # 本地构建（无工具链文件）
   cmake -S . -B build-native
   ```

### 6. 工具链对比

| 方案 | 兼容性 | 配置复杂度 | 适用场景 |
|------|--------|------------|----------|
| WSL2 + 原生编译 | 高 | 中 | 开发调试一体化 |
| MinGW-w64 交叉编译 | 中 | 低 | 轻量级持续集成 |
| Docker 容器化 | 高 | 高 | 标准化构建环境 |

> 通过以上配置，你可以实现在 Windows 上编译 Linux 可执行文件，或在 Linux 上编译 Windows 可执行文件，满足跨平台开发需求。

---

## 最佳实践建议

1. **使用现代CMake**：尽量使用 3.10+ 版本，采用 `target_*` 命令而非全局设置
2. **避免硬编码路径**：使用 `${CMAKE_SOURCE_DIR}` 等内置变量
3. **使用生成器表达式**：`$<CONFIG:Debug>` 等实现条件配置
4. **分离配置和构建**：始终使用独立的build目录
5. **版本控制**：在项目中包含 `cmake_minimum_required` 指定最低版本
6. **文档化选项**：使用 `option()` 和 `message()` 让用户了解可配置项
7. **测试覆盖**：集成CTest进行自动化测试
8. **持续集成**：在CI/CD中使用CMake进行标准化构建

---

*本手册基于 CMake 3.16+ 版本编写，部分特性可能需要更高版本支持。*