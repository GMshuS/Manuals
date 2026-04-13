# 第三章 OpenCode配置详解

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
- 鉴权：`~/.local/share/opencode/auth.json`
- 技能：`~/.config/opencode/skills/` 或 `./.opencode/skills/`
- 命令：`~/.config/opencode/commands/` 或 `./.opencode/commands/`
- 插件：`~/.config/opencode/plugins/` 或 `./.opencode/plugins/`
- MCP：`~/.config/opencode/mcp.json` 或内嵌 `opencode.json`

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

### 3. LLM 提供商配置（核心）

```jsonc
{
  // ============================================
  // LLM 提供商配置 - 核心配置
  // ============================================
  
  "provider": {
    // ------------------- Anthropic 示例 -------------------
    "anthropic": {
      // 模型特定配置
      "models": {
        "claude-sonnet-4-5-20250929": {
          // 默认参数：每次调用该模型都使用的设置
          "options": {
            // 扩展思考模式：Claude 3.7+ 特性
            "thinking": {
              "type": "enabled",      // enabled 或 disabled
              "budgetTokens": 16000   // 思考 Token 预算（最大 32000）
            }
          },
          
          // 变体配置：通过快捷键切换的不同参数组合
          // 使用 Ctrl+V 在对话中循环切换
          "variants": {
            "high": {
              "thinking": {
                "type": "enabled",
                "budgetTokens": 32000   // 高思考预算
              }
            },
            "max": {
              "thinking": {
                "type": "enabled", 
                "budgetTokens": 64000   // 最大思考预算
              }
            }
          }
        },
        
        // 其他模型配置...
        "claude-opus-4-1": {
          "options": {
            "temperature": 0.2   // 创造性控制（0-1）
          }
        }
      },
      
      // 提供商级选项：影响该提供商所有模型
      "options": {
        // API Key：使用 {env:VAR_NAME} 语法引用环境变量
        // 安全最佳实践：从不硬编码密钥，始终使用环境变量
        "apiKey": "{env:ANTHROPIC_API_KEY}",
        
        // 基础 URL：API 端点地址
        // 可用于代理、企业内网部署或第三方兼容服务
        "baseURL": "https://api.anthropic.com",
        
        // 超时设置（毫秒）
        "timeout": 120000,
        
        // 最大重试次数
        "maxRetries": 3
      }
    },
    
    // ------------------- OpenAI 示例 -------------------
    "openai": {
      "models": {
        "gpt-5": {
          "options": {
            "temperature": 0.7,
            "top_p": 1.0,
            "frequency_penalty": 0,
            "presence_penalty": 0
          }
        },
        "o3": {
          "options": {
            "reasoning_effort": "medium"  // low, medium, high
          }
        }
      },
      "options": {
        "apiKey": "{env:OPENAI_API_KEY}",
        "baseURL": "https://api.openai.com/v1"
      }
    },
    
    // ------------------- Google Gemini 示例 -------------------
    "google": {
      "models": {
        "gemini-2.5-pro": {
          "options": {
            "safetySettings": [
              {
                "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                "threshold": "BLOCK_NONE"
              }
            ]
          }
        }
      },
      "options": {
        "apiKey": "{env:GOOGLE_API_KEY}"
      }
    },
    
    // ------------------- Azure OpenAI 示例 -------------------
    "azure": {
      "models": {
        "gpt-4o": {
          "options": {}
        }
      },
      "options": {
        "apiKey": "{env:AZURE_OPENAI_API_KEY}",
        "baseURL": "https://{env:AZURE_RESOURCE_NAME}.openai.azure.com/openai/deployments/{env:AZURE_DEPLOYMENT_NAME}",
        "apiVersion": "2024-12-01-preview"
      }
    },
    
    // ------------------- 本地模型示例（Ollama） -------------------
    "ollama": {
      "models": {
        "llama3.2": {
          "options": {
            "num_ctx": 8192   // 上下文窗口大小
          }
        }
      },
      "options": {
        "baseURL": "http://localhost:11434",
        // 本地模型通常不需要 API Key
        "apiKey": "ollama"
      }
    }
  },
  
  // ------------------- 模型选择 -------------------
  
  // 默认使用的模型，格式：提供商/模型名
  // 必须与上面配置的 provider.models 键匹配
  "model": "anthropic/claude-sonnet-4-5",
  
  // ------------------- 默认 Agent -------------------
  
  // 启动时使用的默认 Agent
  // 可选：build(编码), plan(规划), 或自定义 Agent 名称
  "default_agent": "build",
  
  // ------------------- 提供商控制 -------------------
  
  // 白名单：仅启用列出的提供商（优先级低于黑名单）
  "enabled_providers": ["anthropic", "openai"],
  
  // 黑名单：禁用特定提供商（优先级高于白名单）
  // 用于临时禁用某个提供商而不删除配置
  "disabled_providers": ["google"],
  
  // 注意：若同时设置，disabled_providers 优先
}
```

### 4. 变量替换语法详解

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

### 5. 工具配置

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

### 6. 服务器配置

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

### 7. MCP（Model Context Protocol）配置

```jsonc
{
  // ============================================
  // MCP 配置 - 外部工具和服务集成
  // ============================================
  
  "mcp": {
    // ------------------- MCP 服务器列表 -------------------
    
    "servers": {
      // 本地 STDIO 服务器：通过标准输入输出通信
      "filesystem": {
        "type": "local",           // 类型：local, remote, sse, http
        
        // 启动命令
        "command": "npx",
        
        // 命令参数
        "args": [
          "-y",                    // 自动安装
          "@modelcontextprotocol/server-filesystem",  // 包名
          "/path/to/allowed/dir"   // 允许访问的目录（安全限制）
        ],
        
        // 环境变量
        "env": {
          "NODE_ENV": "production",
          "LOG_LEVEL": "info"
        },
        
        // 自动重启：崩溃后自动重启
        "autoRestart": true
      },
      
      // 远程服务器：通过 HTTP/HTTPS 通信
      "github": {
        "type": "remote",
        
        // 服务器 URL
        "url": "https://api.github.com/mcp",
        
        // OAuth 认证配置
        "oauth": {
          "clientId": "{env:GITHUB_CLIENT_ID}",
          "clientSecret": "{env:GITHUB_CLIENT_SECRET}",  // 若需要
          "scopes": ["repo", "read:user", "issues"],     // 权限范围
          "tokenUrl": "https://github.com/login/oauth/access_token",
          "authorizeUrl": "https://github.com/login/oauth/authorize"
        },
        
        // 请求头
        "headers": {
          "Accept": "application/vnd.github.v3+json"
        }
      },
      
      // SSE（Server-Sent Events）服务器：实时流通信
      "postgres": {
        "type": "sse",
        "url": "http://localhost:3001/sse",
        
        // 作用域：配置存储位置
        // "user": 存储在全局配置（~/.config/opencode/）
        // "local": 存储在项目配置（./.opencode/）
        "scope": "local",
        
        // 当 scope 为 local 时，指定项目路径
        "projectPath": "/home/user/my-project",
        
        // 连接超时
        "timeout": 30000
      },
      
      // HTTP 服务器：标准 REST API
      "custom-api": {
        "type": "http",
        "url": "https://api.example.com/mcp",
        
        // API Key 认证
        "headers": {
          "Authorization": "Bearer {env:CUSTOM_API_KEY}"
        },
        
        // 轮询间隔（毫秒）：检查新消息频率
        "pollingInterval": 1000
      }
    },
    
    // ------------------- 默认启用状态 -------------------
    
    "defaults": {
      // 服务器默认状态：enabled 或 disabled
      // 用户可在 UI 中手动切换
      
      "filesystem": "enabled",     // 默认启用
      "github": "disabled",          // 默认禁用，需手动开启
      "postgres": "enabled"
    },
    
    // ------------------- 全局设置 -------------------
    
    // 最大并发连接数
    "maxConnections": 10,
    
    // 连接超时（毫秒）
    "connectionTimeout": 30000,
    
    // 自动重连：断开后尝试重连
    "autoReconnect": true,
    
    // 重连间隔（毫秒）
    "reconnectInterval": 5000
  }
}
```

### 8. Agent 配置

```jsonc
{
  // ============================================
  // Agent 配置 - AI 角色和行为定义
  // ============================================
  
  "agent": {
    // ------------------- 内置 Agent 覆盖 -------------------
    
    // Build 模式：编码实现，默认 Agent
    "build": {
      // 描述：显示在 UI 中
      "description": "Build mode agent - focused on coding tasks",
      
      // 系统提示词：定义 Agent 角色和能力
      // 可使用 {file:} 引用外部文件
      "systemPrompt": "You are a coding assistant. You help users write, edit, and debug code. Prefer practical solutions over theoretical explanations.",
      
      // 可用工具列表：限制该 Agent 能使用的工具
      // 从全局 tools 配置中筛选
      "tools": ["read", "write", "edit", "bash", "grep"],
      
      // 专用模型：覆盖全局 model 设置
      // 格式：提供商/模型名
      "model": "anthropic/claude-sonnet-4-5",
      
      // 只读模式：true 时禁止修改文件（适合 review 类 Agent）
      "readonly": false,
      
      // 文件关联：自动激活该 Agent 的文件模式
      // 当用户编辑匹配文件时自动切换
      "fileAssociation": {
        "patterns": ["*.rs", "Cargo.toml"],  // Rust 项目
        "languages": ["rust"]
      }
    },
    
    // Plan 模式：架构规划，只读
    "plan": {
      "description": "Plan mode agent - focused on architecture and design",
      "systemPrompt": "You are a software architect. You help users design systems, plan implementations, and review architecture. Do not write code unless explicitly asked.",
      "tools": ["read", "grep", "glob"],     // 无 write/edit/bash
      "model": "anthropic/claude-opus-4-1",  // 使用更强模型
      "readonly": true                       // 强制只读
    },
    
    // ------------------- 自定义 Agent -------------------
    
    // 代码审查专家
    "code-reviewer": {
      "description": "Code review specialist",
      "systemPrompt": "{file:~/agents/code-reviewer.md}",  // 外部文件
      "tools": ["read", "grep", "git"],        // 需要 git 查看差异
      "model": "anthropic/claude-sonnet-4-5",
      "readonly": true
    },
    
    // 文档生成器
    "doc-writer": {
      "description": "Documentation generator",
      "systemPrompt": "You write clear, concise documentation. Generate README, API docs, and inline comments.",
      "tools": ["read", "write", "edit"],
      "model": "openai/gpt-5",
      // 文件关联：编辑 .md 文件时自动激活
      "fileAssociation": {
        "patterns": ["*.md", "docs/**"],
        "languages": ["markdown"]
      }
    },
    
    // 测试生成器
    "test-generator": {
      "description": "Unit test generator",
      "systemPrompt": "You generate comprehensive unit tests. Aim for high coverage and edge case handling.",
      "tools": ["read", "write", "glob"],
      "model": "anthropic/claude-sonnet-4-5"
    }
  },
  
  // ------------------- Agent 文件定义方式（推荐）-------------------
  
  // 除 JSON 配置外，还支持文件定义，更清晰可维护
  
  // 文件路径：~/.config/opencode/agents/{name}.md
  // 或项目级：./.opencode/agents/{name}.md
  
  // 示例：~/.config/opencode/agents/security-auditor.md
  /*
  ---
  name: security-auditor
  description: Security vulnerability scanner
  tools: [read, grep, bash]
  model: anthropic/claude-opus-4-1
  readonly: true
  ---
  
  You are a security expert. Analyze code for:
  - SQL injection vulnerabilities
  - XSS risks
  - Insecure dependencies
  - Hardcoded secrets
  
  Provide specific line references and remediation advice.
  */
}
```

### 9. Command 命令配置

```jsonc
{
  // ============================================
  // Command 配置 - 自定义快捷命令
  // ============================================
  
  "command": {
    // ------------------- 测试命令 -------------------
    
    "test": {
      // 显示名称和描述
      "description": "Run project tests",
      
      // 提示词：发送给 AI 的指令
      // 描述要执行的任务，AI 会选择合适工具完成
      "prompt": "Run the test suite using the appropriate command for this project. Detect test framework (Jest, pytest, cargo test, go test, etc.) and execute. Show summary of results.",
      
      // 使用模式：build 或 plan
      // 影响可用的工具和权限
      "mode": "build",
      
      // 专用 Agent：指定使用哪个 Agent 执行
      // 不指定则使用当前激活的 Agent
      "agent": null,
      
      // 快捷方式：触发命令的方式
      // 除名称外，可定义快捷键或别名
      "shortcut": "Ctrl+Shift+T"
    },
    
    // ------------------- 提交命令 -------------------
    
    "commit": {
      "description": "Generate commit message",
      "prompt": "Analyze the current git diff and write a conventional commit message following these rules:\n1. Use semantic prefixes: feat:, fix:, docs:, style:, refactor:, test:, chore:\n2. Keep subject line under 50 characters\n3. Use body for detailed explanation when needed\n4. Reference issue numbers if detected in branch name",
      "mode": "plan",              // Plan 模式更谨慎
      "readonly": true             // 不修改文件，只生成消息
    },
    
    // ------------------- 解释命令 -------------------
    
    "explain": {
      "description": "Explain selected code",
      "prompt": "Explain the current code selection in detail. Cover:\n- What it does\n- How it works\n- Potential edge cases\n- Performance implications",
      "mode": "plan",
      "readonly": true
    },
    
    // ------------------- 重构命令 -------------------
    
    "refactor": {
      "description": "Refactor selected code",
      "prompt": "Refactor the selected code to improve:\n- Readability\n- Performance\n- Maintainability\nPreserve existing behavior. Add tests if missing.",
      "mode": "build"
    },
    
    // ------------------- 文档命令 -------------------
    
    "docs": {
      "description": "Generate documentation",
      "prompt": "Generate comprehensive documentation for the current file or selection. Include:\n- Function/class descriptions\n- Parameter explanations\n- Usage examples\n- Edge cases",
      "mode": "build"
    }
  },
  
  // ------------------- 命令文件定义方式（推荐）-------------------
  
  // 文件路径：./.opencode/commands/{name}.md
  // 或全局：~/.config/opencode/commands/{name}.md
  
  // 示例：./.opencode/commands/lint.md
  /*
  ---
  name: lint
  description: Run linter and fix issues
  mode: build
  shortcut: Ctrl+Shift+L
  ---
  
  Run the appropriate linter for this project (ESLint, Prettier, pylint, clippy, etc.).
  Fix auto-fixable issues and report remaining problems with specific file references.
  
  If no linter config exists, suggest setting one up.
  */
}
```

### 10. Skill 技能配置

```jsonc
{
  // ============================================
  // Skill 配置 - 模块化能力单元
  // ============================================
  
  // ------------------- 简单启用/禁用 -------------------
  
  "skills": {
    // 内置技能
    "git": true,           // Git 操作增强
    "docker": true,        // Docker 容器管理
    "kubernetes": false,    // K8s 操作（禁用）
    
    // 自定义技能：通过目录或插件加载
    "react-expert": true,
    "rust-optimizer": false
  },
  
  // ------------------- 详细技能配置 -------------------
  
  "skill": {
    // 技能路径：加载技能的目录
    "paths": [
      "~/.config/opencode/skills",     // 全局技能
      "./.opencode/skills"              // 项目技能（优先级更高）
    ],
    
    // 具体技能配置
    "config": {
      // Git 技能配置
      "git": {
        // 提交信息模板
        "commitTemplate": "conventional",  // conventional, simple, detailed
        
        // 自动获取：提交前自动获取远程更新
        "autoFetch": true,
        
        // 分支保护：禁止直接操作的分支
        "protectedBranches": ["main", "master", "production"]
      },
      
      // Docker 技能配置
      "docker": {
        // 默认注册表
        "registry": "docker.io",
        
        // 镜像构建缓存
        "buildCache": true,
        
        // 容器清理：停止后自动删除
        "autoRemove": false
      }
    }
  },
  
  // ------------------- 技能目录结构 -------------------
  
  // 技能文件组织示例：
  /*
  .opencode/skills/
  ├── git/                      # 技能名称
  │   ├── skill.json           # 技能元数据
  │   ├── prompts/             # 提示词模板
  │   │   ├── commit.txt
  │   │   └── branch.txt
  │   ├── tools/               # 自定义工具
  │   │   └── git-advanced.js
  │   └── knowledge/           # 知识库
  │       └── workflows.md
  │
  ├── react-expert/
  │   ├── skill.json
  │   ├── prompts/
  │   │   ├── hooks-best-practices.txt
  │   │   └── performance-optimization.txt
  │   └── knowledge/
  │       ├── react-19-features.md
  │       └── nextjs-patterns.md
  │
  └── rust-optimizer/
      ├── skill.json
      └── prompts/
          └── unsafe-guidelines.txt
  */
  
  // skill.json 示例：
  /*
  {
    "name": "react-expert",
    "version": "1.0.0",
    "description": "React and Next.js expertise",
    "author": "Your Name",
    
    // 激活条件
    "activation": {
      "filePatterns": ["*.tsx", "*.jsx", "next.config.*"],
      "dependencies": ["react", "next"]
    },
    
    // 提供的功能
    "features": [
      "component-generation",
      "hook-optimization",
      "performance-analysis"
    ],
    
    // 依赖的其他技能
    "requires": ["typescript"],  // 依赖 typescript 技能
    
    // 冲突的技能
    "conflicts": ["vue-expert"]  // 不能同时激活
  }
  */
}
```

### 11. 插件配置

```jsonc
{
  // ============================================
  // Plugin 配置 - 扩展功能
  // ============================================
  
  "plugin": {
    // ------------------- NPM 插件 -------------------
    
    // 插件包列表：从 npm 安装
    "packages": [
      // 动态上下文修剪：自动管理长对话历史
      "@tarquinen/opencode-dcp",
      
      // 通知集成：系统通知推送
      "opencode-notify",
      
      // Git worktree 管理：多分支并行开发
      "opencode-worktree",
      
      // 代码统计：分析代码变更统计
      "opencode-stats",
      
      // 特定语言支持
      "opencode-rust",           // Rust 语言增强
      "opencode-python"          // Python 语言增强
    ],
    
    // ------------------- 本地插件 -------------------
    
    // 本地路径插件：开发中或私有插件
    "local": [
      // 相对路径（相对于配置文件）
      "./.opencode/plugins/my-plugin",
      
      // 绝对路径
      "/home/user/dev/opencode-plugins/custom-tool",
      
      // 使用 {env:} 动态路径
      "{env:PLUGINS_DIR}/experimental"
    ],
    
    // ------------------- 插件特定配置 -------------------
    
    // 每个插件的独立配置命名空间
    "config": {
      // @tarquinen/opencode-dcp 配置
      "@tarquinen/opencode-dcp": {
        // 最大保留 Token 数
        "maxTokens": 4000,
        
        // 压缩策略：summarize, truncate, archive
        "strategy": "summarize",
        
        // 保留的消息轮数（最近 N 轮不压缩）
        "preserveRounds": 3,
        
        // 摘要模型：用于生成历史摘要
        "summaryModel": "anthropic/claude-haiku"
      },
      
      // opencode-notify 配置
      "opencode-notify": {
        // 通知级别：all, errors, none
        "level": "all",
        
        // 通知方式：native, sound, silent
        "method": "native",
        
        // 长时间任务阈值（毫秒）
        "longTaskThreshold": 30000
      },
      
      // opencode-worktree 配置
      "opencode-worktree": {
        // 基础路径：worktree 存放目录
        "basePath": "../.worktrees",
        
        // 自动清理：删除已合并的 worktree
        "autoCleanup": true
      }
    },
    
    // ------------------- 插件管理 -------------------
    
    // 自动更新插件
    "autoUpdate": true,
    
    // 插件加载超时（毫秒）
    "loadTimeout": 10000,
    
    // 严格模式：插件加载失败时是否中断启动
    "strict": false
  }
}
```

### 12. 代码格式化配置

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

### 13. 快捷键配置

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

---

## 四、完整配置示例（带详细注释）

```jsonc
/**
 * OpenCode 完整配置示例
 * 
 * 配置文件：~/.config/opencode/opencode.json（全局）
 * 或：./opencode.json（项目级）
 * 
 * 配置格式：JSONC（支持注释和尾随逗号）
 * 验证：使用 $schema 启用编辑器自动补全
 */

{
  // ============================================
  // 元数据与验证
  // ============================================
  
  // JSON Schema 声明，提供 IDE 自动补全和验证
  "$schema": "https://opencode.ai/config.json",
  
  // ============================================
  // 基础应用设置
  // ============================================
  
  // 数据存储目录：会话历史、数据库等
  // 注意：包含敏感信息，不要提交到 Git
  "directory": ".opencode",
  
  // 工作目录基准，null 表示当前目录
  "workdir": null,
  
  // 调试模式：启用详细日志
  "debug": false,
  
  // 自动更新策略：true(自动), "notify"(通知), false(禁用)
  "autoupdate": "notify",
  
  // ============================================
  // 主题与界面
  // ============================================
  
  // 界面主题：opencode, tokyonight, dracula 等
  "theme": "tokyonight",
  
  // TUI 终端界面设置
  "tui": {
    // 滚动加速：macOS 风格平滑滚动
    "scroll_acceleration": { "enabled": true },
    
    // 差异显示：auto(自动), stacked(单列)
    "diff_style": "auto"
  },
  
  // ============================================
  // LLM 提供商配置（核心）
  // ============================================
  
  "provider": {
    // Anthropic Claude 配置
    "anthropic": {
      "models": {
        // Claude 4.5 Sonnet：主力编码模型
        "claude-sonnet-4-5": {
          "options": {
            // 扩展思考模式
            "thinking": {
              "type": "enabled",
              "budgetTokens": 16000
            }
          },
          // 变体：通过 Ctrl+V 切换
          "variants": {
            "high": { "thinking": { "budgetTokens": 32000 } },
            "max": { "thinking": { "budgetTokens": 64000 } }
          }
        }
      },
      "options": {
        // API Key 从环境变量读取（安全）
        "apiKey": "{env:ANTHROPIC_API_KEY}",
        "baseURL": "https://api.anthropic.com"
      }
    },
    
    // OpenAI 备用配置
    "openai": {
      "models": {
        "gpt-5": { "options": { "temperature": 0.7 } }
      },
      "options": {
        "apiKey": "{env:OPENAI_API_KEY}"
      }
    }
  },
  
  // 默认使用模型
  "model": "anthropic/claude-sonnet-4-5",
  
  // 默认 Agent 模式
  "default_agent": "build",
  
  // 启用/禁用提供商控制
  "enabled_providers": ["anthropic", "openai"],
  
  // ============================================
  // 工具权限配置
  // ============================================
  
  "tools": {
    // Bash 终端：启用但需确认危险命令
    "bash": {
      "enabled": true,
      "requireApproval": ["rm -rf", "sudo", "DROP TABLE", "curl.*| sh"]
    },
    
    // 文件操作：全部启用
    "edit": true,
    "write": true,
    "read": true,
    
    // 代码搜索
    "grep": true,
    "glob": true
  },
  
  // 权限全局策略
  "permission": {
    "edit": "ask",      // 修改文件前询问
    "bash": "ask",      // 执行命令前询问
    "write": "allow"    // 创建文件自动允许
  },
  
  // ============================================
  // MCP 外部服务集成
  // ============================================
  
  "mcp": {
    "servers": {
      // 文件系统访问（本地）
      "filesystem": {
        "type": "local",
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-filesystem", "."]
      },
      
      // GitHub API（远程）
      "github": {
        "type": "remote",
        "url": "https://api.github.com/mcp",
        "oauth": {
          "clientId": "{env:GITHUB_CLIENT_ID}",
          "scopes": ["repo", "read:user"]
        }
      }
    },
    "defaults": {
      "filesystem": "enabled",
      "github": "disabled"  // 默认禁用，需手动开启
    }
  },
  
  // ============================================
  // 上下文指令文件
  // ============================================
  
  // 自动加载的项目规范文件
  "instructions": [
    "opencode.md",           // OpenCode 专用规范
    ".cursorrules",          // Cursor 兼容
    ".github/copilot-instructions.md"  // GitHub Copilot 兼容
  ],
  
  // ============================================
  // 快捷键（可选自定义）
  // ============================================
  
  "keybinds": {
    "toggleMode": "Tab",           // 模式切换
    "fileSearch": "Ctrl+P",        // 文件搜索
    "variantCycle": "Ctrl+V"       // 模型变体切换
  },
  
  // ============================================
  // 分享与隐私
  // ============================================
  
  // 分享控制：manual(手动), auto(自动), disabled(禁用)
  "share": "manual"
}
```

---

## 五、配置最佳实践（带注释）

```jsonc
/**
 * OpenCode 配置最佳实践指南
 */

{
  // ============================================
  // 1. 安全最佳实践
  // ============================================
  
  // ✅ 正确：使用环境变量存储敏感信息
  "apiKey": "{env:ANTHROPIC_API_KEY}",
  
  // ❌ 错误：永远不要硬编码密钥
  // "apiKey": "sk-ant-xxxxx",
  
  // ✅ 正确：限制 Bash 危险命令
  "bash": {
    "enabled": true,
    "requireApproval": [
      "rm -rf /",           // 系统级删除
      "sudo",               // 提权
      "curl.*| sh",         // 管道执行
      "eval",               // 代码执行
      "exec"                // 进程替换
    ]
  },
  
  // ============================================
  // 2. 团队协作最佳实践
  // ============================================
  
  // 项目级配置（opencode.json）应提交到 Git
  // 包含：项目规范、技术栈特定设置、共享 Agent
  
  // 用户级配置（~/.config/opencode/opencode.json）不提交
  // 包含：个人主题、快捷键、私有 API Key
  
  // ✅ 项目配置示例（提交到 Git）
  "instructions": [
    "./PROJECT_GUIDELINES.md",  // 项目规范
    "./API_CONVENTIONS.md"      // API 约定
  ],
  
  // ✅ 用户配置示例（本地私有）
  "theme": "dracula",           // 个人主题偏好
  "keybinds": {
    "toggleMode": "Ctrl+Space"  // 个人快捷键习惯
  },
  
  // ============================================
  // 3. 性能优化最佳实践
  // ============================================
  
  // 上下文压缩：防止 Token 超限
  "compaction": {
    "auto": true,    // 自动触发
    "prune": true    // 清理旧输出
  },
  
  // 文件监控：排除大型/无关目录
  "watcher": {
    "ignore": [
      "node_modules/**",
      ".git/**",
      "dist/**",
      "*.min.js",     // 压缩文件
      "*.map",        // Source map
      "coverage/**"   // 测试覆盖率报告
    ]
  },
  
  // ============================================
  // 4. 多环境配置最佳实践
  // ============================================
  
  // 使用环境变量区分环境
  "provider": {
    "anthropic": {
      "options": {
        // 开发环境：使用测试密钥
        // 生产环境：使用正式密钥
        "apiKey": "{env:ANTHROPIC_API_KEY}",
        
        // 不同环境使用不同端点
        "baseURL": "{env:ANTHROPIC_BASE_URL}"
      }
    }
  },
  
  // ============================================
  // 5. 模块化配置最佳实践
  // ============================================
  
  // 复杂配置拆分到独立文件
  
  // ✅ 使用 {file:} 引用外部配置
  "systemPrompt": "{file:~/prompts/enterprise-coding.md}",
  
  // ✅ Agent 使用文件定义
  // 创建：~/.config/opencode/agents/security-expert.md
  
  // ✅ Command 使用文件定义
  // 创建：./.opencode/commands/deploy.md
  
  // ✅ Skill 使用目录结构
  // 创建：./.opencode/skills/frontend-expert/
  
  // ============================================
  // 6. 版本控制最佳实践
  // ============================================
  
  // .gitignore 配置（项目根目录）
  /*
  # OpenCode 数据目录（包含敏感信息）
  .opencode/
  
  # 但保留项目级配置（如果不使用 opencode.json）
  # !.opencode/agents/
  # !.opencode/commands/
  # !.opencode/skills/
  
  # 本地覆盖配置
  opencode.local.json
  */
  
  // ============================================
  // 7. 调试配置最佳实践
  // ============================================
  
  // 开发时启用调试
  "debug": true,
  "debugLsp": false,  // 仅在调试 LSP 时启用
  
  // 使用环境变量临时覆盖
  // OPENCODE_CONFIG_CONTENT='{"debug": true}' opencode
  
  // ============================================
  // 8. 备份与迁移
  // ============================================
  
  // 配置导出：复制 ~/.config/opencode/ 目录
  // 会话导出：复制 .opencode/ 目录（跨设备迁移对话历史）
  
  // 注意：.opencode/ 包含数据库和敏感信息，迁移时注意清理
}
```
---

## 六、 配置文件操作注意事项

- 注释规范：JSONC 支持单行注释（//）和多行注释（/* */），但注释不可嵌套，否则会导致配置文件解析失败。

- 生效规则：修改配置文件后，部分配置项（如 logLevel、editor、plugins）需重启 OpenCode 才能生效，服务器端口、主机名等配置无需重启，修改后立即生效。

- 备份建议：修改配置文件前，建议备份原始文件（如重命名为 opencode.jsonc.bak），避免配置错误导致工具无法启动。

- 配置查询：可通过 TUI 命令`/config` 查看当前生效的配置，快速验证配置是否正确。

---

> 以上配置涵盖了 OpenCode 的所有主要配置项，每个配置项都添加了详细的中文注释，说明其作用、可选值、安全注意事项和最佳实践建议。