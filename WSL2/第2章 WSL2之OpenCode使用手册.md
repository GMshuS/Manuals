# 在 WSL2 中使用 OpenCode

> 在 WSL2 中运行 OpenCode 是官方推荐的方式，能获得比 Windows 原生运行更好的文件系统性能和终端兼容性。

---

## 目录

1. [安装与使用](#一安装与使用)

---

## 一、安装与使用

### 1.1 安装 OpenCode

**方式一：官方脚本（推荐，无需 Node.js）**

```bash
curl -fsSL https://opencode.ai/install | bash
```

**方式二：npm/bun 安装**

```bash
npm install -g opencode-ai
```

若没npm安装，则先`安装`并设置`npm的prefix`，避免被Windows的npm污染：

```bash
# 1. 安装 nodejs 跟 npm
# 更新安装源
sudo apt update
# 安装
sudo apt install -y nodejs npm

# 2. 设置 Linux 用户级 prefix
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"

# 3. 确保 PATH 包含 Linux 全局 bin（放在 .bashrc 最前面）
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

```

**验证安装**

```bash
# 查看opencode的安装位置，输出`/usr/local/bin/opencode`说明已经按装到了Linux系统
which opencode
# 输出opencode的版本，验证是否正常运行
opencode --version
```

> 注意：若安装后当前会话找不到 `opencode` 命令，先 `exit` 退出 WSL，重新进入即可生效。

### 1.2 配置模型 API

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

### 1.3 VS Code 配置：Remote - WSL

**Windows 端安装扩展**

在 Windows 的 VS Code 中安装：
- Remote - WSL（微软官方，必装）
- 可选：Remote Development 扩展包

**连接 WSL2 项目**

方法一：从 WSL2 终端启动

在 WSL2 中进入项目目录（可以是 Windows 磁盘上的项目）：

```bash
cd /mnt/c/Users/你的用户名/Projects/my-project
code .
```

VS Code 会自动在 WSL2 中安装 Server 组件，左下角显示 WSL: Ubuntu，此时所有终端、调试、扩展均在 WSL2 环境中运行。

方法二：从 VS Code 直接连接

点击 VS Code 左下角 `><` 图标 → Connect to WSL → 选择 Ubuntu。

### 1.4 在 VS Code 中使用 OpenCode

**方案 A：集成终端直接使用（最简单）**

连接 WSL2 后，按 `` Ctrl+` `` 打开 VS Code 集成终端（自动是 WSL2 的 bash/zsh），直接输入：

```bash
opencode
```

所有 TUI 功能、快捷键、模型切换完全可用，且能直接操作 Windows 文件（通过 `/mnt/c/` 路径）。

**方案 B：OpenCode Desktop + WSL2 Server**

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

**方案 C：Web 界面 + WSL2**

在 WSL2 终端运行：

```bash
opencode web --hostname 0.0.0.0
```

然后在 Windows 浏览器访问输出的 `http://localhost:<port>` 地址。

### 1.5 配置迁移（从 Windows 到 WSL2）

若之前在 Windows 使用过 OpenCode，可将配置迁移至 WSL2：

```bash
# 1. 复制认证信息
mkdir -p ~/.local/share/opencode
cp /mnt/c/Users/你的用户名/.local/share/opencode/auth.json ~/.local/share/opencode/

# 2. 复制配置文件
mkdir -p ~/.config/opencode
cp /mnt/c/Users/你的用户名/.config/opencode/*.json ~/.config/opencode/
```

> 注意：迁移后建议检查 `whereis npm`，若显示 `/mnt/c/...` 说明仍在使用 Windows 的 Node.js，建议在 WSL2 内独立安装 Node.js/npm 以避免意外。

### 1.6 配置建议

**设置默认编辑器**

```bash
echo 'export EDITOR="code --wait"' >> ~/.bashrc
source ~/.bashrc
```

这样在使用 `/editor` 或 `/export` 命令时，会自动在 VSCode 中打开文件。

### 1.7 常见问题

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

- [OpenCode 官方文档](https://opencode.ai)
- [WSL 官方文档](https://learn.microsoft.com/zh-cn/windows/wsl/)

---

> 文档生成时间：2026-05-22
> 文档版本：v1.0
