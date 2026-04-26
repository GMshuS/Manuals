# OpenCode 插件配置与使用手册

本手册涵盖 OpenCode 插件的完整配置、开发、管理与生态推荐，整合了官方文档与社区最佳实践。

---

## 目录

1. [插件加载方式](#一插件加载方式)
2. [配置文件体系](#二配置文件体系)
3. [插件开发详解](#三插件开发详解)
4. [完整插件实例](#四完整插件实例)
5. [查看已安装插件](#五查看已安装插件)
6. [卸载插件](#六卸载插件)
7. [社区插件推荐](#八社区插件推荐)
8. [调试与日志](#九调试与日志)
9. [资源汇总](#十资源汇总)

---

## 一、插件加载方式

OpenCode 支持两种插件来源：**本地文件** 和 **npm 包**。

### 1.1 本地文件插件

将 JS/TS 文件放入以下目录，启动时自动加载：

| 范围 | 路径 |
|------|------|
| 项目级 | `.opencode/plugins/` |
| 全局 | `~/.config/opencode/plugins/` |

**特点**：无需配置 `opencode.json`，直接放入即可生效。

### 1.2 npm 插件

在 `opencode.json` 的 `plugin` 数组中声明：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "opencode-helicone-session",
    "@my-org/custom-plugin",
    "opencode-wakatime"
  ]
}
```

**安装机制**：OpenCode 使用 Bun 在启动时自动安装并缓存到 `~/.cache/opencode/node_modules/`。

### 1.3 本地开发插件

指向构建后的 JS 文件路径：

```json
{
  "plugin": ["file:///path/to/your/plugin/dist/index.js"]
}
```

---

## 二、配置文件体系

OpenCode 采用多层配置合并机制，**后加载的配置覆盖前者**：

| 优先级 | 配置来源 | 用途 |
|--------|----------|------|
| 1 | 远程配置 (`.well-known/opencode`) | 组织级默认 |
| 2 | 全局配置 `~/.config/opencode/opencode.json` | 用户偏好 |
| 3 | 自定义路径 (`OPENCODE_CONFIG`) | 自定义覆盖 |
| 4 | 项目配置 `opencode.json` | 项目专属 |
| 5 | `.opencode/` 目录 | 插件、Agent、命令 |
| 6 | 内联配置 (`OPENCODE_CONFIG_CONTENT`) | 运行时覆盖 |
| 7 | 托管配置 (系统目录/MDM) | 最高优先级，用户不可覆盖 |

**配置格式**：支持 JSON 和 JSONC（带注释），通过 `$schema` 提供自动补全。

---

## 三、插件开发详解

### 3.1 基础结构

插件是一个导出 `Plugin` 函数的 JS/TS 模块，接收上下文对象，返回 hooks 对象：

```typescript
import { Plugin, tool } from '@opencode-ai/plugin'

export const MyPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {
  console.log("Plugin initialized!")
  return {
    // Hook 实现
  }
}
```

**上下文对象 (ctx) 包含**：
- `project`：项目信息（id、worktree、vcs）
- `directory`：当前工作目录
- `worktree`：Git 工作区根目录
- `client`：OpenCode SDK 客户端（连接 localhost:4096）
- `$`：Bun Shell API，用于执行命令

### 3.2 核心 Hook 类型

| Hook | 用途 | 示例场景 |
|------|------|----------|
| `tool` | 注册自定义工具 | 添加 API 调用、文件操作工具 |
| `event` | 监听系统事件 | 会话完成通知、文件变更监听 |
| `tool.execute.before` | 拦截工具执行前 | 参数修改、权限检查 |
| `tool.execute.after` | 拦截工具执行后 | 结果处理、日志记录 |
| `permission.ask` | 控制权限请求 | 自动允许/拒绝特定操作 |
| `config` | 修改 OpenCode 配置 | 注入自定义配置项 |
| `chat.message` | 拦截聊天消息 | 消息预处理 |
| `chat.params` | 修改 LLM 参数 | 调整 temperature、topP |
| `shell.env` | 注入环境变量 | 统一设置 API Key |
| `experimental.session.compacting` | 自定义上下文压缩 | 保留关键状态 |

### 3.3 自定义工具示例

```typescript
import { type Plugin, tool } from '@opencode-ai/plugin'

export const CustomToolsPlugin: Plugin = async (ctx) => {
  return {
    tool: {
      gitStatus: tool({
        description: 'Get git status',
        args: {},
        async execute() {
          const result = await ctx.$`git status --porcelain`
          return result.text()
        },
      }),
      hello: tool({
        description: 'Say hello',
        args: {
          name: tool.schema.string().describe('Name to greet'),
        },
        async execute({ name }) {
          return `Hello, ${name}!`
        },
      }),
    },
  }
}
```

工具参数使用 Zod schema 定义，支持 `.string()`、`.number()`、`.optional()`、`.default()` 等方法。

### 3.4 权限控制示例

```typescript
export const MyPlugin: Plugin = async (ctx) => {
  return {
    'permission.ask': async (permission, output) => {
      // 自动允许读取文件权限
      if (permission.type === 'read_file') {
        output.status = 'allow'
      }
    },
    'tool.execute.before': async ({ tool }, { args }) => {
      // 禁止读取 .env 文件
      if (tool === 'read' && args.filePath.includes('.env')) {
        throw new Error("Do not read .env files")
      }
    },
  }
}
```

### 3.5 事件监听完整列表

**会话事件**：`session.created`、`session.updated`、`session.idle`、`session.error`、`session.deleted`、`session.compacted`、`session.diff`、`session.status`

**消息事件**：`message.updated`、`message.removed`、`message.part.updated`、`message.part.removed`

**文件事件**：`file.edited`、`file.watcher.updated`

**权限事件**：`permission.asked`、`permission.replied`

**TUI 事件**：`tui.prompt.append`、`tui.command.execute`、`tui.toast.show`

**其他**：`command.executed`、`lsp.client.diagnostics`、`lsp.updated`、`installation.updated`、`server.connected`

---

## 四、完整插件实例

### 4.1 项目搭建

```bash
mkdir opencode-my-plugin
cd opencode-my-plugin
bun init -y
```

安装依赖：

```bash
bun add @opencode-ai/plugin @opencode-ai/sdk zod
bun add -d @types/node typescript @tsconfig/node22
```

配置 TypeScript（`tsconfig.json`）：

```json
{
  "extends": "@tsconfig/node22/tsconfig.json",
  "compilerOptions": {
    "outDir": "dist",
    "module": "preserve",
    "declaration": true,
    "moduleResolution": "bundler",
    "strict": true
  },
  "include": ["src"]
}
```

配置 `package.json`：

```json
{
  "name": "opencode-my-plugin",
  "version": "1.0.0",
  "type": "module",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch"
  }
}
```

### 4.2 完整插件实例：代码审查助手

```typescript
// src/index.ts
import { Plugin, tool } from '@opencode-ai/plugin'
import type { z } from 'zod'

export const CodeReviewPlugin: Plugin = async (ctx) => {
  // 插件初始化日志
  await ctx.client.app.log({
    body: {
      service: 'code-review-plugin',
      level: 'info',
      message: 'CodeReviewPlugin initialized',
      extra: { project: ctx.project.id, worktree: ctx.worktree },
    },
  })

  return {
    // ==================== 1. 自定义工具 ====================
    tool: {
      // 工具 1：获取最近的 Git 提交记录
      getRecentCommits: tool({
        description: '获取最近的 Git 提交记录，用于代码审查',
        args: {
          count: tool.schema.number().min(1).max(50).default(10)
            .describe('获取的提交数量'),
          author: tool.schema.string().optional()
            .describe('按作者筛选（可选）'),
        },
        async execute(args, toolCtx) {
          const { count, author } = args
          
          try {
            let cmd = ctx.$`git log --oneline -n ${count}`
            if (author) {
              cmd = ctx.$`git log --oneline --author=${author} -n ${count}`
            }
            
            const result = await cmd
            const commits = result.text().trim().split('\n').map(line => {
              const [hash, ...msgParts] = line.split(' ')
              return { hash: hash.substring(0, 7), message: msgParts.join(' ') }
            })
            
            return JSON.stringify({ commits, total: commits.length }, null, 2)
          } catch (error) {
            return `Error fetching commits: ${error instanceof Error ? error.message : String(error)}`
          }
        },
      }),

      // 工具 2：获取文件变更统计
      getFileChanges: tool({
        description: '获取指定提交的文件变更详情',
        args: {
          commitHash: tool.schema.string().describe('提交的 hash（完整或前 7 位）'),
        },
        async execute(args) {
          try {
            const { stdout: diffStat } = await ctx.$`git diff --stat ${args.commitHash}^..${args.commitHash}`
            const { stdout: files } = await ctx.$`git diff --name-only ${args.commitHash}^..${args.commitHash}`
            
            return JSON.stringify({
              commit: args.commitHash,
              summary: diffStat.trim(),
              changedFiles: files.trim().split('\n').filter(Boolean),
            }, null, 2)
          } catch (error) {
            return `Error: ${error instanceof Error ? error.message : String(error)}`
          }
        },
      }),

      // 工具 3：运行项目测试并返回结果
      runTests: tool({
        description: '运行项目测试套件并返回结果摘要',
        args: {
          pattern: tool.schema.string().optional()
            .describe('测试文件匹配模式（可选）'),
          coverage: tool.schema.boolean().default(false)
            .describe('是否生成覆盖率报告'),
        },
        async execute(args) {
          try {
            let cmd = args.coverage 
              ? ctx.$`npm test -- --coverage` 
              : ctx.$`npm test`
            
            if (args.pattern) {
              cmd = args.coverage
                ? ctx.$`npm test -- --coverage --testPathPattern=${args.pattern}`
                : ctx.$`npm test -- --testPathPattern=${args.pattern}`
            }

            const result = await cmd
            return `✅ Tests passed\n\n${result.text()}`
          } catch (error: any) {
            return `❌ Tests failed\n\nExit code: ${error.exitCode}\nOutput: ${error.stdout || error.message}`
          }
        },
      }),
    },

    // ==================== 2. 事件监听 ====================
    event: async ({ event }) => {
      // 会话空闲时发送桌面通知
      if (event.type === 'session.idle') {
        const { stdout: branch } = await ctx.$`git branch --show-current`.quiet()
        
        await ctx.$`osascript -e 'display notification "Session completed on branch: ${branch.trim()}" with title "OpenCode"'`
          .catch(() => {
            // macOS 以外平台静默失败
          })
        
        await ctx.client.app.log({
          body: {
            service: 'code-review-plugin',
            level: 'info',
            message: 'Session completed',
            extra: { branch: branch.trim() },
          },
        })
      }

      // 文件编辑事件记录
      if (event.type === 'file.edited') {
        await ctx.client.app.log({
          body: {
            service: 'code-review-plugin',
            level: 'debug',
            message: 'File edited',
            extra: { file: (event as any).file },
          },
        })
      }
    },

    // ==================== 3. 权限控制 ====================
    'permission.ask': async (permission, output) => {
      // 自动允许读取代码文件
      if (permission.type === 'read_file') {
        const path = (permission as any).path || ''
        const allowedExtensions = ['.ts', '.js', '.tsx', '.jsx', '.json', '.md']
        if (allowedExtensions.some(ext => path.endsWith(ext))) {
          output.status = 'allow'
          return
        }
      }

      // 自动允许编辑代码文件
      if (permission.type === 'edit') {
        const path = (permission as any).path || ''
        if (!path.includes('.env') && !path.includes('secret')) {
          output.status = 'allow'
          return
        }
      }

      // 禁止删除操作（rm -rf）
      if (permission.type === 'bash') {
        const command = (permission as any).command || ''
        if (command.includes('rm -rf') || command.includes('rm -r /')) {
          output.status = 'deny'
          return
        }
      }

      // 其他权限保持默认（ask）
    },

    // ==================== 4. 环境变量注入 ====================
    'shell.env': async (input, output) => {
      // 注入项目根目录
      output.env.PROJECT_ROOT = ctx.worktree
      
      // 注入当前分支名
      try {
        const { stdout } = await ctx.$`git branch --show-current`.quiet()
        output.env.GIT_BRANCH = stdout.trim()
      } catch {
        output.env.GIT_BRANCH = 'unknown'
      }

      // 注入最近提交 hash
      try {
        const { stdout } = await ctx.$`git rev-parse --short HEAD`.quiet()
        output.env.GIT_COMMIT = stdout.trim()
      } catch {
        output.env.GIT_COMMIT = 'unknown'
      }
    },

    // ==================== 5. 工具执行 Hook ====================
    'tool.execute.before': async ({ tool, sessionID, callID }, { args }) => {
      await ctx.client.app.log({
        body: {
          service: 'code-review-plugin',
          level: 'debug',
          message: `Tool executing: ${tool}`,
          extra: { sessionID, callID, args: JSON.stringify(args) },
        },
      })
    },

    'tool.execute.after': async ({ tool, sessionID, callID }, { title, output, metadata }) => {
      await ctx.client.app.log({
        body: {
          service: 'code-review-plugin',
          level: 'debug',
          message: `Tool completed: ${tool}`,
          extra: { sessionID, callID, title, outputLength: String(output).length },
        },
      })
    },

    // ==================== 6. 配置 Hook ====================
    config: async (config) => {
      // 为插件添加配置命名空间
      (config as any).codeReview = {
        enabled: true,
        autoReview: true,
        maxFilesPerReview: 20,
      }
    },

    // ==================== 7. 会话压缩 Hook（实验性）====================
    'experimental.session.compacting': async (input, output) => {
      output.context.push(`
      ## 代码审查上下文
      - 当前项目：${ctx.project.id}
      - 工作分支：${ctx.worktree}
      - 审查规则：关注安全性、性能、可维护性
      - 已审查文件：记录在当前会话中
      `)
    },
  }
}
```

### 4.3 轻量级插件实例：通知插件

```typescript
// src/notify.ts
import { Plugin } from '@opencode-ai/plugin'

export const NotifyPlugin: Plugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type === 'session.idle') {
        // macOS 通知
        await $`osascript -e 'display notification "Coding session done!" with title "OpenCode"'`
          .catch(() => {})
      }
      
      if (event.type === 'session.error') {
        await $`osascript -e 'display notification "Error occurred!" with title "OpenCode" sound name "Basso"'`
          .catch(() => {})
      }
    },
  }
}
```

### 4.4 构建与部署

**构建**：

```bash
bun run build
```

**本地测试（方式一：文件路径）**：

```json
// 项目根目录的 opencode.json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["file:///absolute/path/to/opencode-my-plugin/dist/index.js"]
}
```

**本地测试（方式二：bun link）**：

```bash
# 在插件目录
bun link

# 在测试项目目录
bun link opencode-my-plugin

# opencode.json
{
  "plugin": ["opencode-my-plugin"]
}
```

**发布到 npm**：

```bash
# 登录 npm
npm login

# 发布（确保名称以 opencode- 开头）
npm publish --access public
```

发布后使用：

```json
{
  "plugin": ["opencode-my-plugin@1.0.0"]
}
```

### 4.5 目录结构

```
opencode-my-plugin/
├── src/
│   └── index.ts          # 主入口
├── dist/                 # 编译输出
├── package.json
├── tsconfig.json
└── README.md
```

---

## 五、查看已安装插件

### 5.1 查看 npm 安装的插件

**通过配置文件查看**：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "opencode-notify",
    "opencode-skillful",
    "@my-org/custom-plugin"
  ]
}
```

查看位置：
- 项目级：`./opencode.json`
- 全局：`~/.config/opencode/opencode.json`

**查看实际安装的包**：

```bash
# 查看缓存的插件
ls ~/.cache/opencode/node_modules/

# 查看具体包信息
ls -la ~/.cache/opencode/

# 过滤 opencode 相关包
ls ~/.cache/opencode/node_modules/ | grep opencode
```

**启动日志查看**：

```bash
opencode
# 启动时会显示类似：
# [plugin] Loading opencode-notify...
# [plugin] Loading opencode-skillful...
```

### 5.2 查看本地文件插件

```bash
# 项目级本地插件
ls .opencode/plugins/

# 全局本地插件
ls ~/.config/opencode/plugins/

# 自定义配置目录
ls $OPENCODE_CONFIG_DIR/plugins/
```

### 5.3 运行时查看

**使用 SDK 客户端查询**：

```typescript
import { createClient } from '@opencode-ai/sdk'

const client = createClient({ baseURL: 'http://localhost:4096' })

// 获取当前配置（包含插件列表）
const config = await client.config.get()
console.log(config.plugin) // 插件数组
```

**通过 TUI 界面**：

1. 按 `/` 打开命令面板
2. 输入 `/config` 或相关命令查看当前配置
3. 插件信息会显示在配置摘要中

### 5.4 调试与排查

**查看详细加载日志**：

```bash
DEBUG=opencode:plugin opencode
# 或
OPENCODE_LOG_LEVEL=debug opencode
```

**验证插件是否成功加载**：

观察启动时的插件初始化输出：
- 成功：`[plugin] ✓ opencode-notify loaded`
- 失败：`[plugin] ✗ opencode-xxx failed to load: [错误原因]`

**检查插件依赖**：

如果本地插件使用了外部 npm 包，检查配置目录的 `package.json`：

```bash
cat ~/.config/opencode/package.json
# 或
cat .opencode/package.json
```

### 5.5 快速查看脚本

添加到 `.bashrc`/`.zshrc`：

```bash
alias opencode-plugins='echo "=== npm 插件 ===" && cat opencode.json 2>/dev/null | grep -A 20 "\"plugin\"" || cat ~/.config/opencode/opencode.json 2>/dev/null | grep -A 20 "\"plugin\""; echo "=== 本地插件 ===" && ls .opencode/plugins/ 2>/dev/null && ls ~/.config/opencode/plugins/ 2>/dev/null'
```

---

## 六、卸载插件

### 6.1 卸载 npm 插件

**从配置中移除**：

编辑 `opencode.json`，从 `plugin` 数组中删除目标插件：

```json
// 修改前
{
  "plugin": [
    "opencode-notify",
    "opencode-skillful",  // ← 要卸载这个
    "@my-org/custom-plugin"
  ]
}

// 修改后
{
  "plugin": [
    "opencode-notify",
    "@my-org/custom-plugin"
  ]
}
```

**注意**：只需删除配置项，OpenCode 下次启动时自动清理，无需手动运行 `npm uninstall`。

**清理缓存（彻底删除）**：

```bash
# 删除特定插件
rm -rf ~/.cache/opencode/node_modules/opencode-skillful

# 或清空整个插件缓存（下次启动会重新安装保留的插件）
rm -rf ~/.cache/opencode/node_modules/
```

### 6.2 卸载本地文件插件

**项目级插件**：

```bash
# 删除插件文件
rm .opencode/plugins/my-plugin.ts
# 或
rm -rf .opencode/plugins/my-plugin/
```

**全局插件**：

```bash
rm ~/.config/opencode/plugins/my-plugin.ts
# 或
rm -rf ~/.config/opencode/plugins/my-plugin/
```

**清理空目录**：

```bash
# 检查并删除空插件目录
rmdir .opencode/plugins/ 2>/dev/null || true
rmdir ~/.config/opencode/plugins/ 2>/dev/null || true
```

### 6.3 卸载后验证

**重启 OpenCode**：

```bash
opencode
```

观察启动日志，确认目标插件不再出现：
- 卸载前：`[plugin] Loading opencode-skillful...`
- 卸载后：无相关输出

**使用 SDK 验证（可选）**：

```typescript
import { createClient } from '@opencode-ai/sdk'

const client = createClient({ baseURL: 'http://localhost:4096' })
const config = await client.config.get()

console.log('已安装插件:', config.plugin)
// 确认目标插件已不在列表中
```

### 6.4 批量卸载与重置

**一键清空所有插件**：

```bash
# 方法 1：清空配置中的 plugin 数组
# 编辑 opencode.json 将 "plugin" 设为 [] 或删除该键

# 方法 2：直接清空所有插件目录
rm -rf ~/.cache/opencode/node_modules/
rm -rf ~/.config/opencode/plugins/*
rm -rf .opencode/plugins/*
```

**重置到初始状态**：

```bash
# 备份配置
cp ~/.config/opencode/opencode.json ~/.config/opencode/opencode.json.bak

# 编辑配置，仅保留基础设置，删除所有 plugin 条目
cat > ~/.config/opencode/opencode.json << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "model": "anthropic/claude-sonnet-4-5"
}
EOF
```

### 6.5 快捷命令脚本

添加到 `.bashrc` / `.zshrc`：

```bash
# 卸载 npm 插件
opencode-uninstall() {
  local plugin=$1
  local config_file="opencode.json"
  
  # 先查找项目配置，再查找全局配置
  [ -f "$config_file" ] || config_file="$HOME/.config/opencode/opencode.json"
  
  if [ -z "$plugin" ]; then
    echo "用法：opencode-uninstall <插件名>"
    return 1
  fi
  
  # 使用临时文件安全编辑 JSON
  bun -e "
    const fs = require('fs');
    const config = JSON.parse(fs.readFileSync('$config_file', 'utf8'));
    if (config.plugin) {
      config.plugin = config.plugin.filter(p => !p.includes('$plugin'));
      fs.writeFileSync('$config_file', JSON.stringify(config, null, 2));
      console.log('已从配置移除：$plugin');
    }
  "
  
  # 清理缓存
  rm -rf "$HOME/.cache/opencode/node_modules/$plugin"
  echo "已清理缓存，重启 OpenCode 生效"
}

# 列出所有插件
opencode-plugins() {
  echo "=== npm 插件（配置中）==="
  cat opencode.json 2>/dev/null | grep -A 10 '"plugin"' || \
  cat ~/.config/opencode/opencode.json 2>/dev/null | grep -A 10 '"plugin"'
  
  echo ""
  echo "=== 本地插件（项目级）==="
  ls .opencode/plugins/ 2>/dev/null || echo "(无)"
  
  echo ""
  echo "=== 本地插件（全局）==="
  ls ~/.config/opencode/plugins/ 2>/dev/null || echo "(无)"
}
```

使用：

```bash
opencode-plugins              # 查看所有插件
opencode-uninstall opencode-notify  # 卸载指定插件
```

### 6.6 常见问题

| 问题 | 原因 | 解决 |
|------|------|------|
| 删除配置后插件仍在运行 | OpenCode 进程未重启 | 完全退出并重新启动 OpenCode |
| 缓存清理后插件自动恢复 | 配置中仍保留该插件 | 检查 `opencode.json` 是否已删除条目 |
| 本地插件删除后报错 | 其他配置引用该插件 | 检查 `plugin` 数组中是否有 `file://` 路径指向已删除文件 |
| 全局与项目插件冲突 | 同名插件在不同层级 | 同时检查 `~/.config/opencode/` 和 `./opencode.json` |

## 七、社区插件推荐

以下是 OpenCode 生态中值得推荐的插件，按使用场景分类整理。

### 7.1 认证与模型接入（省钱必备）

| 插件 | 功能 | 安装 |
|------|------|------|
| `opencode-openai-codex-auth` | 用 ChatGPT Plus/Pro 订阅代替 API 计费 | `npm i opencode-openai-codex-auth` |
| `opencode-gemini-auth` | 用现有 Gemini 计划代替 API 计费 | `npm i opencode-gemini-auth` |
| `opencode-antigravity-auth` | 免费使用 Antigravity 模型 | `npm i opencode-antigravity-auth` |
| `opencode-google-antigravity-auth` | Google Antigravity OAuth，支持 Google Search | `npm i opencode-google-antigravity-auth` |
| `opencode-qwen-auth` | 通义千问 OAuth 认证，支持多账号轮询 | `npm i opencode-qwen-auth` |

**推荐理由**：OpenCode 本身免费，但 API 调用需付费。这些插件让你用现有订阅计划（ChatGPT Plus、Gemini、千问等）零额外成本使用高端模型。

### 7.2 效率与生产力（核心推荐）

| 插件 | 功能 | 场景 |
|------|------|------|
| `oh-my-opencode` | 背景 Agent、预置 LSP/AST/MCP 工具、精选 Agent 集合 | 必装，相当于给 OpenCode 装上"超能力套件" |
| `opencode-morph-fast-apply` | 10 倍速代码编辑，延迟编辑标记 | 大文件重构时节省大量时间 |
| `opencode-dynamic-context-pruning` | 自动剪枝过时工具输出，优化 Token 使用 | 省钱神器，减少 API 消耗 |
| `opencode-skillful` | Agent 按需懒加载 Prompt，技能发现与注入 | 避免一次性加载过多上下文 |
| `opencode-supermemory` | 跨会话持久化记忆 | 长期项目保持上下文连续性 |
| `opencode-snip` | 自动为 shell 命令添加 snip 前缀，减少 60-90% Token 消耗 | 频繁执行命令时显著降低成本 |

`oh-my-opencode` 是社区公认的"瑞士军刀"，包含背景 Agent、代码分析工具、Claude Code 兼容层，几乎是进阶用户的标配。

### 7.3 通知与交互体验

| 插件 | 功能 | 平台 |
|------|------|------|
| `opencode-notify` / `opencode-notificator` | 原生 OS 通知（任务完成/权限请求/错误） | macOS/Linux/Windows |
| `opencode-smart-voice-notify` | 智能语音通知（ElevenLabs/Edge TTS/SAPI） | 全平台 |
| `opencode-ntfy.sh` | 推送通知到手机（通过 ntfy.sh） | 移动端 |
| `opencode-zellij-namer` | AI 自动重命名 Zellij 会话 | Zellij 用户 |
| `opencode-warcraft-notifications` | 魔兽音效通知（趣味性） | 全平台 |

**推荐组合**：`opencode-notify` + `opencode-ntfy.sh`，本地开发时桌面通知，离开工位时手机推送。

### 7.4 安全与隐私

| 插件 | 功能 |
|------|------|
| `opencode-vibeguard` | 将敏感信息/PII 替换为占位符后再发送给 LLM，本地恢复 |
| `envsitter-guard` | 防止 Agent 读取/编辑 `.env` 文件，仅允许安全检视 |
| `cc-safety-net` | 拦截破坏性 git 和文件系统命令 |

**生产环境必装**：`envsitter-guard` 和 `opencode-vibeguard` 可防止 API Key、密码等敏感信息泄露到第三方 LLM。

### 7.5 开发环境与隔离

| 插件 | 功能 |
|------|------|
| `opencode-daytona` | 在隔离的 Daytona 沙盒中运行会话，支持 git 同步和实时预览 |
| `opencode-devcontainers` | 多分支 DevContainer 隔离，自动分配端口 |
| `opencode-worktree` | 零摩擦 Git Worktree 管理，自动创建/清理 |
| `opencode-direnv` | 自动加载 direnv 环境变量（Nix flakes 用户必备） |

**团队协作推荐**：`opencode-daytona` 或 `opencode-devcontainers` 确保每个分支/任务在独立环境中运行，避免依赖冲突。

### 7.6 工作流与自动化

| 插件 | 功能 |
|------|------|
| `opencode-conductor` | 协议驱动工作流：Context → Spec → Plan → Implement 生命周期自动化 |
| `micode` | 结构化 Brainstorm → Plan → Implement 工作流 |
| `opencode-background-agents` | Claude Code 风格的背景 Agent，异步委托 |
| `opencode-scheduler` | 定时任务调度（launchd/systemd），支持 cron 语法 |
| `pilot` | 自动化守护进程，轮询 GitHub Issues 和 Linear Tickets |
| `opencode-workspace` | 16 合 1 多 Agent 编排套件 |

**大型项目推荐**：`opencode-conductor` 或 `micode` 强制规范 AI 的开发流程，避免"想到哪写到哪"的混乱。

### 7.7 监控与可观测性

| 插件 | 功能 |
|------|------|
| `opencode-sentry-monitor` | Sentry AI 监控，追踪和调试 Agent 行为 |
| `opencode-plugin-otel` | OpenTelemetry 导出器，支持 Datadog/Honeycomb/Grafana |
| `opencode-quota` | Token 配额追踪和用量提醒 |
| `tokenscope` | 综合 Token 用量分析和成本追踪 |
| `context-analysis` | 详细 Token 使用分析 |
| `opencode-wakatime` | 编码时间追踪（WakaTime 集成） |

**企业级推荐**：`opencode-plugin-otel` 可将 OpenCode 的指标、日志、追踪导出到现有可观测平台，与 Claude Code 的监控信号对齐。

### 7.8 搜索与网络

| 插件 | 功能 |
|------|------|
| `opencode-websearch-cited` | 原生网页搜索，Google Grounded 风格引用 |
| `opencode-firecrawl` | 网页爬取、抓取和搜索（通过 Firecrawl CLI） |
| `opencode-google-ai-search` | 查询 Google AI Mode (SGE) |
| `opencode-pty` | 让 AI Agent 在 PTY 中运行后台进程并交互 |

**研究型任务推荐**：`opencode-websearch-cited` + `opencode-firecrawl` 组合，实现带引用的深度网络调研。

### 7.9 实用小工具

| 插件 | 功能 |
|------|------|
| `opencode-type-inject` | 自动注入 TypeScript/Svelte 类型到文件读取 |
| `opencode-md-table-formatter` | 清理 LLM 生成的 Markdown 表格 |
| `opencode-shell-strategy` | 防止非交互式 shell 命令挂起 |
| `opencode-snippets` | 内联文本扩展（`#snippet` 触发），Prompt 工程 DRY 原则 |
| `opencode-synced` | 跨机器同步 OpenCode 配置 |
| `model-announcer` | 自动注入当前模型名称到聊天上下文 |
| `optimal-model-temps` | 自动为特定模型设置最优采样温度 |
| `unmoji` | 去除 Agent 输出中的所有 emoji |

### 7.10 快速上手指南

**基础配置（推荐新手）**：

```json
// opencode.json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "opencode-dynamic-context-pruning",
    "opencode-notify",
    "opencode-skillful",
    "opencode-shell-strategy"
  ]
}
```

**进阶配置（开发者）**：

```json
{
  "plugin": [
    "oh-my-opencode",
    "opencode-morph-fast-apply",
    "opencode-supermemory",
    "opencode-snip",
    "envsitter-guard",
    "opencode-worktree"
  ]
}
```

**企业/团队配置**：

```json
{
  "plugin": [
    "opencode-conductor",
    "opencode-devcontainers",
    "opencode-plugin-otel",
    "opencode-vibeguard",
    "opencode-sentry-monitor"
  ]
}
```

---

## 八、调试与日志

### 8.1 结构化日志

使用结构化日志而非 `console.log`：

```typescript
export const MyPlugin: Plugin = async ({ client }) => {
  await client.app.log({
    body: {
      service: "my-plugin",
      level: "info",  // debug | info | warn | error
      message: "Plugin initialized",
      extra: { foo: "bar" },
    },
  })
}
```

### 8.2 日志级别说明

| 级别 | 用途 |
|------|------|
| `debug` | 详细调试信息，仅在排查问题时启用 |
| `info` | 常规信息，如插件初始化、工具调用 |
| `warn` | 警告信息，如配置异常、降级处理 |
| `error` | 错误信息，需要立即关注 |

### 8.3 排查插件加载问题

1. 启用详细日志：`DEBUG=opencode:plugin opencode`
2. 检查启动输出中的插件初始化日志
3. 验证插件文件路径或 npm 包名称是否正确
4. 确认插件依赖已正确安装

---

## 九、资源汇总

| 资源 | 链接 |
|------|------|
| Awesome OpenCode（社区精选） | [GitHub](https://github.com/awesome-opencode/awesome-opencode) |
| 官方生态页面 | [opencode.ai/docs/ecosystem](https://opencode.ai/docs/ecosystem/) |
| npm 插件搜索 | [npmjs.com/search?q=keywords:opencode-plugins](https://www.npmjs.com/search?q=keywords:opencode-plugins) |
| 插件开发模板 | `opencode-plugin-template` |
| 插件市场 CLI | `opencode-marketplace`（支持从 GitHub 安装） |

---

## 附录：常见问题排查

| 问题 | 排查方法 |
|------|----------|
| 插件安装了但没生效 | 检查 `opencode.json` 语法是否正确；查看启动日志是否有加载错误 |
| npm 插件版本冲突 | 删除 `~/.cache/opencode/node_modules/` 让 OpenCode 重新安装 |
| 本地插件不加载 | 确认文件在 `.opencode/plugins/` 或 `~/.config/opencode/plugins/` 目录下 |
| 插件加载顺序问题 | 记住加载顺序：全局配置 → 项目配置 → 全局插件目录 → 项目插件目录 |

---

*本手册整合了 OpenCode 插件的完整配置、开发、管理与生态推荐，适用于从新手到高级开发者的所有用户。*
