# WSL2 完全手册

> 整合了 WSL2 的安装与卸载、常用命令速查，以及在 WSL2 中使用 OpenCode 的完整指南。

---

## 目录

1. [WSL2 安装与卸载](#一wsl2-安装与卸载)
2. [WSL2 常用命令速查](#二wsl2-常用命令速查)
3. [在 WSL2 中使用 OpenCode](#三在-wsl2-中使用-opencode)

---

## 一、WSL2 安装与卸载

### 前置条件检查

#### 系统版本要求

| 系统 | 最低要求 | 检查方法 |
|------|----------|----------|
| Windows 11 | 所有版本 | Win+R 输入 `winver` 查看 |
| Windows 10 | 2004 版（Build 19041）及以上 | Win+R 输入 `winver` 查看 |

#### 硬件要求

- **CPU 虚拟化**：必须在 BIOS/UEFI 中启用
- **检查方法**：任务管理器 → 性能 → CPU → 查看"虚拟化"状态

### 快速安装法（推荐）

适用于 Windows 10 2004+ 和 Windows 11 系统，一键自动安装。

1. **以管理员身份打开 PowerShell**
2. **执行一键安装命令**：
   ```powershell
   wsl --install
   ```
3. **等待安装完成**：此命令会自动启用 WSL 和虚拟机平台功能、下载安装 WSL2 内核、安装默认 Linux 发行版（Ubuntu）
4. **重启电脑**完成安装
5. **设置用户名和密码**

### 手动安装法

#### 步骤 1：启用 WSL 和虚拟机平台功能

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

#### 步骤 2：重启电脑

#### 步骤 3：安装 WSL2 内核更新包

- **x64 架构**：[WSL2 Linux 内核更新包（x64）](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)
- **ARM64 架构**：[WSL2 Linux 内核更新包（ARM64）](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_arm64.msi)

#### 步骤 4：设置 WSL2 为默认版本

```powershell
wsl --set-default-version 2
```

#### 步骤 5：安装 Linux 发行版

**方法 1：Microsoft Store 安装（推荐）**

打开 Microsoft Store，搜索 Ubuntu、Debian、Kali Linux 等并安装。

**方法 2：命令行安装特定发行版**

```powershell
wsl --list --online
wsl --install -d Ubuntu-22.04
```

### 离线安装法（终极方案）

#### 适用场景

- 网络错误 0x80072efe
- 系统版本较老，不支持 `--web-download` 参数
- Microsoft Store 无法下载
- 防火墙/安全软件阻止连接

#### 安装步骤

**第一步：启用 WSL2 功能**

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

执行完后重启电脑，重启后设置默认 WSL2：

```powershell
wsl --set-default-version 2
```

**第二步：下载 Ubuntu 离线包**

```
https://wslstorestorage.blob.core.wslblob/Ubuntu2204-22040.4.202409210.appx
```

保存到 D 盘根目录。

**第三步：安装离线包**

方法 A：双击安装（最简单）

方法 B：命令行安装

```powershell
cd D:\
Add-AppxPackage .\Ubuntu2204-22040.4.202409210.appx
```

**第四步：初始化 Ubuntu**

1. 打开开始菜单 → 找到 **Ubuntu 22.04 LTS** 并启动
2. 等待几秒自动解压配置
3. 设置 **Linux 用户名**（英文小写）+ **密码**

### 验证安装结果

```powershell
wsl --list --verbose
```

**成功输出示例**：
```
  NAME      STATE           VERSION
* Ubuntu    Running         2
```

### 前置准备：更新系统 + 安装基础依赖

打开 WSL2 终端（Ubuntu），先执行这一步，所有开发环境的基础：

```bash
运行
# 更新软件源（必做）
sudo apt update -y
# 升级系统软件
sudo apt upgrade -y
# 安装编译工具、网络工具、编辑器等通用依赖
sudo apt install -y build-essential curl wget git vim unzip net-tools
```

### 进阶配置

#### 更新 WSL 到最新版本

```powershell
wsl --update
```

#### 更改默认安装位置

```powershell
wsl --export Ubuntu D:\wsl\Ubuntu.tar
wsl --unregister Ubuntu
wsl --import Ubuntu D:\wsl\Ubuntu D:\wsl\Ubuntu.tar --version 2
ubuntu config --default-user 用户名
```

#### 安装图形界面

安装 VcXsrv 或 X410，在 WSL 中安装桌面环境，配置 DISPLAY 环境变量。

### 卸载 WSL

```powershell
wsl --unregister 发行版名称
dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /all /norestart
```

### 常见问题与解决方案

#### 错误 0x80072efe：与微软服务器连接终止

**方案 1：网络重置**

```powershell
netsh winsock reset
netsh int ip reset
ipconfig /flushdns
ipconfig /release
ipconfig /renew
wsl --shutdown
Get-Service LxssManager | Restart-Service
```

完成后重启电脑。

**方案 2：修改 DNS 服务器**

设置为阿里云 `223.5.5.5` 或腾讯云 `119.29.29.29`，备用 `114.114.114.114`。

**方案 3：Web 下载方式**

```powershell
wsl --install -d Ubuntu --web-download
```

**方案 4：离线安装（终极解决）**

#### 错误 0x80370102：未启用虚拟化

进入 BIOS/UEFI 启用 CPU 虚拟化，确保 Hyper-V 相关功能已启用。

#### 错误：WSL 2 需要更新内核组件

下载并安装官方内核更新包。

#### 错误 0x80070003：系统版本过低

升级 Windows 到 2004 版（Build 19041）及以上。

#### 其他检查项

- 确认 WSL 功能已启用
- 检查系统时间与互联网同步
- 临时关闭安全软件

---

## 二、WSL2 常用命令速查

### 基础启停查看

```powershell
# 查看已安装发行版及版本
wsl --list --verbose
wsl -l -v

# 仅列出发行名
wsl -q

# 查看在线可安装系统
wsl --list --online

# 立即关闭所有WSL实例
wsl --shutdown

# 终止指定发行版
wsl -t Ubuntu

# 设置默认启动发行版
wsl -s Ubuntu

# 直接进入默认WSL
wsl

# 以root身份进入指定系统
wsl -u root -d Ubuntu
```

### 版本管理切换

```powershell
# 设置新建系统默认使用WSL2
wsl --set-default-version 2

# 更改已有发行版版本
wsl --set-version Ubuntu 2
```

### 导入导出迁移备份

```powershell
# 导出系统为备份压缩包
wsl --export Ubuntu D:\wsl\ubuntu_backup.tar

# 注销删除现有系统
wsl --unregister Ubuntu

# 导入恢复系统到指定目录
wsl --import Ubuntu D:\wsl\ubuntu D:\wsl\ubuntu_backup.tar --version 2

# 导入后设置默认登录用户
ubuntu config --default-user guosen
```

### 安装卸载

```powershell
# 在线安装指定系统
wsl --install -d Ubuntu

# 离线包安装
Add-AppxPackage 包路径.appx

# 卸载发行版
wsl --unregister Ubuntu
```

### 内核与更新

```powershell
# 更新WSL内核
wsl --update

# 回滚内核版本
wsl --update --rollback

# 查看WSL运行状态
wsl --status
```

### WSL内目录互访

#### WSL访问Windows

```bash
cd /mnt/c
cd /mnt/d
cd /mnt/c/Users/guosen
```

#### Windows访问WSL

资源管理器地址输入 `\\wsl$\Ubuntu`

#### 自动挂载配置

```bash
sudo nano /etc/wsl.conf
```

```ini
[automount]
enabled=true
options="metadata,uid=1000,gid=1000,umask=22"
mountFsTab=false
```

保存后执行 `wsl --shutdown` 重启生效。

### 网络相关

```powershell
wsl --shutdown
wsl hostname -I
```

WSL内查看网卡：

```bash
ip addr
```

#### 忘记密码

```powershell
wsl -u root
passwd 用户名
```

### 日常快捷操作

```bash
# WSL内用VSCode打开当前目录
code .

# 查看系统发行信息
lsb_release -a

# 查看内核版本
uname -r
```

---

## 三、在 WSL2 中使用 OpenCode

在 WSL2 中运行 OpenCode 是官方推荐的方式，能获得比 Windows 原生运行更好的文件系统性能和终端兼容性。

### 安装 OpenCode

#### 方式一：官方脚本（推荐，无需 Node.js）

```bash
curl -fsSL https://opencode.ai/install | bash
```

#### 方式二：npm 安装

```bash
npm install -g opencode-ai
```

#### 方式三：Bun 安装

```bash
bun add -g opencode-ai
```

验证安装：

```bash
opencode --version
```

> 注意：若安装后当前会话找不到 `opencode` 命令，先 `exit` 退出 WSL，重新进入即可生效。

### 配置模型 API

编辑配置文件：

```bash
nano ~/.config/opencode/opencode.json
```

添加 provider（示例）：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "your_provider": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "显示名称",
      "options": {
        "baseURL": "https://your-api-endpoint.com/v1"
      },
      "models": {
        "model-id": {
          "name": "模型显示名"
        }
      }
    }
  }
}
```

配置 API 密钥：

```bash
nano ~/.local/share/opencode/auth.json
```

```json
{
  "your_provider": {
    "type": "api",
    "key": "你的API密钥"
  }
}
```

### VS Code 配置：Remote - WSL

1. Windows 端安装扩展

在 Windows 的 VS Code 中安装：
- Remote - WSL（微软官方，必装）
- 可选：Remote Development 扩展包

2. 连接 WSL2 项目

方法一：从 WSL2 终端启动

在 WSL2 中进入项目目录（可以是 Windows 磁盘上的项目）：

```bash
cd /mnt/c/Users/你的用户名/Projects/my-project
code .
```

VS Code 会自动在 WSL2 中安装 Server 组件，左下角显示 WSL: Ubuntu，此时所有终端、调试、扩展均在 WSL2 环境中运行

方法二：从 VS Code 直接连接

点击 VS Code 左下角 `><` 图标 → Connect to WSL → 选择 Ubuntu。

### 在 VS Code 中使用 OpenCode

#### 方案 A：集成终端直接使用（最简单）

连接 WSL2 后，按 `` Ctrl+` `` 打开 VS Code 集成终端（自动是 WSL2 的 bash/zsh），直接输入：

```bash
opencode
```

所有 TUI 功能、快捷键、模型切换完全可用，且能直接操作 Windows 文件（通过 `/mnt/c/` 路径）

#### 方案 B：OpenCode Desktop + WSL2 Server

若偏好使用 OpenCode Desktop 客户端，但让后端运行在 WSL2：

1. WSL2 中启动 Server：
   
```bash
   opencode serve --hostname 0.0.0.0 --port 4096
   ```

2. Windows Desktop 客户端连接：
   在设置中指定 Server URL 为 `http://localhost:4096`

3. 带密码保护：
   
```bash
   OPENCODE_SERVER_PASSWORD=你的密码 opencode serve --hostname 0.0.0.0
   ```

#### 方案 C：Web 界面 + WSL2

在 WSL2 终端运行：

```bash
opencode web --hostname 0.0.0.0
```

然后在 Windows 浏览器访问输出的 `http://localhost:<port>` 地址

### 切换工作目录

#### 方式 1：「打开文件夹」对话框（最常用）

快捷键：`Ctrl + K` 然后 `Ctrl + O`（或菜单栏 文件 → 打开文件夹）

此时弹出的文件浏览器是 WSL2 内部的 Linux 文件系统，你可以直接选择：
- WSL2 内部路径，如 `/home/用户名/项目A`
- Windows 磁盘挂载路径，如 `/mnt/c/Users/用户名/Projects/项目B`

点击「确定」后，VS Code 会重新加载窗口并切换到该目录。

#### 方式 2：命令面板快速切换

快捷键：`Ctrl + Shift + P`，然后输入：
```
Remote-WSL: Open Folder in WSL
```
或中文界面下：
```
Remote-WSL: 在 WSL 中打开文件夹
```
这会直接弹出 WSL2 文件选择对话框，无需先断开连接。

#### 方式 3：终端内用 `code` 命令打开新窗口

在 VS Code 的集成终端（已处于 WSL2 环境）中执行：

```bash
# 打开新窗口
code /path/to/another-project
# 或打开当前目录（另起新窗口）
cd ~/另一个项目
code .
```

> 若不想新开窗口，而是替换当前窗口，加 `-r` 参数：

```bash
> code -r .
```


#### 方式 4：添加到工作区（多目录并行）

如果你需要同时操作多个目录，不必频繁切换：
文件 → 将文件夹添加到工作区（`Ctrl + K` 然后 `Ctrl + A`）
这样左侧资源管理器会显示多个根目录，适合微服务或多模块项目。

#### 方式 5：资源管理器地址栏直接跳转

点击左侧资源管理器顶部的面包屑路径（当前文件夹名），可以直接输入绝对路径跳转，例如：
```
/home/你的用户名/Projects/demo
```
按回车即可加载该目录。

#### 补充：如何确认当前处于 WSL2 环境？

看 VS Code 左下角状态栏，应显示：

```
>< WSL: Ubuntu
```

如果显示的是普通的本地路径（如 `C:\Users\...`），说明当前窗口还在 Windows 本地，需要先点击左下角 `><` 图标 → 连接到 WSL。

### 配置迁移（从 Windows 到 WSL2）

若之前在 Windows 使用过 OpenCode，可将配置迁移至 WSL2：

```bash
# 1. 复制认证信息
mkdir -p ~/.local/share/opencode
cp /mnt/c/Users/你的用户名/.local/share/opencode/auth.json ~/.local/share/opencode/

# 2. 复制配置文件
mkdir -p ~/.config/opencode
cp /mnt/c/Users/你的用户名/.config/opencode/*.json ~/.config/opencode/
```

> 注意：迁移后建议检查 `whereis npm`，若显示 `/mnt/c/...` 说明仍在使用 Windows 的 Node.js，建议在 WSL2 内独立安装 Node.js/npm 以避免意外

### 配置建议

#### 设置默认编辑器

```bash
echo 'export EDITOR="code --wait"' >> ~/.bashrc
source ~/.bashrc
```

这样在使用 `/editor` 或 `/export` 命令时，会自动在 VSCode 中打开文件。

### 常见问题

| 问题 | 解决方案 |
|------|----------|
| 启动后空白屏幕 | 尝试更换终端模拟器（推荐 Windows Terminal、VS Code 终端），确保支持 true color 和 Unicode |
| Illegal instruction (core dumped) | 可能是 CPU 指令集兼容性问题，尝试安装 baseline 版本，或更新 WSL2 内核 |
| TUI 间歇性冻结 | 与 Node.js JIT 和 WSL 内核有关，尝试更换 Node.js 版本（如 v22 LTS） |
| 中文乱码 | WSL2 原生 UTF-8 环境通常无此问题；若出现，检查终端字体和 locale 设置 |
| 插件安装代理失败 | 若使用代理，避免在环境变量中设置 `all_proxy=socks5://...`，或改用本地插件路径 |
| VSCode 终端中 `opencode` 命令找不到 | 先 `exit` 退出 WSL，重新进入；或检查 `~/.local/bin` 是否在 PATH 中 |
| `@` 符号无法引用本地文件 | 确保在 workspace 根目录启动 opencode，且文件路径正确 |
| 火绒等安全软件拦截 | 关闭 ARP 攻击防护，或添加 VSCode 和 WSL 到白名单 |

---

## 附录

### A. 参考资料

- [WSL 官方文档](https://learn.microsoft.com/zh-cn/windows/wsl/)
- [OpenCode 官方文档](https://opencode.ai)

### B. 安装方式对比

| 安装方式 | 适用场景 | 推荐度 |
|----------|----------|--------|
| 快速安装 | 系统版本新、网络良好 | ⭐⭐⭐⭐⭐ |
| 手动安装 | 自定义发行版需求 | ⭐⭐⭐⭐ |
| 离线安装 | 网络问题、旧版系统 | ⭐⭐⭐⭐⭐ |

---

> 文档生成时间：2026-05-22
> 文档版本：v1.0
