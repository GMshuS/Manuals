Anthropic与OpenAI的API协议在多个维度存在显著差异，主要体现在设计哲学、接口格式、能力特性和适用场景等方面。

#### Anthropic与OpenAI协议的核心区别

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

#### 在OpenCode中配置两种协议的常用大模型

##### 1. 获取API密钥
- **OpenAI**：访问https://platform.openai.com创建API Key（格式：`sk-...`）
- **Anthropic**：访问https://console.anthropic.com创建API Key（格式：`sk-ant-...`）

##### 2. 配置方式（推荐按优先级选择）

######## 方式一：环境变量配置（最安全）
```bash
# 临时设置（仅当前会话）
export OPENAI_API_KEY="sk-your-openai-key"
export ANTHROPIC_API_KEY="sk-ant-your-anthropic-key"

# 永久保存（添加到shell配置文件）
echo 'export OPENAI_API_KEY="sk-your-openai-key"' >> ~/.zshrc
echo 'export ANTHROPIC_API_KEY="sk-ant-your-anthropic-key"' >> ~/.zshrc
source ~/.zshrc
```

######## 方式二：OpenCode认证命令
```bash
# 运行认证命令
opencode auth login

# 选择提供商（OpenAI或Anthropic）
# 粘贴API Key
# 按回车完成
```

认证信息存储在：`~/.local/share/opencode/auth.json`

######## 方式三：配置文件手动配置
在项目根目录创建`opencode.json`或`opencode.jsonc`文件：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "openai": {
      "options": {
        "baseURL": "https://api.openai.com/v1",
        "apiKey": "YOUR_OPENAI_API_KEY"
      },
      "models": {
        "gpt-4-turbo": {
          "name": "GPT-4 Turbo"
        },
        "gpt-4o": {
          "name": "GPT-4o"
        }
      }
    },
    "anthropic": {
      "options": {
        "baseURL": "https://api.anthropic.com/v1",
        "apiKey": "YOUR_CLAUDE_API_KEY"
      },
      "models": {
        "claude-3-5-sonnet": {
          "name": "Claude 3.5 Sonnet"
        },
        "claude-3-opus": {
          "name": "Claude 3 Opus"
        }
      }
    }
  },
  "model": "anthropic/claude-3-5-sonnet",  // 默认模型
  "small_model": "openai/gpt-4o-mini"      // 小型模型（用于简单任务）
}
```

##### 3. 配置本地大模型
对于支持OpenAI兼容协议的本地大模型（如Llama、Qwen等），可通过修改`baseURL`指向本地服务：

```json
{
  "provider": {
    "local-openai": {
      "options": {
        "baseURL": "http://localhost:8000/v1",  // 本地服务地址
        "apiKey": "not-needed-for-local"        // 本地服务可能不需要密钥
      },
      "models": {
        "llama3": {
          "name": "Llama 3 70B"
        }
      }
    },
    "local-anthropic": {
      "options": {
        "baseURL": "http://localhost:8080/v1",  // 支持Anthropic协议的本地服务
        "apiKey": "local-key"
      }
    }
  }
}
```

##### 4. 验证配置
```bash
# 查看已配置的认证信息
opencode auth list

# 测试模型调用
opencode chat --model openai/gpt-4-turbo
opencode chat --model anthropic/claude-3-5-sonnet
```

##### 5. 安全最佳实践
1. **绝不将API Key提交到代码仓库**：使用`.gitignore`排除配置文件
2. **使用密钥管理服务**：生产环境推荐使用AWS Secrets Manager、Azure Key Vault等
3. **定期轮换API Key**：降低泄露风险
4. **设置请求超时**：在配置中添加`timeout`参数（单位：毫秒）
5. **启用缓存**：设置`setCacheKey: true`提高性能

通过以上配置，您可以在OpenCode中灵活切换使用OpenAI和Anthropic的云端大模型，同时也能接入支持这两种协议的本地大模型，实现统一的管理和调用接口。