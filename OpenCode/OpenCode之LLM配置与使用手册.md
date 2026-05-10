# OpenCode LLM 配置详解

OpenCode 基于 AI SDK 和 Models.dev 生态，支持 **75+ LLM 提供商**，包括所有主流云服务和本地部署模型。本文将全面解析 OpenCode 的 LLM 配置体系，从基础结构到高级定制，覆盖所有常见使用场景。

## 一、LLM 提供商配置（核心）

### 1. Anthropic 与 OpenAI 协议的核心区别

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

### 2. 配置大模型的方法

#### 2.1 获取 API 密钥

- **OpenAI**：访问 https://platform.openai.com 创建 API Key（格式：`sk-...`）
- **Anthropic**：访问 https://console.anthropic.com 创建 API Key（格式：`sk-ant-...`）

#### 2.2 配置方式（推荐按优先级选择）

#### 2.2.1 方式一：环境变量配置（最安全）

```bash
# 临时设置（仅当前会话）
export OPENAI_API_KEY="sk-your-openai-key"
export ANTHROPIC_API_KEY="sk-ant-your-anthropic-key"

# 永久保存（添加到 shell 配置文件）
echo 'export OPENAI_API_KEY="sk-your-openai-key"' >> ~/.zshrc
echo 'export ANTHROPIC_API_KEY="sk-ant-your-anthropic-key"' >> ~/.zshrc
source ~/.zshrc
```

#### 2.2.2 方式二：OpenCode 认证命令

```bash
# 运行认证命令
opencode auth login

# 选择提供商（OpenAI 或 Anthropic）
# 粘贴 API Key
# 按回车完成

# 查看已配置的认证信息
opencode auth list
```

认证信息存储在：`~/.local/share/opencode/auth.json`

#### 2.2.3 方式三：配置文件手动配置

在 `opencode.json` 或 `opencode.jsonc` 文件中进行配置：

**配置文件位置与优先级**

OpenCode 采用多层级配置合并机制，后面的配置会覆盖前面的冲突项：

| 优先级 | 配置源 | 说明 |
|--------|--------|------|
| 1（最低） | 远程配置 | `.well-known/opencode` 组织默认值 |
| 2 | 全局配置 | `~/.config/opencode/opencode.json` |
| 3 | 自定义配置 | `OPENCODE_CONFIG` 环境变量指定的文件 |
| 4 | 项目配置 | 项目根目录的 `opencode.json` |
| 5 | 目录配置 | `.opencode/` 目录下的配置 |
| 6（最高） | 内联配置 | `OPENCODE_CONFIG_CONTENT` 环境变量 |

**配置格式**

支持 **JSON** 和 **JSONC**（带注释的 JSON）格式，推荐使用 JSONC 以便添加注释：

```jsonc
{
  "$schema": "https://opencode.ai/config.json", // 启用编辑器自动补全和验证
  "model": "anthropic/claude-sonnet-4-5", // 默认主模型
  "small_model": "anthropic/claude-haiku-4-5" // 轻量级任务模型
}
```

## 二、配置文件手动配置详解

### 1. 基础模型配置

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  
  // 全局默认模型（格式：provider_id/model_id）
  "model": "anthropic/claude-sonnet-4-5",
  
  // 轻量级任务专用模型（标题生成、摘要等）
  "small_model": "anthropic/claude-haiku-4-5",
  
  // 提供商配置
  "provider": {
    "anthropic": {
      // 提供商全局选项
      "options": {
        "apiKey": "{env:ANTHROPIC_API_KEY}", // 从环境变量读取密钥
        "timeout": 600000, // 请求超时（毫秒）
        "setCacheKey": true // 启用缓存键
      },
      
      // 模型特定配置
      "models": {
        "claude-sonnet-4-5": {
          "options": {
            "thinking": {
              "type": "enabled",
              "budgetTokens": 16000 // 思考预算
            }
          }
        }
      }
    }
  },
  
  // 启用的提供商白名单（仅加载指定提供商）
  "enabled_providers": ["anthropic", "openai"],
  
  // 禁用的提供商（优先级高于 enabled_providers）
  "disabled_providers": ["gemini"]
}
```

### 2 官方提供商配置示例

#### 2.1 Anthropic（Claude）

```jsonc
{
  "provider": {
    "anthropic": {
      "options": {
        "apiKey": "{env:ANTHROPIC_API_KEY}",
        "baseURL": "https://api.anthropic.com/v1"
      }
    }
  },
  "model": "anthropic/claude-opus-4-5",
  "small_model": "anthropic/claude-haiku-4-5"
}
```

#### 2.2 OpenAI

```jsonc
{
  "provider": {
    "openai": {
      "options": {
        "apiKey": "{env:OPENAI_API_KEY}"
      },
      "models": {
        "gpt-5": {
          "options": {
            "reasoningEffort": "high"
          }
        }
      }
    }
  },
  "model": "openai/gpt-5",
  "small_model": "openai/gpt-4o-mini"
}
```

#### 2.3 Azure OpenAI

```jsonc
{
  "provider": {
    "azure-openai": {
      "options": {
        "apiKey": "{env:AZURE_OPENAI_API_KEY}",
        "baseURL": "https://YOUR_RESOURCE_NAME.openai.azure.com/openai/deployments/YOUR_DEPLOYMENT_NAME"
      }
    }
  }
}
```

#### 2.4 GitHub Copilot

```jsonc
{
  "provider": {
    "github-copilot": {
      "options": {
        "deviceCode": true // 启用设备码认证
      }
    }
  }
}
```

## 3. 自定义提供商与本地模型配置

OpenCode 支持任何 **OpenAI 兼容 API** 的模型，包括本地部署的 Ollama、LM Studio、vLLM 等。

### 3.1 通用自定义提供商模板

```jsonc
{
  "provider": {
    "my-custom-provider": { // 自定义提供商ID（任意字符串）
      "npm": "@ai-sdk/openai-compatible", // 使用OpenAI兼容SDK
      "name": "我的自定义模型", // UI中显示的名称
      "options": {
        "baseURL": "https://your-api-endpoint.com/v1", // API地址（必须以/v1结尾）
        "apiKey": "your-api-key", // 不需要认证时填任意字符串
        "headers": { // 可选：自定义请求头
          "X-Custom-Header": "value"
        }
      },
      "models": {
        "model-id-1": { // 模型ID（与API返回一致）
          "name": "模型显示名称1"
        },
        "model-id-2": {
          "name": "模型显示名称2"
        }
      }
    }
  },
  "model": "my-custom-provider/model-id-1"
}
```

### 3.2 Ollama 本地模型配置

```jsonc
{
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (本地)",
      "options": {
        "baseURL": "http://localhost:11434/v1",
        "apiKey": "ollama" // 占位符，Ollama不需要认证
      },
      "models": {
        "qwen3-coder:7b": {
          "name": "Qwen3 Coder 7B"
        },
        "deepseek-coder:33b": {
          "name": "DeepSeek Coder 33B"
        }
      }
    }
  },
  "model": "ollama/qwen3-coder:7b"
}
```

### 3.3 LM Studio 本地模型配置

```jsonc
{
  "provider": {
    "lmstudio": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "LM Studio (本地)",
      "options": {
        "baseURL": "http://localhost:1234/v1",
        "apiKey": "lmstudio"
      },
      "models": {
        "current-model": {
          "name": "当前加载的模型"
        }
      }
    }
  },
  "model": "lmstudio/current-model"
}
```

### 3.4 vLLM 本地模型配置

```jsonc
{
  "provider": {
    "vllm": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "vLLM (本地)",
      "options": {
        "baseURL": "http://localhost:8000/v1",
        "apiKey": "vllm"
      },
      "models": {
        "Qwen3-4B-Instruct-2507": {
          "name": "Qwen3 4B Instruct"
        }
      }
    }
  },
  "model": "vllm/Qwen3-4B-Instruct-2507"
}
```

## 4. 模型推理参数配置

可以在**提供商级别**、**模型级别**或**代理级别**配置推理参数：

```jsonc
{
  "provider": {
    "local-vllm": {
      "options": {
        // 提供商全局参数
        "temperature": 0.3
      },
      "models": {
        "Qwen3-4B-Instruct-2507": {
          "options": {
            // 模型特定参数（覆盖全局）
            "temperature": 0.2,
            "maxTokens": 4096,
            "topP": 0.9,
            "frequencyPenalty": 0.1,
            "presencePenalty": 0.1
          }
        }
      }
    }
  }
}
```

**常用参数说明**：
- `temperature`：控制随机性（0.0-2.0），代码生成建议 0.1-0.5
- `maxTokens`：最大输出长度
- `topP`：核采样阈值（0.0-1.0），控制多样性
- `frequencyPenalty`：抑制重复 token（-2.0-2.0）
- `presencePenalty`：抑制重复主题（-2.0-2.0）

## 5. 多模型管理与切换

### 5.1 模型加载优先级

OpenCode 启动时按以下顺序选择默认模型：
1. `--model` 或 `-m` 命令行标志
2. 配置文件中的 `model` 字段
3. 上次使用的模型
3. 按内部优先级排列的第一个可用模型

### 5.2 运行时切换模型

- **TUI 界面**：按 `Ctrl+M` 调出模型选择菜单
- **命令行**：`opencode run --model provider/model-id "你的请求"`
- **提示词指定**：在提示词开头添加 `@model=provider/model-id`

### 5.3 按任务分配模型

可以为不同的代理配置专用模型：

```jsonc
{
  "agent": {
    "coder": { // 代码生成代理
      "model": "anthropic/claude-sonnet-4-5"
    },
    "summarizer": { // 摘要代理
      "model": "anthropic/claude-haiku-4-5"
    },
    "planner": { // 规划代理
      "model": "anthropic/claude-opus-4-5"
    }
  }
}
```

### 6. 完整配置示例

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

## 三、Oh My OpenAgent LLM 配置

Oh My OpenAgent（OMO）是 OpenCode 最流行的插件，提供多代理协作能力。它有自己独立的 LLM 配置体系。

### 1. OMO 配置文件位置

- 全局：`~/.config/opencode/oh-my-opencode.json`
- 项目：`.opencode/oh-my-opencode.json`

### 2. 代理模型配置

```jsonc
{
  "agents": {
    "sisyphus": { // 主编排器
      "model": "anthropic/claude-opus-4-6" // 覆盖默认模型
    },
    "hephaestus": { // 代码执行代理
      "model": "openai/gpt-5.1-codex"
    },
    "atlas": { // 前端代理
      "model": "google/gemini-3-pro"
    }
  },
  
  // 全局回退模型列表
  "fallback_models": [
    "anthropic/claude-sonnet-4-5",
    "openai/gpt-4o",
    "ollama/qwen3-coder:7b"
  ]
}
```

### 3. OMO 模型解析优先级

1. **用户覆盖**：`oh-my-opencode.json` 中明确指定的模型
2. **类别默认**：从任务类别继承的模型
3. **用户回退**：`fallback_models` 列表
3. **内置回退链**：每个代理定义的提供商优先级链
5. **系统默认**：OpenCode 配置的默认模型

## 四、常见问题与故障排除

### 1. 配置验证

使用以下命令检查配置文件是否正确：
```bash
opencode config validate
```

### 2. 调试模式

启用调试模式查看详细的 API 请求和响应：
```jsonc
{
  "debug": true,
  "debugLSP": true
}
```
调试日志保存在 `~/.local/share/opencode/debug.log`

### 3. 常见错误

1. **模型 ID 错误**：确保 `provider_id/model_id` 格式正确
2. **API 地址错误**：必须以 `/v1` 结尾
3. **密钥错误**：使用 `{env:VAR_NAME}` 从环境变量读取，避免硬编码
3. **超时错误**：增加 `timeout` 参数值（单位：毫秒）
5. **本地模型连接失败**：确认本地服务已启动且端口正确

### 4. 推荐模型组合

**全栈开发**：
- 主模型：`anthropic/claude-sonnet-4-5`
- 规划模型：`anthropic/claude-opus-4-5`
- 轻量任务：`anthropic/claude-haiku-4-5`

**本地部署**：
- 8GB 显存：`ollama/qwen3-coder:7b`
- 16GB 显存：`ollama/deepseek-coder:14b`
- 24GB+ 显存：`ollama/deepseek-coder:33b`

**性价比**：
- 主模型：`groq/llama-3-70b-8192`
- 轻量任务：`groq/llama-3-8b-8192`

需要我为你生成一个**开箱即用的完整配置模板**，包含主流云模型和本地模型的配置吗？