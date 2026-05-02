# OpenCode之Hooks完全使用手册

OpenCode 的 Hooks 分为配置钩子（声明式、无需代码）和插件钩子（代码级、深度扩展）两大类，底层由事件总线驱动。

---

# 一、Hooks 分类

## 1. 配置钩子（Config Hooks）
面向普通用户，在 `opencode.json` / `opencode.jsonc` 中声明，无需编写代码。目前为实验性功能 。

钩子	触发时机	用途	
`file_edited`	文件被编辑后	自动格式化、Lint、保存后处理	
`session_completed`	会话结束时	发送通知、归档日志	

## 2. 插件钩子（Plugin Hooks）
面向开发者，通过 TypeScript/JavaScript 插件实现，可访问完整 SDK 。

钩子	触发时机	能力	
`event`	任何总线事件	监听全局事件流	
`config`	初始化时	修改运行时配置	
`tool`	工具注册时	注入自定义工具	
`auth`	认证流程	自定义认证提供商	
`chat.message`	收到新消息	拦截/修改用户消息	
`chat.params`	发送给 LLM 前	调整模型参数	
`permission.ask`	权限请求时	自动批准/拒绝	
`tool.execute.before`	工具执行前	修改工具参数（如转义命令）	
`tool.execute.after`	工具执行后	修改工具输出	
`experimental.chat.messages.transform`	发送给 LLM 前	修改消息列表	
`experimental.chat.system.transform`	系统提示词生成时	修改系统提示词	
`experimental.session.compacting`	会话压缩时	自定义压缩策略，保留关键上下文	

## 3. 底层事件类型
插件可通过 `event` 钩子或 `Bus.subscribe` 监听以下事件 ：

- 文件事件：`file.edited`, `file.watcher.updated`
- 会话事件：`session.created`, `session.compacted`, `session.deleted`, `session.idle`, `session.status`, `session.updated`
- 消息事件：`message.part.removed`, `message.part.updated`, `message.removed`, `message.updated`
- 工具事件：`tool.execute.before`, `tool.execute.after`
- 权限事件：`permission.replied`, `permission.updated`
- LSP 事件：`lsp.client.diagnostics`, `lsp.updated`
- 命令事件：`command.executed`

---

# 二、配置方式

## 1. 配置钩子（JSON/JSONC）
在 `opencode.jsonc` 的 `experimental.hook` 节点中配置 ：

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
          {
            "command": ["black", "$FILE"]
          }
        ]
      },
      "session_completed": [
        {
          "command": ["notify-send", "OpenCode", "Session completed"]
        }
      ]
    }
  }
}
```

## 2. 插件钩子（TS/JS 模块）
插件是一个导出函数的模块，接收上下文对象，返回钩子对象 。

加载路径优先级：
1. 项目级：`.opencode/plugins/` 或 `.opencode/plugin/`
2. 全局级：`~/.config/opencode/plugins/` 或 `~/.config/opencode/plugin/`
3. npm 包：在 `opencode.json` 的 `plugin` 数组中声明

启用插件：

```json
{
  "plugin": [
    "file:///path/to/my-plugin.js",
    "opencode-claude-hooks"
  ]
}
```

---

# 三、使用方法

插件基础结构

```typescript
import type { Plugin } from "@opencode-ai/plugin"

export const MyPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {
  console.log("Plugin initialized!")
  return {
    // 钩子实现
  }
}
```

上下文对象包含：
- `project`：当前项目信息
- `directory`：当前工作目录
- `worktree`：Git 工作树路径
- `client`：OpenCode SDK 客户端（用于与 AI 交互）
- `$`：Bun 的 Shell API

依赖管理
本地插件可使用外部 npm 包。在配置目录（`.opencode/` 或 `~/.config/opencode/`）添加 `package.json`，OpenCode 启动时会自动运行 `bun install` 。

---

# 四、案例

## 1. 安全防护类案例
**案例1：防止敏感文件泄露（`tool.execute.before`）**
```typescript
// 拦截read_file工具读取.env、.aws等敏感文件
export const SensitiveFileGuard = async (ctx) => {
  const sensitivePatterns = [/\.env$/, /\.aws/, /credentials/];
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "read_file") {
        const path = output.args.path;
        if (sensitivePatterns.some(pattern => pattern.test(path))) {
          throw new Error(`禁止访问敏感文件: ${path}`);
        }
      }
    }
  };
};
```

**案例2：危险命令拦截（`tool.execute.before`）**
```typescript
// 拦截rm -rf、格式化等危险命令
export const DangerousCommandGuard = async (ctx) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "bash" || input.tool === "command") {
        const cmd = output.args.command;
        if (cmd.includes("rm -rf") || cmd.includes("mkfs")) {
          throw new Error(`危险命令拦截: ${cmd}`);
        }
      }
    }
  };
};
```

## 2. 上下文优化类案例
**案例3：自定义会话压缩（`experimental.session.compacting`）**
```typescript
// 注入项目文档上下文，避免压缩时丢失关键信息
export const ProjectContextInjector = async (ctx) => {
  return {
    "experimental.session.compacting": async (input, output) => {
      // 读取项目README和AGENTS.md内容
      const readme = await ctx.fs.readFile("README.md", "utf8");
      const agents = await ctx.fs.readFile("AGENTS.md", "utf8");
      
      // 注入到压缩上下文
      output.context.push({
        role: "system",
        content: `项目文档参考:\nREADME:\n${readme.slice(0, 1000)}\nAGENTS.md:\n${agents.slice(0, 1000)}`
      });
    }
  };
};
```

## 3. 流程增强类案例
**案例4：自动添加代码注释（`file.edited`）**
```typescript
// 当文件被编辑时，自动添加标准化注释
export const AutoCommentPlugin = async (ctx) => {
  return {
    "file.edited": async (input) => {
      const { path, content } = input;
      // 只处理JavaScript/TypeScript文件
      if (path.endsWith(".js") || path.endsWith(".ts")) {
        const hasHeader = content.startsWith("/**");
        if (!hasHeader) {
          const comment = `/**
 * 文件: ${path}
 * 创建时间: ${new Date().toISOString()}
 * 描述: 自动生成的标准化注释
 */\n`;
          // 返回修改后的内容
          return { content: comment + content };
        }
      }
    }
  };
};
```

**案例5：命令执行日志记录（`command.executed`）**
```typescript
// 记录所有命令执行结果到日志文件
export const CommandLogger = async (ctx) => {
  return {
    "command.executed": async (input) => {
      const logEntry = `[${new Date().toISOString()}] 命令: ${input.command}\n退出码: ${input.exitCode}\n输出: ${input.output}\n`;
      await ctx.fs.appendFile(".opencode/command-log.txt", logEntry);
    }
  };
};
```

## 4. Oh My OpenCode实用案例
**案例6：任务前自动加载环境变量**
```bash
# ~/.oh-my-opencode/hooks/pre-task.sh
#!/bin/bash
# 加载项目.env文件到环境变量
if [ -f .env ]; then
  echo "加载环境变量中..."
  export $(grep -v '^#' .env | xargs)
fi
```

**案例7：任务后自动生成报告**
```bash
# ~/.oh-my-opencode/hooks/post-task.sh
#!/bin/bash
# 生成任务执行报告
echo "任务完成时间: $(date)" >> task-report.md
echo "执行命令历史: $(cat .opencode/command-log.txt | tail -5)" >> task-report.md
```

---

## 五、与 Claude Code 对比

特性	Claude Code	OpenCode	
主要方式	基于配置的 Shell 命令	基于插件的 TS/JS	
钩子执行	Bash 脚本	完整 SDK 访问	
配置钩子	主要功能	实验性功能	
扩展能力	有限	可定义自定义工具、修改消息流	

如需更具体的某个钩子实现细节，可以进一步说明场景。