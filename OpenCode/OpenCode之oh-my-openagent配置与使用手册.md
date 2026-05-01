# Oh My OpenAgent 配置与使用手册

> oh-my-openagent（OmO）是一个为 OpenCode 设计的多智能体（Multi-Agent）编排框架

---

## 目录

1. [简介](#1-简介)
2. [安装与环境准备](#2-安装与环境准备)
3. [配置文件详解](#3-配置文件详解)
4. [Agents 详解](#4-agents-详解)
5. [使用模式](#5-使用模式)
6. [常用命令](#6-常用命令)
7. [模型选择建议](#7-模型选择建议)
8. [模式切换](#8-模式切换)
9. [最佳实践](#9-最佳实践)
10. [故障排查](#10-故障排查)
11. [进阶功能](#11-进阶功能)
12. [附录](#12-附录)

---

## 1. 简介

### 1.1 oh-my-openagent 是什么

oh-my-openagent（简称 OmO/omo，旧称 oh-my-opencode）是一个为 OpenCode 设计的多智能体（Multi-Agent）编排框架。它将原本"单一 AI 做所有事"的模式升级为多模型分工协作——不同 Agent 负责代码生成、审查、测试、文档等任务，每个 Agent 可独立配置模型，实现 Claude、GPT、Gemini 等在同一个代码库中各取所长。

### 1.2 核心概念

#### Agents（智能体）

- **本质**：具体角色（谁来做）
- **调用方式**：显式 `@agent-name`
- **类比**：具体员工（如"张三"）
- **配置对象**：智能体角色
- **使用场景**：需要特定角色能力时
- **粒度**：细粒度（精确控制）

#### Categories（任务分类）

- **本质**：任务类型（做什么）
- **调用方式**：隐式自动路由
- **类比**：岗位类型（如"前端工程师"）
- **配置对象**：任务分类
- **使用场景**：不知道用谁，只想描述需求
- **粒度**：粗粒度（自动匹配）

#### Agents 与 Categories 的关系

```
用户输入需求
    │
    ├─→ 包含 @agent-name? ──Yes──→ 直接调用指定 Agent
    │                              (如 @oracle 做架构)
    │
    └─→ No ──→ 分析任务类型 ──→ 匹配 Category
                                  │
                                  ├─→ visual-engineering → Gemini
                                  ├─→ quick → 轻量模型
                                  ├─→ deep → 强模型
                                  └─→ unspecified → 默认模型
```

> **一句话总结**：Agents 是点名用人，Categories 是按事分配。

---

## 2. 安装与环境准备

### 2.1 前置要求

- Node.js 18+ 和 npm（OmO 通过 npm 分发）
- OpenCode 1.4.0+（终端 AI 编码代理）
- 至少一个 LLM 提供商的 API Key（Anthropic / OpenAI / Google 等）

### 2.2 安装步骤

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

安装器会自动：
1. 检测 OpenCode 安装
2. 向 `~/.config/opencode/opencode.json` 注入插件引用
3. 生成 Agent 配置文件 `oh-my-openagent.json`

### 2.3 验证安装

```bash
# 检查 OpenCode 版本
opencode --version

# 运行诊断工具
bunx oh-my-opencode doctor
```

`doctor` 命令会检查系统、配置、工具和模型解析。

### 2.4 快速初始化配置

#### 方式一：自动初始化（推荐）

在 OpenCode TUI 中直接运行：

```
/init-deep
```

这会自动生成 `AGENTS.md` 文件并初始化所有 Agent 配置。

#### 方式二：AI 代理自动安装

将以下提示词粘贴给 Claude Code 或其他 AI 代理，它会自动读取安装指南并完成配置：

```
Install and configure oh-my-opencode by following instructions at:
https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/refs/heads/dev/docs/guide/installation.md
```

---

## 3. 配置文件详解

### 3.1 配置文件位置与优先级

OmO 采用两级配置，JSON/JSONC 格式（支持注释和尾逗号）：

| 级别 | 路径（全局） | 路径（项目级） | 作用范围 |
|------|-------------|---------------|----------|
| 1（最高） | — | `.opencode/oh-my-openagent.json[c]` | 当前项目 |
| 2 | `~/.config/opencode/oh-my-openagent.json[c]` | `%APPDATA%\opencode\oh-my-openagent.json[c]` | 所有项目 |

**配置优先级**：项目配置 > 全局配置

> **兼容性说明**：旧版配置名 `oh-my-opencode.json` 仍被识别，但新版推荐使用 `oh-my-openagent.json`。

### 3.2 完整配置示例

```jsonc
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json",

  // ========== Agent 模型配置 ==========
  "agents": {
    // Sisyphus：总指挥，强烈推荐 Claude Opus 4.7
    "sisyphus": {
      "model": "anthropic/claude-opus-4-7"
    },
    // Oracle：知识库/问答
    "oracle": {
      "model": "openai/gpt-5.4",
      "variant": "high"
    },
    // Librarian：文档处理
    "librarian": {
      "model": "google/gemini-3-flash"
    },
    // Atlas：代码分析
    "atlas": {
      "model": "anthropic/claude-sonnet-4-5"
    }
  },

  // ========== 任务类别模型 ==========
  "categories": {
    "visual-engineering": {
      "model": "google/gemini-3.1-pro",
      "variant": "high"
    },
    "quick": {
      "model": "openai/gpt-5-nano"
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

### 3.3 Agents 配置层

智能体角色定义：

| 智能体 | 主模型 | 备用模型 | 角色推测 |
|--------|--------|----------|----------|
| sisyphus | `guosen-anthropic-qwen35-plus/qwen35-plus` | `kimi-for-coding/k2p5` | 核心推理/编码 |
| oracle | `opencode-go/glm-5` | 无 | 知识/问答 |
| librarian | `opencode-go/minimax-m2.7` | `minimax-m2.7-highspeed` | 文档/检索 |
| explore | `opencode-go/minimax-m2.7` | `minimax-m2.7-highspeed` | 探索/搜索 |
| multimodal-looker | `guosen-anthropic-qwen35-plus/qwen35-plus` | 无 | 多模态视觉 |
| prometheus | `guosen-anthropic-qwen35-plus/qwen35-plus` | 无 | 监控/预警 |
| metis | `guosen-anthropic-qwen35-plus/qwen35-plus` | `kimi-for-coding/k2p5` | 策略/规划 |
| momus | `opencode-go/glm-5` | 无 | 批评/评估 |
| atlas | `guosen-anthropic-qwen35-plus/qwen35-plus` | `minimax-m2.7` | 重负载/支撑 |
| sisyphus-junior | `guosen-anthropic-qwen35-plus/qwen35-plus` | `minimax-m2.7` | 轻量版 sisyphus |

### 3.4 Categories 配置层

任务分类定义：

| 分类 | 主模型 | 备用模型 | 用途 |
|------|--------|----------|------|
| visual-engineering | `qwen35-plus` | `k2p5` | 视觉工程 |
| ultrabrain | `qwen35-plus` | 无 | 超脑/深度推理 |
| deep | `qwen35-plus` | 无 | 深度思考 |
| quick | `minimax-m2.7` | 无 | 快速响应 |
| unspecified-low | `qwen35-plus` | `minimax-m2.7` | 未指定 - 低负载 |
| unspecified-high | `qwen35-plus` | `minimax-m2.7` | 未指定 - 高负载 |
| writing | `qwen35-plus` | `minimax-m2.7` | 写作 |

### 3.5 模型策略与设计原则

#### 模型梯队

| 优先级 | 模型 | 特点 |
|--------|------|------|
| Tier 1 | `guosen-anthropic-qwen35-plus/qwen35-plus` | 主力高性能模型，承担 70% 场景 |
| Tier 2 | `opencode-go/glm-5` | 中等性能，用于 oracle/momus |
| Tier 3 | `opencode-go/minimax-m2.7` | 基础模型，fallback 或轻量任务 |
| Tier 4 | `minimax-m2.7-highspeed` | 极速版，用于 librarian/explore |
| Tier 5 | `kimi-for-coding/k2p5` | 编码专用 fallback |

#### 设计原则

1. **主力集中**：`qwen35-plus` 是绝对主力，覆盖深度推理、编码、多模态、写作等
2. **快速场景降级**：`quick` / `librarian` / `explore` 使用轻量模型保证延迟
3. **编码专属 fallback**：`k2p5` 仅作为 sisyphus 和 metis 的编码备用
4. **无单点故障**：关键角色（sisyphus, metis, atlas）都有 fallback
5. **神话题名**：用希腊神话角色命名，暗示职责（oracle→知识，atlas→承重，momus→批评）

---

## 4. Agents 详解

### 4.1 Sisyphus（总指挥）

**作用**：OmO 的核心大脑，所有 Ultrawork 任务的入口点。

**工作流程**：

```
用户输入 ulw <任务>
    │
    ▼
Sisyphus 接收任务
    │
    ├── 简单任务 ──► 直接委派给 Hephaestus 或 Librarian
    │
    └── 复杂任务 ──► 调用 Prometheus 做规划
                         │
                         ▼
                    Atlas 执行计划
```

**使用方式**：

```bash
# 直接触发（Sisyphus 自动接管）
ulw 实现用户认证系统

# 或明确指定
@sisyphus 协调完成以下工作：重构 API 层、添加测试、更新文档
```

### 4.2 Hephaestus（深度执行者）

**作用**：专注于复杂、深度的代码实现任务。它是"工匠型"Agent，适合需要大量编码工作的场景。

**特点**：
- 自主工作，不需要频繁交互
- 专为 GPT-5.3-codex 优化（代码生成能力最强）
- 适合长时间运行的编码任务

**使用方式**：

```bash
# 通过 Sisyphus 自动委派
ulw 实现一个完整的 JWT 认证中间件

# 或明确指定
@hephaestus 重写数据库连接池，支持连接复用和自动故障转移
```

> ⚠️ **注意**：不要将其替换为 Claude，因为提示词专为 Codex 设计。

### 4.3 Prometheus（规划师）

**作用**：在执行前进行充分的需求澄清和计划制定，避免"边做边改"。

**工作流程**：

```
/start-work 或按 Tab
    │
    ▼
Prometheus 启动访谈模式
    │
    ├── 问澄清问题（像资深工程师面试你）
    │   "这个功能的并发要求是多少？"
    │   "需要支持哪些数据库？"
    │   "现有代码的兼容策略是什么？"
    │
    ├── 识别范围边界和潜在风险
    │
    ├── 调用 Metis 做差距分析
    │
    ├── 调用 Momus 做严格审查
    │
    └── 输出 YAML 格式的详细计划
```

**使用方式**：

```bash
# 启动规划模式
/start-work

# 回答 Prometheus 的问题后，它会生成计划
# 然后运行
/start-work
# Atlas 接管执行
```

**适用场景**：
- 关键生产环境变更
- 跨多模块的大型重构
- 需要文档化决策轨迹的合规项目

### 4.4 Atlas（执行调度）

**作用**：Prometheus 规划完成后，Atlas 负责将计划拆解为具体任务，分发给各个专业 Agent 执行。

**工作流程**：

```
Prometheus 计划完成
    │
    ▼
Atlas 读取 YAML 计划
    │
    ├── 任务 1 ──► Hephaestus（编码）
    ├── 任务 2 ──► Oracle（架构审查）
    ├── 任务 3 ──► Explore（代码搜索）
    └── 任务 4 ──► Librarian（文档更新）
    │
    ▼
汇总结果，报告进度
```

**使用方式**：

```bash
# 通常在 Prometheus 规划后自动触发
# 也可手动调用
@atlas 执行当前计划中的第 3-5 步
```

### 4.5 其他 Agent 角色

| Agent | 角色 | 核心功能 | 典型使用场景 |
|-------|------|----------|--------------|
| Oracle | 知识库 | 高风险架构决策、复杂推理 | 技术选型、架构决策 |
| Librarian | 图书管理员 | 文档研究、外部 API 查询 | 查文档、搜最佳实践 |
| Explore | 探索者 | 代码库导航、模式检测 | 查找代码、理解结构 |
| Metis | 策略师 | 任务范围分析、预规划咨询 | 评估可行性 |
| Momus | 批评者 | 质量审查、合规验证 | 代码审查 |
| Atlas | 执行者 | 知识检索、架构上下文 | 需要历史知识 |
| Multimodal-looker | 视觉分析 | 视觉内容分析 | 处理图片、UI 截图 |

### 4.6 Agent 选择速查

```
任务类型判断：
    │
    ├── 需要详细规划？ ──是──► Prometheus + Atlas
    │
    ├── 需要持续优化？ ──是──► /ralph-loop 或 /ulw-loop
    │
    ├── 纯代码重构？ ────是──► /refactor
    │
    └── 其他日常任务 ────否──► ulw（Sisyphus 自动分配）
```

---

## 5. 使用模式

### 5.1 通过 @ 符号直接调用 Agent

适用场景：你知道该让谁做，需要特定角色的能力。

```bash
# 架构决策 → 找 Oracle
@oracle 这个微服务拆分方案有什么风险？

# 查文档 → 找 Librarian  
@librarian Redis Cluster 的脑裂问题怎么解决？

# 代码审查 → 找 Momus
@momus 审查一下 src/auth/login.ts 的代码质量

# 前端实现 → 找前端专家
@frontend-ui-ux-engineer 做一个带动画的加载按钮
```

**特点**：
- 直接、明确
- 适合复杂任务需要特定 expertise
- 可以组合多个 Agent 并行

### 5.2 通过 Sisyphus 自动委派

适用场景：只需要任务结果，让 Sisyphus 自动委派任务。

```bash
# 使用 ulw (ultra lazy write) 让 Sisyphus 自主处理复杂任务
ulw 实现一个用户认证系统，包含登录、注册、JWT token

# Sisyphus 会自动拆解任务并委派给：
# - @prometheus 做规划
# - @atlas 执行代码
# - @momus 做代码审查
```

### 5.3 显式规划 → 执行流程

适用场景：对于需要精确控制的复杂任务。

```bash
# 1. 按 Tab 键切换到 Plan 模式，让 Prometheus 做规划
@plan 设计一个支持 10 万 QPS 的订单系统

# 2. 查看生成的计划后，执行
/start-work

# 3. Atlas 会按步骤执行
```

### 5.4 隐式 Category 路由（省心自动）

适用场景：你只关心任务本身，不关心谁来做。

Categories 是自动路由机制，不需要手动 `@` 调用。当你描述任务时，Sisyphus 或 OpenCode 会根据关键词自动匹配 Category。

| Category | 触发场景 | 自动路由的模型 |
|----------|----------|---------------|
| `visual-engineering` | 前端 UI/UX、图片处理、CSS 调整 | `qwen35-plus` |
| `ultrabrain` | 超复杂推理、架构设计 | `qwen35-plus` |
| `deep` | 深度思考、算法设计 | `qwen35-plus` |
| `quick` | 快速查询、简单问答 | `minimax-m2.7` |
| `writing` | 文档撰写、注释生成 | `qwen35-plus` |

**使用示例**：

```bash
# 自动路由到 visual-engineering
帮我设计一个响应式的导航栏，支持暗黑模式

# 自动路由到 quick
查一下当前文件的行数

# 自动路由到 deep
设计一个支持分布式事务的订单状态机
```

**特点**：
- 无需记忆 Agent 名称
- 系统自动匹配最优模型
- 适合日常快速使用

### 5.5 混合使用（高级）

适用场景：复杂项目需要 orchestration。

```bash
# 1. 先用 Librarian 调研（显式 Agent）
@librarian 调研一下 OAuth2 PKCE 流程的最新最佳实践

# 2. 再用 Oracle 做决策（显式 Agent）
@oracle 基于上面的调研，决定我们的认证方案

# 3. 最后让 Sisyphus 自动执行（Category 路由）
ulw 实现上面确定的认证系统
```

---

## 6. 常用命令

### 6.1 常用 Slash 命令详解

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

### 6.4 命令补充说明

- **循环模式**（`/ralph-loop`、`/ulw-loop`）适合需要多轮自动迭代的场景，如代码质量持续改进、大规模重构等。普通任务用单次 `ulw` 即可，避免不必要的 Token 消耗。

- **`/compact` 与 `/handoff` 的区别**：`compact` 是当前会话内压缩历史；`handoff` 是跨会话保存工作快照。前者省 Token，后者保进度。

- **`/refactor` 模式**会激活专门的审查流程，包含影响分析 → 安全重构 → 回归测试 → 验证提交四个阶段，比普通 `ulw` 更适合关键代码重构。

### 6.5 ultrawork 模式

在 OpenCode TUI 中输入：

```
ultrawork
# 或缩写
ulw
```

系统会自动启动 Sisyphus 主指挥，分配任务给各个 Agent，你会看到多代理并行工作的日志输出。

### 6.6 Prometheus 规划模式

需要精确控制时，按 Tab 键进入 Prometheus（Planner）模式：
- 通过对话创建详细工作计划
- 完成后运行 `/start-work` 执行，获得完整编排

### 6.7 Refactor 重构模式

```bash
# 结构化重构
/refactor
```

---

## 7. 模型选择建议

### 7.1 模型选择参考

| Agent | 推荐模型 | 可安全替换为 | 危险替换 |
|-------|----------|--------------|----------|
| Sisyphus（总指挥） | Claude Opus 4.7 | Sonnet, Kimi K2.5, GLM 5 | 旧版 GPT 模型 |
| Prometheus（规划） | Claude Opus | GPT-5.4（自动切换提示词） | — |
| Atlas（分析） | Kimi K2.5 | Sonnet, GPT-5.4 | — |
| Hephaestus（构建） | GPT-5.3-codex | — | Claude（专为 Codex 设计） |
| Explore（探索） | 快速模型 | — | Opus（成本高、浪费） |
| Librarian（文档） | 轻量模型 | — | Opus（不需要强推理） |

### 7.2 私有模型/本地部署

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

## 8. 模式切换

在 `oh-my-openagent`（OMO）安装后，想要切回 OpenCode 原生的 **build/plan 模式**，有以下三种常用方案：

### 8.1 恢复原生 Plan + 保留 Builder（推荐）

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

### 8.2 完全禁用 Sisyphus

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

### 8.3 临时彻底卸载 OMO（最干净）

如果不再需要 OMO，直接从 OpenCode 主配置移除插件：

1. 编辑 `~/.config/opencode/opencode.json`：

```json
{
  "plugin": [] // 移除 "oh-my-opencode"
}
```

2. 重启 opencode → 完全恢复官方原生 Build/Plan 模式。

### 8.4 切换与验证方法

1. 重启 opencode 后，按 **Tab 键**循环切换模式，状态栏会显示当前是 **Build** 还是 **Plan**。
2. 验证：
   - Build 模式：可直接修改文件、执行命令
   - Plan 模式：默认只读，修改前会询问确认

---

## 9. 最佳实践

### 9.1 场景推荐表

| 你的需求 | 推荐方式 | 实际执行 |
|----------|----------|----------|
| "帮我看看这个架构有没有问题" | `@oracle` | Agent 显式调用 |
| "做一个暗黑模式的按钮" | 直接描述 | `visual-engineering` → Gemini |
| "查一下 Redis 最佳实践" | `@librarian` | Agent 显式调用 |
| "修一下这个拼写错误" | 直接描述 | `quick` → 轻量模型 |
| "实现整个用户系统" | `ulw` | Sisyphus 编排多 Agent |
| "审查这段代码质量" | `@momus` | Agent 显式调用 |
| "设计一个高并发方案" | `@oracle` 或 直接描述 | Agent 或 `ultrabrain` |
| "生成 CHANGELOG" | `@document-writer` | Agent 显式调用 |

### 9.2 选择决策树

```
开始
  │
  ├─→ 需要特定角色的专业知识？
  │     ├─→ 是 → 用 Agent（@oracle, @momus 等）
  │     └─→ 否 → 继续
  │
  ├─→ 任务类型明确（前端/快速/深度/写作）？
  │     ├─→ 是 → 用 Category（直接描述需求）
  │     └─→ 否 → 继续
  │
  ├─→ 复杂多步骤任务？
  │     ├─→ 是 → 用 Sisyphus（ulw 或 @sisyphus）
  │     └─→ 否 → 继续
  │
  └─→ 简单单步任务？
        └─→ 是 → 直接提问（走默认 Category 或 Ask 模式）
```

### 9.3 配置建议

在 `oh-my-openagent.json` 中为每个 Agent 分配合适的模型：

```json
{
  "agents": {
    "sisyphus":   { "model": "anthropic/claude-opus-4-7" },
    "prometheus": { "model": "anthropic/claude-opus-4-7" },
    "hephaestus": { "model": "openai/gpt-5.3-codex" },
    "atlas":      { "model": "openai/gpt-5.4" },
    "explore":    { "model": "ollama/qwen2.5-coder:7b" },
    "librarian":  { "model": "ollama/qwen2.5-coder:7b" }
  }
}
```

**原则**：推理型 Agent（Sisyphus、Prometheus）用最强模型；工具型 Agent（Explore、Librarian）可用本地轻量模型降低成本。

---

## 10. 故障排查

### 10.1 常见问题与解决

| 问题 | 原因 | 解决 |
|------|------|------|
| `opencode` 启动后 TUI 无响应 | oh-my-openagent 插件冲突（macOS 上常见） | 运行 `opencode --pure` 临时绕过，或移除插件后排查 |
| Sisyphus 无法正常工作 | 未配置 Claude 模型或缺少订阅 | 配置 `anthropic/claude-opus-4-7`，或手动指定为 GPT-5.4 |
| Agent 未加载 | 配置文件路径或插件名不匹配 | 确认 `opencode.json` 中插件数组包含 `oh-my-openagent` |
| 配置不生效 | 文件路径或格式问题 | 确认文件路径正确，重启 opencode |
| Agent 未找到 | 配置键名拼写错误 | 检查 `oh-my-openagent.json` 中 agents 键名 |
| 模型不可用 | 未配置 API Key | 检查 provider 是否已配置 API key |
| 匿名遥测 | 默认开启 | 设置环境变量 `OMO_SEND_ANONYMOUS_TELEMETRY=0` 关闭 |

### 10.2 配置验证

```bash
# 检查配置是否正确
bunx oh-my-opencode doctor
```

如果想禁用 OMO，从 `opencode.json` 的 `plugin` 数组中移除 `"oh-my-opencode"`。

---

## 11. 进阶功能

### 11.1 Skills

工程技能自动加载

### 11.2 Hooks

Git 提交前自动检查

### 11.3 Browser Automation

浏览器自动化操作

### 11.4 Tmux Integration

终端多会话集成

### 11.5 Git Master

Git 工作流自动化

### 11.6 MCPs

模型上下文协议支持

### 11.7 LSP

语言服务器协议集成

详细配置参考官方文档：[Configuration Reference](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/configuration.md)

---

## 12. 附录

### 12.1 快速参考表

#### Agents 职责速查

| Agent | 职责 | 何时使用 |
|-------|------|----------|
| `@sisyphus` | 主编排器，协调多 Agent | 复杂多步骤任务 |
| `@sisyphus-junior` | 轻量编排，Category 优化委派 | 中等复杂度任务 |
| `@prometheus` | 项目规划、任务拆解 | 需要详细计划时 |
| `@explore` | 代码库导航、模式检测 | 查找代码、理解结构 |
| `@librarian` | 文档研究、外部 API 查询 | 查文档、查最佳实践 |
| `@oracle` | 高风险架构决策、复杂推理 | 关键设计决策 |
| `@metis` | 任务范围分析、预规划咨询 | 评估可行性 |
| `@momus` | 质量审查、合规验证 | 代码审查 |
| `@atlas` | 知识检索、架构上下文 | 需要历史知识 |
| `@multimodal-looker` | 视觉内容分析 | 处理图片、UI 截图 |
| `@hephaestus` | 实现任务、编码工作流 | 纯编码实现 |

#### 使用模式对比

| 模式 | 触发方式 | 参与 Agent | 适用场景 |
|------|----------|------------|----------|
| Ultrawork 快速模式 | `ulw <任务>` | Sisyphus → 自动分配 | 日常开发、Bug 修复、功能添加 |
| Ultrawork 循环模式 | `/ulw-loop` | Sisyphus + 循环迭代 | 大规模重构、持续优化 |
| Prometheus 精确模式 | `/start-work` | Prometheus → Atlas → 各 Agent | 关键项目、复杂架构变更 |
| Ralph 审查模式 | `/ralph-loop` | Ralph（质量审查） | 代码审查、质量提升 |
| Refactor 重构模式 | `/refactor` | Refactor Agent | 结构化重构 |

### 12.2 关键记忆点

| | Agents | Categories |
|---|--------|------------|
| 记住这个 | `@名字` 直接点名 | 描述任务自动匹配 |
| 什么时候用 | 需要专家、审查、特定角色 | 日常开发、不知道用谁 |
| 配置重点 | 定义角色能力、模型、fallback | 定义任务类型、对应模型 |
| 成本意识 | 可精确控制用哪个模型 | 系统自动选择性价比最优 |
| 并行能力 | 支持多 Agent 同时工作 | 单一路由，不支持并行 |

> **一句话总结**：Agents 是"找对人"，Categories 是"办对事"。知道该找谁 → 用 `@Agent`；只知道要做什么 → 直接描述，让 Category 自动路由。

---

## 参考资料

- [Oh My OpenAgent 官方仓库](https://github.com/code-yeongyu/oh-my-openagent)
- [Configuration Reference](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/configuration.md)
- [Installation Guide](https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/refs/heads/dev/docs/guide/installation.md)
