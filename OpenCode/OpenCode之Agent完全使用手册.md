# OpenCode Agent 完全使用手册

> 本手册全面解析 OpenCode 的 Agent 体系，包括内置 Agent、自定义 Agent、权限配置、交互调用及多 Agent 实战，助你构建高效、安全的 AI 编程工作流。

---

## 目录

1. [核心概念](#一核心概念)
2. [内置 Agent 详解](#二内置-agent-详解)
3. [自定义 Agent 完全指南](#三自定义-agent-完全指南)
4. [权限配置 permission 详解](#四权限配置-permission-详解)
5. [Agent 交互与调用机制](#五agent-交互与调用机制)
6. [agent调用slash命令跟skill技能](#六agent调用slash命令跟skill技能)
7. [全套实战案例](#七全套实战案例)
8. [最佳实践建议](#八最佳实践建议)
9. [总结](#九总结)

---

## 一、核心概念

### 1.1 Agent 核心类型

OpenCode 内置了一套完整的**主代理 (Primary Agent) + 子代理 (Subagent)** 协作体系，通过专业化分工与权限隔离实现高效、安全的 AI 编程工作流。

| 类型 | 角色定位 | 交互方式 | 权限特点 |
|------|----------|----------|----------|
| **Primary Agent** | 主助手，顶层调度者 | Tab 键切换，会话入口 | 可配置全权限或受限权限 |
| **Subagent** | 专业助手，专项执行 | @提及调用，主 Agent 自动调用 | 独立会话，上下文隔离 |
| **System Agent** | 后台服务，自动运行 | 不可直接交互 | 系统级权限，专注特定功能 |

### 1.2 设计理念

- **专业化分工**：不同 Agent 专注不同任务类型（构建、规划、探索等）
- **权限隔离**：细粒度权限控制，防止意外修改，提升安全性
- **上下文保护**：子 Agent 拥有独立会话，避免主会话上下文被细节占用
- **灵活协作**：主 Agent 可并行调用多个子 Agent，实现复杂任务分布式处理

### 1.3 核心底层规则

1. **单向调度**：仅 `Primary` 主动调用 `Subagent`，**子代理不能反向调用主代理**
2. **会话隔离**：Subagent 拥有**独立子会话**，上下文完全隔离，不污染主会话 Token
3. **权限独立**：两者 `tools` / `permission` / `model` / 指令完全独立，互不继承
4. **文件共享**：权限隔离，但**项目本地文件互通**，可互相读写同一工程
5. **禁止嵌套**：Subagent 不允许再调用其他 Subagent，只有主代理具备调度权限

---

## 二、内置 Agent 详解

OpenCode 内置了一套完整的主代理 (Primary Agent)+ 子代理 (Subagent) 协作体系，核心包括4 个可交互 Agent与3 个隐藏系统 Agent，通过专业化分工与权限隔离实现高效、安全的 AI 编程工作流。

### 2.1 主代理 (Primary Agents)

内置两个主代理，通过 **Tab 键** 循环切换。

#### 🔨 Build Agent（默认主代理）

| 属性 | 说明 |
|------|------|
| 模式 | `primary`，默认激活 |
| 核心定位 | 全功能开发主力，适合执行完整开发工作流 |
| 权限设置 | 启用所有工具（write、edit、bash、task 等），默认 `ask` 模式需用户确认关键操作 |
| 适用场景 | 编写/修改代码文件、执行系统命令（npm install、git commit 等）、调用子 Agent 处理专项任务、完整项目构建与部署流程 |
| 温度建议 | 0.3-0.5（平衡确定性与创造性） |

#### 📋 Plan Agent（规划分析代理）

| 属性 | 说明 |
|------|------|
| 模式 | `primary`，通过 Tab 键切换激活 |
| 核心定位 | 只读规划专家，专注分析不执行修改 |
| 权限设置 | 默认禁用所有修改性操作（write、edit、bash 设为 `ask`） |
| 适用场景 | 需求分析与技术方案制定、代码审查与优化建议、复杂问题推理与解决思路规划、项目架构设计评审 |
| 温度建议 | 0.0-0.2（高度确定性，适合分析推理） |

### 2.2 子代理 (Subagents)

#### 🌐 General Agent（通用任务代理）

| 属性 | 说明 |
|------|------|
| 模式 | `subagent`，通过 `@general` 调用 |
| 核心定位 | 多面手，处理复杂多步骤任务 |
| 权限设置 | 完整工具访问权限（除 todo 外），可修改文件 |
| 适用场景 | 研究复杂技术问题、执行多步骤数据处理任务、并行运行多个工作单元、跨文件代码重构辅助 |
| 特点 | 可创建独立子会话，支持并行任务执行 |

#### 🔍 Explore Agent（代码探索代理）

| 属性 | 说明 |
|------|------|
| 模式 | `subagent`，通过 `@explore` 调用 |
| 核心定位 | 代码库搜索专家，只读快速扫描 |
| 权限设置 | 完全只读，无法修改任何文件 |
| 适用场景 | 按模式查找文件、搜索代码中的关键字/函数、分析项目结构与依赖关系、快速回答关于现有代码的问题 |
| 特点 | 轻量级，执行速度快，不占用主会话上下文 |

### 2.3 隐藏系统 Agent

| Agent 名称 | 功能 | 触发方式 |
|-----------|------|----------|
| **Compaction** | 长上下文压缩成摘要 | 自动运行（上下文过长时） |
| **Title** | 生成会话简短标题 | 自动运行（会话创建/更新时） |
| **Summary** | 创建会话完整摘要 | 自动运行（会话结束时） |

这些 Agent 在 UI 中不可见，仅在后台执行系统级任务。

---

## 三、自定义 Agent 完全指南

### 3.1 配置文件位置

OpenCode 会**自动扫描**以下目录加载自定义 Agent，优先级：**项目级 > 全局级 > 内置 Agent**

1. **✅ 项目级（推荐）**：
   ```
   你的项目/.opencode/agents/
   ```
   该目录下的所有 `.md`/`.json` 文件都会被识别为自定义 Agent

2. **🌍 全局级**：系统配置目录（所有项目共享），适合通用型 Agent

### 3.2 两种配置格式

| 格式 | 优点 | 适用场景 |
|------|------|----------|
| **Markdown** | 极简语法、配置 + 角色指令分离、易维护 | 90% 的自定义场景 |
| **JSON** | 批量配置、兼容旧版 | 复杂批量管理 |

### 3.3 核心配置项

#### 必填配置（缺一不可）

| 字段 | 说明 | 可选值 |
|------|------|--------|
| `description` | Agent 功能描述（用于识别、搜索） | 字符串 |
| `mode` | Agent 类型 | `primary`（主代理）/ `subagent`（子代理） |

#### 常用可选配置

| 字段 | 说明 | 默认值/示例 |
|------|------|-------------|
| `name` | 自定义调用名称 | 不填则用文件名 |
| `model` | 指定 AI 模型 | anthropic/claude-3.5-sonnet |
| `temperature` | 输出随机性 | 0.1（严谨）~ 0.7（创意） |
| `steps` | 最大执行步数 | 5（防止无限循环） |
| `hidden` | 是否隐藏子代理 | true/false（隐藏后仅主 Agent 自动调用，无法使用 @ 唤出） |

#### 工具配置（`tools`）

```yaml
tools:
  read: true      # 读取文件
  write: true     # 新建文件
  edit: true      # 修改文件
  bash: true      # 执行终端命令
  webfetch: true  # 联网搜索
  task: true      # 执行任务流
```

### 3.4 Markdown 配置模板（推荐 ✅）

```markdown
---
description: 你的 Agent 描述
mode: subagent  # primary 或 subagent
temperature: 0.1
tools:
  read: true
  write: false
permission:
  bash: deny
---

# 角色指令
你是一个 XX 专属助手，专注于 XX 任务...
遵守以下规则：
1. 只做 XX，不做 XX
2. 输出格式为 XX
```

### 3.5 JSON 配置模板（兼容）

```json
{
  "name": "test-agent",
  "description": "测试自定义 Agent",
  "mode": "subagent",
  "temperature": 0.2,
  "tools": { "read": true, "write": false },
  "permission": { "bash": "ask" },
  "prompt": "你是测试助手，仅回答代码问题"
}
```

### 3.6 常用自定义 Agent 示例

#### 示例 1：代码安全审查 Agent（只读）

文件：`.opencode/agents/security-review.md`

```markdown
---
description: 代码安全与质量审查，只读不修改
mode: subagent
name: review
temperature: 0.0
tools:
  read: true
  write: false
  edit: false
  bash: false
  webfetch: false
permission:
  all: deny
---

你是专业代码审查员，仅做分析不修改代码，专注：
1. 安全漏洞（SQL 注入、XSS、权限问题）
2. 代码规范与最佳实践
3. 性能瓶颈与内存泄漏
4. 潜在 Bug 与边界情况
输出简洁的问题 + 修复建议
```

#### 示例 2：数据库 DBA Agent

```markdown
---
description: MySQL/PostgreSQL 数据库专家
mode: subagent
name: dba
temperature: 0.1
tools:
  read: true
  write: false
  bash: false
---

你是资深 DBA，负责：
1. SQL 语句优化、索引设计
2. 表结构规范与约束
3. 慢查询分析
4. 生成安全的 SQL 代码，禁止删除/清空表
```
---

## 四、权限配置 permission 详解

### 4.1 核心基础

`permission` 是 OpenCode Agent **最核心的安全管控配置**，用于**精细化控制 Agent 执行操作的权限等级**。

- **作用**：控制 Agent 所有**可执行操作**的权限等级
- **前置条件**：必须先在 `tools` 中**启用对应工具**，`permission` 才会生效
- **适用范围**：支持 Markdown（YAML 语法）和 JSON 配置

### 4.2 三级权限值

| 权限值 | 含义 | 适用场景 |
|--------|------|----------|
| `allow` | 无需用户确认，**自动直接执行** | 安全操作（git status、npm install） |
| `ask` | **执行前弹窗询问用户**，确认后才运行（默认值） | 常规修改、不确定安全性的操作 |
| `deny` | **完全禁止执行**，直接拒绝 | 危险操作（git push、rm -rf、数据库删表） |

**优先级**：`deny` > `ask` > `allow`

### 4.3 两种配置语法

#### 语法 1：简单模式（全局统一权限）

```yaml
# 所有操作都需要用户确认
permission: ask
```

#### 语法 2：精细模式（分操作/分命令权限）

```yaml
permission:
  read: allow      # 读文件直接允许
  write: ask       # 新建文件询问确认
  edit: deny       # 禁止修改文件
  bash: allow      # 执行命令直接允许
  webfetch: deny   # 禁止联网
```

### 4.4 命令级权限（Bash 专属）

`bash` 工具支持**命令级精细化管控**，可以精准控制特定命令的权限。

#### 语法规则

1. `*` 代表**所有命令**（通配符）
2. 支持模糊匹配（如 `npm *` = 所有 npm 开头的命令）
3. 支持精确匹配（如 `git push` = 仅精准禁止推送）

#### 示例

```yaml
permission:
  bash:
    "*": "ask"            # 所有命令默认：询问用户
    "npm *": "allow"      # 所有 npm 命令：直接执行
    "git status": "allow" # git status：直接执行
    "git push": "deny"    # git push：禁止执行
    "rm *": "deny"        # 所有删除命令：禁止
```

### 4.5 权限优先级（解决配置冲突）

当多个权限配置冲突时，按以下顺序生效：

1. **禁止最高**：`deny` > `ask` > `allow`
2. **精准优先**：精确命令 > 模糊命令 > 通配符 `*`
3. **局部优先**：单操作权限 > 全局统一权限

**示例**：
```yaml
permission:
  bash:
    "*": "allow"
    "git push": "deny"
```
✅ 结果：`git push` 被禁止，其他命令直接执行。

### 4.6 常用配置模板

#### 模板 1：只读权限（代码审查/分析专用）

```yaml
permission:
  read: allow
  write: deny
  edit: deny
  bash: deny
  webfetch: deny
```

#### 模板 2：安全开发权限（日常编码推荐）

```yaml
permission:
  read: allow
  write: ask
  edit: ask
  bash:
    "*": "ask"
    "npm *": "allow"
    "yarn *": "allow"
    "git status": "allow"
    "git push": "deny"
    "rm *": "deny"
  webfetch: ask
```

#### 模板 3：全禁止权限（纯对话助手）

```yaml
permission: deny
```

### 4.7 `permission` 与 `tools` 核心区别

- **`tools`：开关** → 能不能用这个功能（true/false）
- **`permission`：权限** → 能用的话，要不要确认/禁止

**规则**：
1. `tools: false` → 工具直接禁用，`permission` 无效
2. `tools: true` → 工具启用，`permission` 管控权限

---

## 五、Agent 交互与调用机制

### 5.1 调用方式

#### 方式 1：主 Agent 切换

- **快捷键**：会话中按 **Tab 键** 循环切换 Build/Plan 代理
- **配置方式**：自定义 `switch_agent` 快捷键（opencode.json）

#### 方式 2：子 Agent 调用

1. **自动调用**：主 Agent 根据任务描述自动委派给合适子 Agent
   - 代码全局检索、结构分析 → 自动调用 `@explore`
   - 技术调研、复杂方案研究 → 自动调用 `@general`
   - 代码安全检查、规范审查 → 自动调用自定义审查 Subagent

2. **手动调用**：消息中使用 `@` 提及子 Agent
   ```
   @explore 帮我查找所有使用了 UserService 的文件
   @general 帮我研究如何在 FastAPI 中实现 JWT 认证
   @review 审查我的登录接口代码
   @dba 优化这条 SQL 语句
   ```

#### 方式 3：隐藏子代理

配置 `hidden: true` 的 Subagent：
- ❌ 禁止用户手动 `@` 调用
- ✅ 仅允许 Primary 内部自动委派调用

### 5.2 通信原理

我给你讲**底层原理 + 通信流程 + 固定返回格式 + 主代理接收逻辑**，看完你就能自己控制子代理怎么给主代理回传数据、怎么让主代理自动接续流程。

#### 5.2.1 核心结论（先记死）
- **Subagent 不能主动发起调用，只能被动被 Primary 召唤**
- Subagent 做完任务后，**必须输出「结构化总结结果」**，OpenCode 会自动把这份总结**传回主会话**
- 子代理**独立上下文隔离**，只把**最终摘要**回流给 Primary，不会把中间过程全塞回去
- Primary 会**自动接收子代理返回的摘要**，然后继续下一步调度（再调别的子代理、继续编码、给用户答复）

#### 5.2.2 底层通信完整流程（一步不漏）
##### 步骤1：调用发起
Primary / 用户 → 发起 `@xxx` 调用 Subagent
OpenCode **新开独立子会话**，隔离上下文、模型、权限。

##### 步骤2：任务下发（下行）
Primary 会自动精简下发：
- 用户原始需求
- 当前项目文件结构
- 相关代码片段
- 约束规则
**不会把整个主会话历史全发过去**，节省 token。

##### 步骤3：Subagent 内部执行
子代理自己读文件、分析、编码、审查、跑命令，**中间日志留在子会话里**，不回主会话。

##### 步骤4：结果回流（上行关键）
Subagent **输出最终结论/报告** → OpenCode 自动**截断中间过程**，只把**最终总结**推回 Primary 主会话。

##### 步骤5：Primary 接收并继续调度
Primary 读到子代理结果后：
- 分析是否完成
- 是否有 bug、是否要重写
- 自动下一个环节：再调 @code / @review / @test / @bugfix
- 最终整合所有子代理结果给用户

#### 5.2.3 Subagent 返回结果的「硬性规则」
##### 规则1：必须收尾：给出**明确结构化总结**
子代理结尾必须固定输出：
- 任务结论
- 关键文件路径
- 问题清单/通过状态
- 下一步建议

**不可以只扔一堆代码、日志不总结**，否则 Primary 识别不了、无法自动流转。

##### 规则2：中间过程自动屏蔽
子代理中间：翻文件、思考、调试日志
→ **不会返回给 Primary**
只回流你**最后写的总结块**。

##### 规则3：返回内容格式建议（标准规范）
你可以在自定义 Subagent 的 **Prompt 里强制要求**固定返回模板，让 Primary 能稳定解析：

```markdown
#### 任务完成结果
1. 任务状态：通过 / 不通过 / 需修复
2. 涉及文件：
- src/xxx.js
- ...
3. 核心结论：
...
4. 建议下一步：
调用 @code / @review / @test / @bugfix
```

只要子代理按这个格式收尾，Primary 就能**自动识别状态、自动走下一个流程**。

#### 5.2.4 实操：怎么在自定义 Subagent 里强制规范返回
举例子，给你的 `review-agent.md` 加强制返回规则：

```markdown
---
description: 代码审查子代理
mode: subagent
name: review
...
---
你是代码审查专家，只读不修改。
执行完审查后，**必须严格按下面固定格式返回结果**，禁止只贴日志不总结：

### 审查结果
1. 审查状态：【通过 / 不通过】
2. 问题清单：
- 问题1
- 问题2
3. 涉及文件路径：
- 文件1
4. 下一步建议：
如需修复请调用 @bugfix，无需修改可进入测试环节
```

只要你每个 Subagent 都加这一条：
**强制固定结构化输出**
Primary 就能**稳定接收、自动判断、自动流转**。

#### 5.2.5 Primary 如何接收 & 感知子代理结果
1. OpenCode 把子代理**最终总结**插入主会话上下文
2. Primary 能看到：状态、文件、结论、下一步建议
3. Primary 内置逻辑会自动判断：
   - 审查通过 → 自动调 @test
   - 审查不通过 → 自动调 @bugfix
   - 测试失败 → 自动调 @bugfix
4. 全程不需要用户干预

#### 5.2.6 关键限制（必须知道）
1. ❌ Subagent **不能主动呼叫 Primary**，只能被动返回结果
2. ❌ Subagent **不能再嵌套调用其他 Subagent**，只有 Primary 能调度
3. ✅ 子会话中间过程**不回传**，只回传最终总结
4. ✅ 返回内容**只看子代理最后输出**，前面思考过程全部丢弃
5. ✅ 多 Subagent 并行调用，结果会**逐个回流**给 Primary，互不干扰

#### 5.2.7 一句话极简总结
1. Primary 召唤 Subagent
2. Subagent 在独立会话干活
3. Subagent **最后输出结构化总结**
4. OpenCode 自动把总结传回 Primary
5. Primary 读取结果，自动调度下一个子代理

---

## 六、 Primary Agent 与 Subagent实操示例，定制一套开发流程

- 1个 **总调度 Primary Agent**（核心大脑，统筹全流程）
- 5个 **专业 Subagent**（计划、编码、BUG修复、代码审查、编译测试）
- 完整的自动化开发闭环：**需求 → 计划 → 编码 → 审查 → 测试 → 修复 → 交付**
- 所有配置**直接复制即可使用**，严格遵循 OpenCode 规范

### 6.1 整体架构设计
#### 6.1.1 角色分工
| 角色 | 类型 | 核心职责 | 权限 |
|------|------|----------|------|
| **DevMaster** | Primary（主代理） | 总调度，接收需求，自动调用子代理，整合结果 | 全权限（安全管控） |
| **PlanAgent** | Subagent（子代理） | 需求拆解、开发计划、架构设计 | 只读，无修改 |
| **CodeAgent** | Subagent（子代理） | 编写/生成业务代码、组件、接口 | 读写文件，无危险命令 |
| **BugFixAgent** | Subagent（子代理） | 排查BUG、修复代码、调试逻辑 | 读写文件，调试权限 |
| **ReviewAgent** | Subagent（子代理） | 代码质量审查、安全漏洞检测、规范校验 | 只读，无修改 |
| **TestAgent** | Subagent（子代理） | 编译代码、执行单元测试、运行项目 | 允许安全bash命令 |

#### 6.1.2 调用规则
1. **用户只和 Primary 对话**，无需关心子代理
2. Primary **自动识别任务**，委派给对应 Subagent
3. 支持手动 `@` 调用任意子代理
4. 子代理上下文隔离，互不干扰

### 6.2 项目文件结构
在你的项目根目录创建以下结构，OpenCode 会自动加载：
```
你的项目/
└── .opencode/
    └── agents/
        ├── dev-master.md       ### 主代理：总调度
        ├── plan-agent.md       ### 子代理：计划
        ├── code-agent.md       ### 子代理：编码
        ├── bugfix-agent.md     ### 子代理：BUG修复
        ├── review-agent.md     ### 子代理：代码审查
        └── test-agent.md       ### 子代理：编译测试
```

### 6.3 完整配置代码（直接复制使用）
#### 6.3.1 主代理：DevMaster（总调度）
文件：`.opencode/agents/dev-master.md`
```markdown
---
description: 全流程开发总调度，自动调用计划/编码/审查/测试/修复子代理
mode: primary
name: devmaster
temperature: 0.2
tools:
  read: true
  write: true
  edit: true
  bash: true
  webfetch: true
permission:
  # 总调度仅做调度，不直接执行危险操作
  bash:
    "*": "ask"
    "git status": "allow"
---

# 核心指令
你是**开发流程总调度师**，严格按照以下流程执行：
1. 接收用户开发需求，优先调用 @plan 生成开发计划
2. 根据计划调用 @code 编写代码
3. 代码完成后调用 @review 审查代码
4. 审查通过调用 @test 编译测试
5. 测试出现BUG调用 @bugfix 修复
6. 所有环节通过，交付最终成果
7. 自动协调所有子代理，不重复工作，不越权操作
```

#### 6.3.2 子代理：PlanAgent（开发计划）
文件：`.opencode/agents/plan-agent.md`
```markdown
---
description: 需求分析、开发计划拆解、架构设计、任务拆分
mode: subagent
name: plan
temperature: 0.0
tools:
  read: true
  write: false
  edit: false
  bash: false
  webfetch: false
permission:
  all: allow
---

# 角色：专业架构师&计划员
你只做**只读规划**，不修改任何代码：
1. 分析用户需求，拆解为可执行的开发任务
2. 输出技术方案、文件结构、实现步骤
3. 标注风险点、依赖项、验收标准
4. 输出格式：清晰的markdown计划文档
```

#### 6.3.3 子代理：CodeAgent（代码编写）
文件：`.opencode/agents/code-agent.md`
```markdown
---
description: 根据开发计划编写业务代码、接口、组件
mode: subagent
name: code
temperature: 0.1
tools:
  read: true
  write: true
  edit: true
  bash: false
  webfetch: true
permission:
  write: ask
  edit: ask
---

# 角色：高级开发工程师
严格按照计划编写代码：
1. 遵循行业最佳实践，代码规范、注释完整
2. 只编写计划内的代码，不随意修改
3. 生成可直接运行的代码
4. 主动告知代码编写进度和文件路径
```

#### 6.3.4 子代理：BugFixAgent（BUG修复）
文件：`.opencode/agents/bugfix-agent.md`
```markdown
---
description: 排查代码BUG、逻辑错误、异常问题，精准修复
mode: subagent
name: bugfix
temperature: 0.1
tools:
  read: true
  write: true
  edit: true
  bash: false
permission:
  edit: allow
---

### 角色：资深调试专家
专注BUG修复：
1. 分析报错信息、定位问题代码
2. 最小化修改，不破坏原有逻辑
3. 修复后验证问题是否解决
4. 输出修复说明
```

#### 6.3.5 子代理：ReviewAgent（代码审查）
文件：`.opencode/agents/review-agent.md`
```markdown
---
description: 代码质量审查、安全漏洞检测、规范校验、优化建议
mode: subagent
name: review
temperature: 0.0
tools:
  read: true
  write: false
  edit: false
  bash: false
permission:
  all: allow
---

# 角色：代码审查专家
只读审查，不修改代码：
1. 检查代码规范、潜在BUG、安全漏洞
2. 校验性能、可读性、可维护性
3. 输出审查报告：通过/不通过+问题清单
```

#### 6.3.6 子代理：TestAgent（编译测试）
文件：`.opencode/agents/test-agent.md`
```markdown
---
description: 项目编译、单元测试、运行验证、构建打包
mode: subagent
name: test
temperature: 0.0
tools:
  read: true
  write: false
  edit: false
  bash: true
permission:
  bash:
    ### 仅允许编译/测试/安装依赖的安全命令
    "*": "ask"
    "npm install *": "allow"
    "npm run build": "allow"
    "npm run test": "allow"
    "npm run dev": "allow"
---

# 角色：测试&构建工程师
负责编译和测试：
1. 执行编译命令，检查是否报错
2. 运行单元测试，验证功能
3. 启动项目，验证基础可用性
4. 输出测试结果：通过/失败+日志
```

### 6.4 实操：完整开发流程演示
#### 6.4.1 前提
1. 将以上文件放入项目目录
2. 重启 OpenCode
3. 按 `Tab` 切换到主代理 **DevMaster**

#### 6.4.2 场景：用户需求
> 我需要开发一个用户登录接口，包含参数校验、JWT签发、错误返回

全流程自动执行（Primary 自动调用所有子代理）

### 6.5 手动调用子代理（灵活使用）
你也可以直接指挥总调度，手动触发任意环节：
```text
@plan 帮我拆解登录模块开发计划
@code 根据计划编写登录代码
@review 审查我写的代码
@test 编译测试项目
@bugfix 修复接口报错500问题
```

### 6.6 核心特性（这套定制流程的优势）
1. **全自动化**：用户只需提需求，Primary 自动走完开发全流程
2. **权限绝对安全**：
   - 计划/审查：只读，无任何修改风险
   - 测试：仅允许安全命令，禁止删除/推送
3. **专业分工**：每个子代理只做一件事，精度更高
4. **上下文隔离**：子任务不污染主对话，效率更高
5. **可扩展**：新增文档、部署、数据库等子代理只需加文件

### 6.7 关键说明
1. **主代理唯一入口**：用户永远只和 Primary 交互，无需管理子代理
2. **单向调用**：Primary → Subagent，子代理不能反向调用
3. **自动调度**：Primary 内置调度逻辑，完全自动化
4. **无缝衔接**：所有子代理共享项目文件，流程无断点

---

## 七、最佳实践建议

1. **安全优先**：涉及关键修改时，先用 Plan Agent 分析评估，再用 Build Agent 执行
2. **任务拆分**：复杂任务拆分为多个子任务，通过子 Agent 并行处理
3. **权限精细化**：对不同 Agent 设置差异化权限
4. **上下文管理**：利用子 Agent 独立会话特性，避免主会话上下文膨胀
5. **常见问题排错**：
   - 配置不生效 → 检查目录 `.opencode/agents/`、检查语法、重启 OpenCode
   - 调用不到 Agent → 检查 `name` 字段，确认 `mode` 为 `subagent`
   - 权限不生效 → 检查 `tools` 是否启用、权限优先级 `deny` > `ask` > `allow`

---

## 八、总结

OpenCode 内置 Agent 体系通过**专业化分工**和**精细化权限控制**，构建了一个高效、安全的 AI 编程协作环境。核心的 Build/Plan 双主 Agent 分别负责"执行"与"思考"，配合 General/Explore 子 Agent 处理专项任务，形成了完整的开发工作流闭环。

通过合理配置和灵活调用这些 Agent，开发者可以显著提升编程效率，同时降低误操作风险，实现"思考 - 规划 - 执行 - 审查"的全流程 AI 辅助开发。
