# OpenSpec 完全使用手册

> 版本：基于 OpenSpec v1.2.0+ 整理
> 参考来源：官方文档、GitHub 仓库及社区实战指南

---

## 目录

1. [技术原理](#一技术原理)
2. [安装与初始化](#二安装与初始化)
3. [命令列表](#三命令列表)
4. [各种开发场景详细使用流程](#四各种开发场景详细使用流程)
5. [流程中的目录结构与输出文件解析](#五流程中的目录结构与输出文件解析)
6. [与 Spec Kit、GSD、Superpowers 等工具的对比](#六与-spec-kitgsdsuperpowers-等工具的对比)

---

## 一、技术原理

### 1.1 核心问题：AI 编码的真正瓶颈是对齐

使用 AI 结对编程时，开发者常遇到以下痛点：

- **需求理解偏差**：花了大段文字描述功能，AI 看似理解了，写出来的代码却跑偏，反复纠偏消耗大量上下文窗口
- **上下文丢失**：对话关闭后，所有设计决策、技术约束全部蒸发，下次需要从头解释
- **状态断层**：功能做到一半被打断，重新打开对话后 AI 完全不知道之前做到哪了

**根源**：AI 的"记忆"只存在于当前对话中。对话关了，一切归零。

### 1.2 解决思路：把共识写成文件

OpenSpec 的思路很朴素：既然对话会消失，那就把重要的东西写成文件。需求是什么、技术方案怎么设计、实现步骤有哪些——全部以 Markdown 文件持久化在项目里。AI 每次开工，不是从你的口头描述出发，而是从这份"共识文档"出发。

### 1.3 核心理念：规格驱动开发（Spec-Driven Development）

**核心主张**：在写代码之前，先花一点时间把"要做什么"用结构化的方式写下来。这份文档不是给人看的需求文档，而是 **给 AI 看的行为契约**——它告诉 AI 系统应该表现出什么行为，AI 基于这份契约去写代码，你基于这份契约去验收。

### 1.4 四个设计原则

| 原则 | 说明 |
|------|------|
| **灵活，而非死板** | 没有"规划阶段不许写代码"的锁定。写到一半发现 specs 不对？回去改就是了。不存在阶段门禁 |
| **迭代，而非瀑布** | 不要求一次把所有事情想清楚。先写个大概，边做边完善 |
| **简单，而非复杂** | 就是几个 Markdown 文件，没有数据库、没有服务端、没有 Dashboard。`openspec init` 之后就能用 |
| **存量优先** | 绝大多数人不是在写全新项目，而是在改已有代码。OpenSpec 从第一天起就为"改存量系统"设计 |

### 1.5 两个核心概念

#### Specs（主规格）

系统当前行为的权威描述——"源真相"（Source of Truth）。它回答的是"系统 **现在** 是怎么运作的"。

#### Changes（变更）

你正在进行的修改——每个功能、每个 Bug 修复独立一个文件夹，互不干扰。它回答的是"我们 **打算怎么改**"。

当一个变更完成并归档后，它里面的规格变化会合并进 specs——主规格因此更新，变更则移入归档目录。

### 1.6 工件（Artifacts）：从"为什么"到"怎么做"

每个变更包含 4 个工件，它们之间有明确的依赖关系：

```
proposal.md  →  specs/  →  design.md  →  tasks.md
 为什么做？     做什么？     怎么做？       具体步骤
```

- **proposal.md**：回答"为什么要做这件事"——动机、范围（做什么和不做什么）、预期收益
- **specs/**：回答"系统行为会怎么改变"——用 Delta Specs 描述新增、修改、删除了哪些行为
- **design.md**：回答"技术上怎么实现"——架构决策、组件设计、技术选型的理由
- **tasks.md**：回答"具体要干哪几件事"——带复选框的实现清单，AI 在 `/opsx:apply` 时逐条执行

这个依赖关系是 **"使能"而不是"门禁"**。你完全可以先写 design 再补 specs，或者直接跳到 tasks。按推荐顺序走效果最好，因为每一步都在为下一步提供信息基础。

### 1.7 Delta Specs：改存量代码的秘密武器

OpenSpec 用 **增量规格（Delta Specs）** 解决了"每次修改就要重写整个系统规格"的问题——你只需要描述"这次改了什么"。

每个变更的 `specs/` 子目录里存放三类变化：

```markdown
## ADDED Requirements
### Requirement: Theme Switching
系统 MUST 提供深色/浅色主题切换功能。

## MODIFIED Requirements
### Requirement: Page Background (MODIFIED)
- 原：系统 MUST 使用固定白色背景（#FFFFFF）
- 新：系统 MUST 根据当前主题设置显示对应的背景色

## REMOVED Requirements
### Requirement: Fixed Color Scheme (REMOVED)
- 原：系统 MUST 使用预设的固定配色方案
- 原因：被新的主题系统取代
```

归档时，这些增量会自动合并进 `openspec/specs/` 主规格——ADDED 的内容追加进去，MODIFIED 的内容替换旧版本，REMOVED 的内容被移除。

### 1.8 Specs 的书写规范

#### 需求（Requirements）

使用 RFC 2119 关键字表达意图强度：

| 关键字 | 含义 |
|--------|------|
| **MUST** | 必须实现，不实现就是 Bug |
| **SHOULD** | 强烈建议，除非有充分理由可以不做 |
| **MAY** | 可选的增强功能 |

示例：
```markdown
### Requirement: Login Authentication
系统 MUST 在用户提供有效凭证时签发 JWT token。
系统 MUST 在凭证无效时返回 401 错误，且不泄露是用户名还是密码错误。
系统 SHOULD 在连续 5 次失败后触发临时锁定。
系统 MAY 支持"记住我"功能以延长 token 有效期。
```

#### 场景（Scenarios）

用 Given/When/Then 格式描述具体测试用例：

```markdown
#### Scenario: Successful Login
Given 用户名 "alice" 存在且密码正确
When 用户提交登录请求
Then 系统返回 200 和有效的 JWT token
And token 有效期为 24 小时
```

**重要原则**：specs 只描述外部可观察的行为，不描述内部实现。判断标准：如果你把底层实现换了，但系统对外的行为没有任何变化，那这个东西就不该出现在 specs 里。

### 1.9 渐进式严格

OpenSpec 官方推荐"渐进式严格"——先轻后重：

- **日常开发（Lite Spec）**：大多数变更只需要简短的行为描述、清晰的范围界定和基本的验收条件
- **高风险变更（Full Spec）**：涉及跨团队协作、API 变更、数据迁移等场景时，值得写更详尽的规格——完整的 Given/When/Then 场景、边界条件分析、错误处理路径

判断标准：**如果这个变更搞砸了的返工成本很高，就多花点时间写规格；如果改错了 5 分钟就能修好，那写个大概就够了。**

---

## 二、安装与初始化

### 2.1 前置要求

- **Node.js 20.19.0+**

### 2.2 安装 OpenSpec CLI

```bash
npm install -g @fission-ai/openspec@latest
```

### 2.3 初始化项目

```bash
cd your-project
openspec init
```

初始化时 CLI 会问你使用哪些 AI 工具（Claude Code、Cursor、Copilot 等），然后自动往对应目录写入 Skill 和斜杠命令文件。

**非交互式初始化**（适合 CI/CD 或脚本）：
```bash
# 配置特定工具
openspec init --tools claude,cursor

# 配置所有支持的工具
openspec init --tools all

# 跳过工具配置
openspec init --tools none

# 强制清理旧文件
openspec init --force
```

**支持的工具 ID**：`amazon-q`, `antigravity`, `auggie`, `bob`, `claude`, `cline`, `codex`, `forgecode`, `codebuddy`, `continue`, `costrict`, `crush`, `cursor`, `factory`, `gemini`, `github-copilot`, `iflow`, `junie`, `kilocode`, `kimi`, `kiro`, `opencode`, `pi`, `qoder`, `lingma`, `qwen`, `roocode`, `trae`, `windsurf`

### 2.4 配置项目上下文（强烈推荐）

在 `openspec/config.yaml` 里告诉 AI 你的项目是什么样的：

```yaml
# ==============================================
# OpenSpec 全局核心配置文件
# 官方文档：https://www.notemi.cn/openspec-complete-user-guide
# ==============================================

# --------------------------
# 1. 基础核心配置 (必选)
# --------------------------
# 工作流 Schema：固定为 spec-driven (官方标准)
schema: spec-driven
# 配置文件版本 (自动维护，无需修改)
version: 1.0.0
# 配置文件标识 (自动维护，无需修改)
config_id: auto-generated

# --------------------------
# 2. 工作模式配置 (必选)
# --------------------------
# 配置文件：Core / Expanded
# - Core：极简模式，仅4个核心命令
# - Expanded：完整模式，解锁批量归档、并行执行、分步工件
profile: Expanded

# --------------------------
# 3. 全局项目上下文 (核心！给AI的全局信息)
# --------------------------
# 所有 AI 对话/工件生成 自动继承此上下文，无需重复描述
context: |
  技术栈：TypeScript、React 18、Node.js、Express、PostgreSQL
  项目规范：
  - 代码规范：ESLint + Prettier
  - 样式方案：CSS Modules + Tailwind CSS
  - 测试框架：Vitest
  - 目录结构：src/components、src/api、src/hooks、src/utils
  接口规范：RESTful API，统一响应格式 { code, data, msg }
  禁止事项：禁止使用 console.log，统一用 logger 工具

# --------------------------
# 4. 自定义工件校验规则 (可选)
# 强制 AI 生成的 proposal/specs/design/tasks 遵循规范
# --------------------------
rules:
  # 立项文档规则
  proposal:
    - 必须包含：动机、范围(做/不做)、影响模块、回滚方案
    - 字数不低于 100 字
  # 规格文档规则
  specs:
    - 必须使用 RFC 2119 关键字：MUST/SHOULD/MAY
    - 核心需求必须配套 Given/When/Then 测试场景
    - 禁止描述内部实现，仅描述外部行为
  # 技术设计规则
  design:
    - 必须包含：技术选型、核心逻辑、依赖清单
    - 复杂功能需绘制简易架构说明
  # 任务清单规则
  tasks:
    - 任务颗粒度：单任务≤10分钟工作量
    - 必须标注依赖关系、操作文件路径
    - 禁止模糊描述（如：优化代码）

# --------------------------
# 5. 任务执行引擎配置 (重点：tasks.md 并行执行)
# --------------------------
execution:
  # ========== 并行执行核心开关 ==========
  # 开启 tasks.md 内部任务并行 (true/false)
  enable_parallel: true
  # 默认最大并发任务数 (推荐 2~4，避免AI过载)
  parallel_limit: 3
  # 是否遵守任务依赖关系 (@dep)
  respect_dependencies: true
  # 并行组之间是否串行执行 (true=推荐，防止逻辑混乱)
  serial_between_groups: true

  # ========== 执行行为配置 ==========
  # 执行任务时是否自动保存文件
  auto_save: true
  # 执行完成后是否自动校验规格一致性
  auto_verify: true
  # 注：breakpoint_resume 在 v1.0.0 中尚未支持，如需断点续跑请关注后续版本

# --------------------------
# 6. AI 客户端适配配置 (可选)
# 适配 Claude Code / Cursor / Copilot / OpenCode
# --------------------------
ai:
  # 默认AI客户端
  default_client: claude_code
  # 模型参数
  model_params:
    temperature: 0.1  # 低温度=更规范、高温度=更灵活
    max_tokens: 8192
  # 多客户端并行隔离配置
  multi_agent:
    enable_isolation: true  # 多客户端任务强隔离
    # 注：enable_isolation 为 true 时，allow_cross_change 无效，已移除

# --------------------------
# 7. 高级配置 (可选，默认即可)
# --------------------------
advanced:
  # 自定义目录路径 (默认无需修改)
  # 注：如 config.yaml 位于 openspec/ 目录下，可使用相对路径
  dirs:
    specs: ./specs
    changes: ./changes
    archive: ./archive
  # 格式化配置
  format:
    markdown_line_length: 120
    auto_format_files: true
  # 校验严格等级：loose / standard / strict
  validation_level: standard
  # 日志等级：error / warn / info / debug
  log_level: info
```

- `context` 会注入到 **所有** 工件的生成过程中——相当于一次配置，以后再也不用在对话开头反复交代技术栈了
- `rules` 是针对特定工件类型的额外要求

可以让 AI 先生成，然后自己修改：
```
Please read openspec/config.yaml and help me fill it out with details about my project, tech stack, and conventions，请使用中文，后续所有的spec都使用中文编写。
```

### 2.5 启用扩展命令

默认只安装了 4 个核心命令（`propose`、`explore`、`apply`、`archive`）。解锁完整命令集：

```bash
openspec config profile
openspec update
```

选择 **Expanded Profile** 后，`new`、`continue`、`ff`、`verify`、`sync`、`bulk-archive`、`onboard` 等高级命令就可以用了。

---

## 三、命令列表

OpenSpec 的命令分为 **两层体系**：

### 3.1 第一层：CLI 命令（终端操作）

用于项目管理、配置和状态查看。

| 命令 | 用途 | 示例 |
|------|------|------|
| `openspec init` | 初始化项目 | `openspec init --tools claude,cursor` |
| `openspec update` | 升级并刷新项目配置 | `openspec update` |
| `openspec list` | 查看活跃变更和规格 | `openspec list --specs` |
| `openspec view` | 查看特定变更详情 | `openspec view <change-id>` |
| `openspec show` | 显示规格内容 | `openspec show <spec-path>` |
| `openspec validate` | 检查变更和规格是否有问题 | `openspec validate <change-id> --strict` |
| `openspec archive` | 归档已完成变更 | `openspec archive <change-id> --yes` |
| `openspec status` | 查看工作流状态 | `openspec status --change <name>` |
| `openspec config` | 查看和修改配置 | `openspec config profile` |
| `openspec schema init` | 创建自定义 Schema | `openspec schema init my-schema` |
| `openspec schema fork` | 复制默认 Schema 并修改 | `openspec schema fork spec-driven research-first` |
| `openspec schema validate` | 验证 Schema 合法性 | `openspec schema validate my-schema` |
| `openspec workspace setup` | 设置跨仓库工作区（beta） | `openspec workspace setup` |
| `openspec feedback` | 提交反馈 | `openspec feedback` |
| `openspec completion` | Shell 补全配置 | `openspec completion bash` |

### 3.2 第二层：AI 工作流命令（对话中调用）

在 Claude Code、Cursor、Windsurf 等 AI 工具对话里调用，让 AI 进入具体工作流动作。

#### 核心工作流命令（Core Profile，默认启用）

| 命令 | 功能定位 | 作用说明 |
|------|----------|----------|
| `/opsx:propose` | 创建变更 + 生成所有规划制品 | 一步创建变更目录，生成 proposal.md、specs/、design.md、tasks.md |
| `/opsx:explore` | 纯思考模式 | 梳理思路、调研方案、明确需求，不写代码 |
| `/opsx:apply` | 执行变更任务 | 读取 tasks.md，逐条实现代码，更新复选框 |
| `/opsx:archive` | 归档已完成变更 | 将变更移入 archive/，合并 delta specs 到主规格 |

#### 扩展工作流命令（Expanded Profile，需手动开启）

| 命令 | 功能定位 | 作用说明 | 适用场景 |
|------|----------|----------|----------|
| `/opsx:new` | 新建变更脚手架 | 只创建 change 目录与元数据，不一次生成全部 artifacts | 想手动控制规划节奏 |
| `/opsx:continue` | 逐个生成下一个制品 | 按依赖链（proposal → specs → design → tasks）一次只生成一个工件 | 复杂需求、想逐步评审 |
| `/opsx:ff` | 快进生成所有规划制品 | 按依赖顺序自动完成 proposal/specs/design/tasks | 已确定范围，想走 expanded 路线 |
| `/opsx:verify` | 验证实现与工件一致性 | 从完整性、正确性、一致性三个维度检查实现 | 归档前质量把关 |
| `/opsx:sync` | 手动同步 delta specs | 把 change 下的增量规格合并进主 specs，但不归档 | 长周期 change、并行 change 依赖最新规格 |
| `/opsx:bulk-archive` | 批量归档多个变更 | 校验多个变更并处理 spec 冲突 | 多任务并行后统一收口 |
| `/opsx:onboard` | 引导式上手教程 | 用真实代码库跑一遍完整 OpenSpec workflow | 新成员培训、团队试点 |

### 3.3 遗留命令（Legacy Commands）

使用旧的"all-at-once"工作流，仍然兼容：

| 命令 | 说明 |
|------|------|
| `/openspec:proposal` | 一次创建所有制品（proposal、specs、design、tasks） |
| `/openspec:apply` | 实现变更 |
| `/openspec:archive` | 归档变更 |

---

## 四、各种开发场景详细使用流程

### 4.1 场景一：快速路径（日常小功能）

适合简单功能开发、Bug 修复等日常场景。

```
/opsx:propose <需求描述>
/opsx:apply
/opsx:sync # 可选步骤，opsx:archive时会提示进行sync
/opsx:archive
```

**详细步骤**：

1. **立项**：`/opsx:propose 添加用户暗黑模式切换功能`
   - AI 自动创建 `openspec/changes/add-dark-mode/` 目录
   - 生成 proposal.md（动机、范围、预期收益）
   - 生成 specs/ 下的 Delta Specs（ADDED/MODIFIED/REMOVED）
   - 生成 design.md（技术方案）
   - 生成 tasks.md（带复选框的任务清单）
   - AI 停止并等待你确认

2. **确认**：阅读 proposal.md 和 specs/，确认范围正确。如需调整，直接修改文件或告诉 AI 重新生成。

3. **实现**：`/opsx:apply`
   - AI 读取 tasks.md 和 design.md
   - 逐条执行任务，勾选复选框
   - 实现过程中可参考 openspec/specs/ 了解现有系统行为

4. **归档**：`/opsx:archive`
   - AI 将 `changes/add-dark-mode/` 移入 `changes/archive/YYYY-MM-DD-add-dark-mode/`
   - 将 Delta Specs 合并进 `openspec/specs/`
   - 更新主规格文件

### 4.2 场景二：先调研再实施（复杂功能）

适合技术方案不明确、需要调研的复杂功能。

```
/opsx:explore
/opsx:propose <change>
/opsx:apply
/opsx:sync # 可选步骤，opsx:archive时会提示进行sync
/opsx:archive
```

**详细步骤**：

1. **探索**：`/opsx:explore 调研前端状态管理方案：Redux vs Zustand vs Jotai`
   - AI 不写代码，只进行调研分析
   - 输出调研报告，对比各方案优缺点
   - 给出推荐方案及理由

2. **立项**：基于调研结果，`/opsx:propose 迁移状态管理到 Zustand`
   - 生成完整规划制品

3. **实现与归档**：同场景一

### 4.3 场景三：扩展路径（复杂项目、团队协作）

适合需要精细控制、多人协作、高风险变更。

```
# 开启扩展模式
openspec config profile
openspec update

# 用到的命令
/opsx:new <change>
/opsx:continue  # 或 /opsx:ff
/opsx:apply
/opsx:verify
/opsx:archive
```

**详细步骤**：

1. **新建变更脚手架**：`/opsx:new 重构支付模块`
   - 只创建目录结构和 `.openspec.yaml` 元数据
   - 不生成任何工件

2. **逐步生成制品**：`/opsx:continue`
   - 第一次执行：生成 proposal.md → 停止等待确认
   - 第二次执行：生成 specs/ → 停止等待确认
   - 第三次执行：生成 design.md → 停止等待确认
   - 第四次执行：生成 tasks.md → 停止等待确认
   - 每步都可人工审查、修改后再继续

   或者使用 `/opsx:ff` 一次生成所有规划制品（类似 `/opsx:propose`）

3. **实现**：`/opsx:apply`

4. **验证**：`/opsx:verify`
   - AI 检查实现是否与 proposal、specs、design、tasks 一致
   - 从完整性、正确性、一致性三个维度检查
   - 输出验证报告，指出偏差

5. **归档**：`/opsx:archive`

### 4.4 场景四：并行开发多个功能

OpenSpec 的 Changes 设计天然支持并行开发。

```
# 功能 A
/opsx:propose 添加用户评论功能

# 功能 B（在同一对话或新对话中）
/opsx:propose 优化图片加载性能

# 分别实现
/opsx:apply user-comment-feature
/opsx:apply optimize-image-loading

# 分别归档
/opsx:archive user-comment-feature
/opsx:archive optimize-image-loading
```

**关键点**：
- 两个变更各自在独立的 `changes/` 子目录中工作
- 互不干扰 specs
- 归档时分别合并到主规格
- 如存在冲突，`/opsx:bulk-archive` 可批量处理

### 4.5 场景五：长周期变更 + 中途同步规格

适合开发周期较长、需要与主线保持同步的变更。

```
/opsx:new 大规模重构订单系统
/opsx:ff
/opsx:apply

# 中途主规格有更新（其他变更已归档）
/opsx:sync
# AI 将其他变更已合并到主规格的最新状态同步到当前变更的参考中

/opsx:apply  # 继续实现
/opsx:verify
/opsx:archive
```

### 4.6 场景六：存量项目首次接入 OpenSpec

适合已有代码库、从未写过规格的项目。

```
# 1. 初始化
openspec init

# 2. 配置上下文（关键！）
# 编辑 openspec/config.yaml，写入技术栈、架构、规范

# 3. 让 AI 分析现有代码，生成初始规格
/opsx:onboard
# 或手动：
/opsx:explore 分析当前项目结构，帮我生成初始规格文档

# 4. 从第一个小变更开始
/opsx:propose 修复登录页面的样式错位
/opsx:apply
/opsx:archive
```

**关键策略**：
- 不需要先给整个系统写完整规格
- 直接从第一个变更开始，specs 会随着归档逐渐积累
- 使用 `/opsx:onboard` 可跑一遍完整教程（约 15 分钟，11 个阶段）

### 4.7 场景七：Bug 修复

```
/opsx:propose 修复用户登出后缓存未清空的问题
```

**proposal.md 示例**：

```markdown
# Proposal: Fix Cache Not Cleared on Logout

## Motivation
用户登出后，本地缓存中仍保留敏感数据，可能导致安全风险。

## Scope
### In Scope
- 登出时清空 localStorage 中的用户相关缓存
- 登出时清空内存中的用户状态

### Out of Scope
- 服务端会话清理（已在服务端处理）
- 第三方登录的缓存清理

## Expected Benefit
消除用户登出后的数据残留风险。
```

**specs/ 示例**：
```markdown
## ADDED Requirements

### Requirement: Cache Cleanup on Logout
系统 MUST 在用户点击登出按钮后，清空 localStorage 中所有以 `user_` 为前缀的键。
系统 MUST 在登出后重置内存中的用户状态树为初始值。

#### Scenario: Successful Logout
Given 用户已登录且 localStorage 中有 `user_token` 和 `user_profile`
When 用户点击登出按钮
Then 系统清空 localStorage 中的 `user_token` 和 `user_profile`
And 内存中的用户状态树重置为初始值
And 页面跳转至登录页
```

---

## 五、流程中的目录结构与输出文件解析

### 5.1 整体目录结构

```
your-project/
├── openspec/
│   ├── specs/                          # 主规格（系统当前行为的源真相）
│   │   ├── auth/
│   │   │   └── spec.md                 # 认证模块的当前行为
│   │   ├── payments/
│   │   │   └── spec.md                 # 支付模块的当前行为
│   │   └── ui/
│   │       └── spec.md                 # UI 模块的当前行为
│   ├── changes/                        # 活跃变更
│   │   ├── add-dark-mode/              # 变更：添加暗黑模式
│   │   │   ├── .openspec.yaml          # 变更元数据（可选）
│   │   │   ├── proposal.md             # 提案：为什么做、做什么
│   │   │   ├── design.md               # 设计：技术方案
│   │   │   ├── tasks.md                # 任务：实现清单
│   │   │   └── specs/                  # 增量规格
│   │   │       └── ui/
│   │   │           └── spec.md         # UI 模块的 Delta Specs
│   │   ├── fix-login-bug/              # 变更：修复登录 Bug
│   │   │   ├── proposal.md
│   │   │   ├── design.md
│   │   │   ├── tasks.md
│   │   │   └── specs/
│   │   │       └── auth/
│   │   │           └── spec.md
│   │   └── archive/                    # 归档变更
│   │       └── 2026-05-17-add-dark-mode/
│   │           ├── proposal.md
│   │           ├── design.md
│   │           ├── tasks.md
│   │           └── specs/
│   ├── config.yaml                     # 项目配置（技术栈、规则）
│   └── schemas/                        # 自定义 Schema（可选）
├── .claude/                            # Claude Code 集成（示例）
│   ├── commands/opsx/
│   │   ├── apply.md
│   │   ├── archive.md
│   │   ├── explore.md
│   │   └── propose.md
│   └── skills/
│       ├── openspec-apply-change/SKILL.md
│       ├── openspec-archive-change/SKILL.md
│       ├── openspec-explore/SKILL.md
│       └── openspec-propose/SKILL.md
└── src/                                # 你的项目代码
```

### 5.2 各目录/文件详解

#### `openspec/specs/` — 主规格（Source of Truth）

- **用途**：描述系统 **现在** 是怎么运作的
- **组织方式**：按能力（capability）组织，如 `auth/`、`payments/`、`ui/`，而非按变更或 ticket
- **更新时机**：仅在 `/opsx:archive` 时由 Delta Specs 自动合并更新
- **阅读价值**：任何团队成员随时打开，就能知道系统当前的确切行为

#### `openspec/changes/` — 活跃变更

- **用途**：存放正在开发中的变更，每个变更一个独立文件夹
- **命名建议**：使用简洁的 kebab-case，如 `add-dark-mode`、`fix-login-bug`、`refactor-payment-gateway`
- **并行开发**：多个变更可同时存在，互不干扰

#### `openspec/changes/archive/` — 归档变更

- **用途**：存放已完成的变更，保留完整历史上下文
- **命名格式**：`YYYY-MM-DD-<change-name>/`
- **价值**：不仅是代码历史，更是决策历史——你能看到"当时为什么这么做"

#### `openspec/config.yaml` — 项目配置

具体配置参考 **[配置项目上下文（强烈推荐）](#24-配置项目上下文强烈推荐)**

#### `.openspec.yaml` — 变更元数据（可选）

```yaml
id: add-dark-mode
status: in-progress
created: 2026-05-17
author: developer-name
priority: high
```

### 5.3 工件文件详解

#### `proposal.md` — 提案

```markdown
# Proposal: Add Dark Mode Support

## Motivation
用户反馈在夜间使用应用时界面过亮，影响体验。添加暗黑模式可提升用户留存率。

## Scope
### In Scope
- 深色/浅色主题切换开关
- 跟随操作系统主题设置
- 主题选择持久化到 localStorage

### Out of Scope
- 自定义主题色（如"粉色模式"）
- 服务端主题同步

## Expected Benefit
- 提升夜间使用体验
- 符合现代应用设计趋势
```

**核心要素**：
- **Motivation**：为什么要做？（业务价值、用户痛点）
- **Scope**：明确边界，防止范围蔓延
  - In Scope：这次要做什么
  - Out of Scope：这次不做什么（同样重要！）
- **Expected Benefit**：预期收益，用于事后评估

#### `specs/<domain>/spec.md` — 增量规格

```markdown
## ADDED Requirements

### Requirement: Theme Switching
系统 MUST 提供深色/浅色主题切换功能。
系统 SHOULD 支持跟随操作系统主题设置。

#### Scenario: Manual Theme Switch
Given 用户当前使用浅色主题
When 用户点击主题切换开关
Then 界面切换为深色主题
And 选择结果持久化到 localStorage

#### Scenario: System Theme Follow
Given 用户设备设置为深色模式
When 用户首次访问应用
Then 界面自动使用深色主题

## MODIFIED Requirements

### Requirement: Page Background (MODIFIED)
- 原：系统 MUST 使用固定白色背景（#FFFFFF）
- 新：系统 MUST 根据当前主题设置显示对应的背景色

## REMOVED Requirements

### Requirement: Fixed Color Scheme (REMOVED)
- 原：系统 MUST 使用预设的固定配色方案
- 原因：被新的主题系统取代
```

**核心要素**：
- **ADDED**：新增的行为需求
- **MODIFIED**：修改的行为需求（必须标注原内容和新内容）
- **REMOVED**：移除的行为需求（必须说明原因）
- **Scenario**：Given/When/Then 格式的可验证场景

#### `design.md` — 设计方案

```markdown
# Design: Dark Mode Implementation

## Architecture Decision
使用 CSS 变量 + data-attribute 方案，而非 CSS-in-JS 或两套样式文件。

理由：
- CSS 变量切换无运行时开销
- 与现有 Tailwind CSS 集成良好
- 支持跟随系统主题的媒体查询

## Component Design
### ThemeProvider
- 读取 localStorage 中的主题偏好
- 监听系统主题变化（matchMedia）
- 通过 React Context 向下传递当前主题

### ThemeToggle
- 开关组件，调用 ThemeProvider 的切换方法
- 显示当前主题图标（太阳/月亮）

## Data Flow
1. 应用启动时，ThemeProvider 初始化主题状态
2. 用户点击 ThemeToggle → 更新 Context → 更新 data-attribute
3. CSS 变量根据 data-attribute 自动切换
4. 同时持久化到 localStorage

## Edge Cases
- 首次访问无 localStorage 数据时，默认跟随系统主题
- 系统主题切换时，若用户未手动设置过偏好，则自动跟随
```

**核心要素**：
- **Architecture Decision**：关键架构决策及理由
- **Component Design**：组件/模块设计
- **Data Flow**：数据流描述
- **Edge Cases**：边界情况处理

#### `tasks.md` — 任务清单

```markdown
# Tasks: Dark Mode Implementation

## Phase 1: Infrastructure
- [ ] T001: 在 tailwind.config.js 中定义 dark 模式配色变量
- [ ] T002: 创建 ThemeProvider 组件，管理主题状态
- [ ] T003: 创建 useTheme hook，供各组件读取主题

## Phase 2: UI Components
- [ ] T004: 创建 ThemeToggle 开关组件
- [ ] T005: 在 Header 中集成 ThemeToggle
- [ ] T006: 更新所有硬编码颜色为 CSS 变量

## Phase 3: Integration
- [ ] T007: 添加系统主题监听（matchMedia）
- [ ] T008: 实现 localStorage 持久化
- [ ] T009: 编写单元测试（ThemeProvider、ThemeToggle）

## Phase 4: Verification
- [ ] T010: 手动测试浅色/深色/跟随系统三种模式
- [ ] T011: 验证刷新页面后主题偏好保持
```

**核心要素**：
- **Phase 分组**：按逻辑阶段组织任务
- **Task ID**：如 T001、T002，便于追踪和引用
- **Checkbox**：`- [ ]` 格式，AI 实现后勾选 `- [x]`
- **可验证性**：每个任务完成后应能独立验证

### 5.4 归档时的合并逻辑

当执行 `/opsx:archive` 时，OpenSpec 执行以下操作：

1. **解析 Delta Specs**：读取 `changes/<name>/specs/` 下的 ADDED、MODIFIED、REMOVED 标记
2. **合并到主规格**：
   - ADDED → 追加到 `openspec/specs/<domain>/spec.md`
   - MODIFIED → 替换主规格中对应需求
   - REMOVED → 从主规格中删除对应需求
3. **移动目录**：将 `changes/<name>/` 移入 `changes/archive/YYYY-MM-DD-<name>/`
4. **语义级合并**：基于需求级别解析，而非简单的文本匹配，避免冲突

---

## 六、与 Spec Kit、GSD、Superpowers 等工具的对比

### 6.1 五款工具一句话定位

| 工具 | 核心定位 | 一句话描述 |
|------|----------|------------|
| **OpenSpec** | 增量变更管理 | 围绕一次变更生成 proposal、tasks、design 和 spec delta，让评审者先看"意图和需求如何变化"，再看代码 |
| **Spec Kit** | 规格驱动方法论工具包 | GitHub 出品的严格顺序流程工具（constitution → specify → plan → tasks → implement），强调规格先行 |
| **GSD** | 长任务执行增强 | 把开发拆成 initialize、discuss、plan、execute、verify、ship 等循环，适合大型多阶段任务 |
| **Superpowers** | 完整开发方法论 | 将 brainstorming、规格澄清、计划、TDD、子代理执行、验证和审查组织成一套可复用的方法论 |
| **planning-with-files** | 轻量持久化上下文 | 用 `task_plan.md`、`findings.md`、`progress.md` 三个文件把 Agent 的工作记忆写入磁盘 |

### 6.2 详细对比表

| 维度 | OpenSpec | Spec Kit | GSD | Superpowers |
|------|----------|----------|-----|-------------|
| **核心能力** | 规格驱动、增量变更、需求/设计/任务沉淀 | 规格驱动方法论、严格阶段流程 | 执行增强、上下文治理、长任务推进 | 多 agent、完整开发闭环、skills 生态 |
| **适合场景** | 存量项目增量变更、需求评审、多人协作 | 绿场项目、功能开发、遗留系统现代化 | 重构升级、复杂实现、大仓库治理 | 能力扩展、插件生态、多代理协作 |
| **流程严格度** | 灵活（使能而非门禁） | 严格（必须按顺序执行） | 中等（分阶段但可调整） | 中等（完整闭环但可裁剪） |
| **存量项目友好度** | ⭐⭐⭐⭐⭐（Delta Specs 专为存量设计） | ⭐⭐⭐（支持但流程偏绿场） | ⭐⭐⭐⭐（支持 brownfield） | ⭐⭐⭐⭐（支持但偏重流程） |
| **学习成本** | 中 | 中 | 中 | 中到高 |
| **团队落地难度** | 中 | 中 | 中 | 中到高 |
| **Token 消耗** | 低（聚焦变更，不重复描述系统） | 中（每次从 constitution 开始） | 高（多轮对话、分阶段执行） | 中到高（完整流程覆盖） |
| **并行开发支持** | ⭐⭐⭐⭐⭐（Changes 天然隔离） | ⭐⭐⭐（单线流程） | ⭐⭐⭐（waves 机制） | ⭐⭐⭐⭐（subagent 分工） |
| **AI 工具支持** | 30+（Claude、Cursor、Copilot 等） | 30+（GitHub 官方支持） | 多工具 | 多工具 |
| **企业团队适配** | 很适合 | 很适合 | 很适合 | 适合，但不建议首上 |
| **推荐阶段** | 第一阶段（规范建设） | 第一阶段参考 / 第二阶段补充 | 第二阶段 | 第三阶段 |

### 6.3 各工具深度解析

#### OpenSpec

**优势**：
- **Delta Specs 机制**：改存量代码时只需描述"这次改了什么"，不需要重写整个系统规格
- **Changes 隔离**：多个变更可同时推进互不冲突，归档时自动合并
- **渐进式严格**：日常开发写 Lite Spec，高风险变更写 Full Spec，灵活适应不同场景
- **轻量级**：无数据库、无服务端，就是 Markdown 文件

**劣势**：
- 绿场项目（全新项目）需要特殊处理，不能像存量项目那样直接用 Delta Specs
- 对"变更意图"的规格化很专注，但对执行阶段的控制不如 GSD/Superpowers 精细

**最佳实践**：
- 适合已有代码库的团队接入
- 与 planning-with-files 叠加使用，解决记忆 + 变更管理两层问题

#### Spec Kit

**优势**：
- **GitHub 官方出品**：与 Copilot Workspaces 深度集成，生态完善
- **Constitution 机制**：项目级别的"宪法"文件，确保所有 AI 交互遵循同一套原则
- **严格问责链**：Constitution → Specification → Plan → Tasks → Implementation，每步都有验证
- **analyze 命令**：跨工件一致性检查，发现矛盾和遗漏

**劣势**：
- 流程严格，不能跳过步骤（如必须先 `/speckit.specify` 才能 `/speckit.plan`）
- 每次变更都从 constitution 开始，对存量小变更略显沉重
- 没有 Delta Specs 机制，改存量系统时需要更多手动处理

**最佳实践**：
- 适合从零开始的新项目，或需要统一团队方法论的场景
- 与 OpenSpec 组合：Spec Kit 做"方法论建设"，OpenSpec 做"日常变更管理"

#### GSD（Get Shit Done）

**优势**：
- **长任务治理**：把大型任务拆成 phase，每阶段结束可人工检查、批准后再继续
- **Fresh Context**：每阶段结束后可清理上下文，避免长对话的"失忆"问题
- **并行 Waves**：支持多 wave 并行执行，提升效率
- **原子提交**：每个 task 对应一个 commit，历史清晰

**劣势**：
- Token 消耗大（实测完成同样功能，GSD 需要 3 个完整 session，OpenSpec 只需 1 个）
- 对话式交互多，需要开发者频繁参与决策
- 对简单变更显得过于沉重

**最佳实践**：
- 适合大型重构、多阶段复杂功能
- 与 OpenSpec 组合：GSD 管"大任务拆分"，OpenSpec 管"每个小变更的规格"

#### Superpowers

**优势**：
- **完整闭环**：从 brainstorming 到 finishing 覆盖整个开发周期
- **TDD 内置**：强调 red/green TDD、YAGNI、DRY
- **子代理分工**：subagent-driven-development 支持并行任务
- **验证与审查**：verification/review 流程内建

**劣势**：
- 学习成本和落地难度较高
- 对"变更意图"的规格化不如 OpenSpec 专注
- 首次用户体验虽好，但在无尽的重构循环中可能消耗大量 token

**最佳实践**：
- 适合希望给 Agent 一套默认工程流程的团队
- 不建议作为首个接入的工具，建议在团队已有一定规范基础后引入

### 6.4 选型决策树

```
你的 Agent 当前最常失败在哪里？
│
├─ "做着做着忘了目标" → planning-with-files（三文件持久化记忆）
│
├─ "还没理解需求就开始写代码" → mattpocock/skills / Superpowers（grill + brainstorming）
│
├─ "已有系统的增量变更难评审" → OpenSpec（Delta Specs + Changes 隔离）
│
├─ "大型任务分阶段推进失控" → GSD（phase + waves + 原子提交）
│
├─ "写完就算完成，没测试/审查" → Superpowers / mattpocock/skills（TDD + debug + review）
│
└─ "多 Agent 并行协作混乱" → GSD / Superpowers（subagent 分工）
```

### 6.5 推荐组合方案

#### 轻量个人开发者
```
planning-with-files + mattpocock/skills
```
- planning-with-files 负责外置记忆
- mattpocock/skills 负责需求澄清、TDD 和诊断

#### Brownfield 团队（已有代码库）
```
OpenSpec + planning-with-files + TDD/debug skills
```
- OpenSpec 管理"本次改什么"
- planning-with-files 记录调研和执行进度
- TDD/debug skills 保障实现质量

#### 大型功能或项目级开发
```
GSD 或 Superpowers + OpenSpec
```
- 任务非常长、阶段很多、需要多 Agent 并行 → 选 GSD
- 更希望给 Agent 一套默认工程流程 → 选 Superpowers
- 涉及多人评审或需求边界复杂 → 叠加 OpenSpec 管理变更意图

---

## 附录：快速参考卡片

### 命令速查表

| 你想做什么 | 用什么命令 |
|------------|------------|
| 初始化项目 | `openspec init` |
| 开启扩展命令 | `openspec config profile` → `openspec update` |
| 快速开发一个功能 | `/opsx:propose` → `/opsx:apply` → `/opsx:archive` |
| 先调研再开发 | `/opsx:explore` → `/opsx:propose` → `/opsx:apply` → `/opsx:archive` |
| 精细控制每步 | `/opsx:new` → `/opsx:continue` ×4 → `/opsx:apply` → `/opsx:verify` → `/opsx:archive` |
| 一次生成所有规划 | `/opsx:ff` |
| 归档前检查质量 | `/opsx:verify` |
| 批量归档多个变更 | `/opsx:bulk-archive` |
| 新成员学习流程 | `/opsx:onboard` |
| 查看项目状态 | `openspec list` / `openspec status` |
| 验证规格合法性 | `openspec validate <change-id>` |

### 目录结构速记

```
openspec/
├── specs/          ← 系统现在是什么样的（源真相）
├── changes/          ← 我们打算改什么（活跃变更）
│   └── archive/      ← 我们已经改完了什么（历史归档）
└── config.yaml       ← 项目上下文和规则
```

### 工件依赖链

```
proposal.md（为什么）
    ↓
specs/（做什么）
    ↓
design.md（怎么做）
    ↓
tasks.md（具体步骤）
    ↓
/opsx:apply（执行）
    ↓
/opsx:archive（归档 + 合并规格）
```

---

> **最后提醒**：OpenSpec 不是银弹。它解决的是"AI 对话上下文丢失导致的需求对齐问题"。如果你的痛点不在这里，可能不需要它。但如果每次和 AI 合作都觉得"沟通成本比写代码还高"——OpenSpec 可能就是那块缺失的拼图。
