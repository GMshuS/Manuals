# OpenCode 使用手册

# 前言

OpenCode 是一款开源的 AI 编码代理工具，支持终端界面（TUI）、桌面应用和 IDE 扩展三种使用形式，可帮助开发者高效处理代码分析、功能开发、问题排查等任务，兼容 Windows、macOS、Linux 跨平台环境，支持多种 LLM 提供商及本地模型部署，兼顾隐私安全与易用性。

本手册适用于所有 OpenCode 用户（从新手到进阶开发者），涵盖安装配置、核心功能、命令详解、高级用法及故障排查，力求步骤清晰、可直接操作，帮助用户快速上手并充分发挥工具价值。

# 第一章 基础准备

## 1.1 前提条件

使用 OpenCode 前，需满足以下基础环境要求，确保工具正常运行：

- 终端环境：需安装现代终端模拟器，推荐 WezTerm（跨平台）、Alacritty（跨平台）、Ghostty（Linux/macOS）、Kitty（Linux/macOS），避免使用老旧终端导致 TUI 界面异常。

- API 密钥：若使用在线 LLM 提供商（如 OpenCode Zen、OpenAI、Anthropic 等），需提前获取对应平台的 API 密钥；本地部署模型可无需 API 密钥。

- 系统依赖：

- Linux/macOS：确保系统已安装 curl、git 等基础工具，部分版本需依赖 ncursesw 库（TUI 运行必需）。

- Windows：推荐使用 WSL（Windows Subsystem for Linux）以获得最佳兼容性，原生 Windows 需安装 Microsoft Edge WebView2 Runtime（桌面应用必需）。

## 1.2 版本说明

本手册基于 OpenCode 最新稳定版编写，推荐使用官方最新版本以获得完整功能支持和 bug 修复。可通过以下命令查看当前版本：

```bash
opencode --version
```

# 第二章 安装教程（跨平台）

OpenCode 提供多种安装方式，可根据自身系统和使用习惯选择，优先推荐使用官方安装脚本或对应系统的包管理工具，确保版本最新。

## 2.1 通用安装方式（全平台）

### 2.1.1 官方安装脚本（推荐）

适用于 Linux、macOS 及 WSL 环境，一键安装最新版本：

```bash
curl -fsSL https://opencode.ai/install | bash
```

### 2.1.2 Node.js 生态安装（npm/bun/pnpm/yarn）

若已安装 Node.js 或 Bun 运行时，可通过包管理工具全局安装：

```bash
# npm
npm install -g opencode-ai
# bun
bun install -g opencode-ai
# pnpm
pnpm install -g opencode-ai
# yarn
yarn global add opencode-ai
```

## 2.2 分系统安装方式

### 2.2.1 macOS 系统

除通用方式外，可通过 Homebrew 安装（推荐使用官方 tap 以获取最新版本）：

```bash
# 官方 tap（推荐）
brew install anomalyco/tap/opencode
# 官方公式（更新频率较低）
brew install opencode
```

### 2.2.2 Linux 系统

- Arch Linux：可通过 pacman 或 paru 安装
```bash
# 稳定版
sudo pacman -S opencode
# 最新版(AUR)
paru -S opencode\-bin`
```

- Debian/Ubuntu：需先安装依赖库，再使用通用安装脚本
```bash
sudo apt-get update && sudo apt-get install -y libncursesw5-dev
curl -fsSL https://opencode.ai/install | bash
```

### 2.2.3 Windows 系统

推荐使用 WSL 环境安装（参考 Linux 安装方式），原生 Windows 可通过以下方式安装：

- Chocolatey 安装 `choco install opencode`

- Scoop 安装 `scoop install opencode`

- 二进制文件安装：从 OpenCode 官方 Releases 页面下载对应 Windows 版本二进制文件，解压后添加至系统环境变量 PATH 即可。

注意：原生 Windows 环境下，OpenCode 桌面应用需依赖 Microsoft Edge WebView2 Runtime，若启动后出现空白窗口，需先安装或更新该组件。

### 2.2.4 Docker 安装（跨平台）

适合快速部署，无需配置系统依赖，启动命令如下：

```bash
# 基础版本
docker run -it --rm ghcr.io/anomalyco/opencode
# 带本地模型（如 Qwen3-4B），指定端口避免冲突
docker pull opencode-ai/opencode:v3.0.9.2-qwen
docker run -it --rm -p 8080:8080 -p 8001:8000 opencode-ai/opencode:v3.0.9.2-qwen3
```

验证 Docker 服务是否就绪：执行 `curl http://localhost:8001/health`，返回 `{status:healthy}` 即表示模型服务正常。

## 2.3 安装验证

安装完成后，在终端执行以下命令，若能正常启动 TUI 界面或显示版本信息，即表示安装成功：

```bash
# 启动 TUI 界面
opencode
# 查看版本
opencode --version
```

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

#### 3.1 Anthropic与OpenAI协议的核心区别

Anthropic与OpenAI的API协议在多个维度存在显著差异，主要体现在设计哲学、接口格式、能力特性和适用场景等方面。

| 对比维度 | OpenAI API | Anthropic API |
|---------|-----------|--------------|
| **设计定位** | 行业标准制定者，兼顾C端与B端，主打通用化多场景适配 | 聚焦企业级市场，主打安全合规与场景化生产力提升，适配金融、医疗等强监管行业 |
| **系统提示词** | 作为messages数组中的第一条消息(role: "system") | 独立的system参数，不在messages数组中 |
| **响应结构** | `response.choices[0].message.content` | `response.content[0].text`（数组格式，为多模态准备） |
| **上下文长度** | GPT-4 Turbo：128K token（约96,000字） | Claude 3.5 Sonnet：200K token（约150,000字） |
| **计费模式** | 统一费率模式 | 按复杂度计价：标准请求($0.02/千token)、复杂推理($0.06/千token)、高危内容过滤(额外加收20%) |
| **核心优势** | 创意内容生成、多模态互动、通用性强 | 长文档处理、代码生成、安全合规、企业系统集成 |
| **API端点** | `https://api.openai.com/v1/chat/completions` | `https://api.anthropic.com/v1/messages` |
| **鉴权方式** | `Authorization: Bearer`头部认证 | 需同时配置`x-api-key`和`anthropic-version`头部 |

#### 3.2 在OpenCode中配置两种协议的常用大模型

##### 3.2.1 获取API密钥
- **OpenAI**：访问https://platform.openai.com创建API Key（格式：`sk-...`）
- **Anthropic**：访问https://console.anthropic.com创建API Key（格式：`sk-ant-...`）

##### 3.2.2 配置方式（推荐按优先级选择）

- 方式一：环境变量配置（最安全）
```bash
# 临时设置（仅当前会话）
export OPENAI_API_KEY="sk-your-openai-key"
export ANTHROPIC_API_KEY="sk-ant-your-anthropic-key"

# 永久保存（添加到shell配置文件）
echo 'export OPENAI_API_KEY="sk-your-openai-key"' >> ~/.zshrc
echo 'export ANTHROPIC_API_KEY="sk-ant-your-anthropic-key"' >> ~/.zshrc
source ~/.zshrc
```

- 方式二：OpenCode认证命令
```bash
# 运行认证命令
opencode auth login

# 选择提供商（OpenAI或Anthropic）
# 粘贴API Key
# 按回车完成
```

认证信息存储在：`~/.local/share/opencode/auth.json`

- 方式三：配置文件手动配置
在项目根目录创建`opencode.json`或`opencode.jsonc`文件：

```josnc
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
			// 需要指定定义协议类型，这里设置openai兼容协议，如果是anthropic需改为"@ai-sdk/anthropic"
			"npm": "@ai-sdk/openai-compatible",
			
			// 提供商级选项：影响该提供商所有模型
			"options": {
				// 本地服务地址
				"baseURL": "https://dashscope.aliyuncs.com/compatible-mode/v1",
				
				// api密钥，本地服务可能不需要密钥
				"apiKey": "你的API key",
        
				// 超时设置（毫秒）
				"timeout": 120000,
				
				// 最大重试次数
				"maxRetries": 3
			},
			
			// 模型特定配置
			"models": {
				"qwen-plus-2025-07-14": {
					// 模型名称，在Agent界面上展示
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
> 配置小结：
> **provider**：定义了LLM供应商的配置域，接着它的下一层配置就是LLM供应商的集合，包括 **知名大模型供应商（openai、anthropic、google等）** 或者 **自定义大模型（个人搭建、公司搭建的大模型等）**；
> 各个LLM供应商的配置主要包括npm、name、options、models等
> 1. **npm**（可选）：大模型的接入协议，**openai** 或者 **anthropic**协议，对于知名供应商可以不用配置，opencode知道它们的协议类型，对于自定义大模型建议配置上；
> 2. **name**（可选）：LLM供应商的别名，会在Agent上显示；
> 3. **options**（关键）：LLM供应商高级选项，选项主要有**baseURL（基础服务地址）**、**apiKey（API密钥）**、**timeout（超时时间）**、**maxRetries（最大重试次数）**等；
> 4. **models**（关键）：LLM供应商的模型配置，可以配置多个模型，每个模型的配置主要有 **name（模型的别名，会在Agent上显示）** 、 **options（模型的特殊选项）** 等；

##### 3.2.3 验证配置
```bash
# 查看已配置的认证信息
opencode auth list

# 测试模型调用
opencode chat --model openai/gpt-4-turbo
opencode chat --model anthropic/claude-3-5-sonnet
```

##### 3.2.4 安全最佳实践
1. **绝不将API Key提交到代码仓库**：使用`.gitignore`排除配置文件
2. **使用密钥管理服务**：生产环境推荐使用AWS Secrets Manager、Azure Key Vault等
3. **定期轮换API Key**：降低泄露风险
4. **设置请求超时**：在配置中添加`timeout`参数（单位：毫秒）
5. **启用缓存**：设置`setCacheKey: true`提高性能

通过以上配置，您可以在OpenCode中灵活切换使用OpenAI和Anthropic的云端大模型，同时也能接入支持这两种协议的本地大模型，实现统一的管理和调用接口。

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
### 14. 权限配置（Permission）
```jsonc
{
  "permission": {
    "edit": "allow", // 允许写文件：allow/ask/deny
    "bash": "ask", // 执行 shell：allow/ask/deny
    "network": "deny", // 网络访问
    "delete": "ask", // 删除文件
    "read": ["src/", "docs/"], // 允许读取目录
    "write": ["src/"] // 允许写入目录
  }
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

# 第四章 VSCode 中使用 OpenCode

OpenCode 支持 VSCode 扩展集成，可在 VSCode 内直接调用 OpenCode 的 AI 编码能力，无需切换终端，提升开发效率，配置步骤如下（兼容 Windows、macOS、Linux 系统）：

## 4.1 安装 VSCode 扩展

- 打开 VS Code，进入扩展市场（快捷键 Ctrl+Shift+X）。

- 搜索 OpenCode，找到 `opencode`【作者：`SST`】的插件。

- 点击“安装”并重启 VS Code。

## 4.2 关联 OpenCode 配置（关键步骤）

VSCode 扩展会自动读取 OpenCode 全局配置文件，无需重复配置 LLM 提供商，只需确保以下两点：

- 确认 OpenCode 已完成全局配置，API 密钥、LLM 提供商配置正确，且 OpenCode 可正常启动。

- 若扩展未自动识别配置，手动指定配置文件路径：

1. 打开 VSCode 「设置」（快捷键`Ctrl\+,` / `Cmd\+,`），搜索「OpenCode: Config Path」。

2. 在输入框中填写 OpenCode 配置文件的绝对路径，例如：

3. Windows：`%USERPROFILE%\\.config\\opencode\\opencode.jsonc`

4. macOS/Linux：`\~/.config/opencode/opencode.jsonc`

5. 填写完成后，重启 VSCode 扩展（点击扩展面板中 OpenCode 扩展的「重启」按钮）。

## 4.3 VSCode 内核心操作方法

配置完成后，可在 VSCode 内通过多种方式使用 OpenCode，贴合编码场景：

### 4.3.1 方式 1：右键菜单调用（最常用）

- 在 VSCode 编辑器中选中代码片段，右键点击，选择「OpenCode: 分析选中代码」「OpenCode: 优化选中代码」「OpenCode: 排查代码 bug」等选项，即可快速调用 AI 能力。

- 右键点击空白处，选择「OpenCode: 新建会话」，可创建新的 AI 对话，咨询编码相关问题（支持引用当前打开的文件）。

### 4.3.2 方式 2：命令面板调用

- 按下 `Ctrl\+Shift\+P` / `Cmd\+Shift\+P`，输入「OpenCode」，会列出所有可用命令，例如：

- OpenCode: 启动服务（若扩展未自动连接 OpenCode 服务）

- OpenCode: 停止服务

- OpenCode: 导出当前会话（导出为 Markdown 文件）

- OpenCode: 切换 LLM 模型（快速切换已配置的提供商和模型）

### 4.3.3 方式 3：快捷键调用（可自定义）

- 默认快捷键：`Ctrl\+Alt\+O`（打开 OpenCode 对话面板），可自定义快捷键：

- 打开 VSCode 「键盘快捷方式」（快捷键 `Ctrl\+K Ctrl\+S` / `Cmd\+K Cmd\+S`），搜索「OpenCode」，为对应命令设置自定义快捷键。

## 4.4 VSCode 扩展配置补充（可选）

为了获得更好的体验，如实时代码补全，可以在 VS Code 的设置（`settings.json`）中添加以下配置：
```json
{
  "opencode.lsp.enabled": true,
  "opencode.lsp.autoStart": true,
  "editor.inlineSuggest.enabled": true,
  "editor.suggest.showInlineCompletions": true
}
```

重要配置项解析：
> - opencode.lsp.enabled
> 含义：这是 OpenCode 插件的总开关。将其设置为 true 才能启用其内置的语言服务器协议（LSP）功能。
> 作用：开启后，OpenCode 才能提供代码跳转、错误诊断、智能感知等高级功能。如果为 false，则 LSP 相关功能将全部关闭。
> - opencode.lsp.autoStart
> 含义：控制语言服务器是否自动启动。设置为 true 表示自动启动。
> 作用：当你打开一个受支持的项目时，OpenCode 的语言服务器会在后台自动运行，无需你手动通过命令面板去启动它，让智能辅助随时待命。

## 4.5 常见问题排查

- 问题 1：VSCode 扩展显示「未连接 OpenCode 服务」

- 解决方案：手动启动 OpenCode 服务（终端执行`opencode serve`），重启 VSCode 扩展；若仍失败，检查配置文件路径是否正确，且 OpenCode 可正常启动。

- 问题 2：调用 AI 时提示「API 密钥无效」

- 解决方案：检查 OpenCode 配置文件中的 `providers` 配置，确保 API 密钥正确，且 LLM 提供商已完成认证，重启 OpenCode 服务和 VSCode 扩展。

- 问题 3：扩展无法识别配置文件

- 解决方案：确认配置文件路径填写正确（绝对路径），且配置文件格式为 JSONC（无语法错误），可通过 VSCode 打开配置文件，检查是否有语法报错（红色波浪线）。

# 第五章 核心功能使用指南

OpenCode 的核心功能主要通过 TUI 界面（终端）和桌面应用实现，以下详细介绍常用功能的使用方法，涵盖代码交互、文件操作、会话管理等。

## 5.1 项目初始化
进入需要处理的项目目录，初始化 OpenCode 以让工具理解项目结构和编码规范，步骤如下：
1. 导航到项目目录：cd /path/to/your/project
2. 启动 OpenCode TUI：opencode
3. 输入 /init 命令，OpenCode 会自动分析项目结构，并在项目根目录生成AGENTS.md 文件。
提示：建议将AGENTS.md 文件提交到 Git 仓库，有助于 OpenCode 后续更精准地理解项目编码规范和结构。

## 5.2 TUI 界面基础操作

TUI 是 OpenCode 的核心交互方式，启动后进入交互式界面，支持以下基础操作：
- 启动 TUI：opencode（默认当前目录）或 opencode /path/to/project（指定项目目录）。
- 输入提示：直接在输入框中输入问题或指令，按 Enter 提交。
- 文件引用：使用 @ 符号模糊搜索并引用项目中的文件，例如 How is auth handled in @packages/functions/src/api/index.ts?，文件内容会自动添加到对话中。
- 执行 shell 命令：以 ! 开头输入命令，例如 !ls -la，命令输出会添加到对话中。
- 快捷键前缀：默认使用 ctrl+x 作为快捷键前缀，配合其他按键实现快速操作（详见 5.3 快捷键列表）。

## 5.3 常用功能详解

### 5.3.1 代码咨询与分析

可向 OpenCode 咨询代码相关问题，包括代码解释、bug 排查、优化建议等，示例如下：

- 代码解释：`Explain the logic of the function in @src/main.go`

- bug 排查：`Why does this code throw an error? @src/utils.cpp`

- 优化建议：`Suggest ways to optimize the performance of this loop @src/loop.cpp`

### 5.3.2 功能开发与迭代

OpenCode 可协助开发新功能，建议先通过“计划模式”制定实现方案，再进行开发，步骤如下：

1. 按 Tab 键切换到计划模式（右下角会显示模式指示器），此时 OpenCode 仅提供实现计划，不修改代码。

2. 输入功能需求，例如：`When a user deletes a note, flag it as deleted in the database and create a screen to show recently deleted notes.`

3. 查看 OpenCode 给出的计划，可补充反馈或细节，迭代完善计划。

4. 计划确认后，再次按 Tab 键切换回构建模式，OpenCode 会根据计划修改代码。

> 提示：可将图片拖放到 TUI 界面，为 OpenCode 提供设计参考或截图，辅助功能开发。

### 5.3.3 会话管理

OpenCode 会保存当前项目的会话记录，支持会话切换、新建、导出等操作，核心命令如下：

- 新建会话：/new（别名/clear），快捷键 ctrl+x n。

- 查看/切换会话：/sessions（别名/resume、/continue），快捷键ctrl+x l。

- 导出会话：/export，将当前会话导出为 Markdown 并在默认编辑器中打开，快捷键ctrl+x x。

- 压缩会话：/compact（别名 /summarize），快捷键ctrl+x c

### 5.3.4 插件管理

OpenCode 支持插件扩展功能，插件分为全局插件和项目插件，管理方法如下：

- 全局插件：macOS/Linux 为~/.config/opencode/plugins/，Windows 为 %USERPROFILE%\.config\opencode\plugins。

- 项目插件：<your-project>/.opencode/plugins/（仅项目级配置生效）。

禁用插件：修改配置文件，将 plugin 键设为空数组 []，或临时移走插件目录中的插件文件，重启 OpenCode 即可。

## 5.4 常用命令与快捷键大全

### 5.4.1 核心命令（TUI 中使用）

|命令|别名|功能描述|快捷键|
|---|---|---|---|
|/connect|\-|添加 LLM 提供商并配置 API 密钥|\-|
|/compact|/summarize|压缩当前会话|ctrl\+x c|
|/details|\-|切换工具执行详情显示|ctrl\+x d|
|/editor|\-|打开外部编辑器编写消息（使用 EDITOR 环境变量指定的编辑器）|ctrl\+x e|
|/exit|/quit、/q|退出 OpenCode|ctrl\+x q|
|/export|\-|导出当前会话为 Markdown|ctrl\+x x|
|/help|\-|显示帮助对话框|ctrl\+x h|
|/init|\-|初始化项目，生成 AGENTS.md 文件|ctrl\+x i|
|/models|\-|列出可用 LLM 模型|ctrl\+x m|
|/new|/clear|开始新会话|ctrl\+x n|
|/redo|\-|重做之前撤销的消息（需项目为 Git 仓库）|ctrl\+x r|
|/sessions|/resume、/continue|列出会话并切换|ctrl\+x l|
|/share|\-|分享当前会话|ctrl\+x s|
|/themes|\-|列出可用 TUI 主题|ctrl\+x t|

### 5.4.2 快捷键（TUI 界面）

- 通用快捷键：ctrl+x q（退出）、ctrl+x n（新建会话）、ctrl+x l（切换会话）、ctrl+x h（帮助）。
- 编辑快捷键：ctrl+a（全选输入框）、ctrl+w（删除输入框中最后一个单词）、ctrl+u（清空输入框）。
- 界面快捷键：ctrl+x d（显示/隐藏工具执行详情）、ctrl+x t（切换 TUI 主题）、ctrl+x m（查看可用模型）。

# 第六章 常见问题及解决方案
## 6. Bun has crashed
既然你已经卸载了全局的 Bun，而 OpenCode 依然报错 `panic: ... Segmentation fault` 并显示 `Bun has crashed`，这直接说明 **OpenCode 正在调用其内置的 Bun 版本，并且这个内置版本在你的系统上运行崩溃了**。

### 🧐 为什么会出现这种情况？

1. **独立运行环境**：OpenCode 为了保证在不同电脑上都能运行，会将一个特定版本的 Bun 打包在它的安装目录中（正如报错信息中显示的 `node_modules/opencode-windows-x64/bin/opencode.exe` 内部封装了 Bun）。
2. **不再依赖全局**：当你卸载了全局 Bun 后，OpenCode 失去了外部依赖，只能退回到使用这个“自带”的版本。
3. **崩溃原因**：报错 `Segmentation fault` 通常意味着内存访问冲突。这可能是由于：
    - **版本 Bug**：OpenCode 内置的 Bun 版本（看起来是 1.4.0）存在特定的 Bug。
    - **系统冲突**：你之前安装的 npm 版本的 Bun 残留文件（shims）可能与 OpenCode 的调用发生了冲突。

### 💡 解决方案

既然问题出在 OpenCode 内部的 Bun 上，你需要尝试修复环境或强制它使用外部版本。

#### 彻底清理残留（优先尝试）
你之前是用 `npm` 安装的 Bun，虽然卸载了脚本，但 npm 的残留文件可能还在干扰。

1. **删除 npm 的 Bun 残留文件**：
   根据你截图中的 `where bun` 输出，手动删除以下两个文件：
   - `C:\Users\guosen\AppData\Roaming\npm\bun`
   - `C:\Users\guosen\AppData\Roaming\npm\bun.cmd`
   - *注意：如果 `AppData\Roaming\npm` 目录下还有 `node_modules\bun` 文件夹，也一并删除。*

2. **重启终端**：关闭所有 PowerShell 和 CMD 窗口，重新打开。

3. **再次运行 OpenCode**：看看问题是否解决。

#### 重新安装全局 Bun（最稳妥的方案）
既然内置的坏了，最好的办法是**重新安装一个全局的、稳定的 Bun**，并强制 OpenCode 使用它。

1. **重新安装 Bun**（使用官方推荐方式，比 npm 更稳定）：
   在 PowerShell 中运行：
   ```powershell
   iwr https://bun.sh/install.ps1 -useb | iex
   ```
2. **验证安装**：
   运行 `bun --version`，确保能看到版本号，且 `where bun` 指向的是 `C:\Users\guosen\.bun\bin\bun.exe`。
3. **让 OpenCode 使用它**：
   重新安装全局 Bun 后，OpenCode 通常会优先检测并使用系统路径下的 Bun，从而绕过它那个有问题的内置版本。

#### 更新 OpenCode
如果上述方法无效，说明 OpenCode 内置的 Bun 版本与你的 Windows 系统（可能是某些杀毒软件或系统版本）存在兼容性问题。
- 检查是否有 **OpenCode 的更新版本**。开发者可能已经在新版本中修复了内置 Bun 的崩溃问题或升级了 Bun 版本。

### 📌 总结
目前的错误是因为 **OpenCode 被迫使用了它自己那个有缺陷的内置 Bun**。请尝试 **方案 1** 清理干扰，如果不行，直接执行 **方案 2** 重新安装全局 Bun 即可解决。
