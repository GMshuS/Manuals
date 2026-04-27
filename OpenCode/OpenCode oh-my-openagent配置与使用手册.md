# oh-my-openagent 配置与使用手册

> oh-my-openagent（简称 OmO/omo）是一个为 OpenCode 设计的多智能体（Multi-Agent）编排框架。它将原本"单一 AI 做所有事"的模式升级为多模型分工协作——不同 Agent 负责代码生成、审查、测试、文档等任务，每个 Agent 可独立配置模型，实现 Claude、GPT、Gemini 等在同一个代码库中各取所长。

---

## 目录

1. [安装与环境准备](#一安装与环境准备)
2. [配置文件详解](#二配置文件详解)
3. [Agents 使用指南](#三agents-使用指南)
4. [Categories 使用指南](#四categories-使用指南)
5. [核心使用模式](#五核心使用模式)
6. [Slash 命令详解](#六-slash-命令详解)
7. [项目实战](#七项目实战)
8. [高级配置](#八高级配置)
9. [恢复原生模式](#九恢复原生模式)
10. [常见问题与故障排查](#十常见问题与故障排查)
11. [进阶功能](#十一进阶功能)

---

## 一、安装与环境准备

### 1.1 前置要求

| 组件 | 版本要求 | 说明 |
|------|----------|------|
| Node.js | 18+ | 通过 npm 分发 |
| OpenCode | 1.4.0+ | 终端 AI 编码代理 |
| API Key | 至少一个 | Anthropic / OpenAI / Google 等 |

### 1.2 安装步骤

```bash
# 1. 安装 Node.js 20（如未安装）
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs   # Ubuntu/Debian
# 或
sudo dnf install -y nodejs   # Rocky/RHEL

# 2. 全局安装 oh-my-opencode（npm 包名仍为 oh-my-opencode）
npm install -g oh-my-opencode

# 3. 运行安装器（非交互式模式示例）
oh-my-opencode install --no-tui --claude=yes --openai=yes --gemini=no
```

**安装器会自动完成：**
1. 检测 OpenCode 安装
2. 向 `~/.config/opencode/opencode.json` 注入插件引用
3. 生成 Agent 配置文件 `oh-my-openagent.json`

### 1.3 验证安装

```bash
# 检查 OpenCode 版本
opencode --version

# 运行诊断工具
bunx oh-my-opencode doctor
```

`doctor` 命令会检查系统、配置、工具和模型解析，输出类似：

```
oMoMoMoMo Doctor

⚠ 3 issues found:
1. Comment checker unavailable → 安装 @code-yeongyu/comment-checker
2. No LSP servers detected → 安装 LSP 服务器
3. GitHub CLI missing → 安装 gh CLI
```

---

## 二、配置文件详解

### 2.1 配置文件优先级

OmO 采用两级配置，JSONC 格式（支持注释和尾逗号）：

| 级别 | 路径（Windows） | 路径（Linux/macOS） | 作用范围 |
|------|-----------------|---------------------|----------|
| 项目级 | `<project>/.opencode/oh-my-openagent.json[c]` | 同左 | 当前项目 |
| 用户级 | `%APPDATA%\opencode\oh-my-openagent.json[c]` | `~/.config/opencode/oh-my-openagent.json[c]` | 所有项目 |

**配置优先级：项目配置 > 全局配置**

> **兼容性说明：** 旧版配置名 `oh-my-opencode.json` 仍被识别，但新版推荐使用 `oh-my-openagent.json`。

### 2.2 完整配置示例

```jsonc
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json",

  // ========== Agent 模型配置 ==========
  "agents": {
    "sisyphus": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus",
      "fallback_models": [
        {
          "model": "kimi-for-coding/k2p5"
        }
      ]
    },
    "oracle": {
      "model": "opencode-go/glm-5"
    },
    "librarian": {
      "model": "opencode-go/minimax-m2.7",
      "fallback_models": [
        {
          "model": "opencode-go/minimax-m2.7-highspeed"
        }
      ]
    },
    "explore": {
      "model": "opencode-go/minimax-m2.7",
      "fallback_models": [
        {
          "model": "opencode-go/minimax-m2.7-highspeed"
        }
      ]
    },
    "multimodal-looker": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus"
    },
    "prometheus": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus"
    },
    "metis": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus",
      "fallback_models": [
        {
          "model": "kimi-for-coding/k2p5"
        }
      ]
    },
    "momus": {
      "model": "opencode-go/glm-5"
    },
    "atlas": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus",
      "fallback_models": [
        {
          "model": "opencode-go/minimax-m2.7"
        }
      ]
    },
    "sisyphus-junior": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus",
      "fallback_models": [
        {
          "model": "opencode-go/minimax-m2.7"
        }
      ]
    }
  },

  // ========== 任务类别模型 ==========
  "categories": {
    "visual-engineering": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus",
      "fallback_models": [
        {
          "model": "kimi-for-coding/k2p5"
        }
      ]
    },
    "ultrabrain": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus"
    },
    "deep": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus"
    },
    "quick": {
      "model": "opencode-go/minimax-m2.7"
    },
    "unspecified-low": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus",
      "fallback_models": [
        {
          "model": "opencode-go/minimax-m2.7"
        }
      ]
    },
    "unspecified-high": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus",
      "fallback_models": [
        {
          "model": "opencode-go/minimax-m2.7"
        }
      ]
    },
    "writing": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus",
      "fallback_models": [
        {
          "model": "opencode-go/minimax-m2.7"
        }
      ]
    }
  },

  // ========== 功能开关 ==========
  "skills": true,
  "hooks": true,
  "browser": false,
  "tmux": true,
  "git-master": true,
  "comment-checker": false,
  "mcp": [],
  "lsp": true
}
```

### 2.3 核心字段解析

**配置整体结构：**

```json
{
  "$schema": "配置规范校验地址",
  "agents": { ... },    // 单个智能体配置 - 具体功能的独立 AI 角色
  "categories": { ... } // 分类配置 - 按场景/能力分组的模型配置
}
```

| 字段 | 说明 |
|------|------|
| `$schema` | JSON 格式校验文件，确保配置符合框架规范 |
| `model` | 主模型：当前智能体/分类优先使用的大模型（格式：`厂商/模型名`） |
| `fallback_models` | 备用模型列表：主模型不可用时（超时、ERR、限流）的降级模型 |

### 2.4 项目初始化

在项目目录下创建配置结构：

```
my-project/
├── .opencode/
│   ├── oh-my-openagent.json    ← OMO 主配置
│   ├── skills/                 ← 自定义技能
│   └── agents/                 ← 自定义 Agent（可选）
├── src/
└── AGENTS.md                   ← 由 /init-deep 生成
```

**初始化命令：**

```bash
# 方式一：使用 /init-deep 自动生成 AGENTS.md（推荐）
# 在 OpenCode TUI 中执行：
/init-deep

# 方式二：手动创建配置文件
mkdir -p .opencode
touch .opencode/oh-my-openagent.json
```

---

## 三、Agents 使用指南

### 3.1 基础概念

**Agents** 是具体的智能体角色，每个名称对应一个独立功能的智能体。

### 3.2 Agent 职责速查表

| Agent | 职责 | 何时使用 | 主模型 |
|-------|------|----------|--------|
| `@sisyphus` | 主编排器，协调多 Agent | 复杂多步骤任务 | qwen35-plus |
| `@sisyphus-junior` | 轻量编排，Category 优化委派 | 中等复杂度任务 | qwen35-plus |
| `@prometheus` | 项目规划、任务拆解 | 需要详细计划时 | qwen35-plus |
| `@oracle` | 高风险架构决策、复杂推理 | 关键设计决策 | glm-5 |
| `@metis` | 任务范围分析、预规划咨询 | 评估可行性 | qwen35-plus |
| `@explore` | 代码库导航、模式检测 | 查找代码、理解结构 | minimax-m2.7 |
| `@librarian` | 文档研究、外部 API 查询 | 查文档、查最佳实践 | minimax-m2.7 |
| `@momus` | 质量审查、合规验证 | 代码审查 | glm-5 |
| `@atlas` | 知识检索、架构上下文 | 需要历史知识 | qwen35-plus |
| `@multimodal-looker` | 视觉内容分析 | 处理图片、UI 截图 | qwen35-plus |
| `@hephaestus` | 实现任务、编码工作流 | 纯编码实现 | - |
| `@frontend-ui-ux-engineer` | 前端/UI 专家 | 处理视觉相关任务 | gemini |
| `@document-writer` | 文档工程师 | 生成 CHANGELOG、README | qwen35-plus |

### 3.3 调用方式

#### 方式一：通过 `@` 符号直接调用

在 OpenCode 终端中，使用 `@agent-name` 直接调用特定智能体：

```bash
@sisyphus 帮我重构这个模块的代码
@oracle 这个架构决策有什么风险？
@explore 查找项目中所有使用 UserService 的地方
@librarian 查一下 Redis 集群的最佳实践
@momus 帮我审查这段代码
```

#### 方式二：通过 Sisyphus 自动委派

Sisyphus 是 OMO 的主编排器，它会根据任务类型自动选择合适的 Agent：

```bash
# 使用 ulw (ultra lazy write) 让 Sisyphus 自主处理复杂任务
ulw 实现一个用户认证系统，包含登录、注册、JWT token

# Sisyphus 会自动拆解任务并委派给：
# - @prometheus 做规划
# - @atlas 执行代码
# - @momus 做代码审查
```

#### 方式三：显式规划 → 执行流程

对于需要精确控制的复杂任务：

```bash
# 1. 按 Tab 键切换到 Plan 模式，或输入：
@plan 设计一个支持 10 万 QPS 的订单系统

# 2. 查看生成的计划后，执行
/start-work

# 3. Atlas 会按步骤执行
```

### 3.4 禁用特定 Agent

```json
{
  "disabled_agents": ["momus", "sisyphus-junior"]
}
```

---

## 四、Categories 使用指南

### 4.1 基础概念

**Categories** 是任务分类，根据任务类型自动路由到对应模型。当你描述任务时，Sisyphus 或 OpenCode 会根据关键词自动匹配 Category。

### 4.2 Category 映射表

| Category | 触发场景 | 自动路由模型 | 含义 |
|----------|----------|--------------|------|
| `visual-engineering` | 前端 UI/UX、图片处理、CSS 调整 | qwen35-plus | 视觉工程/图像处理 |
| `ultrabrain` | 超复杂推理、架构设计 | qwen35-plus | 超强算力/复杂推理 |
| `deep` | 深度思考、算法设计 | qwen35-plus | 深度思考/长文本分析 |
| `quick` | 快速查询、简单问答 | minimax-m2.7 | 快速响应/轻量请求 |
| `writing` | 文档撰写、注释生成 | qwen35-plus | 文本创作/写作 |
| `unspecified-low` | 未分类低负载任务 | qwen35-plus → minimax | 低优先级通用任务 |
| `unspecified-high` | 未分类高负载任务 | qwen35-plus → minimax | 高优先级通用任务 |

### 4.3 使用示例

```bash
# 自动路由到 visual-engineering
帮我设计一个响应式的导航栏，支持暗黑模式

# 自动路由到 quick
查一下当前文件的行数

# 自动路由到 deep
设计一个支持分布式事务的订单状态机

# 自动路由到 ultrabrain
我们的消息队列该用 Kafka 还是 RabbitMQ？

# 自动路由到 writing
帮我写一个 API 接口文档
```

### 4.4 显式指定 Category 覆盖

```bash
# 强制使用 deep 类别（即使描述像 quick 任务）
@category:deep 分析这个函数的算法复杂度并给出优化方案
```

---

## 五、核心使用模式

### 5.1 Ultrawork 模式（最常用）

在 OpenCode TUI 中输入：

```bash
ultrawork
# 或缩写
ulw
```

系统会自动启动 Sisyphus 主指挥，分配任务给各个 Agent，你会看到多代理并行工作的日志输出。

### 5.2 Prometheus 规划模式

需要精确控制时，按 Tab 键进入 Prometheus（Planner）模式：

- 通过对话创建详细工作计划
- 完成后运行 `/start-work` 执行，获得完整编排

### 5.3 使用场景最佳实践

| 场景 | 推荐方式 | 原因 |
|------|----------|------|
| 简单任务 | 直接提问，不使用 Agent | 避免 overhead |
| 复杂且不想操心 | `ulw` + 让 Sisyphus 自主处理 | 全自动委派 |
| 复杂且要精确控制 | `@plan` → `/start-work` | 先规划后执行 |
| 前端/视觉任务 | 直接描述，自动路由 `visual-engineering` | 自动用多模态模型 |
| 快速搜索/导航 | `@explore` 或 `@librarian` | 轻量模型，低延迟 |
| 代码审查 | `@momus` | 专门的质量审查 Agent |
| 架构决策 | `@oracle` | 高 stakes 推理 |
| 深度研究 | `@metis` | 任务范围分析 |

---

## 六、Slash 命令详解

### 6.1 常用 Slash 命令表

| 命令 | 功能 | 使用场景 | 详细说明 |
|------|------|----------|----------|
| `/init-deep` | 自动生成分层 `AGENTS.md` 并初始化 Agent 配置 | 首次进入新项目时 | 扫描项目结构，在各级目录生成上下文文件，让 Agent 精准读取局部上下文而非整个仓库 |
| `/start-work` | 启动 Prometheus 模式的执行阶段 | 完成规划后执行 | Prometheus 完成需求访谈和计划生成后，用此命令启动 Atlas 执行详细计划 |
| `/ralph-loop` | 激活 Ralph 循环模式 | 持续优化场景 | 启动自动迭代循环，Ralph Agent 持续审查和改进代码质量 |
| `/ulw-loop` | 激活 Ultrawork 循环模式 | 大规模任务持续执行 | Ultrawork 的循环版本，适合需要多轮迭代的大型重构或功能开发 |
| `/refactor` | 进入重构专用模式 | 代码重构时 | 激活专门的 Refactor Agent，提供结构化重构流程，包含影响分析和安全回滚机制 |
| `/handoff` | 创建上下文摘要，在新会话中继续工作 | 会话中断/切换时 | 将当前工作进度、关键决策和待办事项打包成摘要，便于跨会话无缝衔接 |
| `/compact` | 压缩上下文，节省 Token | 长会话/Token 告警时 | 对当前会话历史进行智能压缩，保留关键决策点，移除冗余对话，降低 Token 消耗 |
| `/cancel-ralph` | 取消长时间任务 | 任务失控/需中断时 | 强制停止 Ralph 或其他长时间运行的后台 Agent 任务 |

### 6.2 命令使用流程图

```
新项目首次使用
    │
    ▼
┌─────────────┐
│ /init-deep  │  ← 建立项目上下文
└─────────────┘
    │
    ▼
选择工作模式
    │
    ├── 复杂任务，需要精确控制 ──► Prometheus 模式
    │                                │
    │   1. 按 Tab 进入 Prometheus    │
    │   2. 回答澄清问题              │
    │   3. 生成详细计划              │
    │   4. /start-work 启动执行      │
    │                                │
    └── 快速执行，全自动处理 ─────► Ultrawork 模式
                                     │
                                     ├── 单次执行：ulw <任务>
                                     │
                                     └── 持续迭代：/ulw-loop
```

### 6.3 典型使用场景示例

#### 场景 1：新项目接入

```bash
# 第一步：建立上下文
/init-deep

# 第二步：分析架构（只读，安全）
@oracle 分析当前项目架构，指出技术债务和优化点

# 第三步：规划重构
/start-work
# → 回答 Prometheus 的澄清问题
# → 获得详细执行计划

# 第四步：执行并持续优化
/refactor
# 或
/ulw-loop
```

#### 场景 2：长会话 Token 告警

```bash
# 当收到 Token 即将超限的提示时
/compact

# 压缩后继续工作
ulw 继续完成刚才的登录功能实现
```

#### 场景 3：跨天工作交接

```bash
# 下班前
/handoff
# → 生成上下文摘要文件

# 第二天新会话
# 读取昨天的 handoff 摘要，无缝继续
```

#### 场景 4：取消失控任务

```bash
# Ralph 循环陷入无限优化时
/cancel-ralph

# 或取消所有后台任务
/background-cancel all
```

### 6.4 补充说明

- **循环模式**（`/ralph-loop`、`/ulw-loop`）适合需要多轮自动迭代的场景，如代码质量持续改进、大规模重构等。普通任务用单次 `ulw` 即可，避免不必要的 Token 消耗。

- **`/compact` 与 `/handoff` 的区别**：`compact` 是当前会话内压缩历史；`handoff` 是跨会话保存工作快照。前者省 Token，后者保进度。

- **`/refactor` 模式**会激活专门的审查流程，包含影响分析 → 安全重构 → 回归测试 → 验证提交四个阶段，比普通 `ulw` 更适合关键代码重构。

---

## 七、项目实战

### 7.1 全栈 Web 开发项目配置

```jsonc
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json",
  
  "agents": {
    "sisyphus": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus",
      "fallback_models": [{ "model": "kimi-for-coding/k2p5" }],
      "comment": "主协调器，负责编排所有子 Agent"
    },
    "oracle": {
      "model": "opencode-go/glm-5",
      "comment": "架构师，负责技术选型和架构决策"
    },
    "librarian": {
      "model": "opencode-go/minimax-m2.7",
      "fallback_models": [{ "model": "opencode-go/minimax-m2.7-highspeed" }],
      "comment": "文档研究员，查外部 API、最佳实践"
    },
    "explore": {
      "model": "opencode-go/minimax-m2.7",
      "fallback_models": [{ "model": "opencode-go/minimax-m2.7-highspeed" }],
      "comment": "代码库导航，快速搜索和理解项目结构"
    },
    "frontend-ui-ux-engineer": {
      "model": "google/antigravity-gemini-3-pro-high",
      "comment": "前端/UI 专家，处理视觉相关任务"
    },
    "document-writer": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus",
      "comment": "文档工程师，生成 CHANGELOG、README"
    },
    "multimodal-looker": {
      "model": "google/antigravity-gemini-3-pro-high",
      "comment": "视觉分析，处理截图、UI 设计稿"
    }
  },

  "categories": {
    "visual-engineering": {
      "model": "google/antigravity-gemini-3-pro-high",
      "comment": "前端/UI/UX 任务自动路由到 Gemini"
    },
    "ultrabrain": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus",
      "comment": "复杂架构决策用最强模型"
    },
    "deep": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus",
      "comment": "深度调研与执行"
    },
    "quick": {
      "model": "opencode-go/minimax-m2.7",
      "comment": "快速修错字、单文件修改"
    },
    "writing": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus",
      "fallback_models": [{ "model": "opencode-go/minimax-m2.7" }],
      "comment": "文档写作"
    },
    "unspecified-low": {
      "model": "opencode-go/minimax-m2.7",
      "comment": "未分类低负载任务用轻量模型"
    },
    "unspecified-high": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus",
      "fallback_models": [{ "model": "opencode-go/minimax-m2.7" }],
      "comment": "未分类高负载任务"
    }
  }
}
```

### 7.2 实战场景演示

#### 场景 1：从零开发全栈用户管理系统

```bash
# Step 1: 让 Prometheus 做规划
# 按 Tab 切换到 Plan 模式，或输入：
@plan 设计一个支持 OAuth2 + JWT 的用户管理系统，包含：
- 用户注册/登录/找回密码
- RBAC 权限管理
- 操作日志审计
- 前端管理后台

# Step 2: Sisyphus 自动编排执行
# 使用 ulw (ultra lazy work) 让 Sisyphus 全权处理
ulw 按照上面的规划实现整个用户管理系统

# Sisyphus 会自动：
# 1. @oracle 确认架构方案
# 2. @explore 分析现有代码库
# 3. @librarian 查 OAuth2 最佳实践
# 4. 并行启动 @frontend-ui-ux-engineer 和 @atlas（后端）
# 5. @momus 做代码审查
# 6. @document-writer 生成文档
```

#### 场景 2：前端 UI 重构（Category 自动路由）

```bash
# 描述中包含 UI/前端关键词，自动路由到 visual-engineering
帮我设计一个响应式的用户仪表盘，支持暗黑模式，
包含：数据卡片、折线图、最近活动列表

# 系统自动：
# - Category: visual-engineering
# - 模型：gemini-3-pro（多模态强）
# - Agent: frontend-ui-ux-engineer
```

#### 场景 3：遗留系统重构（大型项目）

参考真实案例：某金融科技公司用 OMO 将 50 万行 Java 单体应用迁移到微服务：

```bash
# 1. 初始化深度上下文
/init-deep

# 2. 启动现代化改造
ulw 将当前单体应用按领域拆分为微服务：
- 识别可独立的服务边界
- 提取用户服务、订单服务、支付服务
- 确保 API 兼容性
- 更新数据访问层为独立数据库
```

**Sisyphus 并行执行流程：**

```
┌─────────────┐
│  @oracle    │ → 分析系统依赖，确定服务边界
│  架构分析   │
└──────┬──────┘
       ↓
┌─────────────┐     ┌─────────────┐
│  @explore   │     │ @librarian  │
│  代码库扫描  │     │ 查微服务最佳实践│
└──────┬──────┘     └──────┬──────┘
       ↓                   ↓
┌─────────────────────────────────┐
│      @atlas + @frontend         │
│   并行实现后端 + 前端适配         │
└─────────────────────────────────┘
       ↓
┌─────────────┐
│   @momus    │ → 代码审查、兼容性验证
│   质量审查   │
└──────┬──────┘
       ↓
┌─────────────┐
│ @document   │ → 生成迁移文档、CHANGELOG
│  文档生成   │
└─────────────┘
```

### 6.3 需求与路由对照表

| 需求 | 命令 | 路由结果 |
|------|------|----------|
| 修个 typo | `把 login.tsx 第 15 行的 className 拼写改对` | `quick` → `minimax-m2.7`（快且便宜） |
| 研究新技术 | `调研一下 GraphQL Federation 的优缺点，给出接入方案` | `deep` → `qwen35-plus`（深度推理） |
| 架构决策 | `我们的消息队列该用 Kafka 还是 RabbitMQ？` | `ultrabrain` → `qwen35-plus`（最强模型） |
| 前端组件 | `做一个带动画的加载组件` | `visual-engineering` → `gemini-3-pro`（多模态） |

### 7.4 项目阶段推荐用法

| 项目阶段 | 推荐用法 | 关键 Agent/Category |
|----------|----------|---------------------|
| 项目启动 | `/init-deep` + `@plan` | Prometheus、Oracle |
| 日常开发 | `ulw` 让 Sisyphus 自主处理 | Sisyphus、Atlas |
| 前端/UI | 直接描述需求 | `visual-engineering` → Gemini |
| 代码审查 | `@momus` | Momus |
| 文档维护 | `@document-writer` | Document-writer |
| 紧急修复 | 直接提问（不用 Agent） | `quick` → 轻量模型 |
| 技术调研 | `@librarian` + `@explore` 并行 | Librarian、Explore |

---

## 八、高级配置

### 8.1 自定义 Agent 配置

可以覆盖内置 Agent 或添加新 Agent：

```jsonc
{
  "agents": {
    "sisyphus": {
      "model": "anthropic/claude-opus-4-5",
      "provider": "anthropic",
      "temperature": 0.1,
      "thinking": { "budget": 32000 },
      "fallback_chain": [
        { "model": "kimi-k2-5", "provider": "kimi-for-coding" },
        { "model": "glm-5", "provider": "zai-coding-plan" }
      ]
    }
  }
}
```

### 8.2 背景任务并发配置

```jsonc
{
  "background_task": {
    "defaultConcurrency": 5,
    "providerConcurrency": {
      "anthropic": 3,
      "openai": 2
    }
  }
}
```

### 8.3 多 Agent 并行协作

```bash
# 同时启动多个 Agent 处理不同部分
@explore 查找所有使用 Redis 的地方
@librarian 查 Redis Cluster 的最佳配置
# 两个任务并行执行，结果汇总给 Sisyphus
```

### 8.4 自定义工作流（YAML 方式）

在 `.opencode/workflows/` 下创建工作流：

```yaml
# .opencode/workflows/feature-workflow.yaml
name: feature-workflow
steps:
  - agent: pm              # 需求分析
  - agent: oracle          # 架构设计
  - parallel:              # 并行执行
      - agent: atlas       # 后端实现
      - agent: frontend-ui-ux-engineer  # 前端实现
  - agent: momus           # 代码审查
  - agent: document-writer # 文档生成
```

执行：

```bash
/workflow feature-workflow
```

### 8.5 成本优化策略

```jsonc
{
  "categories": {
    "quick": {
      "model": "opencode-go/minimax-m2.7",
      "comment": "轻量任务用最便宜模型"
    },
    "deep": {
      "model": "guosen-anthropic-qwen35-plus/qwen35-plus",
      "fallback_models": [
        { "model": "opencode-go/minimax-m2.7" }
      ],
      "comment": "深度任务用强模型，失败时降级"
    }
  }
}
```

### 8.6 私有模型/本地部署

如需私有化部署（如使用 Qwen3.5-35B-int4 量化模型），可通过 llama.cpp 启动本地服务：

```bash
llama-server \
  --model qwen3.5-35b-int4.gguf \
  --port 36605 \
  --host 0.0.0.0 \
  --ctx-size 32768 \
  --n-gpu-layers 34 \
  --parallel 2
```

然后在配置中指向本地端点即可。

---

## 九、恢复原生模式

在 `oh-my-openagent`（OMO）安装后，想要切回 OpenCode 原生的 **build/plan 模式**，核心是关闭 OMO 对原生模式的覆盖，有三种常用方案（从轻量到完全恢复）：

### 9.1 仅恢复原生 Plan + 保留 Builder（推荐）

编辑 OMO 配置文件（全局 `~/.config/opencode/oh-my-opencode.json` 或项目 `.opencode/oh-my-opencode.json`），加入：

```json
{
  "sisyphus_agent": {
    "replace_plan": false,        // 不替换原生 Plan
    "default_builder_enabled": true // 启用原生 Builder
  }
}
```

保存后**重启 opencode**，即可用 `Tab` 在原生 Build/Plan 间切换，同时保留 OMO 的其他 Agent（如 `@librarian`/`@explore`）。

### 9.2 完全禁用 Sisyphus，彻底回归原生模式

想完全回到 OpenCode 原版（无 OMO 编排），配置：

```json
{
  "sisyphus_agent": {
    "disabled": true  // 关闭 Sisyphus 编排
  }
}
```

- ✅ 可正常用 `Tab` 切换 **Build/Plan**
- ✅ 保留 OMO 所有独立 Agent（`@oracle`/`@librarian` 等）
- ❌ 无法用 `ulw`/`@plan` 等 Sisyphus 相关功能

### 9.3 临时彻底卸载 OMO（最干净）

如果不再需要 OMO，直接从 OpenCode 主配置移除插件：

1. 编辑 `~/.config/opencode/opencode.json`：

```json
{
  "plugin": [] // 移除 "oh-my-opencode"
}
```

2. 重启 opencode → 完全恢复官方原生 Build/Plan 模式。

### 9.4 切换与验证方法

1. 重启 opencode 后，按 **Tab 键**循环切换模式，状态栏会显示当前是 **Build** 还是 **Plan**。
2. 验证：
   - Build 模式：可直接修改文件、执行命令
   - Plan 模式：默认只读，修改前会询问确认

---

## 十、常见问题与故障排查

### 10.1 常见问题表

| 问题 | 原因 | 解决 |
|------|------|------|
| `opencode` 启动后 TUI 无响应 | oh-my-openagent 插件冲突（macOS 上较常见） | 运行 `opencode --pure` 临时绕过，或移除插件后排查 |
| Sisyphus 无法正常工作 | 未配置 Claude 模型或缺少订阅 | 配置 `anthropic/claude-opus-4-7`，或手动指定为 GPT-5.4 |
| Agent 未加载 | 配置文件路径或插件名不匹配 | 确认 `opencode.json` 中插件数组包含 `oh-my-openagent` |
| 配置不生效 | 文件路径错误 | 确认文件路径正确，重启 opencode |
| Agent 未找到 | 配置键名拼写错误 | 检查 `oh-my-openagent.json` 中 agents 键名是否正确 |
| 模型不可用 | 未配置 API key | 检查 provider 是否已配置 API key |
| Sisyphus 不委派 | 命令前缀错误 | 确认是否使用了 `ulw` 前缀或 `@sisyphus` |
| Category 路由错误 | 关键词不匹配 | 检查描述中的关键词是否匹配 category 定义 |
| 想禁用 OMO | - | 从 `opencode.json` 的 `plugin` 数组中移除 `"oh-my-opencode"` |
| 匿名遥测 | 默认开启 | 设置环境变量 `OMO_SEND_ANONYMOUS_TELEMETRY=0` 关闭 |

### 10.2 快速诊断

```bash
# 运行诊断工具
bunx oh-my-opencode doctor
```

---

## 十一、进阶功能

### 11.1 功能开关总览

| 功能 | 配置项 | 说明 |
|------|--------|------|
| Skills | `"skills": true` | 工程技能自动加载 |
| Hooks | `"hooks": true` | Git 提交前自动检查 |
| Browser | `"browser": false` | 浏览器自动化操作 |
| Tmux | `"tmux": true` | 终端多会话集成 |
| Git Master | `"git-master": true` | Git 工作流自动化 |
| Comment Checker | `"comment-checker": false` | 代码注释检查 |
| MCPs | `"mcp": []` | 模型上下文协议支持 |
| LSP | `"lsp": true` | 语言服务器协议集成 |

### 11.2 快速初始化配置

**方式一：自动初始化（推荐）**

在 OpenCode TUI 中直接运行：

```
/init-deep
```

这会自动生成 `AGENTS.md` 文件并初始化所有 Agent 配置。

**方式二：AI 代理自动安装**

将以下提示词粘贴给 Claude Code 或其他 AI 代理，它会自动读取安装指南并完成配置：

```
Install and configure oh-my-opencode by following instructions at:
https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/refs/heads/dev/docs/guide/installation.md
```

---

## 附录：模型选择建议

| Agent | 推荐模型 | 可安全替换为 | 备注 |
|-------|----------|--------------|------|
| Sisyphus（总指挥） | Claude Opus 4.7 | Sonnet, Kimi K2.5, GLM 5 | 旧版 GPT 模型不推荐 |
| Prometheus（规划） | Claude Opus | GPT-5.4（自动切换提示词） | - |
| Atlas（分析） | Kimi K2.5 | Sonnet, GPT-5.4 | - |
| Hephaestus（构建） | GPT-5.3-codex | - | Claude 专为 Codex 设计 |
| Explore（探索） | 快速模型 | - | Opus 成本高、浪费 |
| Librarian（文档） | 轻量模型 | - | Opus 不需要强推理 |

---

## 参考资料

- [官方配置参考](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/configuration.md)
- [安装指南](https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/refs/heads/dev/docs/guide/installation.md)
- [Schema 规范](https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json)
