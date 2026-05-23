# OpenCode Hooks 与 Plugin 使用手册

> 整合了 OpenCode Hooks 与 Plugin 的概念辨析、三层架构机制、插件安装管理、Hooks 参数详解、Plugin 开发调试及社区生态推荐的完整指南。

---

## 目录

1. [认识 Hooks 与 Plugin](#一认识-hooks-与-plugin)
2. [Hooks 与 Plugin 机制](#二hooks-与-plugin-机制)
3. [插件管理](#三插件管理)
4. [Hooks 参数详解](#四hooks-参数详解)
5. [Plugin 开发与调试](#五plugin-开发与调试)
6. [社区插件推荐](#六社区插件推荐)

---

## 一、认识 Hooks 与 Plugin

Hooks 是 OpenCode 暴露的"扩展接口/协议"，Plugin 是开发者用代码实现这些接口的主要手段。两者是接口定义与接口实现的关系。

### 1.1 层次关系

```
┌─────────────────────────────────────────┐
│           Hooks（扩展接口层）            │
│  定义了 8 个标准扩展点 + 实验性扩展点     │
│  config / tool / event / chat.* / tool.* │
└─────────────────────────────────────────┘
                    ▲
        ┌──────────┴──────────┐
        │                     │
┌───────┴───────┐    ┌───────┴───────┐
│    Plugin     │    │  Config Hook  │
│  （代码实现）  │    │ （声明式实现）  │
│  TypeScript   │    │  opencode.jsonc │
│  模块导出 hooks│    │  command 配置   │
└───────────────┘    └───────────────┘
```

### 1.2 关键区分

| 维度 | Hooks | Plugin |
|------|-------|--------|
| 本质 | 扩展点/事件拦截协议 | 代码载体/模块 |
| 角色 | 被实现的接口 | 实现接口的手段之一 |
| 存在形式 | 运行时的事件名称（如 `chat.message`） | 磁盘上的 `.ts` 文件或 npm 包 |
| 其他实现方式 | 还可通过 Config Hook（JSON 配置）实现 | 只是最灵活的一种实现方式 |

### 1.3 一句话总结

> Hooks 是"在哪里可以扩展"，Plugin 是"用代码写扩展逻辑"。

除了 Plugin，还可以用 Config Hook（`opencode.jsonc` 里的 `file_edited`、`session_completed`）来实现 Hooks，只是 Config Hook 只能跑 shell 命令，而 Plugin 能写任意 TypeScript 逻辑。

---

## 二、Hooks 与 Plugin 机制

OpenCode 的插件与钩子系统采用三层架构设计：底层事件总线、中层插件钩子、上层配置钩子。

### 2.1 整体架构概览

| 层级 | 名称 | 适用对象 | 能力范围 |
|------|------|----------|----------|
| Layer 1 | 事件总线（Event Bus） | 系统内部 | 所有模块通信的基础设施，支持发布/订阅 |
| Layer 2 | 插件钩子（Plugin Hooks） | 开发者 | TypeScript/JavaScript 代码级扩展，可修改行为 |
| Layer 3 | 配置钩子（Config Hooks） | 普通用户 | 声明式配置，在特定事件时运行外部命令 |

核心关系：插件通过钩子响应事件。事件由 OpenCode 内部触发，钩子拦截事件并执行自定义逻辑。

### 2.2 事件总线（底层）

事件总线是一切的基础，核心实现不到 100 行。

**关键设计特点**：
1. **通配符订阅**：支持 `"*"` 通配符，插件系统通过 `subscribeAll` 订阅所有事件，再内部分发
2. **双通道发布**：事件同时发送到本地订阅者和 `GlobalBus`（Node.js EventEmitter），负责跨进程通信（IPC）
3. **异步并发**：所有订阅者通过 `Promise.all` 并发执行，发布是非阻塞的

**订阅 API**：
```typescript
// 持续监听特定事件
Bus.subscribe(File.Event.Edited, async (payload) => { ... })

// 一次性监听（返回 "done" 后自动取消）
Bus.once(Session.Event.Created, (payload) => { ... })

// 监听所有事件（插件系统使用）
Bus.subscribeAll(async (event) => { ... })
```

所有 `subscribe` 调用都返回取消订阅函数，便于清理。

### 2.3 插件钩子（中层）

插件是 JavaScript/TypeScript 模块，通过钩子订阅 OpenCode 内部事件，从而扩展或修改默认行为。

**插件加载位置**（优先级依次）：
1. 项目级插件：`.opencode/plugin/` 目录下的 `.ts` 文件
2. 全局插件：`~/.config/opencode/plugin/` 目录
3. npm 包：在 `opencode.json` 中通过 `plugin` 数组配置

**插件入口与上下文**：
```typescript
import type { Plugin } from "@opencode-ai/plugin"

export default async ({ client, $, project, directory }: PluginInput) => {
  return {
    // 钩子实现...
  }
} satisfies Plugin
```

上下文包含：
- `client`：SDK 客户端，可向智能体发消息
- `$`：Bun Shell API，用于执行命令
- `project`：项目信息
- `directory`：工作目录

**钩子执行模型**：
钩子采用顺序执行（非并发），按加载顺序依次处理 `output` 对象。后加载的插件能看到前面插件的修改结果，类似中间件链：

```typescript
export async function trigger<Name extends keyof Hooks>(name: Name, input, output) {
  for (const hook of state().hooks) {
    const fn = hook[name]
    if (!fn) continue
    await fn(input, output)  // 直接修改 output
  }
  return output
}
```

- `input`：只读上下文
- `output`：可修改的结果对象，插件通过直接修改来注入行为

### 2.4 核心 Hooks 总览

OpenCode 官方提供的标准 Hooks：

| Hook | 触发时机 | 能力 | 典型用途 |
|------|----------|------|----------|
| `config` | 初始化时 | 修改运行时配置 | 注入自定义配置项 |
| `tool` | 系统启动时 | 注册新工具 | 添加自定义工具供 LLM 调用 |
| `event` | 任何总线事件 | 监听全局事件流 | 监听文件变更、会话状态 |
| `chat.message` | 收到用户消息时 | 拦截/修改消息 | 关键词检测、首消息处理 |
| `chat.params` | 发送给 LLM 前 | 调整模型参数 | 修改 temperature、模型选择 |
| `chat.headers` | 发送 HTTP 请求前 | 注入请求头 | 添加认证头 |
| `tool.execute.before` | 工具执行前 | 可阻止执行 | 权限检查、安全验证 |
| `tool.execute.after` | 工具执行后 | 修改输出 | 日志记录、输出截断 |

**实验性 Hooks**：

| Hook | 能力 |
|------|------|
| `experimental.chat.messages.transform` | 修改发送给 LLM 的消息列表 |
| `experimental.chat.system.transform` | 修改系统提示词（System Prompt） |
| `experimental.session.compacting` | 自定义会话压缩行为 |
| `permission.ask` | 自动批准或拒绝权限请求 |
| `experimental.text.complete` | 生成后文本处理 |
| `command.execute.before` | 命令执行前拦截 |
| `shell.env` | Shell 环境变量注入 |
| `tool.definition` | 工具描述修改 |
| `auth` | 自定义认证提供者 |

**可用事件类型**：

插件的 `event` 钩子可以订阅以下事件：

- **文件事件**：`file.edited`, `file.watcher.updated`
- **会话事件**：`session.created`, `session.compacted`, `session.idle`, `session.deleted`
- **消息事件**：`message.updated`, `message.removed`, `message.part.updated`
- **工具事件**：`tool.execute.before`, `tool.execute.after`
- **权限事件**：`permission.replied`, `permission.updated`
- **LSP 事件**：`lsp.client.diagnostics`, `lsp.updated`
- **命令事件**：`command.executed`

### 2.5 配置钩子（上层）

面向不写代码的用户，通过 `opencode.jsonc` 配置。

**`file_edited` 钩子**：
文件被编辑后触发，支持 glob 模式匹配：

```jsonc
{
  "experimental": {
    "hook": {
      "file_edited": {
        "*.ts": [
          {
            "command": ["prettier", "--write", "$FILE"],
            "environment": { "NODE_ENV": "production" }
          }
        ],
        "*.py": [
          { "command": ["black", "$FILE"] }
        ]
      }
    }
  }
}
```

`$FILE` 会被替换为实际文件路径。

**`session_completed` 钩子**：
会话结束时触发，适合做通知、日志归档：

```jsonc
{
  "experimental": {
    "hook": {
      "session_completed": [
        {
          "command": ["notify-send", "OpenCode", "Session completed"]
        }
      ]
    }
  }
}
```

---

## 三、插件管理

### 3.1 安装插件

**配置钩子（JSON/JSONC）**：

在 `opencode.jsonc` 的 `experimental.hook` 节点中配置。

**插件钩子（TS/JS 模块）**：

插件是一个导出函数的模块，接收上下文对象，返回钩子对象。

加载路径优先级：
1. 项目级：`.opencode/plugins/` 或 `.opencode/plugin/`
2. 全局级：`~/.config/opencode/plugins/` 或 `~/.config/opencode/plugin/`
3. npm 包：在 `opencode.json` 的 `plugin` 数组中声明

**启用插件**：

```jsonc
{
  "plugin": [
    // 放在标准插件目录 `.opencode/plugins` 下
    "MyPlugin.js",
    // 放在其他位置（使用绝对路径）
    "file:///path/to/MyPlugin.js",
    // 其它插件
    "opencode-claude-hooks"
  ]
}
```

**依赖管理**：

本地插件可使用外部 npm 包。在配置目录（`.opencode/` 或 `~/.config/opencode/`）添加 `package.json`，OpenCode 启动时会自动运行 `bun install`。

### 3.2 查看已安装插件

**查看 npm 安装的插件**：

通过配置文件查看：
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

查看实际安装的包：
```bash
# 查看缓存的插件
ls ~/.cache/opencode/node_modules/

# 过滤 opencode 相关包
ls ~/.cache/opencode/node_modules/ | grep opencode
```

启动日志查看：
```bash
opencode
# 启动时会显示类似：
# [plugin] Loading opencode-notify...
# [plugin] Loading opencode-skillful...
```

**查看本地文件插件**：
```bash
# 项目级本地插件
ls .opencode/plugins/

# 全局本地插件
ls ~/.config/opencode/plugins/

# 自定义配置目录
ls $OPENCODE_CONFIG_DIR/plugins/
```

### 3.3 卸载插件

**卸载 npm 插件**：

编辑 `opencode.json`，从 `plugin` 数组中删除目标插件即可，无需手动运行 `npm uninstall`。

清理缓存（彻底删除）：
```bash
# 删除特定插件
rm -rf ~/.cache/opencode/node_modules/opencode-skillful

# 或清空整个插件缓存（下次启动会重新安装保留的插件）
rm -rf ~/.cache/opencode/node_modules/
```

**卸载本地文件插件**：
```bash
# 项目级插件
rm .opencode/plugins/my-plugin.ts

# 全局插件
rm ~/.config/opencode/plugins/my-plugin.ts
```

**卸载后验证**：

重启 OpenCode 并观察启动日志，确认目标插件不再出现。

**常见问题**：

| 问题 | 原因 | 解决 |
|------|------|------|
| 删除配置后插件仍在运行 | OpenCode 进程未重启 | 完全退出并重新启动 OpenCode |
| 缓存清理后插件自动恢复 | 配置中仍保留该插件 | 检查 `opencode.json` 是否已删除条目 |
| 本地插件删除后报错 | 其他配置引用该插件 | 检查 `plugin` 数组中是否有 `file://` 路径指向已删除文件 |
| 全局与项目插件冲突 | 同名插件在不同层级 | 同时检查 `~/.config/opencode/` 和 `./opencode.json` |

---

## 四、Hooks 参数详解

OpenCode 的所有 Hooks 都遵循统一的调用契约：`(input, output) => Promise<void>`。`input` 是只读上下文，`output` 是可修改的结果对象——通过直接修改 `output` 的属性来影响后续流程。

### 4.1 通用约定

| 规则 | 说明 |
|------|------|
| 直接修改 | 必须直接修改 `output` 对象，不要返回新对象 |
| 只读 input | `input` 为只读上下文，修改无效 |
| 顺序执行 | 多个插件的同一 Hook 按加载顺序串行执行，后加载的插件能看到前面插件的修改结果 |
| 异步支持 | 所有 Hook 都是 `async`，可执行 I/O 操作 |

### 4.2 标准 Hooks 上下文参数详解

#### 4.2.1 `config` — 运行时配置注入

触发时机：插件初始化时执行一次。

| 参数 | 字段 | 类型 | 可修改 | 说明 |
|------|------|------|--------|------|
| `input` | `command` | `Record<string, CommandDef>` | ✅ | 斜杠命令定义表 |
| | `agent` | `Record<string, AgentDef>` | ✅ | Agent 定义表 |
| | `mcp` | `MCPConfig` | ✅ | MCP 服务器配置 |

无 `output` 参数，直接修改 `input` 对象本身（唯一一个修改 input 的 Hook）。

```typescript
config: async (config) => {
  config.command = config.command || {}
  config.command["deploy"] = {
    template: "Run deployment for $ARGUMENTS",
    description: "Deploy to production",
  }
}
```

#### 4.2.2 `tool` — 工具注册

注意：这不是 `(input, output)` 回调，而是返回工具定义对象。

| 返回值 | 类型 | 说明 |
|--------|------|------|
| `tool` | `Record<string, ToolDefinition>` | 工具名称 → 工具定义的映射 |

工具定义通过 `tool({ description, args, execute })` 构造。

```typescript
import { tool } from "@opencode-ai/plugin"

return {
  tool: {
    gitStatus: tool({
      description: "Get git status in one line",
      args: {},
      async execute(args, ctx) {
        return "Working tree clean"
      },
    }),
  },
}
```

**ToolContext 参数**（`execute` 的第二个参数）：

| 字段 | 类型 | 说明 |
|------|------|------|
| `sessionID` | `string` | 当前会话 ID |
| `messageID` | `string` | 当前消息 ID |
| `agent` | `string` | 当前 Agent 标识 |
| `directory` | `string` | 项目目录（优先于 `process.cwd()`） |
| `worktree` | `string` | Git worktree 根路径 |
| `abort` | `AbortSignal` | 取消信号 |
| `metadata()` | `function` | 设置工具元数据（标题等） |
| `ask()` | `function` | 请求权限（异步） |

#### 4.2.3 `event` — 全局事件监听

| 参数 | 字段 | 类型 | 可修改 | 说明 |
|------|------|------|--------|------|
| `input` | `event` | `BusEvent` | ❌ | 事件对象，含 `type` 和 `data`/`properties` |

只读观察者，无法修改事件或阻止流程。如需拦截，应使用专门的 Hook。

```typescript
event: async ({ event }) => {
  if (event.type === "file.edited") {
    console.log("File edited:", (event as any).data?.path)
  }
}
```

**常见事件数据结构**：

| 事件类型 | `event.data` 结构 |
|----------|-------------------|
| `file.edited` | `{ path: string; content: string; timestamp: number }` |
| `tool.execute.before` | `{ tool: string; args: Record<string, any>; user: string }` |
| `tool.execute.after` | `{ tool: string; duration: number; success: boolean; output?: any; error?: string }` |

#### 4.2.4 `chat.message` — 消息拦截

触发时机：收到用户消息后、发送给 LLM 前。

| 参数 | 字段 | 类型 | 可修改 | 说明 |
|------|------|------|--------|------|
| `input` | `sessionID` | `string` | ❌ | 当前会话 ID |
| | `agent` | `string` | ❌ | 当前 Agent 标识 |
| | `model` | `{ providerID: string; modelID: string }` | ❌ | 当前模型信息 |
| | `messageID` | `string` | ❌ | 消息 ID |
| | `variant` | `string` | ❌ | 消息变体标识 |
| `output` | `message` | `UserMessage` | ✅ | 用户消息对象 |
| | `parts` | `Part[]` | ✅ | 消息分片数组 |

```typescript
"chat.message": async ({ sessionID, model }, { message, parts }) => {
  if (message.content?.includes("ultrawork")) {
    // 修改消息或附加元数据
  }
}
```

#### 4.2.5 `chat.params` — LLM 参数调整

触发时机：发送给 LLM 前。

| 参数 | 字段 | 类型 | 可修改 | 说明 |
|------|------|------|--------|------|
| `input` | `sessionID` | `string` | ❌ | 会话 ID |
| | `agent` | `string` | ❌ | Agent 标识 |
| | `model` | `Model` | ❌ | 模型配置对象 |
| | `provider` | `ProviderContext` | ❌ | 提供商上下文 |
| | `message` | `UserMessage` | ❌ | 当前用户消息 |
| `output` | `temperature` | `number` | ✅ | 采样温度 |
| | `topP` | `number` | ✅ | Top-p 采样 |
| | `topK` | `number` | ✅ | Top-k 采样 |
| | `options` | `Record<string, any>` | ✅ | 其他模型参数（透传） |

```typescript
"chat.params": async ({ model, provider, message }, { temperature, topP, options }) => {
  if (model.modelID.includes("claude")) {
    temperature = 0.3
  }
  options.customParam = "value"
}
```

#### 4.2.6 `chat.headers` — HTTP 请求头注入

| 参数 | 字段 | 类型 | 可修改 | 说明 |
|------|------|------|--------|------|
| `input` | `sessionID` | `string` | ❌ | 会话 ID |
| | `agent` | `string` | ❌ | Agent 标识 |
| | `model` | `Model` | ❌ | 模型配置 |
| | `provider` | `ProviderContext` | ❌ | 提供商上下文 |
| | `message` | `UserMessage` | ❌ | 当前消息 |
| `output` | `headers` | `Record<string, string>` | ✅ | 请求头键值对 |

```typescript
"chat.headers": async (input, { headers }) => {
  headers["X-Custom-Auth"] = "bearer-token"
}
```

#### 4.2.7 `tool.execute.before` — 工具执行前拦截

| 参数 | 字段 | 类型 | 可修改 | 说明 |
|------|------|------|--------|------|
| `input` | `tool` | `string` | ❌ | 工具名称（如 `bash`、`Read`） |
| | `sessionID` | `string` | ❌ | 当前会话 ID |
| | `callID` | `string` | ❌ | 本次调用唯一 ID |
| `output` | `args` | `any` | ✅ | 工具参数，可直接修改 |
| | `abort` | `string` | ✅ | 赋值为字符串即可阻止执行，值为拒绝原因 |

阻止执行：给 `output.abort` 赋值字符串，或 `throw new Error()`。

```typescript
"tool.execute.before": async ({ tool, sessionID, callID }, { args, abort }) => {
  if (tool === "bash") {
    args.command = args.command.replace("rm -rf", "rm -ri")
  }
  if (tool === "Read" && args.filePath?.includes(".env")) {
    abort = "Security policy: .env files are blocked"
  }
}
```

> 版本差异：部分旧文档中结构为 `{ call: { name, input } }`，当前官方版本使用 `input.tool` / `output.args` 结构。

#### 4.2.8 `tool.execute.after` — 工具执行后处理

触发时机：工具执行完成后、结果写入会话前。

| 参数 | 字段 | 类型 | 可修改 | 说明 |
|------|------|------|--------|------|
| `input` | `tool` | `string` | ❌ | 工具名称 |
| | `sessionID` | `string` | ❌ | 会话 ID |
| | `callID` | `string` | ❌ | 调用 ID |
| | `args` | `any` | ❌ | 原始调用参数（只读） |
| `output` | `title` | `string` | ✅ | 工具结果标题 |
| | `output` | `string` | ✅ | 工具输出内容（可修改返回给 LLM 的结果） |
| | `metadata` | `any` | ✅ | 工具元数据 |

```typescript
"tool.execute.after": async ({ tool, args }, { title, output, metadata }) => {
  if (tool === "edit" && args?.filePath?.endsWith(".ts")) {
    await $`prettier --write ${args.filePath}`
  }
}
```

#### 4.2.9 `permission.ask` — 权限请求控制

触发时机：系统需要请求用户权限时。设置为 `allow` 可自动批准，`deny` 自动拒绝。

| 参数 | 字段 | 类型 | 可修改 | 说明 |
|------|------|------|--------|------|
| `input` | `type` | `string` | ❌ | 权限类型（如 `read_file`、`bash`） |
| | `target` | `string` | ❌ | 请求目标（文件路径或命令） |
| | `patterns` | `string[]` | ❌ | 匹配模式 |
| | `always` | `string[]` | ❌ | 总是允许的列表 |
| | `metadata` | `Record<string, any>` | ❌ | 附加元数据 |
| `output` | `status` | `"allow" \| "deny" \| "ask"` | ✅ | 覆盖权限决策 |

```typescript
"permission.ask": async (permission, { status }) => {
  if (permission.type === "read_file" && permission.target?.endsWith(".md")) {
    status = "allow"
  }
}
```

#### 4.2.10 `command.execute.before` — 命令执行前拦截

| 参数 | 字段 | 类型 | 可修改 | 说明 |
|------|------|------|--------|------|
| `input` | `command` | `string` | ❌ | 命令名称 |
| | `sessionID` | `string` | ❌ | 会话 ID |
| | `arguments` | `string` | ❌ | 命令参数 |
| `output` | `parts` | `Part[]` | ✅ | 可注入额外内容到输出 |

#### 4.2.11 `shell.env` — Shell 环境变量注入

触发时机：每次执行 `bash` 工具前，用于修复无状态 shell 或注入 secrets。

| 参数 | 字段 | 类型 | 可修改 | 说明 |
|------|------|------|--------|------|
| `input` | `cwd` | `string` | ❌ | 当前工作目录 |
| | `sessionID` | `string` | ❌ | 会话 ID（可选） |
| | `callID` | `string` | ❌ | 调用 ID（可选） |
| `output` | `env` | `Record<string, string>` | ✅ | 环境变量键值对 |

```typescript
"shell.env": async ({ cwd }, { env }) => {
  env.PATH = `/usr/local/bin:${env.PATH}`
  env.API_KEY = process.env.API_KEY || ""
}
```

### 4.3 实验性 Hooks 上下文参数详解

#### 4.3.1 `experimental.chat.messages.transform` — 消息列表变换

触发时机：发送给 LLM 前，对完整消息列表进行最终调整。

| 参数 | 字段 | 类型 | 可修改 | 说明 |
|------|------|------|--------|------|
| `input` | — | `{}` | — | 空对象 |
| `output` | `messages` | `{ info: Message; parts: Part[] }[]` | ✅ | 完整消息历史，可增删改 |

```typescript
"experimental.chat.messages.transform": async (input, { messages }) => {
  messages.push({
    info: { role: "user", content: "Remember: use TypeScript strict mode" },
    parts: []
  })
}
```

#### 4.3.2 `experimental.chat.system.transform` — 系统提示词注入

触发时机：构造 LLM 请求时。

| 参数 | 字段 | 类型 | 可修改 | 说明 |
|------|------|------|--------|------|
| `input` | `sessionID` | `string` | ❌ | 会话 ID（可选） |
| | `model` | `Model` | ❌ | 模型配置 |
| `output` | `system` | `string[]` | ✅ | 系统提示词字符串数组，可 `push` 新内容 |

```typescript
"experimental.chat.system.transform": async ({ sessionID, model }, { system }) => {
  system.push(`<<custom-context>
    Important project rules: Always use async/await.
  </custom-context>`)
}
```

#### 4.3.3 `experimental.session.compacting` — 会话压缩控制

触发时机：会话达到上下文长度限制、触发压缩时。

| 参数 | 字段 | 类型 | 可修改 | 说明 |
|------|------|------|--------|------|
| `input` | `sessionID` | `string` | ❌ | 当前会话 ID |
| `output` | `context` | `string[]` | ✅ | 要保留到压缩后上下文的字符串片段 |
| | `prompt` | `string` | ✅ | 可选，完全替换压缩提示词 |

```typescript
"experimental.session.compacting": async ({ sessionID }, { context, prompt }) => {
  context.push(`<<preserved-state>
    Task progress: 75%
    Current branch: feature/auth-refactor
  </preserved-state>`)
}
```

#### 4.3.4 `experimental.text.complete` — 生成后文本处理

触发时机：文本生成完成后、展示给用户前。

| 参数 | 字段 | 类型 | 可修改 | 说明 |
|------|------|------|--------|------|
| `input` | `sessionID` | `string` | ❌ | 会话 ID |
| | `messageID` | `string` | ❌ | 消息 ID |
| | `partID` | `string` | ❌ | 文本分片 ID |
| `output` | `text` | `string` | ✅ | LLM 生成的原始文本 |

```typescript
"experimental.text.complete": async ({ sessionID, messageID, partID }, { text }) => {
  text += "\n\n---\nGenerated by OpenCode"
}
```

### 4.4 其他专用 Hooks

#### 4.4.1 `tool.definition` — 工具描述修改

触发时机：工具列表发送给 LLM 前，可动态修改工具的描述或参数结构。

| 参数 | 字段 | 类型 | 可修改 | 说明 |
|------|------|------|--------|------|
| `input` | `toolID` | `string` | ❌ | 工具标识 |
| `output` | `description` | `string` | ✅ | 工具描述（展示给 LLM） |
| | `parameters` | `any` | ✅ | 参数结构（JSON Schema） |

#### 4.4.2 `auth` — 自定义认证提供者

非 `(input, output)` 回调，返回认证配置对象：

| 返回值字段 | 类型 | 说明 |
|------------|------|------|
| `provider` | `string` | 认证提供商标识 |
| `loader` | `function` | 异步加载认证配置 |
| `methods` | `AuthMethod[]` | 认证方法列表（OAuth、API Key 等） |

### 4.5 参数修改模式速查表

| 目标操作 | 修改方式 | 示例 |
|----------|----------|------|
| 修改标量值 | 直接赋值 `output.xxx = ...` | `output.temperature = 0.5` |
| 追加数组内容 | `push` 到数组 | `output.system.push("...")` |
| 阻止工具执行 | `output.abort = "原因"` | `output.abort = "Blocked"` |
| 自动批准权限 | `output.status = "allow"` | `output.status = "allow"` |
| 修改请求头 | `output.headers["key"] = "value"` | `output.headers["X-Auth"] = "token"` |
| 注入环境变量 | `output.env["KEY"] = "value"` | `output.env.PATH = "/usr/bin"` |

### 4.6 常见错误

| 错误 | 原因 | 正确做法 |
|------|------|----------|
| 修改 `input` | `input` 为只读上下文 | 只修改 `output` |
| 返回新对象 | Hook 不接收返回值 | 直接修改传入的 `output` |
| 同步处理 | 阻塞事件循环 | 使用 `async` 并在必要时 `await` |
| 未检查事件类型 | `event` Hook 收到所有事件 | 使用 `if (event.type === "...")` 过滤 |
| 使用 `process.cwd()` | 不可靠 | 使用 `ctx.directory` 或 `ctx.worktree` |

---

## 五、Plugin 开发与调试

### 5.1 基础结构

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

### 5.2 核心 Hook 类型速查

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

### 5.3 事件监听完整列表

- **会话事件**：`session.created`、`session.updated`、`session.idle`、`session.error`、`session.deleted`、`session.compacted`、`session.diff`、`session.status`
- **消息事件**：`message.updated`、`message.removed`、`message.part.updated`、`message.part.removed`
- **文件事件**：`file.edited`、`file.watcher.updated`
- **权限事件**：`permission.asked`、`permission.replied`
- **TUI 事件**：`tui.prompt.append`、`tui.command.execute`、`tui.toast.show`
- **其他**：`command.executed`、`lsp.client.diagnostics`、`lsp.updated`、`installation.updated`、`server.connected`

### 5.4 完整开发实例

#### 5.4.1 项目搭建

环境准备：OpenCode 插件基于 Bun 运行时，开发前确保已安装 `bun` 和 `opencode` CLI。

```bash
# 创建插件包
mkdir my-opencode-plugin && cd my-opencode-plugin
bun init
```

安装依赖：
```bash
bun add @opencode-ai/plugin @opencode-ai/sdk zod
bun add -d @types/node typescript
```

`package.json` 核心依赖：
```json
{
  "dependencies": {
    "@opencode-ai/plugin": "latest",
    "@opencode-ai/sdk": "latest",
    "zod": "latest"
  },
  "devDependencies": {
    "@types/node": "latest",
    "typescript": "latest"
  }
}
```

TypeScript 配置：
```json
{
  "extends": "@tsconfig/node22/tsconfig.json",
  "compilerOptions": {
    "outDir": "dist",
    "module": "preserve",
    "declaration": true,
    "moduleResolution": "bundler"
  },
  "include": ["src"]
}
```

三种加载方式：

| 方式 | 路径 | 适用场景 |
|------|------|----------|
| 项目级 | `./.opencode/plugin/my-plugin.ts` | 仅当前项目使用，无需发布 |
| 全局级 | `~/.config/opencode/plugin/my-plugin.ts` | 个人跨项目使用 |
| npm 包 | `opencode.json` 中配置 `"plugin": ["my-plugin"]` | 团队共享或公开发布 |

本地开发推荐：项目级或全局级直接放 `.ts` 源文件，OpenCode 会自动用 Bun 执行，无需手动编译。

如需打包（用于发布或复杂依赖）：
```bash
bun build src/index.ts --outdir dist --target bun --format esm
```

#### 5.4.2 实例 1：最小可用插件（Hello Tool）

`src/index.ts`：
```typescript
import { Plugin, tool } from '@opencode-ai/plugin'

export default (async (ctx) => {
  return {
    tool: {
      hello: tool({
        description: 'Say hello to someone',
        args: {
          name: tool.schema.string().describe('Name to greet'),
        },
        async execute({ name }) {
          return `Hello, ${name}!`
        },
      }),
    },
  }
}) satisfies Plugin
```

将文件保存到 `.opencode/plugin/hello.ts`，重启 OpenCode 后，Agent 就能调用 `hello` 工具。

#### 5.4.3 实例 2：带 Hooks 的综合插件

以下插件同时演示了工具注册、权限拦截、消息预处理、系统提示词注入四种能力：

```typescript
import { Plugin, tool } from '@opencode-ai/plugin'

export default (async ({ client, $, project, directory }) => {
  const startTime = Date.now()

  return {
    // 1. 注册自定义工具
    tool: {
      gitStatus: tool({
        description: 'Get git status in one line',
        args: {},
        async execute() {
          const result = await $`git status --porcelain`
          return result.text() || "Working tree clean"
        },
      }),

      notify: tool({
        description: 'Send a notification to the user without expecting reply',
        args: {
          text: tool.schema.string().describe('Notification text'),
        },
        async execute({ text }, toolCtx) {
          await client.session.prompt({
            path: { id: toolCtx.sessionID },
            body: {
              noReply: true,
              parts: [{ type: 'text', text }],
            },
          })
          return "Notified"
        },
      }),
    },

    // 2. 权限自动批准
    'permission.ask': async (permission, output) => {
      if (permission.type === 'read_file' && permission.target?.endsWith('.md')) {
        output.status = 'allow'
      }
    },

    // 3. 工具执行前拦截（安全策略）
    'tool.execute.before': async ({ tool, sessionID }, { args, abort }) => {
      if (tool === 'Read' && args.filePath?.includes('.env')) {
        abort = 'Security policy: .env files are blocked'
      }
      if (tool === 'bash') {
        console.log(`[${sessionID}] bash: ${args.command}`)
      }
    },

    // 4. 工具执行后处理
    'tool.execute.after': async ({ tool }, output) => {
      if (tool === 'edit' && output.args?.filePath?.endsWith('.ts')) {
        await $`prettier --write ${output.args.filePath}`
      }
    },

    // 5. 系统提示词注入
    'experimental.chat.system.transform': async (input, output) => {
      output.system.push(`<<plugin-context>
        Project: ${project.name}
        Directory: ${directory}
        Plugin uptime: ${(Date.now() - startTime) / 1000}s
      </plugin-context>`)
    },

    // 6. 事件监听
    event: async ({ event }) => {
      if (event.type === 'session.created') {
        console.log('New session started')
      }
    },
  }
}) satisfies Plugin
```

#### 5.4.4 实例 3：配置型插件（Config Hook）

通过 `config` Hook 以编程方式注入命令和 Agent：

```typescript
export default (async (ctx) => {
  return {
    config: async (config) => {
      config.command = config.command || {}
      config.command["deploy"] = {
        template: "Run deployment script for $ARGUMENTS",
        description: "Deploy to production",
      }

      config.agent = config.agent || {}
      config.agent["security-auditor"] = {
        model: "claude-sonnet-4",
        systemPrompt: "You are a security auditor. Review all code for vulnerabilities.",
      }
    },
  }
}) satisfies Plugin
```

#### 5.4.5 实例 4：会话压缩控制（Memory 插件模式）

```typescript
'experimental.session.compacting': async (input, output) => {
  const coreMemories = await recallCoreMemories(input.sessionID)

  output.context.push(`<<critical-memory>
    ${coreMemories.join('\n')}
  </critical-memory>`)
}
```

### 5.5 构建与部署

**构建**：
```bash
bun run build
```

**本地测试（文件路径）**：
```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["file:///absolute/path/to/opencode-my-plugin/dist/index.js"]
}
```

**本地测试（bun link）**：
```bash
# 在插件目录
bun link

# 在测试项目目录
bun link opencode-my-plugin
```

**发布到 npm**：
```bash
npm login
npm publish --access public
```

发布后使用：
```json
{
  "plugin": ["opencode-my-plugin@1.0.0"]
}
```

### 5.6 目录结构

```
opencode-my-plugin/
├── src/
│   └── index.ts          # 主入口
├── dist/                 # 编译输出
├── package.json
├── tsconfig.json
└── README.md
```

### 5.7 调试技巧

#### 5.7.1 文件日志调试（最常用）

```typescript
import { writeFileSync } from 'fs'

function fileLog(msg: string, tag = 'plugin') {
  const line = `[${new Date().toISOString()}][${tag}] ${msg}\n`
  writeFileSync('/tmp/opencode-debug.log', line, { flag: 'a' })
}

// 在 Hook 中使用
'chat.message': async (input, output) => {
  fileLog(`DEBUG: input = ${JSON.stringify(input)}`, 'debug')
  fileLog(`DEBUG: output = ${JSON.stringify(output)}`, 'debug')
}
```

查看日志：
```bash
# 实时跟踪
tail -f /tmp/opencode-debug.log

# 过滤自己的调试信息
cat /tmp/opencode-debug.log | grep DEBUG
```

#### 5.7.2 插件重载机制

| 场景 | 行为 |
|------|------|
| 每次启动新会话 | 重新加载插件 |
| 修改 `.ts` 源文件 | 不会自动热重载，需重启 OpenCode |
| 使用 npm 包 | 首次自动 `bun install`，后续需手动更新 |

开发循环：
1. 编辑插件文件
2. `Ctrl+C` 退出 OpenCode
3. 重新启动 `opencode`
4. 检查 `/tmp` 日志

#### 5.7.3 使用 Debug Agent 插件（高级调试）

社区提供了 `opencode-debug-agent` 插件，专门用于运行时调试：

```json
{
  "plugin": ["opencode-debug-agent"]
}
```

功能：
- 启动 HTTP 服务器捕获执行数据
- 提供 `debug_start`, `debug_read`, `debug_stop` 等工具
- 自动在代码中插入 `fetch()` 埋点，捕获运行时的 input/output 数据

#### 5.7.4 本地开发 Starter 模板

```bash
git clone https://github.com/darrenhinde/OpenCode-plugin-starter.git
cd OpenCode-plugin-starter
bun install
bun run build:plugin   # 打包到 dist/
```

该模板包含：
- 完整的 `my-little-ui` 示例插件（工具 + Hooks + Agent）
- `context/` 目录：给 LLM 的插件开发知识库
- 根目录 `config.json`：配置 OpenCode 加载本地插件
- `package.json` 中使用 `"my-little-ui": "file:./my-little-ui"` 本地引用

### 5.8 插件开发最佳实践

1. **避免重复初始化**：使用 `seen` 集合防止同一函数被多次注册（当模块同时导出命名导出和默认导出时）
2. **热重载注意**：目前 OpenCode 的插件系统正在完善热重载机制，上游正在添加 `skill.list` / `skill.load` 等钩子以支持单缓存、单失效点
3. **内部 Hooks 分层**：如果 OpenCode 的原生钩子粒度不够，可以在插件内部再实现更细粒度的钩子系统（如 oh-my-opencode 内部实现了 46 个自己的 Hooks）
4. **善用 `subscribeAll`**：通过 `event` 钩子 + `subscribeAll` 桥接，可以监听所有事件而不需要逐个订阅

---

## 六、社区插件推荐

以下是 OpenCode 生态中值得推荐的插件，按使用场景分类整理。

### 6.1 认证与模型接入（省钱必备）

| 插件 | 功能 | 安装 |
|------|------|------|
| `opencode-openai-codex-auth` | 用 ChatGPT Plus/Pro 订阅代替 API 计费 | `npm i opencode-openai-codex-auth` |
| `opencode-gemini-auth` | 用现有 Gemini 计划代替 API 计费 | `npm i opencode-gemini-auth` |
| `opencode-antigravity-auth` | 免费使用 Antigravity 模型 | `npm i opencode-antigravity-auth` |
| `opencode-google-antigravity-auth` | Google Antigravity OAuth，支持 Google Search | `npm i opencode-google-antigravity-auth` |
| `opencode-qwen-auth` | 通义千问 OAuth 认证，支持多账号轮询 | `npm i opencode-qwen-auth` |

### 6.2 效率与生产力（核心推荐）

| 插件 | 功能 | 场景 |
|------|------|------|
| `oh-my-opencode` | 背景 Agent、预置 LSP/AST/MCP 工具、精选 Agent 集合 | 必装，相当于给 OpenCode 装上"超能力套件" |
| `opencode-morph-fast-apply` | 10 倍速代码编辑，延迟编辑标记 | 大文件重构时节省大量时间 |
| `opencode-dynamic-context-pruning` | 自动剪枝过时工具输出，优化 Token 使用 | 省钱神器，减少 API 消耗 |
| `opencode-skillful` | Agent 按需懒加载 Prompt，技能发现与注入 | 避免一次性加载过多上下文 |
| `opencode-supermemory` | 跨会话持久化记忆 | 长期项目保持上下文连续性 |
| `opencode-snip` | 自动为 shell 命令添加 snip 前缀，减少 60-90% Token 消耗 | 频繁执行命令时显著降低成本 |

### 6.3 通知与交互体验

| 插件 | 功能 | 平台 |
|------|------|------|
| `opencode-notify` / `opencode-notificator` | 原生 OS 通知（任务完成/权限请求/错误） | macOS/Linux/Windows |
| `opencode-smart-voice-notify` | 智能语音通知（ElevenLabs/Edge TTS/SAPI） | 全平台 |
| `opencode-ntfy.sh` | 推送通知到手机（通过 ntfy.sh） | 移动端 |
| `opencode-zellij-namer` | AI 自动重命名 Zellij 会话 | Zellij 用户 |
| `opencode-warcraft-notifications` | 魔兽音效通知（趣味性） | 全平台 |

### 6.4 安全与隐私

| 插件 | 功能 |
|------|------|
| `opencode-vibeguard` | 将敏感信息/PII 替换为占位符后再发送给 LLM，本地恢复 |
| `envsitter-guard` | 防止 Agent 读取/编辑 `.env` 文件，仅允许安全检视 |
| `cc-safety-net` | 拦截破坏性 git 和文件系统命令 |

### 6.5 开发环境与隔离

| 插件 | 功能 |
|------|------|
| `opencode-daytona` | 在隔离的 Daytona 沙盒中运行会话，支持 git 同步和实时预览 |
| `opencode-devcontainers` | 多分支 DevContainer 隔离，自动分配端口 |
| `opencode-worktree` | 零摩擦 Git Worktree 管理，自动创建/清理 |
| `opencode-direnv` | 自动加载 direnv 环境变量（Nix flakes 用户必备） |

### 6.6 工作流与自动化

| 插件 | 功能 |
|------|------|
| `opencode-conductor` | 协议驱动工作流：Context → Spec → Plan → Implement 生命周期自动化 |
| `micode` | 结构化 Brainstorm → Plan → Implement 工作流 |
| `opencode-background-agents` | Claude Code 风格的背景 Agent，异步委托 |
| `opencode-scheduler` | 定时任务调度（launchd/systemd），支持 cron 语法 |
| `pilot` | 自动化守护进程，轮询 GitHub Issues 和 Linear Tickets |
| `opencode-workspace` | 16 合 1 多 Agent 编排套件 |

### 6.7 监控与可观测性

| 插件 | 功能 |
|------|------|
| `opencode-sentry-monitor` | Sentry AI 监控，追踪和调试 Agent 行为 |
| `opencode-plugin-otel` | OpenTelemetry 导出器，支持 Datadog/Honeycomb/Grafana |
| `opencode-quota` | Token 配额追踪和用量提醒 |
| `tokenscope` | 综合 Token 用量分析和成本追踪 |
| `context-analysis` | 详细 Token 使用分析 |
| `opencode-wakatime` | 编码时间追踪（WakaTime 集成） |

### 6.8 搜索与网络

| 插件 | 功能 |
|------|------|
| `opencode-websearch-cited` | 原生网页搜索，Google Grounded 风格引用 |
| `opencode-firecrawl` | 网页爬取、抓取和搜索（通过 Firecrawl CLI） |
| `opencode-google-ai-search` | 查询 Google AI Mode (SGE) |
| `opencode-pty` | 让 AI Agent 在 PTY 中运行后台进程并交互 |

### 6.9 实用小工具

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

### 6.10 快速上手指南

**基础配置（推荐新手）**：
```json
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

## 附录

### A. 参考资料

- [OpenCode 官方文档](https://opencode.ai)
- [OpenCode 配置文档](https://opencode.ai/config.json)
- [@opencode-ai/plugin SDK](https://www.npmjs.com/package/@opencode-ai/plugin)
- [OpenCode Plugin Starter](https://github.com/darrenhinde/OpenCode-plugin-starter.git)

### B. 术语表

| 术语 | 说明 |
|------|------|
| Hooks | OpenCode 暴露的扩展接口/协议，定义扩展点 |
| Plugin | 实现 Hooks 的代码载体（TS/JS 模块或 npm 包） |
| Config Hook | 通过 JSON 声明式配置实现的简单钩子 |
| 事件总线 | 底层发布/订阅通信基础设施 |
| Event | 系统内部触发的具体事件，如 `file.edited` |
| Input | Hook 的只读上下文参数 |
| Output | Hook 的可修改结果对象 |

---

> 文档生成时间：2026-05-23
> 文档版本：v1.0
