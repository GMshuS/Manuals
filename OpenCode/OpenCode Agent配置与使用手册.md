# OpenCode Agent 完整手册

## 目录

- [一、核心概念：Primary Agent 与 Subagent](#一核心概念primary-agent-与-subagent)
- [二、内置 Agent](#二内置-agent)
- [三、创建自定义 Agent](#三创建自定义-agent)
- [四、Agent 配置项全解](#四agent-配置项全解)
- [五、Agent 调用机制](#五agent-调用机制)
- [六、企业级架构：1主代理 + 5子代理](#六企业级架构1主代理--5子代理)
- [七、Commands（自定义命令）与 Agent](#七commands自定义命令与-agent)
- [八、Skills（技能）与 Agent](#八skills技能与-agent)
- [九、最佳实践](#九最佳实践)
- [十、常见问题](#十常见问题)

---

## 一、核心概念：Primary Agent 与 Subagent

### 1. Primary Agent（主代理）
- **角色**：对话入口、总控、调度者
- **交互**：用户直接聊天，Tab 键切换多个 Primary
- **权限**：可全工具/受限，能调用 Subagent
- **典型职责**：需求理解、任务拆解、结果验收、多子代理编排

### 2. Subagent（子代理）
- **角色**：领域专家、执行者
- **交互**：不能直接作为会话入口；只能：
  - 主代理通过 `Task` 工具调用
  - 用户手动 `@子代理名` 调用
- **权限**：通常是**只读/受限工具**，专注单一任务
- **典型职责**：代码搜索、审查、写单测、查文档、API 调用等

### 3. 关键区别一览

| 维度 | Primary Agent | Subagent |
|---|---|---|
| 交互方式 | 直接对话、Tab 切换 | `@` 调用或被主代理调度 |
| 会话入口 | ✅ 可作为默认会话 | ❌ 不能作为会话入口 |
| 工具权限 | 可全开放/受限 | 通常只读或最小权限 |
| 数量 | 少量（如 2~4 个） | 可大量（按领域拆分） |
| 可见性 | 始终可见 | 可 `hidden: true` 隐藏 |

---

## 二、内置 Agent

### 1. 内置 Primary Agent

#### Build（默认）
- mode: `primary`
- 工具：**全开**（读/写/编辑/bash/git 等）
- 用途：日常开发、改代码、跑命令、完整项目操作

#### Plan
- mode: `primary`
- 工具：**受限**（文件编辑、bash 默认 `ask`，需确认）
- 用途：需求分析、方案规划、代码评审、只看不改

### 2. 内置 Subagent

#### General
- mode: `subagent`
- 工具：几乎全开（除 todo），可改文件
- 用途：复杂调研、多步骤任务、并行子工作流

#### Explore
- mode: `subagent`，**只读**
- 工具：只能读文件、搜索代码、查结构
- 用途：快速探索代码库、找文件、查定义、回答代码问题

---

## 三、创建自定义 Agent

### 方式一：CLI 交互式创建（推荐）
```bash
# 启动交互式创建
opencode agent create
```
按提示填写：
1. Agent 名称（如 `backend-java`、`code-reviewer`）
2. 模式：`primary` 或 `subagent`
3. 模型：如 `anthropic/claude-sonnet-4`、`zhipu/glm4`
4. 描述：用途（用于主代理自动选择）
5. 系统提示：角色设定、工作流程
6. 工具权限：read/write/edit/bash/git 等开关

生成位置：
- 项目级：`.opencode/agent/<name>.md`
- 用户级：`~/.config/opencode/agent/<name>.md`

### 方式二：手写配置文件

#### 1）JSON 配置（opencode.json）
```json
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "backend-java": {
      "mode": "subagent",
      "model": "zhipu/glm4",
      "description": "Java 后端开发专家，使用 Spring Boot",
      "prompt": "你是资深 Java 后端工程师，精通 Spring Boot 与 RESTful API...",
      "tools": {
        "read": true,
        "write": true,
        "edit": true,
        "bash": false,
        "git": false
      },
      "hidden": false
    },
    "tech-lead": {
      "mode": "primary",
      "model": "anthropic/claude-opus-4",
      "description": "技术负责人，负责架构设计与任务拆分",
      "prompt": "你是经验丰富的技术负责人，擅长需求拆解、架构设计、任务分配...",
      "tools": {
        "read": true,
        "write": true,
        "edit": true,
        "bash": true,
        "git": true
      }
    }
  }
}
```

#### 2）Markdown 配置（.opencode/agent/*.md）
文件：`.opencode/agent/frontend-react.md`
```markdown
---
mode: subagent
model: anthropic/claude-sonnet-4
description: React 前端专家，擅长组件开发与状态管理
hidden: false
tools:
  read: true
  write: true
  edit: true
  bash: false
---

你是资深 React 前端工程师，精通 React 18、TypeScript、TailwindCSS...
```

---

## 四、Agent 配置项全解

### 1. 基础字段（必选）
- `mode`：`primary` / `subagent` / `all`（默认 all）
- `model`：模型名，如 `anthropic/claude-sonnet-4`
- `description`：一句话描述（用于主代理自动匹配）
- `prompt`：系统提示词（角色、能力、工作流程、约束）

### 2. 工具权限（tools）
控制 Agent 可用能力：
```json
"tools": {
  "read": true,      // 读文件
  "write": true,     // 写/新建文件
  "edit": true,      // 编辑文件
  "bash": false,     // 执行 bash 命令
  "git": true,       // git 操作
  "todo": false      // 任务管理
}
```

### 3. 高级字段
- `hidden`（仅 Subagent）：`true` 时不在 `@` 补全显示，只能被代码调用
- `temperature`：模型温度（0~1，越低越保守）
- `max_tokens`：最大输出长度

---

## 五、Agent 调用机制

### 1. 核心调用规则
1. **Primary 是唯一入口**：你只和 Primary 聊天，Subagent 不会主动出现
2. **两种调用方式**
   - **自动调用**：Primary 智能判断 → 自动派任务给 Subagent
   - **手动调用**：你直接输入 `@Subagent名` 强制调用
3. **调用本质**：Primary 用 `Task` 工具把任务交给 Subagent，Subagent 执行完返回结果给 Primary，Primary 再整理给你

### 2. 自动调用 Subagent（最常用）

#### 工作流程
你 → Primary（理解需求）→ **自动选择 Subagent** → Subagent（执行任务）→ Subagent 返回结果 → Primary 验收 → 回复你

#### 真实调用示例
```
你：帮我看看这个项目的用户模块代码结构，然后审查一下登录接口有没有安全问题

Build（Primary）：
我需要先探索项目结构，再调用代码审查专家检查安全问题。

👉 调用 Subagent：Explore
任务：探索项目中用户模块、登录相关的文件结构，列出核心文件路径

Explore（Subagent）返回结果：
用户模块文件：
- src/user/model.py
- src/user/controller.py
- src/user/auth.py
登录接口：src/user/auth.py 第 15-40 行

Build（Primary）收到结果：
已获取结构，现在调用代码审查专家检查安全问题。

👉 调用 Subagent：code-reviewer
任务：审查 src/user/auth.py 登录接口，检查密码明文、SQL注入、权限校验等问题

code-reviewer（Subagent）返回结果：
发现 2 个风险：
1. 密码未加密存储
2. 无请求频率限制

Build（Primary）最终回复你：
项目用户模块结构如下：...
登录接口存在 2 个安全问题：...
建议修复方案：...
```

#### Primary 如何知道调用哪个 Subagent？
完全依靠 **Subagent 配置里的 `description`**
```
description: "只读代码探索专家，分析项目结构、查找文件"
description: "代码审查专家，专注安全漏洞、代码规范检查"
```
Primary 会**语义匹配**你的需求，自动选最合适的专家。

### 3. 手动 @ 直接调用 Subagent

#### 规则
- 格式：`@代理名 你的指令`
- 效果：**跳过 Primary 决策，直接让 Subagent 干活**
- 适用：你明确知道该让哪个专家做

#### 示例
```
你：@Explore 帮我找项目里所有和支付相关的代码

Explore（Subagent）：
找到支付相关文件：
1. src/pay/order.py
2. src/pay/gateway.py
...
```

### 4. Primary + 多 Subagent 串联（高级协作）

一个任务，Primary 自动**依次调用多个 Subagent**：
```
你：帮我开发一个安全的用户登录功能

Build（Primary）：
1. 调用 @Explore 了解现有代码结构
2. 调用 @backend-java 编写登录接口
3. 调用 @code-reviewer 审查代码安全
4. 汇总结果给你
```

### 5. 调用方式对比

| 场景 | Primary 自动调用 Subagent | 你手动 @ 调用 Subagent |
|---|---|---|
| 触发者 | Primary 智能判断 | 你手动指定 |
| 格式 | 直接说需求 | `@名字 指令` |
| 流程 | 自动拆任务、自动选专家 | 直接指定专家 |
| 控制权 | Primary 掌握 | 你完全掌握 |
| 用途 | 复杂任务、自动化协作 | 简单明确、快速指令 |

---

## 六、企业级架构：1主代理 + 5子代理

### 1. 角色分工
- **tech-lead【Primary】**：总负责人，需求拆解、任务编排、汇总输出、异常兜底、串联所有子代理
- **dev-backend【Subagent】**：后端开发，业务编码、接口开发、数据库逻辑
- **dev-frontend【Subagent】**：前端开发，组件、页面、样式、交互逻辑
- **code-review【Subagent】**：代码评审，规范校验、漏洞检测、性能优化
- **test-engineer【Subagent】**：测试工程师，单元测试、用例编写、异常场景覆盖
- **docs-writer【Subagent】**：文档专员，API文档、开发手册、注释优化

### 2. 完整配置文件

路径：项目根目录 `opencode.json`

```json
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "tech-lead": {
      "mode": "primary",
      "model": "anthropic/claude-sonnet-4",
      "temperature": 0.2,
      "description": "技术负责人，需求拆解、任务拆分、调度后端/前端/评审/测试/文档子代理，汇总所有结果并统一输出",
      "prompt": "你是资深技术负责人，负责项目全流程管控。收到需求后必须：1.拆解细分任务；2.根据任务类型自动调用对应子代理；3.收集子代理返回结果；4.统一整合、优化、修复冲突；5.输出完整可落地方案与代码。禁止单独完成细分领域编码、评审、测试工作，必须委派子代理执行。",
      "tools": {
        "read": true,
        "write": true,
        "edit": true,
        "bash": true,
        "git": true,
        "todo": true
      },
      "hidden": false
    },
    "dev-backend": {
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4",
      "temperature": 0.3,
      "description": "后端开发专家，负责接口开发、业务逻辑、数据库操作、服务层代码编写",
      "prompt": "你是后端高级开发工程师，专注服务端编码。严格遵循项目规范，代码附带完整注释，保证健壮性、可扩展性，只完成分配的编码任务，不做评审、测试、文档工作。",
      "tools": {
        "read": true,
        "write": true,
        "edit": true,
        "bash": false,
        "git": false
      },
      "hidden": false
    },
    "dev-frontend": {
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4",
      "temperature": 0.3,
      "description": "前端开发专家，负责Vue/React组件、页面开发、样式适配、接口联调",
      "prompt": "你是前端高级开发工程师，专注页面与组件开发。遵循前端工程化规范，代码简洁易维护，样式兼容主流设备，仅完成前端编码任务。",
      "tools": {
        "read": true,
        "write": true,
        "edit": true,
        "bash": false,
        "git": false
      },
      "hidden": false
    },
    "code-review": {
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4",
      "temperature": 0.1,
      "description": "代码评审专家，只读权限，检查代码规范、安全漏洞、SQL注入、权限控制、性能问题",
      "prompt": "你是代码安全与规范评审专家，仅做只读分析。逐条检查代码问题：代码规范、安全漏洞、逻辑错误、性能隐患、冗余代码，输出问题清单+修复建议，禁止修改代码。",
      "tools": {
        "read": true,
        "write": false,
        "edit": false,
        "bash": false,
        "git": false
      },
      "hidden": false
    },
    "test-engineer": {
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4",
      "temperature": 0.2,
      "description": "测试工程师，编写单元测试、接口测试用例、边界场景测试、异常捕获校验",
      "prompt": "你是专业测试工程师，根据业务代码编写标准化测试用例，覆盖正常场景、边界值、异常报错、参数非法场景，输出完整测试代码与测试说明。",
      "tools": {
        "read": true,
        "write": true,
        "edit": true,
        "bash": false,
        "git": false
      },
      "hidden": false
    },
    "docs-writer": {
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4",
      "temperature": 0.4,
      "description": "文档编写专家，生成API接口文档、代码注释优化、开发说明、使用手册",
      "prompt": "你是专业文档工程师，根据业务代码生成清晰规范的文档：API入参出参、接口说明、代码块注释、业务流程说明，格式整洁、易读易懂。",
      "tools": {
        "read": true,
        "write": true,
        "edit": false,
        "bash": false,
        "git": false
      },
      "hidden": false
    }
  }
}
```

### 3. 标准完整调用工作流

#### 场景需求
> 开发用户登录接口，包含账号密码校验，写完代码后做代码评审、编写单元测试、生成API文档

#### Primary（tech-lead）自动调度流程
1. 任务拆解
   - 任务1：后端编码 → 委派 `dev-backend`
   - 任务2：代码安全评审 → 委派 `code-review`
   - 任务3：单元测试编写 → 委派 `test-engineer`
   - 任务4：生成API文档 → 委派 `docs-writer`

2. 串行调用子代理（标准执行顺序）
   - 第一步：调用 `dev-backend`，生成登录接口完整代码
   - 第二步：携带代码，调用 `code-review`，输出问题与优化建议
   - 第三步：将评审问题反馈给后端代理，修正代码
   - 第四步：调用 `test-engineer`，生成对应测试用例
   - 第五步：调用 `docs-writer`，整理标准化接口文档

3. 结果汇总
   主代理收集所有子代理输出：最终代码+评审报告+测试用例+接口文档，统一格式化后返回给用户。

### 4. 权限与协作约束

1. **写权限隔离**
   - 仅 `dev-backend / dev-frontend / test-engineer` 允许编辑、新建文件
   - `code-review` 纯只读，杜绝越权修改

2. **命令行权限收敛**
   - 仅主代理 `tech-lead` 可执行 bash、git 命令
   - 子代理禁止执行高危命令，保障项目安全

3. **职责强隔离**
   - 编码代理不写文档、不做测试
   - 评审代理不写代码、不修改文件
   - 各司其职，符合团队协作规范

### 5. 扩展与自定义改造
1. 新增子代理：例如增加 `sql-expert`、`security-scan`、`docker-dev`，只需新增一段 subagent 配置
2. 模型差异化配置：复杂评审/架构使用高阶模型，编码、文档使用轻量模型
3. 隐藏子代理：子代理配置添加 `"hidden": true`，无法手动`@`调用，仅允许主代理内部调度

---

## 七、Commands（自定义命令）与 Agent

### 1. Commands 中指定 Agent 的基本机制

在 OpenCode 中，自定义命令（Custom Commands）可以通过配置明确指定由哪个 Agent 来执行。

#### 配置方式

**Markdown 文件方式（推荐）：**
```markdown
---
description: Review pull request changes
agent: code-reviewer        # ← 指定执行该命令的 Agent
model: anthropic/claude-sonnet-4
subtask: true               # ← 强制作为 Subagent 调用
---

Please review the following PR changes and provide:
1. Code quality assessment
2. Potential bugs or issues
3. Suggestions for improvement

!git diff origin/main...HEAD
```

**JSON 配置方式：**
```json
{
  "$schema": "https://opencode.ai/config.json",
  "command": {
    "review": {
      "template": "Review the PR changes for quality and bugs...",
      "description": "Review pull request changes",
      "agent": "code-reviewer",
      "model": "anthropic/claude-sonnet-4-20250514",
      "subtask": true
    }
  }
}
```

#### 文件存放位置

| 级别 | 路径（Linux/macOS） | 优先级 |
|------|---------------------|--------|
| 项目级 | `<PROJECT>/.opencode/commands/` | 高（覆盖全局） |
| 全局级 | `~/.config/opencode/commands/` | 低 |

文件名（不含 `.md`）即为命令名，如 `review-pr.md` → `/review-pr`。

### 2. `agent` 字段：指定执行主体

`agent` 字段决定该命令由哪个 Agent 执行：

```yaml
---
agent: plan        # 使用名为 "plan" 的 Agent 执行
---
```

**行为规则：**
- 若指定的 Agent 是 Subagent（`mode: subagent`），命令默认会触发 Subagent 调用（通过 Task 工具）
- 若指定的 Agent 是 Primary（`mode: primary`），命令由该 Primary Agent 直接执行
- 若未指定，默认使用当前活跃的 Primary Agent

#### 典型场景

| 命令 | 指定 Agent | Agent 模式 | 用途 |
|------|-----------|-----------|------|
| `/review` | `code-reviewer` | `subagent` | 代码审查，不污染主上下文 |
| `/test` | `build` | `primary` | 运行测试，直接在当前会话操作 |
| `/docs` | `docs-writer` | `subagent` | 生成文档，隔离写入操作 |
| `/plan` | `planner` | `subagent` | 任务拆解，只读分析 |

### 3. `subtask` 字段：强制子任务隔离

`subtask` 是一个布尔字段，用于强制将命令作为 Subagent 调用执行，即使指定的 Agent 配置为 `mode: primary`：

```json
{
  "command": {
    "analyze": {
      "agent": "build",
      "subtask": true,    // 强制 build Agent 以 Subagent 身份运行
      "template": "Analyze the codebase architecture..."
    }
  }
}
```

#### 为什么要强制隔离？

| 场景 | 不使用 subtask | 使用 subtask: true |
|------|---------------|-------------------|
| 代码审查 | 审查结果混入主会话上下文 | 审查完成后仅返回结论，主上下文干净 |
| 安全审计 | 审计过程污染当前工作流 | 审计在隔离环境中完成 |
| 文档生成 | 生成过程占用主会话历史 | 仅将最终文档内容带回主会话 |
| 性能分析 | 大量中间分析数据堆积 | 只返回关键结论和建议 |

#### 执行流程对比

**`subtask: false`（默认）：**
```
用户输入 /review
    ↓
当前 Primary Agent 直接执行审查
    ↓
审查过程、中间思考、文件读取全部保留在主会话
```

**`subtask: true`：**
```
用户输入 /review
    ↓
Primary Agent 调用 Task 工具
    ↓
创建隔离的 Subagent 上下文
    ↓
Subagent 独立完成审查
    ↓
返回结构化结果给 Primary Agent
    ↓
Primary Agent 整合后展示给用户
```

### 4. 命令模板中的变量与动态内容

#### 占位符系统

| 占位符 | 说明 | 示例 |
|--------|------|------|
| `$ARGUMENTS` | 用户输入的命令参数 | `/explain src/auth.ts` → `$ARGUMENTS` = `src/auth.ts` |
| `@filename` | 引用文件内容 | `@README.md` 注入 README 内容 |
| `!command` | 执行 Shell 命令并注入输出 | `!git diff` 注入 diff 结果 |

#### 完整示例

**代码解释命令：**
```markdown
---
description: Explain code in detail
agent: plan
subtask: true
---

Please provide a detailed explanation of: @$ARGUMENTS

Include:
- Purpose and functionality
- Key components
- Best practices used or violated
- Suggestions for improvement
```

**PR 审查命令：**
```markdown
---
description: Review pull request changes
agent: code-reviewer
subtask: true
model: anthropic/claude-sonnet-4
---

You are conducting a code review. Analyze the following changes:

!git diff origin/main...HEAD

Focus areas:
1. Security vulnerabilities
2. Performance bottlenecks
3. Maintainability issues

Provide a structured report with severity ratings.
```

**带文件引用的测试命令：**
```markdown
---
description: Run tests with coverage
agent: build
---

Run the full test suite with coverage report and show any failures.
Focus on the failing tests and suggest fixes.

Relevant test files: @$ARGUMENTS
```

### 5. CLI 层面的 Agent 绑定

#### `opencode run` 命令
```bash
# 使用特定 Agent 执行提示
opencode run --agent code-reviewer "Review src/auth.ts for security issues"

# 使用特定模型和 Agent
opencode run --agent plan --model anthropic/claude-haiku-4 "Plan the refactoring"
```

#### 启动时指定默认 Agent
```bash
opencode --agent typescript-expert
```

#### 会话中切换 Agent
在 TUI 中，可通过 Tab 键切换 Primary Agent，切换后执行的自定义命令默认由新的当前 Agent 处理（除非命令自身指定了 `agent` 字段）。

### 6. 限制与注意事项

1. **Task 工具无法展开自定义命令**：当通过 Task 工具调用 Subagent 时，如果 prompt 中包含 `/slashcommand` 形式的自定义命令，不会自动展开执行
2. **权限继承**：Subagent 执行命令时，受限于该 Agent 自身的工具权限配置
3. **命令覆盖内置命令**：自定义命令与内置命令同名时，自定义命令优先
4. **模型覆盖优先级**（从高到低）：
   - 命令中指定的 `model` 字段
   - Agent 配置中指定的 `model` 字段
   - 全局默认模型

### 7. 配置速查表

| 配置项 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `template` | string | ✅ | 发送给 LLM 的提示模板 |
| `description` | string | ✅ | TUI 中显示的命令描述 |
| `agent` | string | ❌ | 指定执行 Agent，默认当前 Agent |
| `subtask` | boolean | ❌ | 强制作为 Subagent 调用，默认 `false` |
| `model` | string | ❌ | 覆盖默认模型 |

---

## 八、Skills（技能）与 Agent

### 1. Skills 基础架构

#### Skills 的发现与加载

Skills 通过 `SKILL.md` 文件定义，存放位置：

| 级别 | 路径 |
|------|------|
| 项目级 | `.opencode/skills/<name>/SKILL.md` |
| 全局级 | `~/.config/opencode/skills/<name>/SKILL.md` |
| Claude 兼容 | `.claude/skills/<name>/SKILL.md` / `~/.claude/skills/<name>/SKILL.md` |
| Agent 兼容 | `.agents/skills/<name>/SKILL.md` / `~/.agents/skills/<name>/SKILL.md` |

#### 文件结构
```markdown
---
name: git-release
description: Create consistent releases and changelogs
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
---

## What I do
- Draft release notes from merged PRs
- Propose a version bump

## When to use me
Use this when you are preparing a tagged release.
```

#### Skills 的加载方式

Agent 通过 `skill` 工具按需加载：
```javascript
skill({ name: "git-release" })
```

加载后，Skill 的内容被注入到当前 Agent 的上下文中，Agent 按照 Skill 中的指令执行。

### 2. 在 Skills 中调用 Agent 的四种方式

#### 方式一：Skill 内容中通过 @mention 调用 Subagent

```markdown
---
name: security-review-pipeline
description: Full security review workflow using multiple agents
---

## Workflow

### Step 1: Initial Scan
@security-auditor Scan the codebase for common vulnerabilities:
- SQL injection
- XSS
- CSRF
- Insecure dependencies

### Step 2: Deep Analysis
@security-auditor For each finding, provide:
- Severity (Critical/High/Medium/Low)
- Attack vector
- Remediation code

### Step 3: Fix Verification
@build Apply the recommended fixes and run tests to verify.
```

#### 方式二：Skill 中通过自然语言指令触发 Agent 调用

```markdown
---
name: incremental-implementation
description: Build features incrementally with planning and review
---

## Instructions

When implementing a feature:

1. **Plan First**: If the task is complex, invoke the planner agent to break it down.
2. **Implement**: Write code following the project's coding standards.
3. **Self-Review**: Before finishing, ask the code-reviewer agent to review your changes.
4. **Test**: Run the test suite. If tests fail, use the debugger agent to diagnose.

## Rules
- Never skip the review step
- Always run tests before declaring completion
- If uncertain about architecture, consult the architect agent
```

#### 方式三：Skill 作为 Agent 的专属能力模块

```json
{
  "agent": {
    "security-auditor": {
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "skills": ["security-checklist", "owasp-top10", "dependency-scan"],
      "tools": {
        "read": true,
        "grep": true,
        "skill": true
      }
    }
  }
}
```

#### 方式四：Skills 2.0 提案中的原生 Subagent 支持

```markdown
---
name: complex-feature-dev
description: Multi-agent workflow for complex feature development
agents:
  - name: planner
    role: task-breakdown
  - name: architect
    role: design-review
  - name: implementer
    role: code-generation
  - name: reviewer
    role: quality-check
---

## Workflow

1. **Planning Phase**
   - agent: planner
   - instruction: Break down the feature into atomic tasks
   - output: task-list.md

2. **Design Phase**
   - agent: architect
   - instruction: Review task-list.md and propose technical design
   - dependencies: [planning-phase]

3. **Implementation Phase**
   - agent: implementer
   - instruction: Implement each task from task-list.md
   - dependencies: [design-phase]

4. **Review Phase**
   - agent: reviewer
   - instruction: Review all changes for quality and security
   - dependencies: [implementation-phase]
```

**Skills 1.0 vs 2.0 对比：**

| 特性 | Skills 1.0 | Skills 2.0（提案） |
|------|-----------|-------------------|
| Agent 调用 | 间接（通过 @mention 或自然语言） | 原生声明式（YAML frontmatter） |
| 并行执行 | 不支持 | 支持多 Agent 并行 |
| 上下文隔离 | 依赖 Agent 自身实现 | 内置隔离上下文栈 |
| 依赖管理 | 无 | 显式声明任务依赖 |
| 权限粒度 | Agent 级别 | Skill 级别 |

### 3. 权限控制：Skills 与 Agent 的访问管理

#### 全局 Skills 权限
```json
{
  "permission": {
    "skill": {
      "*": "allow",
      "pr-review": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

| 权限值 | 行为 |
|--------|------|
| `allow` | Skill 立即加载 |
| `deny` | Skill 对 Agent 隐藏，访问被拒绝 |
| `ask` | 加载前提示用户确认 |

#### 按 Agent 覆盖 Skills 权限

**自定义 Agent（Markdown frontmatter）：**
```markdown
---
description: Internal documentation agent
mode: subagent
permission:
  skill:
    "documents-*": "allow"
    "external-*": "deny"
---
```

**内置 Agent（JSON 配置）：**
```json
{
  "agent": {
    "plan": {
      "permission": {
        "skill": {
          "internal-*": "allow",
          "security-*": "deny"
        }
      }
    }
  }
}
```

#### 禁用特定 Agent 的 Skill 工具
```json
{
  "agent": {
    "plan": {
      "tools": {
        "skill": false
      }
    }
  }
}
```

#### Agent 调用 Subagent 的权限（Task 权限）
```json
{
  "agent": {
    "orchestrator": {
      "mode": "primary",
      "permission": {
        "task": {
          "*": "deny",
          "orchestrator-*": "allow",
          "code-reviewer": "ask"
        }
      }
    }
  }
}
```

### 4. 实战案例

#### 案例一：代码审查流水线 Skill

Skill 定义（`.opencode/skills/code-review-pipeline/SKILL.md`）：
```markdown
---
name: code-review-pipeline
description: Multi-agent code review workflow with security and quality checks
---

## Code Review Pipeline

Execute the following review workflow:

### Phase 1: Static Analysis
@explore Search for:
- Hardcoded secrets or API keys
- TODO/FIXME comments
- Deprecated API usage
- Complex functions (>50 lines)

Report findings with file paths and line numbers.

### Phase 2: Security Review
@security-auditor Review the changed files for:
- Authentication bypasses
- Injection vulnerabilities
- Insecure data handling
- Missing input validation

Provide severity ratings and remediation.

### Phase 3: Quality Review
@code-reviewer Assess:
- Code readability and maintainability
- Test coverage
- Documentation completeness
- Adherence to project standards

### Phase 4: Final Report
Compile all findings into a structured report:
- Executive summary
- Critical issues (must fix)
- Recommendations (should fix)
- Positive observations
```

#### 案例二：TDD 开发 Skill

Skill 定义（`.opencode/skills/tdd-development/SKILL.md`）：
```markdown
---
name: tdd-development
description: Test-driven development workflow
---

## TDD Workflow

Follow strict TDD:

1. **RED**: Write failing tests first
   - @test-writer Create comprehensive test cases
   - Ensure tests fail for the right reasons

2. **GREEN**: Implement minimal code
   - @implementer Write the simplest code to pass tests
   - No premature optimization

3. **REFACTOR**: Improve without changing behavior
   - @code-reviewer Verify tests still pass
   - @refactorer Clean up code while maintaining green tests

4. **VERIFY**: Final validation
   - Run full test suite
   - @security-auditor Quick security scan
   - @performance-analyzer Check for obvious bottlenecks
```

### 5. 配置速查表

| 配置项 | 作用域 | 说明 |
|--------|--------|------|
| `skills`（Agent 配置） | Agent | 指定 Agent 可用的技能列表 |
| `tools.skill` | Agent | 是否启用 Skill 工具 |
| `permission.skill` | 全局/Agent | 控制 Skill 加载权限 |
| `permission.task` | Agent | 控制可调用的 Subagent |
| `mode` | Agent | `primary`/`subagent`/`all` |
| `hidden` | Subagent | 是否在 `@` 自动补全中隐藏 |

---

## 九、最佳实践

### Primary Agent 设计
- 数量：**1~3 个**（如 Build、Plan、TechLead）
- 权限：
  - 开发用：全工具
  - 规划用：受限（编辑/bash 设 ask）
- 提示词：强调**任务拆解、调度、验收**能力

### Subagent 设计
- 数量：**按领域拆分**（前端、后端、测试、安全、文档）
- 权限：**最小权限原则**（如代码审查只开 read）
- 提示词：专注**单一领域深度**，明确输入输出格式
- 高频 Subagent 建议：
  - `code-reviewer`：只读，审查安全/性能/规范
  - `test-engineer`：写单测/集成测试
  - `docs-writer`：写 API 文档、README

### Skills 最佳实践
1. Skill 职责单一：每个 Skill 聚焦一个具体工作流，避免过于复杂
2. Agent 权限最小化：Subagent 只启用必要的工具和 Skill 访问权限
3. 使用 `subtask: true`：在 Commands 中调用 Skill 时，强制隔离执行上下文
4. 版本管理：利用 `compatibility` 和 `metadata` 字段管理 Skill 版本
5. 渐进式加载：Skill 采用懒加载（lazy-load）模式，按需注入上下文，避免 Token 浪费

### 使用口诀
1. **复杂任务直接说** → Primary 自动调用一堆 Subagent 协作
2. **明确专家快速查** → 直接 `@名字` 指令
3. **Subagent 只管专业事**，权限最小化，Primary 总控全局

---

## 十、常见问题

### Q1：如何切换 Primary Agent？
- 会话中按 **Tab** 键循环切换
- 或用快捷键（默认 `switch_agent`）

### Q2：Subagent 没显示在 @ 补全？
- 检查配置：`hidden: false`
- 确认文件名无空格、小写

### Q3：如何让 Primary 自动选择合适 Subagent？
- 写好 `description`，关键词明确（如"Java 后端""React 前端"）
- Primary 会基于描述相似度自动匹配

### Q4：如何快速启用企业级配置？
1. 在项目根目录新建/覆盖 `opencode.json`，粘贴完整配置
2. 重启 OpenCode 会话，加载新 Agent 配置
3. 切换默认主代理为 `tech-lead`
4. 直接输入业务需求，即可全自动走完整多代理协作流程
