# OpenCode之Agent、Slash命令、Skill技能的关系与高级应用
> 本文详细介绍OpenCode中Agent（代理）、Slash命令、Skill（技能）三者的定位与区别，解析三者之间的调用关系与协同机制，并提供全套实战案例与配置模板。

## 目录

```
1. [Agent、Slash命令、Skill层级与协同机制](#一agentslash命令skill层级与协同机制)
2. [agent、slash命令、skill技能之间的调用关系](#二agent-slash命令skill技能之间的调用关系)
3. [全套实战案例](#三全套实战案例)
```

---

## 一、Agent、Slash命令、Skill层级与协同机制

在 OpenCode 的架构中，Agent（代理）、Slash 命令 和 Skill（技能） 是三个不同抽象层级的概念，它们并非竞争关系，而是互相配合的分工体系。以下是它们之间的调用关系与协同机制。

### 1. 三者的定位与区别
| 概念 | 定位 | 核心作用 | 类比 |
|------|------|----------|------|
| Slash 命令 | 用户触发的快捷指令 | 预设指令的快捷方式，用户手动输入 `/command` 触发 | 外卖 App 的「下单按钮」 |
| Skill | 可复用的专业知识包 | 封装特定领域的知识和工作流，按需加载到上下文 | 厨师的「食谱手册」 |
| Agent | 自主执行任务的智能体 | 接收目标、规划拆解、调用工具和 Skill 完成复杂任务 | 完整的「外卖运营团队」 |

**三者的关系总结**
```
┌─────────────────────────────────────────┐
│           用户层 (User)                  │
│    输入 /command 或自然语言描述任务       │
└──────────────┬──────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│         Agent 层 (调度中心)               │
│  接收任务 → 规划拆解 → 决定调用哪些能力    │
└──────────────┬──────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│      Skill 层 (专业知识库)                │
│  按需加载专业知识，指导 Agent 正确执行     │
│  (可自动触发，也可通过 /skill-name 手动调用)│
└──────────────┬──────────────────────────┘
                ↓
┌─────────────────────────────────────────┐
│      工具层 (Tools)                      │
│  执行具体动作：文件读写、命令执行、API 调用 │
└─────────────────────────────────────────┘
```

**一句话：**
- **Slash = 快捷入口**（可触发 Agent）
- **Skill = 能力插件**（被 Agent 加载）
- **Agent = 执行容器**（调度 Slash、加载 Skill、干活）

### 2. OpenCode 中的具体实现
#### Skill 的发现与加载机制
OpenCode 启动后，会将所有可用技能以 XML 格式注入到 `skill` 工具的描述中：
```xml
<available_skills>
  <skill>
    <name>git-release</name>
    <description>创建一致的发布和更新日志</description>
  </skill>
</available_skills>
```

当 Agent 判断某个技能与当前任务相关时，会主动调用：
```typescript
skill({ name: "git-release" })
```
加载完成后，技能中定义的指令会进入 Agent 的工作记忆，影响后续行为。

#### 权限控制
通过 `opencode.json` 配置 Agent 对 Skill 的访问权限：
- `allow`：立即加载
- `deny`：对 Agent 隐藏
- `ask`：加载前提示用户批准

### 3. 关键设计哲学
- 工具（Tools） 解决的是 AI **能不能做**
- Skill 解决的是 AI **会不会正确地做**
- Agent 解决的是 **谁来决定做什么、何时做**

当三者协同工作时，AI 才算真正具备了「专业性」。

---

## 二、agent、slash命令、skill技能之间的调用关系

### 1. Agent 与 Slash 命令 之间的调用关系

#### 1）在 Agent Prompt 里直接写「执行 /xxx」
适合：把 Slash 当成固定步骤。
```markdown
### 你的指令
你是 Primary Agent，负责开发流程调度。
按顺序执行：
1. 调用 /plan 生成开发计划
2. 调用 /code 编写代码
3. 调用 /review 审查代码
...
```
效果：Agent 会**模拟输入 /plan**，触发对应的 Slash 命令（可能绑定了 Subagent）。

#### 2）Slash 绑定 Agent（推荐）
在 `opencode.jsonc` 或 `commands/plan.md` 定义：
```jsonc
// commands/plan.md
---
description: 生成开发计划
agent: plan   // 绑定到 plan Subagent
---
请拆解需求，输出结构化开发计划...
```

然后 Primary Agent 只要写：
```
执行 /plan
```
就会**自动唤醒 plan Subagent**，执行命令里的 Prompt，最后把结构化结果返回给 Primary。

### 2. Agent 与 Skill 技能调用关系

#### 1）Skill 示例
示例：`.opencode/skills/code-review/SKILL.md`
```markdown
---
name: code-review
description: 代码审查，检查规范、安全、性能
tags: [review, code, quality]
---
### What I do
- 检查代码规范与格式
- 检查安全漏洞与异常处理
- 检查性能问题与冗余代码
### Steps
1. 读取指定文件
2. 按清单逐项检查
3. 输出结构化审查结果（按之前约定模板）
```

#### 2）Agent 绑定专属 Skill

Agent 可以声明只加载特定的 Skills，避免上下文膨胀：

```markdown
---
description: "SRE agent for incident response"
skills: ["code-review", "kubernetes", "incident-response"]
---
```

行为规则：
- 有  skills  字段 → 只加载列表中的 Skill 描述
- 无  skills  字段 → 加载所有发现的 Skill（当前默认行为）

#### 3）自动触发（最常用）

Agent 在会话启动时会解析所有可用 Skill 的元数据（描述、触发条件）。当用户输入的任务描述与某个 Skill 匹配时，Agent 会自动通过原生  skill  工具加载并执行

示例：

```bash
> @demo.py review this code
# Agent 自动识别并调用 code-review
```

#### 4）Agent 主动调用 Skill（固定语法）
Agent Prompt 里写：
```markdown
你是 review Subagent，执行代码审查。
调用技能 `code-review` 对 src/ 下所有文件进行审查，严格按标准模板输出结果。
```
- Agent 看到 `` 会**自动调用 skill 工具**，读取 SKILL.md 内容，并入当前 Prompt。
- **只有 Agent 能调用 Skill**，Subagent 也可以加载 Skill。

#### 5）Agent 对 Skill 的权限控制
OpenCode 允许在 Agent 配置中通过  permission.skill  精确控制该 Agent 能加载哪些 Skill，采用**通配符匹配 + 最后规则优先**策略

配置示例：学术研究 Agent

```markdown
---
description: Research assistant for academic work
mode: primary
temperature: 0.3
permission:
  skill:
    "*": deny           # 默认拒绝所有 Skill
    "academic-*": allow # 只允许 academic- 前缀的 Skill
  bash:
    "*": ask
  edit: ask
---
You are a research assistant...

```

这样  research-assistant  Agent 只能调用  academic-paper-reading 、 academic-markdown-to-pdf  等学术 Skill，避免加载无关技能干扰。

### 3. 关键规则总结（必记）
1. **Slash 触发 Agent，Agent 加载 Skill**，三层结构解耦。
- 用 **Slash 绑定 Subagent**（/review → review Subagent）
- Subagent 内部 **加载对应 Skill**（review Subagent → code-review Skill）
2. **只有 Agent 能调用 Skill**，用固定 `` 格式。
3. Subagent 也是 Agent，**可加载 Skill**，但**不能调用其他 Subagent**（只有 Primary 能调度）。
4. 返回结果：**Skill 输出 → Subagent 汇总 → 结构化模板 → Primary 接收**。

### 4. 直接可用的示例（套进你现有流程）

#### 1）Slash：commands/review.md（绑定 review Subagent）
```markdown
---
description: 代码审查流程
agent: review
---
请对指定代码进行审查，输出结构化结果。
```

#### 2）Skill：.opencode/skills/code-review/SKILL.md
```markdown
---
name: code-review
description: 代码审查标准流程
---
### 审查清单
1. 代码规范：命名、格式、注释
2. 逻辑正确性：边界条件、异常处理
3. 安全性：注入、权限、敏感信息
4. 性能：复杂度、冗余、资源释放
### 输出格式
严格按之前约定的「子代理任务结果」模板输出。
```

#### 3）review Subagent：review-agent.md
```markdown
---
name: review
mode: subagent
description: 代码审查子代理
---
你是资深代码审查专家，只读不修改。
加载审查技能：
[{"name":"skill","parameters":{"name":"code-review"}}]
按技能要求执行审查，**必须按标准模板输出结果**，省略中间思考过程。
```

#### 4）Primary Agent：dev-master.md（调度）
```markdown
### 自动调度规则
收到编码完成 → 执行 /review
收到审查结果 → 根据状态：
- 通过 → 执行 /test
- 有问题 → 执行 /bugfix
```

---

## 三、全套实战案例

### 1. 最终目录结构（直接照着建文件夹）
```
项目根目录/
└── .opencode/
    ├── commands/          ## Slash 命令 /plan /code /review /test /bugfix
    ├── skills/           ## 5套标准技能包
    └── agents/           ## 主Agent + 5个Subagent
```

### 2. Slash 命令（5个，放在 `.opencode/commands/`）
#### 2.1 plan.md
```markdown
---
description: 需求拆解、架构方案、开发任务规划
agent: plan
---
请基于当前需求与项目结构，完成专业开发规划，并按标准结构化格式输出结果。
```

#### 2.2 code.md
```markdown
---
description: 根据开发计划编写业务代码、接口、组件
agent: code
---
严格按照已有的开发计划，编写规范可运行代码，按标准结构化格式输出结果。
```

#### 2.3 review.md
```markdown
---
description: 代码规范、安全、性能全量审查
agent: review
---
对现有新增/修改代码进行全面质量与安全审查，按标准结构化格式输出审查报告。
```

#### 2.4 test.md
```markdown
---
description: 项目编译、依赖安装、单元测试、运行校验
agent: test
---
执行项目编译、依赖校验、测试运行，输出结构化测试结果。
```

#### 2.5 bugfix.md
```markdown
---
description: 定位报错、修复BUG、最小改动还原逻辑
agent: bugfix
---
根据测试/审查问题定位根因，最小化修改修复BUG，按标准格式输出修复结果。
```

### 3. Skill 技能包（5个，放在 `.opencode/skills/`）
#### 3.1 plan-skill/SKILL.md
```markdown
---
name: plan-skill
description: 需求分析、架构设计、任务拆分标准技能
tags: [plan,架构,需求拆解]
---
### 工作标准
1. 梳理用户原始需求，明确功能边界与验收标准
2. 分析现有项目目录、技术栈、依赖框架
3. 拆分模块、划分文件结构、定义接口契约
4. 识别风险点、缺失依赖、兼容性问题

### 输出约束
必须使用统一「子代理任务结果」结构化模板输出，
只给结论与规划，不编写任何代码、不执行命令。
```

#### 3.2 code-skill/SKILL.md
```markdown
---
name: code-skill
description: 标准化业务代码编写技能
tags: [coding,开发,接口]
---
### 编码规范
1. 遵循当前项目技术栈与目录规范
2. 代码带完整注释、参数校验、异常捕获
3. 命名规范、结构清晰、可直接运行
4. 只按开发计划实现，不额外扩展无关功能

### 输出约束
完成编码后列出所有新建/修改文件，使用统一结构化模板输出。
```

#### 3.3 review-skill/SKILL.md
```markdown
---
name: review-skill
description: 代码审查标准检查项
tags: [review,质量,安全]
---
### 审查检查清单
#### 1. 代码规范
命名、缩进、注释、冗余代码、魔法值
#### 2. 逻辑质量
边界条件、空值判断、异常处理、循环逻辑
#### 3. 安全风险
注入、越权、敏感信息泄露、参数未校验
#### 4. 性能问题
重复查询、资源未释放、低效循环

### 输出约束
只做审查不修改，按统一结构化模板输出问题清单与结论。
```

#### 3.4 test-skill/SKILL.md
```markdown
---
name: test-skill
description: 项目编译、构建、测试标准化流程
tags: [test,编译,构建]
---
### 测试工作流程
1. 检查依赖完整性
2. 执行项目编译/构建命令
3. 运行单元测试/基础功能校验
4. 记录报错日志、依赖缺失、编译异常

### 输出约束
明确编译/测试状态，列出异常文件与原因，按统一模板输出。
```

#### 3.5 bugfix-skill/SKILL.md
```markdown
---
name: bugfix-skill
description: BUG定位、排查、最小化修复技能
tags: [bugfix,调试,问题修复]
---
### 修复原则
1. 先定位根因，不盲目改代码
2. 最小改动修复，不重构原有正常逻辑
3. 修复后校验功能可用性
4. 记录问题原因、改动点、验证方式

### 输出约束
按统一结构化模板输出：根因、修改文件、修复说明、验证结果。
```

### 4. Agent 配置（6个，放在 `.opencode/agents/`）
#### 4.1 主调度代理：dev-master.md（Primary）
```markdown
---
description: 全流程开发总调度，自动按流程调用规划/编码/审查/测试/修复
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
  bash:
    "*": "ask"
    "git status": "allow"
---

## 角色职责
你是项目全流程开发总调度官，接收用户需求，全自动驱动完整开发流水线。

## 固定调度规则
1. 接收用户需求 → 执行 /plan
2. 收到【规划完成】 → 执行 /code
3. 收到【编码完成】 → 执行 /review
4. 收到【审查通过】 → 执行 /test
5. 收到【审查存在问题】 → 执行 /bugfix
6. 收到【编译/测试失败】 → 执行 /bugfix
7. 收到【BUG修复完成】 → 自动执行 /test 重新验证
8. 测试全部通过 → 汇总所有成果，流程结束交付

## 通信规则
严格识别各子代理返回的「子代理任务结果」结构化内容，
只根据「执行状态、建议下一步动作」自动调度，不随意跳过环节。
```

#### 4.2 子代理：plan-agent.md
```markdown
---
description: 需求分析、架构规划、任务拆分
mode: subagent
name: plan
temperature: 0.0
tools:
  read: true
  write: false
  edit: false
  bash: false
permission:
  all: allow
---
加载技能：
[{"name":"skill","parameters":{"name":"plan-skill"}}]

你只做需求分析与方案规划，不编写代码、不修改文件、不执行命令。

### 强制输出规范
任务完成后必须严格使用以下固定模板输出：
## 子代理任务结果
1. 任务类型：开发计划拆解
2. 执行状态：【规划完成 / 需求不明确】
3. 涉及文件列表：
-
4. 核心摘要：

5. 问题清单：
无
6. 建议下一步动作：
进行编码开发
```

#### 4.3 子代理：code-agent.md
```markdown
---
description: 根据规划编写业务代码
mode: subagent
name: code
temperature: 0.1
tools:
  read: true
  write: true
  edit: true
  bash: false
permission:
  write: ask
  edit: ask
---
加载技能：
[{"name":"skill","parameters":{"name":"code-skill"}}]

严格按照开发计划实现功能，遵循项目规范，代码带注释、健壮可运行。

### 强制输出规范
## 子代理任务结果
1. 任务类型：业务代码编写
2. 执行状态：【编码完成 / 存在逻辑缺失】
3. 涉及文件列表：
-
4. 核心摘要：

5. 问题清单：
无
6. 建议下一步动作：
进行代码审查
```

#### 4.4 子代理：review-agent.md
```markdown
---
description: 代码质量安全审查
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
加载技能：
[{"name":"skill","parameters":{"name":"review-skill"}}]

只读审查，不修改任何代码，按审查清单逐项校验。

### 强制输出规范
## 子代理任务结果
1. 任务类型：代码质量&安全审查
2. 执行状态：【审查通过 / 存在规范问题 / 存在安全隐患】
3. 涉及文件列表：
-
4. 核心摘要：

5. 问题清单：
-
6. 建议下一步动作：
进入BUG修复 / 执行编译测试
```

#### 4.5 子代理：test-agent.md
```markdown
---
description: 项目编译、构建、测试校验
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
    "*": "ask"
    "npm install *": "allow"
    "npm run build": "allow"
    "npm run test": "allow"
---
加载技能：
[{"name":"skill","parameters":{"name":"test-skill"}}]

负责依赖检查、编译构建、运行测试，记录异常日志。

### 强制输出规范
## 子代理任务结果
1. 任务类型：项目编译&单元测试
2. 执行状态：【编译通过测试正常 / 编译失败 / 测试用例不通过】
3. 涉及文件列表：
-
4. 核心摘要：

5. 问题清单：
-
6. 建议下一步动作：
进入BUG修复 / 流程结束交付
```

#### 4.6 子代理：bugfix-agent.md
```markdown
---
description: BUG定位与最小化修复
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
加载技能：
[{"name":"skill","parameters":{"name":"bugfix-skill"}}]

根据审查/测试问题定位根因，最小改动修复，不破坏原有正常逻辑。

### 强制输出规范
## 子代理任务结果
1. 任务类型：BUG定位与修复
2. 执行状态：【修复完成验证通过 / 暂未定位根因】
3. 涉及文件列表：
-
4. 核心摘要：

5. 问题清单：
无
6. 建议下一步动作：
执行编译测试
```

### 5. 使用步骤
1. 在项目根目录建好上面三层文件夹：`commands`、`skills`、`agents`
2. 把对应文件原样粘贴进去
3. 重启 OpenCode
4. 按 `Tab` 切换到主代理 **devmaster**
5. 直接发需求，例如：
```
开发一个用户登录接口，包含参数校验、JWT签发、统一异常返回
```
**全自动流程**：
规划 → 编码 → 审查 → 测试 → 有bug自动修复 → 再测试 → 交付

### 6. 整套体系工作链路
1. 输入 `/plan` → 绑定 plan子代理 → 加载 plan-skill → 结构化结果返回主代理
2. 主代理识别结果 → 自动调用 `/code`
3. 依次流转：编码→审查→测试→修复
4. 所有子代理**统一模板返回**，主代理**固定规则调度**，全程无人干预。

### 7 测试指令（直接粘贴对话发送）
```
基于 FastAPI 新建一个简易工具模块：
1. 编写健康检查接口 /health
2. 编写基础示例接口 /api/info
3. 增加全局异常捕获、统一JSON返回格式
4. 代码添加完整注释，保证可直接运行
```

---

(End of file - total 634 lines)