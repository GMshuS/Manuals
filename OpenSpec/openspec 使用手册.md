# OpenSpec 官方使用手册
## 一、技术原理
OpenSpec 是轻量级**规格驱动AI编码**框架，核心解决AI编码中「上下文丢失、需求对齐难、存量开发协作混乱」三大痛点，核心原理围绕**持久化共识、增量变更、灵活迭代**设计：
1. **共识持久化**：将项目背景、需求、设计等核心信息以Markdown文件持久化在项目中，替代AI对话的临时上下文，让AI每次开发都基于统一的「源真相」文档；
2. **Specs&Changes二分法**：通过`specs`目录存储系统当前行为的权威描述，`changes`目录隔离每个功能/BUG修复的独立开发过程，归档时自动合并增量规格，保证`specs`始终反映系统最新状态；
3. **Delta Specs增量规格**：无需重写全量系统规格，仅描述单次变更的「新增/修改/删除」行为，适配存量项目开发，支持多变更并行无冲突；
4. **工件依赖驱动**：按`proposal(为什么做)→specs(做什么)→design(怎么做)→tasks(做哪几步)`生成结构化工件，依赖关系为「使能而非门禁」，流程灵活可按需调整；
5. **双Profile适配**：默认Core Profile满足高效开发，Expanded Profile提供精细化分步审查，支持自定义Schema扩展工作流。

核心设计原则：**灵活而非死板、迭代而非瀑布、简单而非复杂、存量优先**。

## 二、安装与初始化
### 2.1 前置要求
Node.js 20.19.0+

### 2.2 全局安装
```bash
npm install -g @fission-ai/openspec@latest
```

### 2.3 项目初始化
1. 进入项目根目录执行初始化命令：
```bash
cd your-project
openspec init
```
2. 按CLI提示选择适配的AI工具（Claude Code/Cursor/Copilot等），自动生成`openspec/`核心目录；
3. **必做：配置项目上下文**（减少重复说明，提升AI生成质量），编辑`openspec/config.yaml`：
```yaml
schema: spec-driven # 默认工作流Schema
context: |
  技术栈：TypeScript、React 18、Node.js、PostgreSQL
  API 风格：RESTful，文档在 docs/api.md
  测试框架：Vitest + React Testing Library
  代码规范：参考 .eslintrc.js
rules: # 自定义工件规则
  proposal:
    - 必须包含回滚方案
    - 标注影响的模块范围
  specs:
    - 使用 Given/When/Then 格式描述测试场景
```

### 2.4 启用扩展命令（可选）
默认仅开放4个核心命令，解锁完整命令集需切换至Expanded Profile：
```bash
openspec config profile # 选择Expanded Profile
openspec update
```

## 三、核心命令列表
OpenSpec命令分为**AI对话斜杠命令**（/opsx:xxx）和**终端CLI命令**，按使用场景分类，标注「Core」为默认可用，「Expanded」为扩展命令。

### 3.1 AI对话斜杠命令（核心开发）
| 命令 | 类型 | 核心功能 | 适用场景 |
|------|------|----------|----------|
| `/opsx:propose <需求描述>` | Core | 一步生成全套工件（proposal+specs+design+tasks） | 需求清晰，直接开干 |
| `/opsx:explore <调研问题>` | Core | 技术调研/问题分析，无文件生成，零副作用 | 需求模糊、技术选型、瓶颈分析 |
| `/opsx:apply <变更名>` | Core | 按tasks.md清单逐条执行代码实现，断点续跑 | 开发实现阶段 |
| `/opsx:archive <变更名>` | Core | 归档变更，合并Delta Specs至主规格，留存审计记录 | 功能完成收尾 |
| `/opsx:new <变更名>` | Expanded | 仅创建变更骨架，不生成工件内容 | 手动控制开发节奏，分步推进 |
| `/opsx:continue <变更名>` | Expanded | 按依赖链生成下一个工件，每步可审查修改 | 需求打磨中，需逐步确认 |
| `/opsx:ff <变更名>` | Expanded | 快进生成所有剩余工件 | 方向已确认，无需逐步审查 |
| `/opsx:verify <变更名>` | Expanded | 从完整性/正确性/一致性三维度验证实现与规格匹配度 | 归档前质量检查 |
| `/opsx:sync <变更名>` | Expanded | 仅同步Delta Specs至主规格，不归档变更 | 并行变更需引用当前规格 |
| `/opsx:bulk-archive` | Expanded | 批量归档多个完成的变更，自动解决规格冲突 | 多功能并行开发后统一收尾 |
| `/opsx:onboard` | Expanded | 交互式上手教程，基于真实代码库走通完整流程 | 新用户首次使用 |

### 3.2 终端CLI命令（项目管理）
| 命令 | 核心功能 |
|------|----------|
| `openspec list` | 查看所有活跃变更及任务完成进度 |
| `openspec view` | 打开交互式仪表盘，可视化浏览变更/规格 |
| `openspec show <变更名>` | 查看指定变更的所有工件详情 |
| `openspec status <变更名>` | 查看指定变更的工件完成进度 |
| `openspec validate --all --strict` | 检查所有变更和规格的格式规范性 |
| `openspec archive <变更名>` | 终端端执行归档操作（与/opsx:archive等效） |
| `openspec config profile` | 切换Core/Expanded Profile |
| `openspec schema fork <原Schema> <新Schema>` | 自定义工作流Schema，扩展工件类型 |

## 四、详细使用流程
OpenSpec适配**6种典型开发场景**，核心流程围绕「规格定义→开发实现→验证归档」展开，以下为通用标准流程，各场景可按需调整命令组合。

### 4.1 通用标准流程（Expanded Profile，精细化开发）
**适用**：需求需打磨、复杂功能、跨团队协作，全程可审查可调整
1. **探索调研**（需求模糊时）：`/opsx:explore <调研问题>` → 明确开发方向，无文件生成；
2. **创建变更骨架**：`/opsx:new <变更名>` → 生成`openspec/changes/<变更名>/`空目录；
3. **分步生成工件**：反复执行`/opsx:continue <变更名>`，逐一生成`proposal.md→specs/→design.md→tasks.md`，每步可手动编辑修改工件；
4. **代码实现**：`/opsx:apply <变更名>` → AI按tasks.md逐条执行，断点可重新执行该命令续跑；
5. **质量验证**：`/opsx:verify <变更名>` → 修复验证中发现的WARNING/CRITICAL问题；
6. **归档收尾**：`/opsx:archive <变更名>` → 合并Delta Specs至主规格，变更移至归档目录，生命周期结束。

### 4.2 快速开发流程（Core Profile，高效开发）
**适用**：需求清晰、简单功能/BUG修复，追求开发效率
```bash
/opsx:propose <需求描述> → 审查工件 → /opsx:apply <变更名> → /opsx:verify <变更名> → /opsx:archive <变更名>
```
一步生成全套工件，无需分步操作，最快完成开发。

### 4.3 关键场景专属流程（极简版）
1. **断点续开发**：新对话中直接执行`/opsx:apply <变更名>` → AI自动识别未完成任务，从断点开始；
2. **纯技术调研**：`/opsx:explore <调研问题>` → 多轮对话分析 → 方向确定后再执行`/opsx:propose`/`/opsx:new`；
3. **多功能并行**：为每个功能执行`/opsx:propose/<新>` → 自由切换`/opsx:apply <变更名>` → 全部完成后`/opsx:bulk-archive`；
4. **存量项目接入**：`openspec init` → `/opsx:explore 分析现有代码` → 逐步补全`specs/` → 新功能按标准流程开发，归档自动积累规格。

## 五、目录结构与输出文件解析
### 5.1 核心目录结构（初始化后生成）
```
openspec/
├── specs/        # 系统当前行为的「源真相」，权威描述，归档后自动更新
│   ├── auth/     # 按模块划分，如认证、支付、UI等
│   ├── payments/
│   └── ...
├── changes/      # 活跃变更目录，每个变更一个独立子目录，相互隔离
│   ├── add-dark-mode/ # 变更名，简洁描述功能/BUG
│   └── fix-login-bug/
├── archive/      # 归档目录，存放已完成的变更，带时间戳，留作审计
│   └── 2026-02-27_add-github-oauth/
└── config.yaml   # 项目核心配置，上下文/规则/Schema，全局生效
```

### 5.2 变更目录内部结构（单个变更）
每个变更目录包含**4类核心工件**，按依赖关系生成，均为Markdown格式，易读易编辑：
```
openspec/changes/<变更名>/
├── proposal.md   # 回答「为什么做」
├── specs/        # 回答「做什么」，Delta Specs增量规格
├── design.md     # 回答「怎么做」，技术实现方案
└── tasks.md      # 回答「做哪几步」，带复选框的实现清单
```

### 5.3 核心工件文件解析
#### 5.3.1 proposal.md：立项说明
核心内容：**开发动机、功能范围（做/不做）、预期收益、回滚方案、影响模块**，是后续所有工件的出发点，示例：
```markdown
## 动机
用户反馈无深色模式，夜间使用体验差，需提升产品易用性。
## 范围
- 做：设置页添加深色模式开关、跟随系统主题、持久化选择
- 不做：第三方组件的深色模式适配、全局配色重设计
## 预期收益
夜间使用用户留存提升15%，减少视觉疲劳反馈。
## 影响模块
src/components/Settings/、src/styles/、src/context/
```

#### 5.3.2 specs/：Delta Specs增量规格
仅描述**本次变更的行为变化**，分`ADDED/MODIFIED/REMOVED`三类，需求用RFC 2119关键字（MUST/SHOULD/MAY）定义强度，场景用Given/When/Then描述测试用例，**仅描述外部可观察行为，不涉及内部实现**，示例：
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

## MODIFIED Requirements
### Requirement: Page Background (MODIFIED)
- 原：系统 MUST 使用固定白色背景（#FFFFFF）
- 新：系统 MUST 根据当前主题设置显示对应的背景色
```

#### 5.3.3 design.md：技术设计方案
核心内容：**架构决策、组件设计、技术选型、核心逻辑、依赖引入**，回答「技术上如何实现」，需与specs中的行为要求匹配，示例：
```markdown
## 技术方案
1. 基于React Context实现主题状态管理，创建ThemeContext.ts；
2. 使用CSS变量定义深浅色主题样式，在styles/globals.css中配置；
3. 调用window.matchMedia检测系统主题偏好，实现自动跟随；
4. 选择localStorage持久化用户选择，过期时间永久；
5. 引入classnames库简化主题样式切换，版本^2.3.2。
## 核心逻辑
- 主题切换时同步更新Context状态和localStorage；
- 组件通过useContext(ThemeContext)获取当前主题。
```

#### 5.3.4 tasks.md：实现任务清单
带**复选框**的分步执行清单，AI执行`/opsx:apply`时逐条完成并打勾，支持手动增删/调整顺序，颗粒度需细化至「单步可执行」，示例：
```markdown
- [ ] 安装classnames依赖，执行npm install classnames
- [ ] 在src/context/创建ThemeContext.ts，实现主题状态管理
- [ ] 在src/styles/globals.css中定义CSS变量版深浅色样式
- [ ] 在Settings页面添加主题切换开关组件，绑定Context事件
- [ ] 实现系统主题检测逻辑，在App.tsx中初始化
- [ ] 完成localStorage持久化，同步主题状态
- [ ] 测试所有页面的主题切换效果，修复样式问题
```

## 六、与同类工具对比（Spec-Kit/GSD/Superpowers）
OpenSpec聚焦**AI编码场景的规格驱动开发**，与GitHub Spec-Kit、GSD、Superpowers相比，核心差异体现在**设计目标、适配场景、易用性、AI协同能力**上，以下为详细对比：

| 对比维度 | OpenSpec | GitHub Spec-Kit | GSD（规格驱动开发框架） | Superpowers |
|----------|----------|-----------------|------------------------|-------------|
| **核心设计目标** | 解决AI编码的上下文丢失、需求对齐问题，适配AI协同开发 | 为GitHub项目提供标准化的规格文档管理，聚焦团队协作的文档规范 | 传统开发的规格驱动，强调全量规格、阶段化流程 | 低代码/AI编码工具，聚焦快速生成代码，轻规格 |
| **适配场景** | AI结对编程、存量项目开发、多变更并行、中小团队敏捷开发 | GitHub生态项目、团队协作的规格文档标准化、开源项目规格管理 | 大型传统软件项目、严格的阶段化开发流程、全量规格定义 | 快速原型开发、简单功能生成、无复杂规格需求的AI编码 |
| **规格设计** | Delta Specs增量规格，无需全量定义，适配存量开发 | 全量规格模板，强调标准化文档结构，需按模板编写全量规格 | 全量规格驱动，瀑布式阶段化，要求先定义全量系统规格 | 无结构化规格，仅基于自然语言描述需求，无持久化规格 |
| **AI协同能力** | 深度适配AI，工件为AI设计，支持断点续跑、按清单执行、规格验证 | 无AI适配能力，仅为人工编写/阅读的规格文档模板 | 无AI适配能力，面向传统人工开发流程 | 强AI代码生成能力，弱规格管理，依赖临时对话上下文 |
| **目录/文件** | 轻量级Markdown文件，无数据库/服务端，本地持久化，易编辑 | 基于GitHub仓库的Markdown模板，需遵循固定目录结构 | 复杂的文档体系，含需求/设计/测试等多类重量级文档 | 无本地持久化规格文件，仅临时生成代码，无共识文档 |
| **流程灵活性** | 双Profile，自定义Schema，工件依赖为「使能而非门禁」，可跳步/调整 | 固定模板流程，需按规范编写文档，灵活性低 | 瀑布式阶段化流程，有严格的阶段门禁，灵活性差 | 无固定流程，纯自然语言驱动，无结构化流程 |
| **存量项目友好度** | 极高，无需前置补全规格，从首个变更开始渐进积累 | 中等，需按模板补全现有项目的全量规格文档 | 极低，需先定义全量系统规格，前置成本高 | 中等，可直接生成代码，但无规格积累，后续维护难 |
| **并行开发支持** | 强，变更目录完全隔离，Delta Specs自动解决冲突，支持bulk-archive | 中等，基于Git分支协作，需人工解决文档冲突 | 弱，全量规格易冲突，需严格的版本管理 | 无，基于单对话，不支持多功能并行开发 |
| **学习/使用成本** | 极低，无需学习复杂概念，Markdown易编辑，init后即可用 | 中等，需学习其规格模板和GitHub生态用法 | 极高，需学习完整的规格驱动开发流程和文档规范 | 极低，纯自然语言交互，无学习成本，但后续维护成本高 |
| **核心优势** | AI协同深度适配、增量规格、存量友好、断点续跑、规格与代码同步验证 | GitHub生态无缝集成、规格文档标准化、团队协作规范 | 全量规格可控、开发流程标准化、适合大型项目 | 上手快、代码生成效率高、适合快速原型 |
| **核心劣势** | 非GitHub生态项目的协作能力较弱 | 无AI适配，不支持AI编码，仅聚焦文档管理 | 流程僵化、前置成本高、不适配AI开发和敏捷开发 | 无持久化规格、需求对齐难、上下文丢失、后续维护混乱 |

### 6.1 工具选择建议
1. **选OpenSpec**：主要用AI写代码、存量项目开发、需要持久化共识、多功能并行开发、中小团队敏捷开发；
2. **选GitHub Spec-Kit**：纯人工开发、GitHub生态项目、需要标准化的团队协作规格文档、开源项目规格管理；
3. **选GSD**：大型传统软件项目、需要严格的阶段化开发流程、要求全量规格定义和强流程管控；
4. **选Superpowers**：快速原型开发、简单功能生成、无复杂规格需求、仅追求短期代码生成效率。

## 七、最佳实践（必看）
1. **归档前必执行verify**：抓住实现与规格的不一致，修复成本远低于归档后；
2. **一个变更一个职责**：变更名简洁明确（如add-dark-mode），避免杂项变更（如misc-improvements），否则拆分；
3. **生成工件后先审查再apply**：重点检查tasks.md的任务拆分和specs的边界条件，规格层面修改成本远低于代码层面；
4. **充分利用config.yaml**：将技术栈、代码规范等写入context，一次配置，所有变更自动继承，避免重复描述；
5. **apply前开新对话**：清空历史上下文，避免探索/讨论的噪音影响AI代码生成质量；
6. **高推理模型用在设计阶段**：propose/continue/ff阶段用Claude Opus/GPT-4，apply阶段可使用轻量模型；
7. **渐进式严格**：日常小变更用Lite Spec（简洁描述），高风险变更（跨团队/API变更）用Full Spec（详细场景/边界条件）；
8. **合理选择更新/新建变更**：意图不变仅调整方案→更新现有变更；需求完全变更/范围膨胀→新建变更。