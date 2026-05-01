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

### 3. LLM 提供商配置（核心）

#### 3.1 Anthropic 与 OpenAI 协议的核心区别

Anthropic 与 OpenAI 的 API 协议在多个维度存在显著差异，主要体现在设计哲学、接口格式、能力特性和适用场景等方面。

| 对比维度 | OpenAI API | Anthropic API |
|---------|-----------|--------------|
| **设计定位** | 行业标准制定者，兼顾 C 端与 B 端，主打通用化多场景适配 | 聚焦企业级市场，主打安全合规与场景化生产力提升，适配金融、医疗等强监管行业 |
| **系统提示词** | 作为 messages 数组中的第一条消息 (role: "system") | 独立的 system 参数，不在 messages 数组中 |
| **响应结构** | `response.choices[0].message.content` | `response.content[0].text`（数组格式，为多模态准备） |
| **上下文长度** | GPT-4 Turbo：128K token（约 96,000 字） | Claude 3.5 Sonnet：200K token（约 150,000 字） |
| **计费模式** | 统一费率模式 | 按复杂度计价：标准请求 ($0.02/千 token)、复杂推理 ($0.06/千 token)、高危内容过滤 (额外加收 20%) |
| **核心优势** | 创意内容生成、多模态互动、通用性强 | 长文档处理、代码生成、安全合规、企业系统集成 |
| **API 端点** | `https://api.openai.com/v1/chat/completions` | `https://api.anthropic.com/v1/messages` |
| **鉴权方式** | `Authorization: Bearer` 头部认证 | 需同时配置 `x-api-key` 和 `anthropic-version` 头部 |

#### 3.2 在 OpenCode 中配置两种协议的常用大模型

##### 3.2.1 获取 API 密钥

- **OpenAI**：访问 https://platform.openai.com 创建 API Key（格式：`sk-...`）
- **Anthropic**：访问 https://console.anthropic.com 创建 API Key（格式：`sk-ant-...`）

##### 3.2.2 配置方式（推荐按优先级选择）

**方式一：环境变量配置（最安全）**

```bash
# 临时设置（仅当前会话）
export OPENAI_API_KEY="sk-your-openai-key"
export ANTHROPIC_API_KEY="sk-ant-your-anthropic-key"

# 永久保存（添加到 shell 配置文件）
echo 'export OPENAI_API_KEY="sk-your-openai-key"' >> ~/.zshrc
echo 'export ANTHROPIC_API_KEY="sk-ant-your-anthropic-key"' >> ~/.zshrc
source ~/.zshrc
```

**方式二：OpenCode 认证命令**

```bash
# 运行认证命令
opencode auth login

# 选择提供商（OpenAI 或 Anthropic）
# 粘贴 API Key
# 按回车完成
```

认证信息存储在：`~/.local/share/opencode/auth.json`

**方式三：配置文件手动配置**

在项目根目录创建 `opencode.json` 或 `opencode.jsonc` 文件：

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
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
    
    // ------------------- 自定义模型 -------------------
    "local-openai": {
      // 需要指定定义协议类型，这里设置 openai 兼容协议，如果是 anthropic 需改为"@ai-sdk/anthropic"
      "npm": "@ai-sdk/openai-compatible",
      
      // 提供商级选项：影响该提供商所有模型
      "options": {
        // 本地服务地址
        "baseURL": "https://dashscope.aliyuncs.com/compatible-mode/v1",
        
        // api 密钥，本地服务可能不需要密钥
        "apiKey": "你的 API key",
        
        // 超时设置（毫秒）
        "timeout": 120000,
        
        // 最大重试次数
        "maxRetries": 3
      },
      
      // 模型特定配置
      "models": {
        "qwen-plus-2025-07-14": {
          // 模型名称，在 Agent 界面上展示
          "name": "qwen-plus-2025-07-14",
          // 模型参数（如果有）：每次调用该模型都使用的设置
          "options": {}
        }
      }
    }
  },
  
  // ------------------- 模型选择 -------------------
  // 默认使用的模型，格式：提供商/模型名
  // 必须与上面配置的 provider.models 键匹配
  "model": "local-openai/qwen-plus-2025-07-14",

  // ------------------- 提供商控制 -------------------

  // 白名单：仅启用列出的提供商（优先级低于黑名单）
  "enabled_providers": ["anthropic", "openai"],

  // 黑名单：禁用特定提供商（优先级高于白名单）
  // 用于临时禁用某个提供商而不删除配置
  "disabled_providers": ["google"],

  // 注意：若同时设置，disabled_providers 优先
}
```

> **配置小结：**
> 
> - **provider**：定义了 LLM 供应商的配置域，接着它的下一层配置就是 LLM 供应商的集合，包括 **知名大模型供应商（openai、anthropic、google 等）** 或者 **自定义大模型（个人搭建、公司搭建的大模型等）**
> - 各个 LLM 供应商的配置主要包括 npm、name、options、models 等
>   1. **npm**（可选）：大模型的接入协议，**openai** 或者 **anthropic** 协议，对于知名供应商可以不用配置，opencode 知道它们的协议类型，对于自定义大模型建议配置上
>   2. **name**（可选）：LLM 供应商的别名，会在 Agent 上显示
>   3. **options**（关键）：LLM 供应商高级选项，选项主要有**baseURL（基础服务地址）**、**apiKey（API 密钥）**、**timeout（超时时间）**、**maxRetries（最大重试次数）**等
>   4. **models**（关键）：LLM 供应商的模型配置，可以配置多个模型，每个模型的配置主要有 **name（模型的别名，会在 Agent 上显示）**、**options（模型的特殊选项）** 等

##### 3.2.3 验证配置

```bash
# 查看已配置的认证信息
opencode auth list

# 测试模型调用
opencode chat --model openai/gpt-4-turbo
opencode chat --model anthropic/claude-3-5-sonnet
```

##### 3.2.4 安全最佳实践

1. **绝不将 API Key 提交到代码仓库**：使用 `.gitignore` 排除配置文件
2. **使用密钥管理服务**：生产环境推荐使用 AWS Secrets Manager、Azure Key Vault 等
3. **定期轮换 API Key**：降低泄露风险
4. **设置请求超时**：在配置中添加 `timeout` 参数（单位：毫秒）
5. **启用缓存**：设置 `setCacheKey: true` 提高性能

通过以上配置，您可以在 OpenCode 中灵活切换使用 OpenAI 和 Anthropic 的云端大模型，同时也能接入支持这两种协议的本地大模型，实现统一的管理和调用接口。

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

### 7. Skill 技能配置

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
    "kubernetes": false,   // K8s 操作（禁用）
    
    // 自定义技能：通过目录或插件加载
    "react-expert": true,
    "rust-optimizer": false
  },
  
  // ------------------- 详细技能配置 -------------------
  
  "skill": {
    // 技能路径：加载技能的目录
    "paths": [
      "~/.config/opencode/skills",     // 全局技能
      "./.opencode/skills"             // 项目技能（优先级更高）
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

### 8. 代码格式化配置

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

### 9. 快捷键配置

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

### 10. 权限配置（Permission）

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
