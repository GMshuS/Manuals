# C/C++ 测试框架知识总结

> 本文档基于实际工程咨询整理，覆盖 **gtest（GoogleTest）**、**doctest**、**MSTest** 三大框架的介绍、安装与使用，并结合"多人维护、Windows+Linux 跨平台、MSVC + CMake 双构建"的项目背景给出选型结论。
>
> 阅读前提：C++11 及以上；编译器涉及 MSVC / GCC / Clang。

---

## 1. C/C++ 主流框架对比表

### 1.1 六大主流框架横向对比

| 框架 | 部署形态 | 原生 Mock | BDD 风格 | 编译速度 | 跨平台 | 许可证 | 核心优势 | 主要短板 | 最适合场景 |
|---|---|---|---|---|---|---|---|---|---|
| **GoogleTest (gtest) + GMock** | 源码库，需编译链接，非头文件 | ✅ GMock 原生配套，工业级 | 弱，仅基础 xUnit | 中等，源码量大编译偏慢 | ✅ Windows/Linux/macOS，MSVC/GCC/Clang | BSD 3-Clause（商用友好） | 生态最强，参数化/夹具/死亡测试完善；VS、CI、静态工具集成成熟 | 非头文件需编译；GitHub 访问易出网络问题；编译耗时相对高 | 多人跨平台、需要大量 Mock、企业长期维护 |
| **Catch2** | 头文件库（v3 单头引入） | ❌ 内置 Mock 弱，需搭配 Trompeloeil | ✅ 强 BDD（Given/When/Then、section），可读性极好 | 中 | ✅ Windows/Linux/macOS | Boost License | 测试代码优雅，错误信息清晰，自动发现用例；支持 benchmark | v2→v3 破坏性升级；Mock 需第三方库；大项目编译压力上升 | BDD 风格、现代 C++ 项目，不想编译测试库 |
| **doctest** | 头文件库，极简 | ❌ 无原生 Mock，需 Trompeloeil | 基础支持 | ⭐⭐⭐⭐⭐ 极快（主流 C++ 框架中最快） | ✅ Windows/Linux/macOS | MIT License | 轻量、编译飞快；可嵌入生产代码；API 简洁 | 夹具/参数化能力偏弱；生态比 Catch2/gtest 小 | 大量小用例追求编译速度；嵌入式、性能敏感场景 |
| **CppUTest** | 源码库，需编译 | ✅ CppUMock 配套，支持 C 语言 | ❌ 无 BDD | 快，代码库很小 | ✅ 极强可移植，老旧编译器/嵌入式 | BSD | **原生支持纯 C 代码**；内存泄漏检测；适合资源受限嵌入式 | 断言语法老旧；不擅长现代 C++ 复杂类型；生态小 | 嵌入式、纯 C 项目、裸机/RTOS 测试 |
| **Boost.Test** | Boost 库组件，可选头文件模式 | ❌ 无原生 Mock | 基础 BDD | 慢（依赖 Boost） | ✅ | Boost License | 集成 Boost 生态，功能全面，报告格式多 | 依赖庞大 Boost 库，引入成本高；编译慢；上手复杂 | 本身已依赖 Boost 的项目 |
| **CppUnit** | 编译库，老框架 | ❌ 无原生 Mock | ❌ | 中等 | ✅ | LGPL | 老牌 xUnit，历史久 | 已基本停止活跃维护，语法老旧，生态停滞 | 遗留老项目维护；新项目不要选 |

### 1.2 关键选型要点

- **需要大量 Mock 打桩**：gtest + GMock 仍是综合最优。Catch2/doctest 虽好用，但 Mock 需额外引入 Trompeloeil，学习与调试成本高于 GMock。
- **几乎不需要 Mock、只做简单单测**：优先 doctest，编译速度优势巨大；想写可读 BDD 风格选 Catch2。
- **代码包含大量纯 C / 嵌入式**：CppUTest 更合适。

### 1.3 小众备选（简要说明）

- **Microsoft C++ Native Unit Test Framework（MSTest for C++）**：VS 内置，**仅 Windows MSVC 可用，Linux 完全无法使用**，跨平台需求下直接排除。
- **Trompeloeil**：不是完整测试框架，是**专用 Mock 库**，常搭配 Catch2/doctest 使用。

---

## 2. gtest 框架详解（介绍、安装、使用）

### 2.1 介绍

GoogleTest（简称 gtest）是 Google 开源的 C++ 单元测试框架，**GMock 是配套 Mock 打桩库**，工业级标准，广泛用于大型项目。

| 项目 | 说明 |
|---|---|
| 配套 Mock | ✅ **GMock 原生内置**，最大优势：接口 mock、参数匹配、调用次数校验 |
| 断言类型 | **ASSERT_xxx（致命断言，失败终止当前用例）** / **EXPECT_xxx（非致命，记录失败继续跑）** |
| 高级功能 | 测试夹具 TestFixture、参数化测试、类型参数测试、死亡测试、测试过滤、JUnit XML 报告 |
| 编译器 | MSVC、GCC、Clang 全支持 |
| 跨平台 | Windows / Linux / macOS |
| 构建方式 | 源码编译库（**非头文件库**），需编译出 gtest/gmock 静态库 |
| 许可证 | BSD 3-Clause，商用免费 |
| 生态 | CI、VS 测试适配器、静态扫描工具集成成熟 |

**短板**：源码编译耗时高于 doctest/Catch2；Windows MSVC 全局安装场景极易踩 **MT/MD 运行时库不匹配链接冲突（LNK2038）**。

### 2.2 安装

#### 2.2.1 可用性检查

**方式一：CMake 探测（最标准，跨平台通用）**

```cmake
cmake_minimum_required(VERSION 3.10)
project(check_gtest)
find_package(GTest)
if(GTest_FOUND)
    message(STATUS "✅ GTest found, version: ${GTest_VERSION}, include: ${GTEST_INCLUDE_DIRS}")
else()
    message(STATUS "❌ GTest NOT found")
endif()
```

**方式二：Linux 文件检索（源码/包安装均适用）**

```bash
# 包管理器查询（仅系统包安装可见）
dpkg -l | grep gtest        # Debian/Ubuntu
rpm -qa | grep gtest        # Fedora/RHEL/CentOS
pacman -Qs gtest            # Arch

# 查找头文件与库（源码编译安装的也能查到）
find /usr /usr/local -name "gtest.h" 2>/dev/null
find /usr /usr/local -name "libgtest*.so" -o -name "libgtest*.a" 2>/dev/null
```

**方式三：Windows 文件检索（PowerShell）**

```powershell
# vcpkg 安装查询
vcpkg list | findstr gtest

# 全盘搜索头文件 / 库文件（注意：源码内嵌在项目目录时，C 盘搜不到）
Get-ChildItem -Path C:\ -Recurse -Filter gtest.h -ErrorAction SilentlyContinue
Get-ChildItem -Path C:\ -Recurse -Filter gtest.lib -ErrorAction SilentlyContinue
```

**方式四：极简编译验证（最严谨，编译链接成功才算真正可用）**

```cpp
// test_gtest.cpp
#include <gtest/gtest.h>
TEST(DummyTest, ok) {
    ASSERT_TRUE(true);
}
int main(int argc, char** argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
```

```bash
# Linux
g++ test_gtest.cpp -lgtest -lgtest_main -pthread -o test_gtest
# Windows (MSVC)
cl test_gtest.cpp /I"gtest头目录" gtest.lib gtest_main.lib
```

#### 2.2.2 四种引入/安装方式对比

| 方案 | 是否保留 git 提交 sln | 构建联网 | MT/MD 冲突风险 | 适合场景 |
|---|---|---|---|---|
| **Git Submodule + add_subdirectory** | ✅ 可以 | ❌ 仅首次拉取源码 | ✅ 无风险（自动对齐编译选项） | ⭐⭐⭐⭐⭐ 匹配 sln 工作流、跨平台、多人维护、规避 GitHub 网络问题 |
| **FetchContent** | ⚠️ 可以，但 sln 易与 CMake 不同步 | ⚠️ 首次构建联网（可离线改造） | ✅ 无风险 | ⭐⭐⭐⭐ 长期转型纯 CMake（不再提交 sln） |
| **源码内嵌（vendor，完整源码提交 git）** | ✅ | ❌ 完全离线 | ✅ 无风险 | ⭐⭐⭐ 内网、极少升级 gtest；多人长期维护不推荐 |
| **全局安装（vcpkg / apt）** | ✅ | ❌ 构建离线 | ❌ Windows 高概率 LNK2038 | ⭐⭐ 不推荐，多人异构环境坑多 |

**方式 1：全局系统安装（find_package 模式）**

```powershell
# Windows (vcpkg)
vcpkg install gtest:x64-windows
```

```bash
# Linux (Ubuntu/Debian)
sudo apt install libgtest-dev libgmock-dev
```

```cmake
enable_testing()
find_package(GTest REQUIRED)
add_executable(test_app test.cpp)
target_link_libraries(test_app PRIVATE GTest::gtest_main GTest::gmock)
include(GoogleTest)
gtest_discover_tests(test_app)
```

> ❌ 致命缺点：Windows MSVC 易出现 LNK2038 MT/MD 运行时库不匹配；团队成员本地版本/编译选项不一致造成环境碎片化；CI 需预先部署包管理工具。

**方式 2：源码内嵌子项目（vendor 模式，add_subdirectory）**

```cmake
add_subdirectory(thirdparty/googletest)
add_executable(test_app test.cpp)
target_link_libraries(test_app PRIVATE gtest_main gmock)
```

> ✅ 完全离线；编译选项自动继承主工程（MT/MD 自动对齐）；可继续提交 sln。
> ❌ 仓库体积膨胀；升级需手动替换整个源码目录；多人项目易误改 gtest 源码；git 历史臃肿。

**方式 3：Git Submodule（⭐ 推荐，匹配"保留 sln + 离线构建 + 跨平台"）**

仓库不提交 gtest 源码，只保存 git 引用指针，构建时 `add_subdirectory`，编译行为等价 vendor 内嵌。

```bash
# 添加 submodule（国内网络可换 gitee 镜像）
git submodule add https://github.com/google/googletest.git thirdparty/googletest
# git submodule add https://gitee.com/mirrors/googletest.git thirdparty/googletest
git commit -m "add googletest submodule"

# 新人拉取代码必须执行
git submodule update --init --recursive
```

配套 Windows 一键脚本 `init_submodule.bat`：

```bat
@echo off
git submodule update --init --recursive
pause
```

CMake 脚本：

```cmake
cmake_minimum_required(VERSION 3.16)
project(net_core)
enable_testing()

# submodule 源码目录
add_subdirectory(thirdparty/googletest)

# 业务库
add_library(net_core src/net_core.cpp)
target_include_directories(net_core PUBLIC src)

# 测试程序
add_executable(net_core_tests tests/test_main.cpp tests/test_sample.cpp)
target_link_libraries(net_core_tests PRIVATE net_core gtest_main gmock)

# 自动发现测试用例，支持 ctest
include(GoogleTest)
gtest_discover_tests(net_core_tests)
```

> ⚠️ 坑点：新人容易忘记执行 `git submodule update --init`，README 与 CI 脚本必须写明。

**方式 4：FetchContent（CMake 自动拉取，适合不再提交 sln 的场景）**

```cmake
include(FetchContent)
FetchContent_Declare(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG v1.14.0
  # 国内网络可换 gitee 镜像
  # GIT_REPOSITORY https://gitee.com/mirrors/googletest.git
)
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)   # 关闭 gtest 自身测试，减少编译
set(BUILD_GMOCK ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

add_executable(net_core_tests tests/test.cpp)
target_link_libraries(net_core_tests PRIVATE net_core GTest::gtest_main GTest::gmock)
include(GoogleTest)
gtest_discover_tests(net_core_tests)
```

> ⚠️ 致命限制：CMake 工程最佳实践要求 **sln 是生成产物、不提交 git**；若继续提交 sln，修改 CMake 后 sln 易不同步，多人维护极易踩坑。
> 内网离线场景可用 `SOURCE_DIR` 指定本地预下载源码包，跳过 git 拉取。

### 2.3 使用

#### 基础单元测试（TEST 宏）

```cpp
#include <gtest/gtest.h>

// 测试套件：MathTest，测试用例：AddTest
TEST(MathTest, AddTest) {
    EXPECT_EQ(1 + 2, 3);      // 非致命断言，失败继续执行后续代码
    EXPECT_NE(1 + 1, 3);

    ASSERT_TRUE(2 > 1);       // 致命断言，失败立刻终止当前 TEST
}
```

#### 测试夹具（TEST_F，复用初始化/销毁逻辑）

```cpp
#include <gtest/gtest.h>

class NetTest : public ::testing::Test {
protected:
    void SetUp() override {
        // 每个测试用例执行前初始化资源
    }
    void TearDown() override {
        // 每个测试用例结束后释放资源
    }
};

TEST_F(NetTest, PacketParseTest) {
    EXPECT_TRUE(true);
}
```

#### GMock Mock 示例（核心能力）

```cpp
#include <gtest/gtest.h>
#include <gmock/gmock.h>

// 抽象接口
class IDataStorage {
public:
    virtual ~IDataStorage() = default;
    virtual int Read(int id) = 0;
};

// Mock 类
class MockStorage : public IDataStorage {
public:
    MOCK_METHOD(int, Read, (int id), (override));
};

TEST(MockDemo, ReadTest) {
    MockStorage mock;
    // 预期调用 Read(100) 一次，返回 999
    EXPECT_CALL(mock, Read(100)).Times(1).WillOnce(::testing::Return(999));

    int ret = mock.Read(100);
    EXPECT_EQ(ret, 999);
}
```

#### 常用断言清单

| 宏 | 类型 | 作用 |
|---|---|---|
| `EXPECT_EQ(a, b)` | 非致命 | a == b |
| `EXPECT_NE(a, b)` | 非致命 | a != b |
| `EXPECT_TRUE(cond)` | 非致命 | 条件为真 |
| `EXPECT_FALSE(cond)` | 非致命 | 条件为假 |
| `ASSERT_EQ(a, b)` | 致命 | a == b，失败终止当前用例 |
| `ASSERT_TRUE(cond)` | 致命 | 条件为真，失败终止当前用例 |

#### 跨平台编译运行

```powershell
# Windows (MSVC，CMake 生成 VS 解决方案)
cmake -B build -G "Visual Studio 17 2022"
cmake --build build
cd build
ctest                                    # 或直接运行 .\build\Debug\net_core_tests.exe
```

```bash
# Linux (GCC)
cmake -B build
cmake --build build
cd build
ctest
./net_core_tests
```

#### 常见坑提醒

1. Windows MSVC 全局 vcpkg 安装：**务必保证 gtest 编译时 /MT、/MD 与业务工程完全一致，否则 LNK2038**。
2. gtest v1.14+ 依赖 C++11，CMake 中务必设置 `set(CMAKE_CXX_STANDARD 11)`。
3. 现代 GTest CMake target 自动处理 pthread 链接，旧版本需手动 `-pthread`。
4. submodule 升级版本：进入 `thirdparty/googletest` 切换 tag，主仓库提交 submodule 引用即可。

---

## 3. doctest 框架详解（介绍、安装、使用）

### 3.1 介绍

doctest 是**单头文件、轻量级 C++ 单元测试框架**，MIT 许可证，跨平台，**编译速度远快于 gtest/Catch2**；最大短板是**没有内置 Mock**（需搭配 Trompeloeil）。

| 项目 | 说明 |
|---|---|
| 架构 | Header-only，仅一个 `doctest.h`，**不需要编译库**，直接 include |
| 许可证 | MIT（商用无压力） |
| 编译性能 | ⭐⭐⭐⭐⭐，编译开销极小，适合大量小用例 |
| 断言 | `CHECK`（失败继续跑后续用例）/ `REQUIRE`（失败直接终止当前用例） |
| 测试注册 | 自动注册测试用例，无需手动注册宏 |
| BDD | 支持 `SUBCASE` 做简单 BDD 风格 |
| Mock | ❌ 无内置 Mock，需搭配 Trompeloeil（同为头文件库） |
| CI 集成 | 支持 CTest，可输出 JUnit XML 报告 |
| 优势 | 可嵌入生产代码（宏关闭测试代码）；跨平台一致；引入极简 |
| 劣势 | 夹具、参数化能力弱；生态比 gtest 小；Mock 需额外库 |

> 最低支持：C++11；MSVC / GCC / Clang；Windows、Linux、macOS 全支持。
> 适合：**不需要大量复杂 Mock**、追求编译速度、轻量、跨平台。重度依赖 GMock 打桩的项目迁移成本高。

### 3.2 安装（四种引入方式）

**方案 1：手动下载头文件（最简单，适合保留 sln 提交 git、离线）**

1. 下载 `doctest.h`（v2.4.11 稳定版）放到项目 `thirdparty/doctest/`
2. VS sln 添加 include 目录；Linux 编译时 `-Ithirdparty/doctest`

> ✅ 完全离线，不依赖网络；❌ 升级需手动替换头文件。

**方案 2：Git Submodule（推荐，匹配保留 sln 的工作流）**

```bash
git submodule add https://github.com/doctest/doctest thirdparty/doctest
# 国内网络：git submodule add https://gitee.com/mirrors/doctest.git thirdparty/doctest
git commit -m "add doctest submodule"

# 新人拉取代码
git submodule update --init --recursive
```

**方案 3：FetchContent（CMake 原生）**

```cmake
include(FetchContent)
FetchContent_Declare(
  doctest
  GIT_REPOSITORY https://github.com/doctest/doctest.git
  GIT_TAG v2.4.11
  GIT_SHALLOW ON
)
FetchContent_MakeAvailable(doctest)

target_link_libraries(test_target PRIVATE doctest::doctest)
```

**方案 4：vcpkg / conan 全局安装**

```powershell
# Windows vcpkg
vcpkg install doctest
```

### 3.3 使用

> **注意**：整个项目**只能有一个 cpp 文件定义 `DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN`**（生成 main 函数）；其他测试文件只 include 头文件，不要定义该宏。

`test_main.cpp`（唯一主文件）：

```cpp
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include "doctest.h"
```

`test_math.cpp`（测试用例）：

```cpp
#include "doctest.h"
#include "math_func.h"

TEST_CASE("math::add 测试") {
    CHECK(add(1, 2) == 3);      // 断言失败，继续执行后面代码
    REQUIRE(add(0, 0) == 0);    // 断言失败，直接终止当前 TEST_CASE

    SUBCASE("负数相加") {
        CHECK(add(-1, -2) == -3);
    }
}
```

**常用断言**：

- `CHECK(cond)`：条件不满足，记录失败，继续跑当前用例剩余代码
- `REQUIRE(cond)`：条件不满足，**立刻停止当前 TEST_CASE**
- `CHECK_EQ(a, b)` / `REQUIRE_EQ(a, b)`：相等断言，打印 a、b 实际值
- `CHECK_THROWS(表达式)`：期望抛出异常
- `CHECK_NOTHROW(表达式)`：期望不抛异常

**CMake 完整最小示例（Windows MSVC / Linux GCC 通用）**：

```cmake
cmake_minimum_required(VERSION 3.16)
project(demo LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

enable_testing()

# 业务库
add_library(math_lib math_func.cpp)
target_include_directories(math_lib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

# 测试程序（submodule 本地头文件引入）
add_executable(unit_test test_main.cpp test_math.cpp)
target_link_libraries(unit_test PRIVATE math_lib)
target_include_directories(unit_test PRIVATE thirdparty/doctest)

# 自动发现测试，支持 ctest
include(doctest)
doctest_discover_tests(unit_test)
```

**编译运行**：

```powershell
# Windows
cmake -B build -G "Visual Studio 17 2022"
cmake --build build
cd build
./unit_test.exe        # 或 ctest
```

```bash
# Linux
cmake -B build
cmake --build build
cd build
./unit_test            # 或 ctest
```

**Mock 配套：Trompeloeil（头文件 Mock 库）**

```cpp
#include "doctest.h"
#include "trompeloeil.hpp"

// 接口
struct IStorage {
    virtual ~IStorage() = default;
    virtual void save(const std::string& s) = 0;
};

// Mock
struct MockStorage : IStorage {
    MAKE_MOCK1(save, void(const std::string&), override);
};

TEST_CASE("test mock") {
    MockStorage mock;
    REQUIRE_CALL(mock, save("hello")).TIMES(1);   // 预期调用一次 save("hello")
    business_func(&mock);                          // 业务函数调用 mock
}
```

> 缺点：Trompeloeil 语法学习成本高于 GMock，复杂场景写起来不如 GMock 顺手。

### 3.4 doctest VS gtest 对比

| 对比项 | doctest | gtest + GMock |
|---|---|---|
| 引入 | 单头文件，header-only | 源码库，需要编译 |
| 编译速度 | 极快 | 慢 |
| Mock | 无原生 Mock，依赖 Trompeloeil | 原生 GMock，工业级，功能强 |
| 跨平台 | ✅ Windows/Linux/MSVC/GCC | ✅ |
| VS 支持 | 好，可直接 sln 运行 | 好 |
| 仓库引入 | 头文件，submodule 友好 | 源码库 |
| 许可证 | MIT | BSD 3-Clause |
| 适合场景 | 简单单测、编译速度优先、Mock 少 | 大量 Mock、企业复杂业务，生态完善 |

### 3.5 坑点提醒

1. **只能一个 cpp** 定义 `DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN`，多处定义会报重复 main 链接错误。
2. MSVC 开启预编译头时，`#define` 必须在 `#include "doctest.h"` **之前**。
3. Trompeloeil 对 C++ 版本要求更高，部分老编译器会踩语法坑。
4. doctest 单头文件体积很大，大量测试文件同时 include 会增加预处理开销，但整体仍远快于 gtest。

---

## 4. MSTest 框架详解（介绍、安装、使用）

### 4.1 介绍（先区分两个东西，非常关键）

> **MSTest（.NET）**：C#/.NET 的测试框架，跨平台 Windows/Linux；
> **Microsoft C++ Native Unit Test Framework（口语常称 "MSTest for C++"）**：**仅 Windows + Visual Studio 可用，Linux 完全不支持**——这是核心！

⚠️ **针对跨平台需求**：项目需要 Windows + Linux 跨平台 C/C++ 时，**C++ 原生 MSTest 直接排除**，Linux 下无法编译运行，这是硬限制。

**Microsoft C++ Native Unit Test Framework 特性**：

| 项目 | 说明 |
|---|---|
| 适用平台 | **仅 Windows MSVC + Visual Studio** |
| 支持平台 | ❌ 不支持 Linux、macOS、GCC/Clang，不能跨平台 |
| 许可证 | VS 自带，免费使用 |
| 核心特点 | 深度集成 VS【测试资源管理器】，IDE 内一键运行、调试、查看结果、代码覆盖率 |
| Mock | ❌ 无内置 Mock，需手写或引入第三方库 |
| 宏风格 | `TEST_CLASS` / `TEST_METHOD` |

### 4.2 安装

**不需要下载安装包，安装 Visual Studio 时勾选组件即可**：

1. 安装 VS2019/2022，在安装器勾选：**使用 C++ 的桌面开发**
2. 新建项目 → 搜索 **本机单元测试项目（C++）**，模板自带该框架
3. 头文件：`CppUnitTest.h`，VS 项目模板自动配置引用

**可用性检查**：打开 VS，新建本机 C++ 单元测试项目，编译不报错即环境正常。
> Linux：无任何官方支持，CMake 无法编译，**直接无法使用**。

### 4.3 使用

#### 基础代码示例

```cpp
#include "CppUnitTest.h"
using namespace Microsoft::VisualStudio::CppUnitTestFramework;

// 测试类
TEST_CLASS(MathTest)
{
public:
    // 测试方法
    TEST_METHOD(TestAdd)
    {
        Assert::AreEqual(1 + 2, 3);
        Assert::IsTrue(10 > 1);
    }

    TEST_METHOD(TestString)
    {
        std::wstring s1 = L"hello";
        std::wstring s2 = L"hello";
        Assert::AreEqual(s1, s2);
    }
};
```

#### 常用断言

| 断言 | 说明 |
|---|---|
| `Assert::AreEqual(a, b)` | 相等断言 |
| `Assert::AreNotEqual(a, b)` | 不相等 |
| `Assert::IsTrue(cond)` | 条件为真 |
| `Assert::IsFalse(cond)` | 条件为假 |
| `Assert::Fail(L"message")` | 强制失败 |

#### 在现有 sln 中集成

1. 在现有 sln 右键 → 添加新项目 → **本机单元测试项目（C++）**
2. 在测试项目属性中，添加引用业务库 net_core
3. 编写测试代码；打开菜单【测试】→【测试资源管理器（Ctrl+E, T）】
4. 在测试资源管理器点击「全部运行」，可单独调试某个用例

#### 命令行运行（Windows）

```powershell
# vstest.console.exe 运行测试 dll
vstest.console.exe .\x64\Debug\unittestproject1.dll
```

### 4.4 MSTest（.NET 版）说明

MSTest V2 是 .NET 平台（C#）的单元测试框架，**跨平台 Windows/Linux/macOS**，dotnet CLI 驱动。
👉 **不能用来写原生 C/C++ 单元测试**，只支持 C# 托管代码，C++ 项目不适用。

### 4.5 对比与选型结论

**C++ MSTest VS gtest（结合跨平台需求）**：

| 项目 | C++ MSTest（VS 原生） | gtest + GMock |
|---|---|---|
| 跨平台 | ❌ 仅 Windows，Linux 不可用 | ✅ Windows + Linux + macOS |
| 编译器 | 仅 MSVC | MSVC / GCC / Clang |
| Mock | ❌ 无原生 Mock | ✅ GMock 强大原生 Mock |
| 构建方式 | VS sln 工程，不支持纯 CMake 跨平台 | CMake、sln 都支持 |
| IDE 集成 | VS 测试资源管理器深度集成 | VS 可通过测试适配器集成 |
| 许可证 | VS 内置 | BSD 3-Clause，商用友好 |
| 适用场景 | 仅 Windows 纯 MSVC 项目 | 跨平台、多人维护、需要 Mock |

> ✅ **重要选型结论**：需求是 **Windows + Linux 跨平台 C/C++、MSVC + CMake** 时，**C++ MSTest 不能选**——Linux 环境完全没有官方支持，一旦要跑 Linux CI，测试代码全部作废。MSTest 只适合"只在 Windows VS 跑、完全不需要 Linux"的项目。

**补充**：如果希望保留 VS 测试资源管理器体验，可在 VS 安装 **Google Test 测试适配器**，gtest 用例同样能在测试资源管理器中一键运行调试，兼顾 VS 体验 + Linux 跨平台。

---

## 5. 小结

### 5.1 全框架选型速查

| 框架 | 跨平台 Windows+Linux | 原生 Mock | 适合当前项目？ |
|---|---|---|---|
| **gtest + GMock** | ✅ | ✅ 强 | ⭐⭐⭐⭐⭐ 首选 |
| **doctest** | ✅ | ❌（需 Trompeloeil） | ⭐⭐⭐⭐ Mock 少场景可用 |
| **Catch2** | ✅ | ❌（需 Trompeloeil） | ⭐⭐⭐ BDD 风格 |
| **CppUTest** | ✅ | ✅ CppUMock | ⭐⭐ C 语言/嵌入式 |
| **C++ MSTest** | ❌ 仅 Windows | ❌ | ❌ 不适合跨平台需求 |

### 5.2 最终工程建议（匹配"多人维护 + Windows/Linux 跨平台 + MSVC/CMake + 已提交 sln + GitHub 网络受限"）

1. **保持 gtest + GMock 不变**：现有测试代码已跑通，Mock 能力强，跨平台稳定；问题不在框架本身，而在依赖引入方式。
2. **用 Git Submodule 引入 gtest**（而非继续 vendor 内嵌或全局安装）：
   - 保留现有 sln 提交 git 的工作流，同事拉代码直接打开 sln 编译；
   - 编译阶段不联网，彻底规避 GitHub 网络超时；
   - Windows MSVC / Linux GCC 一套 CMake，gtest 与业务代码共享编译选项，无 MT/MD 链接冲突；
   - 仓库体积不因 gtest 源码膨胀。
3. **README 与 CI 必须写明**：`git submodule update --init --recursive`，并配套一键 bat/sh 脚本降低新人门槛。
4. **长期演进（可选）**：逐步不再提交 sln/vcxproj，统一由 CMake 生成 sln，此时可切换 FetchContent（CMakeLists 为唯一真值，sln 为产物）。
5. **国内网络**：submodule / FetchContent 的仓库地址均可替换为 Gitee 镜像。

### 5.3 核心避坑清单

- **LNK2038（Windows MSVC 最高频坑）**：全局安装 gtest 时 MT/MD 运行时不匹配；源码内嵌 / submodule / FetchContent 自动规避。
- **sln 与 CMake 不同步**：坚持提交 sln 时慎用 FetchContent 原生模式。
- **submodule 忘记拉取**：新人首次编译报找不到头文件，必须文档化 + CI 强制。
- **多 main 冲突**：doctest 只有一个 cpp 定义 `DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN`。
- **跨平台硬限制**：C++ MSTest 仅 Windows；跨平台项目务必选 gtest / doctest / Catch2 等。
