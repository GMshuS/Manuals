# OpenCode 使用手册

## 前言

OpenCode 是一款开源的 AI 编码代理工具，支持终端界面（TUI）、桌面应用和 IDE 扩展三种使用形式，可帮助开发者高效处理代码分析、功能开发、问题排查等任务，兼容 Windows、macOS、Linux 跨平台环境，支持多种 LLM 提供商及本地模型部署，兼顾隐私安全与易用性。

本手册适用于所有 OpenCode 用户（从新手到进阶开发者），涵盖安装配置、核心功能、命令详解、高级用法及故障排查，力求步骤清晰、可直接操作，帮助用户快速上手并充分发挥工具价值。

---

## 目录

- [前言](#前言)
- [第一章 基础准备](#第一章 - 基础准备)
  - [1.1 前提条件](#11-前提条件)
  - [1.2 版本说明](#12-版本说明)
- [第二章 安装教程（跨平台）](#第二章 - 安装与卸载（跨平台）)
  - [2.1 通用安装方式（全平台）](#21-通用安装方式全平台)
    - [2.1.1 官方安装脚本（推荐）](#211-官方安装脚本推荐)
    - [2.1.2 Node.js 生态安装](#212-nodejs-生态安装 npmbunpnpmyarn)
  - [2.2 分系统安装方式](#22-分系统安装方式)
    - [2.2.1 macOS 系统](#221-macos-系统)
    - [2.2.2 Linux 系统](#222-linux-系统)
    - [2.2.3 Windows 系统](#223-windows-系统)
    - [2.2.4 Docker 安装](#224-docker-安装跨平台)
  - [2.3 安装验证](#23-安装验证)
- [第三章 配置指南](#第三章 - 配置指南)
  - [3.1 API 密钥配置](#31-api-密钥配置)
  - [3.2 模型配置](#32-模型配置)
  - [3.3 工作区配置](#33-工作区配置)
- [第四章 OpenCode 使用方式汇总](#第四章 - opencode-使用方式汇总)
  - [一、TUI 终端交互界面](#一tui-终端交互界面默认主力模式)
  - [二、CLI 命令行模式](#二cli-命令行模式非交互脚本)
  - [三、WEB 网页模式](#三web-网页模式浏览器图形界面)
  - [四、API / Serve 服务模式](#四 api--serve-服务模式后台接口)
  - [五、Attach 多客户端连接模式](#五attach-多客户端连接模式)
  - [六、IDE 插件模式](#六ide-插件模式 vscode-等编辑器)
  - [七、Desktop 桌面客户端模式](#七desktop-桌面客户端模式)
  - [八、SDK 开发模式](#八sdk-开发模式代码调用)
  - [九、Docker 容器模式](#九docker-容器模式)
  - [十、Headless 无头后台模式](#十 headless-无头后台模式)
  - [十一、GitHub 集成模式](#十一 github-集成模式)
  - [十二、插件扩展模式](#十二插件扩展模式)
  - [十三、整体汇总表](#十三整体汇总表)
- [第五章 常见问题与故障排查](#第五章 - 常见问题与故障排查)
- [附录](#附录)

---

## 第一章 基础准备

### 1.1 前提条件

使用 OpenCode 前，需满足以下基础环境要求，确保工具正常运行：

- 终端环境：需安装现代终端模拟器，推荐 WezTerm（跨平台）、Alacritty（跨平台）、Ghostty（Linux/macOS）、Kitty（Linux/macOS），避免使用老旧终端导致 TUI 界面异常。

- API 密钥：若使用在线 LLM 提供商（如 OpenCode Zen、OpenAI、Anthropic 等），需提前获取对应平台的 API 密钥；本地部署模型可无需 API 密钥。

- 系统依赖：

- Linux/macOS：确保系统已安装 curl、git 等基础工具，部分版本需依赖 ncursesw 库（TUI 运行必需）。

- Windows：推荐使用 WSL（Windows Subsystem for Linux）以获得最佳兼容性，原生 Windows 需安装 Microsoft Edge WebView2 Runtime（桌面应用必需）。

### 1.2 版本说明

本手册基于 OpenCode 最新稳定版编写，推荐使用官方最新版本以获得完整功能支持和 bug 修复。可通过以下命令查看当前版本：

```bash
opencode --version
```

---

## 第二章 安装与卸载（跨平台）

OpenCode 提供多种安装方式，可根据自身系统和使用习惯选择，优先推荐使用官方安装脚本或对应系统的包管理工具，确保版本最新。

### 2.1 通用安装方式（全平台）

#### 2.1.1 官方安装脚本（推荐）

适用于 Linux、macOS 及 WSL 环境，一键安装最新版本：

```bash
curl -fsSL https://opencode.ai/install | bash
```

#### 2.1.2 Node.js 生态安装（npm/bun/pnpm/yarn）

若已安装 Node.js 或 Bun 运行时，可通过包管理工具全局安装：

```bash
# npm
npm install -g opencode-ai@latest

# bun
bun install -g opencode-ai@latest

# pnpm
pnpm install -g opencode-ai@latest

# yarn
yarn global add opencode-ai@latest
```

### 2.2 分系统安装方式

#### 2.2.1 macOS 系统

除通用方式外，可通过 Homebrew 安装（推荐使用官方 tap 以获取最新版本）：

```bash
# 官方 tap（推荐）
brew install anomalyco/tap/opencode

# 官方公式（更新频率较低）
brew install opencode
```

#### 2.2.2 Linux 系统

- **Arch Linux：** 可通过 pacman 或 paru 安装

  ```bash
  # 稳定版
  sudo pacman -S opencode

  # 最新版 (AUR)
  paru -S opencode-bin
  ```

- **Debian/Ubuntu：** 需先安装依赖库，再使用通用安装脚本

  ```bash
  sudo apt-get update && sudo apt-get install -y libncursesw5-dev
  curl -fsSL https://opencode.ai/install | bash
  ```

#### 2.2.3 Windows 系统

推荐使用 WSL 环境安装（参考 Linux 安装方式），原生 Windows 可通过以下方式安装：

- **Chocolatey 安装：** `choco install opencode`
- **Scoop 安装：** `scoop install opencode`
- **二进制文件安装：** 从 OpenCode 官方 Releases 页面下载对应 Windows 版本二进制文件，解压后添加至系统环境变量 PATH 即可。

> **注意：** 原生 Windows 环境下，OpenCode 桌面应用需依赖 Microsoft Edge WebView2 Runtime，若启动后出现空白窗口，需先安装或更新该组件。

#### 2.2.4 Docker 安装（跨平台）

适合快速部署，无需配置系统依赖，启动命令如下：

```bash
# 基础版本
docker run -it --rm ghcr.io/anomalyco/opencode

# 带本地模型（如 Qwen3-4B），指定端口避免冲突
docker pull opencode-ai/opencode:v3.0.9.2-qwen
docker run -it --rm -p 8080:8080 -p 8001:8000 opencode-ai/opencode:v3.0.9.2-qwen3
```

> **验证：** 执行 `curl http://localhost:8001/health`，返回 `{status:healthy}` 即表示模型服务正常。

### 2.3 安装验证

安装完成后，在终端执行以下命令，若能正常启动 TUI 界面或显示版本信息，即表示安装成功：

```bash
# 启动 TUI 界面
opencode

# 查看版本
opencode --version
```

### 2.4 更新

#### 2.4.1 自动更新（默认开启）
OpenCode 默认**启动时自动后台检查→下载→下次启动生效**，无需手动操作。

关闭/开启自动更新：
```bash
# 编辑配置文件
vim ~/.config/opencode/opencode.json
```
```json
{
  "autoupdate": false  // true=开启（默认），false=关闭
}
```

#### 2.4.2 手动更新（立即升级）
**1. 升级到最新版**
```bash
opencode upgrade
```

**2. 升级/回退到指定版本**
```bash
opencode upgrade 1.14.27
# 或带v前缀
opencode upgrade v1.14.27
```

#### 2.4.3 不同安装方式的更新命令
- **curl/bash 安装**：直接用 `opencode upgrade`
- **Homebrew（macOS/Linux）**：
```bash
brew update
brew upgrade opencode
```
- **npm 全局安装**：
```bash
npm update -g opencode-ai
```

### 2.5 卸载

#### 2.5.1 官方脚本安装（curl 装的，最常见）
```bash
# 1. 卸载本体
opencode uninstall

# 2. 彻底删配置/缓存/数据（干净）
rm -rf ~/.opencode
rm -rf ~/.config/opencode
rm -rf ~/.local/share/opencode
rm -rf ~/.cache/opencode
rm -rf ~/.local/state/opencode
```

#### 2.5.2 npm 全局安装
```bash
npm uninstall -g opencode-ai
# 或新版包名
npm uninstall -g @anomalyco/opencode

# 再删配置（同上）
rm -rf ~/.opencode ~/.config/opencode
```

#### 2.5.3 安装（macOS）
```bash
brew uninstall opencode

# 再删用户目录残留
rm -rf ~/.opencode ~/.config/opencode
```

#### 2.5.4 验证是否卸载干净
```bash
opencode --version
which opencode
```
都提示 `not found` 就彻底删干净了。

---

## 第四章 OpenCode 使用方式汇总

按**交互形态 + 适用场景**统一整理，包含启动命令、核心用法、对比与选择建议，一次性覆盖所有使用入口。

---

### 一、TUI 终端交互界面（默认主力模式）

#### 简介

纯终端交互式界面，功能最完整、操作效率最高，适合本地深度编码、文件修改、对话调试。

#### 启动方式

```bash
# 默认启动（当前目录为工作区）
opencode

# 显式指定 TUI 模式
opencode tui

# 指定项目目录
opencode --cwd /your/project/path

# 加载配置文件
opencode --config opencode.json
```

#### 核心操作

1. **文件引用** — 对话中直接 `@文件名` 读取并带入上下文：

   ```
   帮我优化 @src/main.py 里的函数
   ```

2. **执行系统命令** — 前缀加 `!`：

   ```
   !git status
   !ls -la
   ```

3. **内置斜杠命令**：

   ```
   /help        查看帮助
   /init        初始化项目 agent 配置
   /models      切换大模型
   /session     管理会话
   /undo        撤销上一步修改
   /exit        退出 TUI
   ```

4. **常用快捷键**：
   - `Ctrl+K`：聚焦输入框
   - `Tab`：切换 Agent 模式
   - `Ctrl+C`：中断/退出

#### 适用场景

日常本地开发、快速修改代码、终端重度用户。

---

### 二、CLI 命令行模式（非交互/脚本）

#### 简介

一次性执行指令，无交互界面，适合批处理、自动化、脚本调用、CI/CD。

#### 1. 单次问答

```bash
opencode run "帮我写一个 Python 登录接口"

# 指定模型
opencode run "解释这段 Go 代码" --model qwen-max
```

#### 2. 从文件读取提示词

```bash
opencode run --file prompt.md
```

#### 3. 管道输入/输出

```bash
echo "分析这段代码" | opencode run > result.md
```

#### 4. 会话与配置

```bash
opencode session list        # 查看历史会话
opencode auth login          # 配置 API Key
opencode models              # 列出可用模型
```

#### 适用场景

脚本自动化、批量任务、无界面服务器、快速调用。

---

### 三、WEB 网页模式（浏览器图形界面）

#### 简介

浏览器访问，可视化操作，支持远程、多标签、低学习成本。

#### 启动

```bash
# 随机端口，自动打开浏览器
opencode web

# 指定端口与监听地址
opencode web --port 8080 --host 0.0.0.0

# 设置访问密码（安全）
export OPENCODE_SERVER_PASSWORD="mypassword"
opencode web --host 0.0.0.0
```

#### 功能

- 完整文件树、对话区、代码编辑
- 多会话标签
- 远程访问（局域网/公网）
- 与 TUI/CLI 会话互通

#### 适用场景

不习惯终端、远程开发、团队临时协作、大屏展示。

---

### 四、API / Serve 服务模式（后台接口）

#### 简介

启动后台 HTTP 服务，对外提供标准 API，用于二次开发、多端接入。

#### 启动服务

```bash
opencode serve --port 4096 --host 0.0.0.0
```

#### 调用示例（curl）

```bash
curl http://localhost:4096/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-sonnet",
    "messages": [{"role":"user","content":"优化这段代码"}]
  }'
```

#### 适用场景

自建 AI 服务、接入自有系统、多客户端共享一个实例。

---

### 五、Attach 多客户端连接模式

#### 简介

一个服务端，多个客户端同时连接，共享会话与文件状态。

#### 使用流程

1. 先启动服务：
   ```bash
   opencode web --port 4096
   # 或 opencode serve
   ```
2. 另一终端连接：
   ```bash
   opencode attach http://localhost:4096
   ```

#### 适用场景

多设备切换、多人协作、同一会话跨终端使用。

---

### 六、IDE 插件模式（VS Code 等编辑器）

#### 简介

内嵌到编辑器，直接操作当前文件与选中代码，无缝开发。

#### 安装

```bash
code --install-extension opencode.opencode
```

#### 功能

- 读取当前文件/选中代码
- 内部分屏对话
- 直接生成/替换代码
- 会话与 TUI 互通

#### 适用场景

编辑器内编码、不想切换窗口。

---

### 七、Desktop 桌面客户端模式

#### 简介

独立桌面 GUI 程序，不依赖终端与浏览器。

#### 启动

```bash
opencode desktop
```

#### 功能

- 系统托盘、多窗口、通知
- 完整文件管理与对话
- 自动更新

#### 适用场景

喜欢桌面软件、非技术用户、日常轻量使用。

---

### 八、SDK 开发模式（代码调用）

#### 简介

官方 JS/TS SDK，在项目代码里直接调用 OpenCode。

#### 安装

```bash
npm install @opencode-ai/sdk
```

#### 示例

```typescript
import { createOpencodeClient } from "@opencode-ai/sdk"

const client = createOpencodeClient({
  baseUrl: "http://localhost:4096"
})

const res = await client.chat({
  messages: [{ role: "user", content: "生成一个函数" }]
})
```

#### 适用场景

二次开发、构建自有 AI 工具、集成到业务系统。

---

### 九、Docker 容器模式

#### 简介

容器化部署，环境隔离，不污染主机，适合服务器部署。

#### 启动

```bash
docker run -it --rm \
  -v $(pwd):/project \
  -p 4096:4096 \
  opencode-ai/opencode \
  opencode serve --host 0.0.0.0
```

#### 适用场景

服务器快速部署、干净环境测试、云主机运行。

---

### 十、Headless 无头后台模式

#### 简介

纯后台运行，无任何界面，长期驻留服务。

```bash
nohup opencode serve --headless &
```

#### 适用场景

后台常驻服务、低资源服务器运行。

---

### 十一、GitHub 集成模式

#### 简介

与 GitHub 联动，自动处理 PR、Issue、代码审查。

```bash
opencode github install
```

**功能：**
- PR 自动代码评审
- Issue 自动分析与修复
- 自动生成文档与测试

#### 适用场景

开源项目、团队协作、自动化研发流程。

---

### 十二、插件扩展模式

#### 简介

通过插件扩展 OpenCode 能力。

```bash
opencode plugin install @opencode/google-search
```

**支持：** 联网搜索、自定义工具、外部 API 调用等。

---

### 十三、整体汇总表

| 方式     | 启动关键词         | 交互形式   | 适合人群/场景          |
|----------|--------------------|------------|------------------------|
| TUI      | `opencode`         | 终端交互   | 本地开发、终端用户     |
| CLI      | `opencode run`     | 命令行     | 脚本、自动化、批量任务 |
| WEB      | `opencode web`     | 浏览器     | 远程、可视化、协作     |
| API      | `opencode serve`   | 后台接口   | 二次开发、系统集成     |
| Attach   | `opencode attach`  | 多端连接   | 多设备共享会话         |
| IDE 插件 | 编辑器安装         | 内嵌界面   | 编辑器内编码           |
| Desktop  | `opencode desktop` | 桌面 GUI   | 桌面用户、非技术人员   |
| SDK      | npm 安装           | 代码调用   | 开发者二次开发         |
| Docker   | docker run         | 容器       | 服务器、隔离环境       |
| Headless | nohup + serve      | 后台驻留   | 长期服务、低资源       |
| GitHub   | `opencode github`  | 平台集成   | 开源项目、自动化       |
| Plugins  | `opencode plugin`  | 扩展能力   | 增强功能、自定义工具   |

**最简使用建议：**

- 日常写代码 → **TUI**
- 自动化脚本 → **CLI**
- 远程/浏览器用 → **WEB**
- 编辑器内用 → **IDE 插件**
- 服务器部署 → **Docker + Serve**
- 二次开发 → **API + SDK**

---

## 第三章 配置指南

> **提示：** 本章内容正在补充中，以下为配置概览。

### 3.1 API 密钥配置

OpenCode 支持多种 LLM 提供商，需根据使用的模型配置对应 API 密钥：

```bash
# 方式一：通过环境变量配置
export OPENCODE_API_KEY="your-api-key-here"

# 方式二：通过配置文件
# 在项目根目录创建 opencode.json
{
  "api_key": "your-api-key-here"
}
```

### 3.2 模型配置

```bash
# 查看可用模型
opencode models

# 切换模型（在 TUI 中使用 /models 命令）
```

### 3.3 工作区配置

在项目根目录创建 `opencode.json` 配置文件：

```json
{
  "workdir": "./src",
  "ignore": ["node_modules", "*.log", ".git"],
  "model": "claude-3-sonnet"
}
```

---

## 第五章 常见问题与故障排查

### 5.1 TUI 界面显示异常

**问题：** TUI 界面出现乱码或显示不全

**解决方案：**
1. 确保使用现代终端（WezTerm、Alacritty、Kitty 等）
2. 检查终端编码是否为 UTF-8
3. 确保安装了 ncursesw 库（Linux/macOS）

### 5.2 API 连接失败

**问题：** 无法连接到 LLM 服务

**解决方案：**
1. 检查 API 密钥是否正确配置
2. 检查网络连接
3. 确认代理设置（如需）

### 5.3 Windows 桌面应用空白

**问题：** 桌面应用启动后显示空白窗口

**解决方案：**
1. 安装或更新 Microsoft Edge WebView2 Runtime
2. 重启应用程序

### 5.4 Docker 服务无法访问

**问题：** Docker 容器启动后无法访问服务

**解决方案：**
1. 确认端口映射正确（`-p 8080:8080`）
2. 检查防火墙设置
3. 确认监听地址为 `0.0.0.0`

---

## 附录

### A. 快捷键速查表

| 快捷键   | 功能         |
|----------|--------------|
| Ctrl+K   | 聚焦输入框   |
| Tab      | 切换 Agent 模式 |
| Ctrl+C   | 中断/退出    |

### B. 相关链接

- [OpenCode 官方文档](https://opencode.ai)
- [GitHub 仓库](https://github.com/anomalyco/opencode)
- [问题反馈](https://github.com/anomalyco/opencode/issues)

---