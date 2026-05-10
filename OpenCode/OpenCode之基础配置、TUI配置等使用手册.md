# OpenCode TUI、LLM 等基础配置使用手册

## 一、配置作用域（优先级：低 → 高）

### 1. 远程配置（Remote）

- **作用**：组织/团队统一默认配置（如内部模型、MCP 服务、权限策略）
- **加载时机**：登录支持的提供商时自动拉取
- **优先级**：最低（基础层），可被全局/项目覆盖

### 2. 全局配置（Global）

- **作用**：用户级偏好（主题、默认模型、API Key、快捷键）
- **生效范围**：当前用户所有项目
- **优先级**：覆盖远程，被项目覆盖

### 3. 项目配置（Project）

- **作用**：项目专属设置（模型、权限、插件、技能、命令）
- **生效范围**：仅当前项目
- **优先级**：最高（标准文件）

### 4. 扩展作用域

- **自定义配置**：`OPENCODE_CONFIG` 环境变量指定路径
- **内联配置**：`OPENCODE_CONFIG_CONTENT` 环境变量（JSON 字符串）
- **目录配置**：`.opencode/` 子目录（agents/commands/skills/plugins 等）

---

## 二、配置文件路径（跨平台）

### 主配置（opencode.json/jsonc）

| 类型 | 路径（Linux/macOS） | 路径（Windows） |
|------|---------------------|----------------|
| 远程 | `.well-known/opencode`（URL 端点） | 同左 |
| 全局 | `~/.config/opencode/opencode.json` | `C:\Users\%USERNAME%\.config\opencode\opencode.json` |
| 项目 | `./opencode.json` 或 `./.opencode/opencode.json` | 同左 |
| 自定义 | `$OPENCODE_CONFIG` 指定 | `%OPENCODE_CONFIG%` 指定 |

### 其他关键路径

- **鉴权**：`~/.local/share/opencode/auth.json`
- **技能**：`~/.config/opencode/skills/` 或 `./.opencode/skills/`
- **命令**：`~/.config/opencode/commands/` 或 `./.opencode/commands/`
- **插件**：`~/.config/opencode/plugins/` 或 `./.opencode/plugins/`
- **MCP**：`~/.config/opencode/mcp.json` 或内嵌 `opencode.json`

---

## 三、核心配置详解（带详细注释）

### 1. 基础配置项

```jsonc
{
  // ============================================
  // 基础应用配置
  // ============================================
  
  // JSON Schema 声明，用于编辑器自动补全和验证
  // 支持 https://opencode.ai/config.json 或本地路径
  "$schema": "https://opencode.ai/config.json",
  
  // ------------------- 调试选项 -------------------
  
  // 调试模式：启用详细日志输出，用于排查问题
  // 设为 true 时会在控制台输出详细的内部运行日志
  "debug": false,
  
  // LSP 调试模式：启用语言服务器协议调试
  // 用于开发 OpenCode 本身或调试 LSP 相关功能
  "debugLsp": false,
  
  // ------------------- 自动更新 -------------------
  
  // 自动更新策略
  // true: 自动下载并安装更新（默认）
  // "notify": 仅通知有新版本，不自动安装
  // false: 完全禁用更新检查
  "autoupdate": true,
  
  // ------------------- 上下文压缩 -------------------
  
  // 上下文窗口管理：控制 Token 使用量，防止超出模型限制
  "compaction": {
    // 自动压缩：当上下文接近满时自动触发压缩
    // 压缩策略：保留关键信息，移除冗余内容
    "auto": true,
    
    // 剪枝模式：移除旧的工具输出以节省 Token
    // 例如：删除早期的文件读取结果，保留最新状态
    "prune": true
  },
  
  // ------------------- 文件监控 -------------------
  
  // 文件系统监控：监听文件变化，自动更新索引
  "watcher": {
    // 忽略模式：Glob 语法，匹配的文件不参与监控和索引
    // 建议包含：依赖目录、构建输出、版本控制、临时文件
    "ignore": [
      "node_modules/**",    // Node.js 依赖
      ".git/**",            // Git 仓库
      "dist/**",            // 构建输出
      "build/**",           // 构建目录
      ".next/**",           // Next.js 输出
      "*.log",              // 日志文件
      ".env*"               // 环境文件（安全考虑）
    ]
  },
  
  // ------------------- 指令文件 -------------------
  
  // 上下文指令文件：自动读取并注入到系统提示词中
  // 用于项目规范、编码标准、架构决策等
  // 文件不存在时自动跳过，不会报错
  "instructions": [
    ".github/copilot-instructions.md",  // GitHub Copilot 兼容
    ".cursorrules",                      // Cursor 编辑器兼容
    "opencode.md",                      // OpenCode 专用
    "CLAUDE.md"                         // Claude 项目知识
  ],
  
  // ------------------- 分享设置 -------------------
  
  // 分享功能控制：分享对话和代码片段
  // "manual": 手动确认后分享（默认，推荐）
  // "auto": 自动分享（不推荐，隐私风险）
  // "disabled": 完全禁用分享功能
  "share": "manual"
}
```

### 2. 主题与界面配置

```jsonc
{
  // ============================================
  // 主题与 TUI（终端用户界面）配置
  // ============================================
  
  // 主题名称，控制界面配色方案
  // 内置主题：opencode(默认), catppuccin, dracula, flexoki, gruvbox, 
  //          monokai, onedark, tokyonight, tron
  // 可自定义主题，放置于 ~/.config/opencode/themes/
  "theme": "opencode",
  
  // ------------------- TUI 特定设置 -------------------
  
  "tui": {
    // 滚动加速：启用 macOS 风格的平滑滚动加速
    // 效果：快速滑动时滚动距离增加，慢速时精确控制
    "scroll_acceleration": {
      "enabled": true
    },
    
    // 滚动速度：固定滚动速度倍数（1-10）
    // 仅当 scroll_acceleration.enabled 为 false 时生效
    // 数值越大，每次滚动行数越多
    "scroll_speed": 3,
    
    // 差异显示样式：代码变更的展示方式
    // "auto": 自动选择（根据终端宽度）
    // "stacked": 单列堆叠（适合窄屏）
    "diff_style": "auto"
  }
}
```

### 3. 变量替换语法详解

```jsonc
{
  // ============================================
  // 变量替换语法 - 配置动态化
  // ============================================
  
  // ------------------- 环境变量 -------------------
  // 语法：{env:VARIABLE_NAME}
  // 用途：安全引用敏感信息，支持不同环境使用不同值
  
  "apiKey": "{env:ANTHROPIC_API_KEY}",           // 简单引用
  "baseURL": "{env:CUSTOM_API_URL}",             // URL 引用
  "model": "{env:DEFAULT_MODEL}",                // 甚至模型名也可动态
  
  // ------------------- 文件内容 -------------------
  // 语法：{file:PATH}
  // 用途：加载外部文件内容，如长提示词、系统指令
  
  // 绝对路径（用户主目录）
  "systemPrompt": "{file:~/prompts/coding-assistant.txt}",
  
  // 相对路径（相对于配置文件所在目录）
  "rules": "{file:./project-rules.md}",
  
  // 项目级路径（相对于工作目录）
  "instructions": "{file:../shared-guidelines.md}",
  
  // 嵌套引用：文件内也可使用变量替换
  // coding-assistant.txt 内容示例：
  // "You are coding assistant for {env:PROJECT_NAME}"
  
  // ------------------- 组合使用 -------------------
  
  "provider": {
    "custom": {
      "options": {
        // 动态构建 URL：环境变量 + 固定路径
        "baseURL": "{env:API_HOST}/v1/chat/completions",
        
        // 从文件加载系统提示，文件路径也来自环境变量
        "systemPrompt": "{file:{env:PROMPT_FILE}}"
      }
    }
  }
}
```

### 4. 工具配置

```jsonc
{
  // ============================================
  // 工具（Tools）配置 - AI 可使用的功能
  // ============================================
  
  "tools": {
    // ------------------- 文件操作工具 -------------------
    
    // 读取文件：查看文件内容
    // 安全考虑：默认启用，但受文件系统权限限制
    "read": true,
    
    // 写入文件：创建或覆盖文件
    // 风险：可能意外覆盖重要文件，建议配合 permission 设置
    "write": true,
    
    // 编辑文件：基于差异的精确修改
    // 比 write 更安全，只修改指定部分
    "edit": true,
    
    // 列出目录：查看目录内容
    "list": true,
    
    // ------------------- 终端工具 -------------------
    
    "bash": {
      "enabled": true,           // 是否启用终端执行
      
      // 需要确认的命令列表：匹配这些模式的命令需用户确认
      // 支持字符串匹配或正则表达式
      "requireApproval": [
        "rm -rf",               // 危险删除
        "sudo",                 // 提权操作
        "DROP TABLE",           // 数据库危险操作
        "curl.*| sh",           // 管道到 shell（正则）
        "wget.*| bash",         // 类似风险
        "chmod.*777",           // 过度授权
        "mkfs",                 // 格式化
        "dd if="                // 磁盘操作
      ],
      
      // 超时设置（毫秒）：防止长时间挂起
      "timeout": 30000,
      
      // 工作目录：执行命令的基准路径
      // null 表示使用当前工作目录
      "cwd": null,
      
      // 环境变量：传递给命令的额外环境
      "env": {
        "NODE_ENV": "development"
      }
    },
    
    // ------------------- 代码搜索工具 -------------------
    
    // Grep 搜索：内容搜索，支持正则
    "grep": true,
    
    // Glob 匹配：文件名模式匹配
    "glob": true,
    
    // 语义搜索：基于向量相似度的代码搜索（需配置向量数据库）
    "semantic_search": false,
    
    // ------------------- Web 工具 -------------------
    
    // 网页获取：下载网页内容
    "fetch": true,
    
    // 浏览器自动化：使用 headless 浏览器执行 JS、截图等
    // 需要额外依赖（如 Playwright）
    "browser": false,
    
    // ------------------- 版本控制工具 -------------------
    
    // Git 操作：提交、分支、差异等
    "git": true,
    
    // GitHub API 集成：Issues、PRs、Actions 等
    "github": false
  },
  
  // ------------------- 权限全局设置 -------------------
  
  // 权限控制：工具使用的默认策略
  "permission": {
    // 编辑操作：修改现有文件
    // "allow": 自动执行（默认）
    // "ask": 每次询问确认
    // "deny": 完全禁止
    "edit": "ask",
    
    // Bash 命令：终端执行
    "bash": "ask",
    
    // 写入操作：创建新文件
    "write": "allow",
    
    // 文件读取：通常设为 allow，因只读无风险
    "read": "allow"
  }
}
```

### 5. 服务器配置

```jsonc
{
  // ============================================
  // 服务器配置 - 本地 API 和 Web 界面
  // ============================================
  
  "server": {
    // 监听端口：HTTP 服务端口
    // 0 表示随机可用端口
    "port": 3000,
    
    // 主机名：绑定地址
    // "0.0.0.0": 监听所有接口（允许外部访问）
    // "127.0.0.1": 仅本地访问（更安全）
    "hostname": "0.0.0.0",
    
    // ------------------- mDNS 服务发现 -------------------
    
    // 启用 mDNS：局域网内通过域名访问
    // 效果：其他设备可通过 http://opencode.local:3000 访问
    "mdns": true,
    
    // 自定义 mDNS 域名
    // 默认：opencode.local
    "mdnsDomain": "opencode.local",
    
    // ------------------- CORS 配置 -------------------
    
    // 跨域资源共享：允许哪些前端域名访问 API
    // 开发环境需包含前端地址，生产环境应限制
    "cors": [
      "https://app.example.com",      // 生产前端
      "http://localhost:8080",        // 本地开发
      "http://localhost:3001"         // 备用端口
    ],
    
    // ------------------- 认证配置（如启用） -------------------
    
    "auth": {
      "type": "bearer",              // 认证方式：bearer, basic, api_key
      "secret": "{env:SERVER_SECRET}" // 密钥
    },
    
    // ------------------- HTTPS 配置 -------------------
    
    "tls": {
      "enabled": false,
      "cert": "{file:~/certs/server.crt}",
      "key": "{file:~/certs/server.key}"
    }
  }
}
```

### 6. 代码格式化配置

```jsonc
{
  // ============================================
  // Formatter 配置 - 代码自动格式化
  // ============================================
  
  "formatter": {
    // ------------------- 语言特定配置 -------------------
    
    // JavaScript / TypeScript
    "javascript": {
      // 格式化命令
      "command": "prettier",
      
      // 命令参数
      "args": [
        "--write",           // 直接写入文件
        "--single-quote",    // 使用单引号
        "--trailing-comma",  // 尾随逗号
        "es5",               // ES5 兼容
        "--print-width",
        "100"
      ],
      
      // 配置文件路径：若项目已有配置，优先使用项目配置
      "configFile": ".prettierrc",
      
      // 忽略文件：不格式化的文件模式
      "ignore": ["*.min.js", "dist/**"]
    },
    
    // TypeScript（可继承或覆盖 JS 配置）
    "typescript": {
      "command": "prettier",
      "args": ["--write", "--parser", "typescript"],
      "parent": "javascript"  // 继承 javascript 配置
    },
    
    // Python
    "python": {
      "command": "black",
      "args": [
        "-l", "88",          // 行长度
        "--fast",            // 快速模式（跳过某些检查）
        "--skip-string-normalization"  // 不修改引号
      ],
      
      // 虚拟环境检测：自动激活项目虚拟环境
      "detectVenv": true
    },
    
    // Rust
    "rust": {
      "command": "rustfmt",
      "args": [
        "--emit", "files",   // 直接修改文件
        "--edition", "2021"  // Rust 版本
      ],
      
      // 使用 rustfmt.toml 项目配置
      "useProjectConfig": true
    },
    
    // Go
    "go": {
      "command": "gofmt",
      "args": ["-w"],        // 写入模式
      
      // 额外工具：goimports 自动管理 import
      "additionalTools": ["goimports"]
    },
    
    // ------------------- 全局格式化设置 -------------------
    
    // 保存时自动格式化
    "formatOnSave": true,
    
    // 粘贴时自动格式化
    "formatOnPaste": false,
    
    // 格式化超时（毫秒）
    "timeout": 5000,
    
    // 格式化前确认：true 时显示预览
    "confirmBeforeFormat": false,
    
    // 失败时行为：ignore, warn, error
    "onError": "warn"
  }
}
```

### 7. 快捷键配置

```jsonc
{
  // ============================================
  // Keybinds 配置 - 键盘快捷键
  // ============================================
  
  "keybinds": {
    // ------------------- 模式切换 -------------------
    
    // 切换 Agent 模式（Build <-> Plan）
    // 在对话中快速切换工作模式
    "toggleMode": "Tab",
    
    // ------------------- 文件操作 -------------------
    
    // 文件搜索：快速打开项目文件
    "fileSearch": "Ctrl+P",
    
    // 全局搜索：跨文件内容搜索
    "globalSearch": "Ctrl+Shift+F",
    
    // 最近文件：显示最近访问的文件
    "recentFiles": "Ctrl+R",
    
    // ------------------- 命令面板 -------------------
    
    // 命令面板：执行自定义命令
    "commandPalette": "Ctrl+Shift+P",
    
    // 快速命令：直接输入命令名执行
    "quickCommand": "Ctrl+K",
    
    // ------------------- 历史导航 -------------------
    
    // 历史向上：浏览之前的对话
    "historyUp": "Up",
    
    // 历史向下：浏览之后的对话
    "historyDown": "Down",
    
    // 跳到最新：快速滚动到最新消息
    "jumpToLatest": "Ctrl+End",
    
    // ------------------- 模型变体切换 -------------------
    
    // 变体循环：在 models.variants 中切换
    // 例如：在 "default" -> "high" -> "max" 之间切换
    "variantCycle": "Ctrl+V",
    
    // 变体直接选择：数字键快速选择
    "variantSelect": ["Ctrl+1", "Ctrl+2", "Ctrl+3"],
    
    // ------------------- 界面控制 -------------------
    
    // 侧边栏切换：显示/隐藏文件树等
    "toggleSidebar": "Ctrl+B",
    
    // 全屏模式：专注模式切换
    "toggleFullscreen": "F11",
    
    // 主题切换：循环切换主题
    "themeCycle": "Ctrl+T",
    
    // ------------------- 编辑操作 -------------------
    
    // 复制代码块：复制 AI 生成的代码
    "copyCode": "Ctrl+Shift+C",
    
    // 插入代码：将代码插入到编辑器
    "insertCode": "Ctrl+Shift+I",
    
    // 差异应用：接受代码修改
    "applyDiff": "Ctrl+Enter",
    
    // 差异拒绝：拒绝代码修改
    "rejectDiff": "Ctrl+Escape",
    
    // ------------------- 工具调用 -------------------
    
    // 中断执行：停止当前工具/命令
    "interrupt": "Ctrl+C",
    
    // 确认执行：确认危险操作
    "confirm": "Enter",
    
    // 取消执行：取消当前操作
    "cancel": "Escape"
  },
  
  // ------------------- 快捷键冲突解决 -------------------
  
  // 当快捷键冲突时，优先级顺序
  "priority": [
    "commandPalette",    // 最高
    "fileSearch",
    "globalSearch",
    "toggleMode",
    "variantCycle"       // 最低
  ],
  
  // Vim 模式：启用 Vim 风格快捷键
  "vimMode": false,
  
  // Emacs 模式：启用 Emacs 风格快捷键
  "emacsMode": false
}
```

### 8. 权限配置（Permission）

```jsonc
{
  "permission": {
    "edit": "allow",      // 允许写文件：allow/ask/deny
    "bash": "ask",        // 执行 shell：allow/ask/deny
    "network": "deny",    // 网络访问
    "delete": "ask",      // 删除文件
    "read": ["src/", "docs/"],  // 允许读取目录
    "write": ["src/"]     // 允许写入目录
  }
}
```

---

*文档版本：1.0 | 最后更新：2026-04-27*
