# 本地大模型部署指南
> 本文详细介绍本地大模型部署的主流工具对比、Ollama安装配置、模型推荐、多模型运行、VSCode集成与AMD显卡优化配置。

## 目录

```
1. [主流部署工具对比](#一主流部署工具对比)
2. [Ollama安装与部署](#二ollama安装与部署)
3. [Ollama模型分类推荐](#三ollama模型分类推荐)
4. [Ollama多模型同时运行与OpenCode使用](#四ollama多模型同时运行与opencode使用)
6. [AMD核显Ollama全局优化配置](#五amd核显ollama全局优化配置)
5. [VSCode集成本地大模型](#六vscode集成本地大模型)
```

---

## 一、主流部署工具对比

| 工具 | 特点 | 适用场景 |
| ---- | ---- | ---- |
| Ollama | 一键安装、命令行/REST API、模型库丰富 | 个人用户、快速上手 |
| LM Studio | 图形界面、支持多种格式、内置聊天 | 非技术用户、可视化操作 |
| llama.cpp | 纯C++、极致性能优化、支持量化 | 开发者、边缘设备、低显存 |
| vLLM | 高吞吐、PagedAttention、OpenAI兼容API | 生产环境、API服务 |
| Text Generation Inference (TGI) | HuggingFace出品、多GPU支持 | 企业级部署 |
| xinference | 国产开源、支持多种模型类型 | 中文用户、多模型管理 |

### 硬件要求参考

| 模型规模 | 显存需求（FP16） | 显存需求（4-bit量化） | 推荐配置 |
| ---- | ---- | ---- | ---- |
| 7B | 14 GB | 4 GB | RTX 3060 12GB / M1 Pro 16GB |
| 13B | 26 GB | 8 GB | RTX 3090 24GB / M2 Max 32GB |
| 70B | 140 GB | 40 GB | 2×A100 80GB / 4×RTX 4090 |
| 满血版（如DeepSeek-R1 671B） | 1342 GB | 350 GB | 8×H100 或 多机集群 |

> 💡 CPU+内存方案：llama.cpp 支持纯CPU运行，32GB内存可跑7B量化模型，128GB可跑70B量化模型。

---

## 二、Ollama安装与部署

### 1. 核心简介

Ollama 是一款开源、跨平台的大模型一键运行工具，核心优势：
- 一键安装/运行上千款开源大模型，自动配置环境、量化优化
- 原生支持NVIDIA/AMD显卡加速，自动适配硬件
- 内置**OpenAI兼容API服务**，可对接IDE、Chat客户端、二次开发
- 完全离线运行，数据100%留在本地，无token费用

### 2. 安装前准备

#### 2.1 系统要求

| 系统 | 最低版本要求 |
|------|--------------|
| Windows | Windows 10 22H2 / Windows 11 及以上 |
| macOS | macOS 14 Sonoma 及以上（M系列芯片）/ macOS 12 及以上（Intel芯片） |
| Linux | 内核5.4及以上（Ubuntu/Debian优先适配） |

#### 2.2 硬件适配说明

- ✅ **完美适配**：7B/8B/9B参数模型，纯GPU流畅运行
- ⚠️ **可稳定运行**：13B/14B参数模型，显存+32G内存混合加载
- ❌ **不推荐**：30B以上大模型，易出现卡顿、内存溢出
- **关键前置**：AMD显卡必须安装**最新版Adrenalin驱动**（24.11.1+，支持ROCm 6.1+），否则无法启用GPU加速

#### 2.3 存储要求

- 安装包仅需100MB左右空间
- 模型存储建议预留**50GB以上NVMe SSD空间**（单个7B模型约4GB，14B约8GB）

### 3. 全平台详细安装步骤

#### 3.1 Windows 系统

##### 方法一：图形安装包（新手首选，100%成功）

1. 打开Ollama官网下载页：https://ollama.com/download
2. 点击 **Download for Windows**，下载 `OllamaSetup.exe` 安装包
3. 双击安装包，一路点击「Next」完成安装（自动配置系统环境变量，无需手动操作）
4. 安装完成后，Ollama会自动在后台运行，桌面右下角会出现小羊驼图标

> 自定义安装路径：如需安装到非C盘，用CMD执行 `OllamaSetup.exe /DIR="D:\Ollama"` 即可
> 自定义模型存储路径：添加用户环境变量 `OLLAMA_MODELS`，值为模型存放文件夹（如 `D:\Ollama\Models`），重启Ollama生效

##### 方法二：命令行一键安装（适合程序员）

以**管理员身份**打开PowerShell，执行以下命令：
```powershell
# 官方一键安装脚本
iwr -useb https://ollama.com/install.ps1 | iex
```

##### AMD显卡专属补充配置（必做，启用GPU加速）

如果安装后无法识别Radeon 860M，执行以下操作：
1. 下载AMD专属ROCm运行时：https://ollama.com/download/windows/amd
2. 解压压缩包，将所有文件复制到Ollama安装目录（默认 `C:\Users\你的用户名\AppData\Local\Programs\Ollama`）
3. 重启电脑，重新打开终端

#### 3.2 macOS 系统

##### 方法一：DMG安装包

1. 官网下载 `Ollama.dmg`：https://ollama.com/download/mac
2. 双击打开，将Ollama图标拖拽到「Applications」文件夹
3. 从应用程序打开Ollama，按提示完成初始化

##### 方法二：Homebrew安装

```bash
brew install ollama
```

#### 3.3 Linux 系统

一键安装脚本（Ubuntu/Debian/CentOS通用）：
```bash
curl -fsSL https://ollama.com/install.sh | sh
```
安装完成后，Ollama会自动作为系统服务运行，开机自启

### 4. 安装验证（必做）

安装完成后，打开终端（PowerShell/CMD/终端），执行以下命令验证：

#### 4.1 验证安装是否成功

```bash
ollama --version
```
> 正常输出示例：`ollama version is 0.5.2`，出现版本号即安装成功

#### 4.2 验证GPU是否被识别（关键）

```bash
ollama info
```
- NVIDIA显卡：输出中出现 `GPU: CUDA` 即加速生效
- AMD显卡：输出中出现 `GPU: Vulkan` 即加速生效
- 若只显示CPU，说明GPU驱动未正确配置，回到上文AMD专属配置步骤操作

### 5. 零基础入门：核心使用命令

#### 5.1 核心逻辑

Ollama所有操作都围绕「模型」展开，核心只有3步：**拉取模型 → 运行对话 → 管理模型**

#### 5.2 一键运行模型（新手最快体验）

直接执行以下命令，模型不存在会自动下载，下载完成后直接进入对话界面：
```bash
# 中文全能首选，适配你的AMD配置
ollama run qwen2.5:7b
```
> 运行后，直接输入问题回车即可对话，输入 `/exit` 退出对话，输入 `/help` 查看更多指令

#### 5.3 常用核心命令全解

| 命令 | 作用 | 示例 |
|------|------|------|
| `ollama pull 模型名` | 下载模型到本地 | `ollama pull deepseek-r1:7b` |
| `ollama run 模型名` | 运行模型，进入对话界面 | `ollama run qwen2.5-coder:7b` |
| `ollama list` | 查看本地已安装的所有模型 | `ollama list` |
| `ollama rm 模型名` | 删除本地模型，释放磁盘空间 | `ollama rm llama3.1:8b` |
| `ollama cp 原模型名 新模型名` | 复制模型，用于自定义修改 | `ollama cp qwen2.5:7b my-qwen` |
| `ollama serve` | 启动本地API服务（默认端口11434） | `ollama serve` |
| `ollama show 模型名` | 查看模型详情、配置、参数 | `ollama show qwen2.5:7b` |

### 6. 进阶使用（开发者必备）

#### 6.1 启动OpenAI兼容API服务

Ollama内置与OpenAI完全兼容的API接口，可直接对接VS Code、Cursor、ChatBox等客户端，实现本地AI编程、对话。

**步骤：**

1. 终端执行以下命令，启动API服务：
```bash
ollama serve
```
> 服务默认地址：`http://localhost:11434`，API路径：`http://localhost:11434/v1`

2. 调用示例（curl）：
```bash
curl http://localhost:11434/v1/chat/completions ^
  -H "Content-Type: application/json" ^
  -d "{\"model\": \"qwen2.5-coder:7b\", \"messages\": [{\"role\": \"user\", \"content\": \"用Python写一个冒泡排序算法\"}]}"
```

3. Python调用示例：
先安装依赖：`pip install openai`
```python
from openai import OpenAI

# 对接本地Ollama服务
client = OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"  # 任意非空字符串即可
)

# 发起对话请求
response = client.chat.completions.create(
    model="qwen2.5:7b",
    messages=[{"role": "user", "content": "你好，本地部署的大模型！"}]
)

print(response.choices[0].message.content)
```

#### 6.2 自定义模型配置（Modelfile）

通过Modelfile可以自定义模型的参数、提示词、上下文长度等，适配你的AMD硬件优化。

**示例：创建适配低显存的自定义模型**

步骤一：新建一个名为 `Modelfile` 的文件，写入以下内容：
```ini
# 基础模型，基于已下载的qwen2.5:7b
FROM qwen2.5:7b

# 全局参数优化（AMD Radeon 860M专属）
PARAMETER num_ctx 4096          # 上下文窗口长度
PARAMETER temperature 0.3       # 回答稳定性，数值越低越严谨
PARAMETER top_p 0.9             # 采样优化
PARAMETER low_vram true         # 启用低显存模式
PARAMETER num_threads 12        # 匹配你的Ryzen CPU线程数

# 系统提示词，自定义模型行为
SYSTEM """
你是一个专业的编程助手，擅长Python/Go/前端开发，回答简洁精准，附带代码注释。
"""
```

步骤二：执行命令创建自定义模型：
```bash
ollama create my-code-helper -f ./Modelfile
```

步骤三：运行自定义模型：
```bash
ollama run my-code-helper
```

#### 6.3 多模态图文模型使用

Ollama支持图文理解模型，可直接解析图片、文档、截图。

**示例：运行Qwen2.5多模态模型**
```bash
# 下载并运行多模态模型
ollama run qwen2.5-vl:7b "描述这张图片的内容" --images C:\Users\你的用户名\Pictures\test.png
```

#### 6.4 远程访问Ollama服务

如需在局域网内其他设备访问Ollama，添加系统环境变量：
```
变量名：OLLAMA_HOST
变量值：0.0.0.0
```
重启Ollama服务后，即可通过 `http://你的局域网IP:11434` 远程访问。

> 配置完成后，必须结束任务管理器中的`ollama.exe`进程，重新打开终端启动服务生效。

### 7. 常见问题与解决方案

#### 7.1 安装后执行`ollama`提示"不是内部或外部命令"

- 解决方案：重启电脑，让系统环境变量生效；若仍无效，手动将Ollama安装目录添加到系统PATH环境变量。

#### 7.2 AMD显卡不被识别，只用CPU运行

- 解决方案：
  1. 更新AMD Adrenalin驱动到最新版
  2. 安装AMD ROCm运行时到Ollama目录
  3. 添加环境变量 `OLLAMA_GPU=vulkan`
  4. 重启电脑

#### 7.3 模型下载速度慢/下载失败

- 解决方案：
  1. 配置终端代理，或使用国内镜像源
  2. 手动下载GGUF模型，通过Modelfile导入本地模型
  3. 检查网络，关闭VPN/防火墙干扰

#### 7.4 运行模型提示"显存不足/Out of Memory"

- 解决方案：
  1. 换用更小参数量的模型，或启用INT4量化版本
  2. 添加环境变量 `OLLAMA_LOW_VRAM=true`
  3. 关闭浏览器、游戏等占用显存的程序
  4. 减小`num_ctx`上下文窗口长度

#### 7.5 API调用无响应/连接失败

- 解决方案：
  1. 确认`ollama serve`已正常运行，端口11434未被占用
  2. 关闭防火墙/杀毒软件的拦截
  3. 检查base_url是否正确，结尾不要加斜杠

### 9. 新手必装模型推荐（适配你的配置）

| 模型名 | 一键安装命令 | 适用场景 |
|--------|--------------|----------|
| Qwen2.5-7B | `ollama pull qwen2.5:7b` | 中文全能主力，日常对话、文案、办公 |
| Qwen2.5-Coder-7B | `ollama pull qwen2.5-coder:7b` | 编程开发、代码生成、调试排错 |
| DeepSeek-R1-7B | `ollama pull deepseek-r1:7b` | 逻辑推理、数学计算、复杂问题拆解 |

> 完整模型库可访问Ollama官网：https://ollama.com/library，上千款模型全部支持一键安装。

---

## 三、Ollama模型分类推荐

截至2026年5月，Ollama官方模型库（https://ollama.com/library）收录了**上千款开源大模型**，覆盖全场景、全参数量级，所有模型均支持一键`pull/run`，自动适配Windows/macOS/Linux，默认提供INT4量化优化，完美兼容你的**AMD Radeon 860M + 32G内存**配置。

### 1. 中文全能主力模型（优先推荐）

专为中文场景优化，适配日常对话、文案写作、文档总结、办公场景，你的硬件可流畅运行。

| 模型名称 | 一键拉取命令 | 核心特点 | 适配你的硬件 |
|---------|--------------|---------|-------------|
| Qwen2.5-7B（通义千问） | `ollama pull qwen2.5:7b` | 阿里官方旗舰，中文能力天花板，平衡性能与效果，支持长上下文 | ✅ 纯GPU流畅跑，显存占用≈4GB |
| Qwen2.5-14B | `ollama pull qwen2.5:14b` | 中文全能王，长文本/复杂任务能力远超7B，综合性能对标闭源模型 | ⚠️ 显存+32G内存混合运行，显存占用≈4GB |
| GLM-4-9B（智谱AI） | `ollama pull glm4:9b` | 对标Kimi的国产旗舰，中文理解、长文档总结能力极强，商用友好 | ✅ 纯GPU流畅跑，显存占用≈5GB |
| GLM-5 | `ollama pull glm5:latest` | 2026年最新开源旗舰，推理/编程/中文全面升级，SWE-bench高分 | ⚠️ 显存+内存混合运行，32G内存无压力 |
| Kimi K2.5 | `ollama pull kimi-k2.5:full` | 月之暗面官方开源，超长上下文（26万tokens），文档处理能力拉满 | ✅ 纯GPU流畅跑，显存占用≈4.5GB |
| Yi-1.5-9B | `ollama pull yi:9b-v1.5` | 零一万物开源，中文创作/逻辑推理能力突出，上下文窗口128K | ✅ 纯GPU流畅跑，显存占用≈5GB |

### 2. 编程代码专用模型（你重点关注的开发场景）

专为代码生成、调试、重构、补全优化，支持20+编程语言，适配全栈开发场景。

| 模型名称 | 一键拉取命令 | 核心特点 | 适配你的硬件 |
|---------|--------------|---------|-------------|
| Qwen2.5-Coder-7B | `ollama pull qwen2.5-coder:7b` | 阿里代码专属模型，中文注释/全栈开发适配最好，小模型代码能力天花板 | ✅ 纯GPU流畅跑，显存占用≈4GB |
| DeepSeek-Coder-V2-7B | `ollama pull deepseek-coder-v2:7b` | 深度求索开源，复杂算法/项目重构能力强，支持128K上下文 | ✅ 纯GPU流畅跑，显存占用≈4GB |
| CodeLlama-7B-Instruct | `ollama pull codellama:7b-instruct` | Meta官方代码模型，社区生态最完善，兼容各类IDE插件 | ✅ 纯GPU流畅跑，显存占用≈4GB |
| CodeLlama-13B-Instruct | `ollama pull codellama:13b-instruct` | 大参数量专业代码模型，复杂项目/底层开发能力远超7B | ⚠️ 显存+内存混合运行，32G内存无压力 |
| CodeGemma-7B | `ollama pull codegemma:7b` | Google基于Gemini技术开发，代码补全/数学推理双优，低功耗优化 | ✅ 纯GPU流畅跑，显存占用≈4GB |
| StarCoder2-7B | `ollama pull starcoder2:7b` | 开源社区标杆，支持80+编程语言，适配GitHub Copilot类场景 | ✅ 纯GPU流畅跑，显存占用≈4GB |

### 3. 强逻辑/数学/推理专用模型

专为复杂问题拆解、数学计算、逻辑分析、算法设计优化，推理能力对标GPT-4。

| 模型名称 | 一键拉取命令 | 核心特点 | 适配你的硬件 |
|---------|--------------|---------|-------------|
| DeepSeek-R1-7B | `ollama pull deepseek-r1:7b` | 2026年推理标杆，数学/逻辑能力远超同参数量模型，思维链能力突出 | ✅ 纯GPU流畅跑，显存占用≈4GB |
| Llama3.1-8B | `ollama pull llama3.1:8b` | Meta旗舰，全球公认GPT平替，通用推理/多语言/代码能力均衡 | ✅ 纯GPU流畅跑，显存占用≈4.5GB |
| WizardMath-7B-V1.1 | `ollama pull wizardmath:7b-v1.1` | 数学推理专用模型，高数/线代/奥数解题能力拉满 | ✅ 纯GPU流畅跑，显存占用≈4GB |
| Phi-4-3.8B | `ollama pull phi4:3.8b` | 微软小钢炮，3.8B参数推理能力对标7B，速度极快，显存占用极低 | ✅ 秒开，显存占用≈2GB |
| Gemma3-7B | `ollama pull gemma3:7b` | Google Gemini同技术栈，逻辑严谨，低功耗优化，适配AMD硬件 | ✅ 纯GPU流畅跑，显存占用≈4GB |

### 4. 国际通用全能模型（GPT/Gemini平替）

全球主流开源旗舰，多语言能力强，通用场景适配，适合英文对话、海外业务、跨语言创作。

| 模型名称 | 一键拉取命令 | 核心特点 | 适配你的硬件 |
|---------|--------------|---------|-------------|
| Llama3.3-70B | `ollama pull llama3.3:70b` | Meta最新旗舰，性能接近GPT-4，综合能力开源天花板 | ❌ 你的硬件不推荐，显存/内存需求过高 |
| Llama3.2-3B | `ollama pull llama3.2:3b` | 轻量全能，速度极快，日常对话/轻量任务无压力 | ✅ 秒开，显存占用≈2GB |
| Gemma4-E4B | `ollama pull gemma4:e4b` | Google Gemini官方开源平替，继承Gemini核心能力，多模态支持 | ✅ 纯GPU流畅跑，显存占用≈3GB |
| Mistral-7B-v0.3 | `ollama pull mistral:7b-v0.3` | 开源标杆，推理速度快，显存占用低，社区生态完善 | ✅ 纯GPU流畅跑，显存占用≈4GB |
| GPT-OSS-20B | `ollama pull gpt-oss:20b` | OpenAI官方开源模型，模拟GPT推理逻辑，工具调用能力强 | ⚠️ 显存+32G内存混合运行，需关闭冗余软件 |

### 5. 轻量极速小模型（零压力秒开）

参数量小、速度极快，4GB显存即可流畅运行，适合日常轻量对话、快速补全、低功耗场景，你的配置可秒开。

| 模型名称 | 一键拉取命令 | 核心特点 | 显存占用 |
|---------|--------------|---------|---------|
| Qwen2.5-3B | `ollama pull qwen2.5:3b` | 中文轻量天花板，日常对话/文案完全够用 | ≈2GB |
| Gemma3-2B | `ollama pull gemma3:2b` | Google出品，稳定高效，多语言支持优秀 | ≈1.5GB |
| DeepSeek-R1-1.5B | `ollama pull deepseek-r1:1.5b` | 超轻量推理模型，逻辑能力远超同参数量级 | ≈1GB |
| LFM2.5-1.2B-Thinking | `ollama pull lfm2.5:1.2b-thinking` | 端侧神器，纯CPU也能跑满速，支持代码/推理 | <1GB |
| Granite-4.0-350M | `ollama pull granite:4.0-h-350m` | IBM超轻量模型，集成显卡也能流畅运行 | ≈300MB |

### 6. 多模态图文理解模型（可识别图片/文档/图表）

支持图片+文本混合输入，可解析截图、文档、图表、照片，适配OCR、图文问答、文档分析场景。

| 模型名称 | 一键拉取命令 | 核心特点 | 适配你的硬件 |
|---------|--------------|---------|-------------|
| Qwen2.5-VL-7B | `ollama pull qwen2.5-vl:7b` | 阿里多模态旗舰，中文图文理解最强，支持表格/公式/文档解析 | ✅ 纯GPU流畅跑，显存占用≈5GB |
| Llama 3.2 Vision-11B | `ollama pull llama3.2-vision:11b` | Meta官方多模态，图文推理能力强，支持长文档图片 | ⚠️ 显存+内存混合运行，32G内存无压力 |
| GLM-4V-9B | `ollama pull glm4v:9b` | 智谱AI多模态，中文场景适配最好，支持截图问答/图表分析 | ✅ 纯GPU流畅跑，显存占用≈5GB |
| LLaVA-1.6-7B | `ollama pull llava:7b-v1.6` | 开源多模态标杆，社区生态完善，适配各类插件 | ✅ 纯GPU流畅跑，显存占用≈4.5GB |

### 7. 特殊场景专用模型

#### 7.1 RAG/长文档优化模型

- Llama3-Gradient-8B：`ollama pull llama3-gradient:8b`，支持100万tokens超长上下文，专为知识库RAG优化
- Qwen2.5-7B-128K：`ollama pull qwen2.5:7b-instruct-128k`，128K上下文窗口，长文档一次性加载

#### 7.2 Agent/函数调用模型

- Firefunction-v2-7B：`ollama pull firefunction-v2:7b`，函数调用能力对标GPT-4o，支持复杂API交互
- Llama3-Groq-Tool-Use-8B：`ollama pull llama3-groq-tool-use:8b`，专为工具调用优化，支持多轮Agent执行

#### 7.3 垂直领域模型

- MedLlama2-7B：`ollama pull medllama2:7b`，医疗问答专用模型
- LawLlama-7B：`ollama pull lawllama:7b`，法律条文/案例分析专用模型
- SQLCoder-7B：`ollama pull sqlcoder:7b`，SQL语句生成/优化专用模型

#### 7.4 嵌入模型（RAG必备）

- nomic-embed-text：`ollama pull nomic-embed-text`，开源顶级文本嵌入模型，适配本地知识库
- bge-m3：`ollama pull bge-m3`，中文嵌入天花板，支持多语言/长文本，RAG首选

### 7. 补充说明

#### 7.1 针对你的硬件的终极选型建议

- **日常主力**：`qwen2.5:7b`（中文全能）+ `qwen2.5-coder:7b`（编程）
- **推理优先**：`deepseek-r1:7b` + `llama3.1:8b`
- **长文档处理**：`glm4:9b` + `kimi-k2.5:full`
- **不推荐**：30B以上大模型，会出现卡顿、内存溢出，体验极差

#### 7.2 查看全量模型的方式

- 官方库：访问 https://ollama.com/library 可查看所有模型的完整详情、版本、参数
- 本地查看已安装模型：执行 `ollama list`
- 查看模型详情：执行 `ollama show 模型名 --modelfile`

---

## 四、Ollama多模型同时运行与OpenCode使用

适配你的**AMD Ryzen AI 7 H350 + Radeon 860M + 32G内存**配置，全程复制可用，核心结论先给你：
> Ollama天生支持多模型同时管理运行，只需修改2个核心环境变量即可解锁；OpenCode可通过**OpenAI兼容API**直接对接Ollama的所有模型，实现多模型一键切换、分工调用，你的配置最优可稳定同时运行2个7B级模型。

### 1. 核心原理先搞懂（避免踩坑）

#### 1.1 Ollama 多模型运行的底层逻辑

Ollama是**客户端-服务端(C/S)架构**，核心规则：
- 仅需启动**1次`ollama serve`后台服务**，所有模型都由这个服务统一管理，无需开多个服务（开多个会端口冲突）
- 模型的加载、卸载、推理全由后台服务调度，支持同时加载多个模型，可同时响应多个客户端的调用（OpenCode、多个终端对话、API请求）
- 默认限制：Ollama默认仅允许**同时加载1个模型**，闲置5分钟自动卸载，需修改环境变量解锁多模型能力

#### 1.2 你的硬件适配边界（精准控制不爆显存/内存）

| 同时运行模型组合 | 显存占用 | 内存占用 | 适配性 |
|------------------|----------|----------|--------|
| 2个7B/8B级模型（推荐） | 3.5~5GB（860M显存范围内） | 10~15GB | ✅ 完美流畅，无卡顿 |
| 1个14B + 1个7B模型 | 4~5.5GB | 18~22GB | ⚠️ 可运行，需关闭浏览器等冗余软件 |
| 3个及以上7B模型 | 5GB+ | 20GB+ | ❌ 不推荐，易显存溢出、推理速度骤降 |

### 2. 第一步：配置Ollama支持多模型同时运行（Windows专属）

#### 2.1 配置核心环境变量（和你之前的AMD优化完全兼容）

这是解锁多模型的**核心步骤**，必须操作：
1. 按下 `Win + R` 输入 `sysdm.cpl` 回车，打开「系统属性」
2. 切换到「高级」→ 点击「环境变量」→ 在「系统变量」里，依次新建以下变量：

| 变量名 | 变量值 | 核心作用 |
|--------|--------|----------|
| `OLLAMA_MAX_LOADED_MODELS` | `2` | 允许同时加载的最大模型数（你的配置建议设2，最多设3） |
| `OLLAMA_KEEP_ALIVE` | `-1` | 模型常驻内存的时长：`-1`=永久常驻，不会自动卸载；也可设`30m`=30分钟闲置后卸载 |
| `OLLAMA_GPU` | `vulkan` | 强制启用AMD显卡加速（之前已配可跳过） |
| `OLLAMA_MAX_VRAM` | `3686` | 单模型最大显存占用3.6GB，避免单模型占满显存（之前已配可跳过） |
| `OLLAMA_HOST` | `0.0.0.0` | 允许局域网/本地所有客户端访问（OpenCode对接必备） |

#### 2.2 重启Ollama服务，让配置生效

1. 关闭所有正在运行的Ollama终端、对话窗口
2. 打开「任务管理器」→ 「详细信息」→ 找到`ollama.exe`，右键结束进程
3. 重新打开PowerShell/终端，执行以下命令启动后台服务：
```bash
ollama serve
```
> 终端显示`Listening on [::]:11434`，说明服务启动成功，**不要关闭这个终端**（关闭服务就停了）

#### 2.3 验证多模型配置是否生效

新开一个PowerShell终端，执行：
```bash
ollama info
```
在输出的「Config」部分，能看到你设置的`max_loaded_models=2`、`keep_alive=-1`，说明配置成功。

### 3. 第二步：多模型同时运行的2种正确方式

#### 方式1：API调用自动加载（OpenCode对接首选）

无需手动提前运行模型，OpenCode通过API调用时，Ollama会自动加载对应模型，已加载的模型会常驻内存，实现秒切秒响应。

**示例：同时调用2个模型，验证是否都能正常响应（新开终端执行）**
```bash
# 调用第一个模型：qwen2.5:7b（通用）
curl http://localhost:11434/v1/chat/completions ^
  -H "Content-Type: application/json" ^
  -d "{\"model\": \"qwen2.5:7b\", \"messages\": [{\"role\": \"user\", \"content\": \"你好\"}]}"

# 调用第二个模型：qwen2.5-coder:7b（代码）
curl http://localhost:11434/v1/chat/completions ^
  -H "Content-Type: application/json" ^
  -d "{\"model\": \"qwen2.5-coder:7b\", \"messages\": [{\"role\": \"user\", \"content\": \"写一行Python打印Hello World\"}]}"
```
> 两个请求都正常返回结果，说明多模型同时运行成功；可打开任务管理器，看到NPU/显卡/内存都有对应占用。

#### 方式2：同时开多个终端对话窗口

适合手动测试多模型效果，每个终端对应一个模型，互不干扰：
1. 终端1：`ollama run qwen2.5:7b`（通用对话）
2. 终端2：`ollama run qwen2.5-coder:7b`（代码生成）
3. 两个窗口可同时对话，Ollama后台服务会同时调度两个模型，不会冲突。

### 4. 第三步：在OpenCode中配置&使用多个Ollama模型

针对你之前关注的**OpenCode IDE代码助手**、**Oh My OpenAgent Agent生态**两个核心场景，分别给出可直接复制的配置方案。

#### 场景1：OpenCode 代码编辑器/IDE 基础配置（多模型切换）

适用于OpenCode桌面端、VS Code OpenCode插件，核心是对接Ollama的OpenAI兼容API，添加多个模型。

**步骤1：基础API配置（全局只配1次）**

在 `opencode.json` 或 `opencode.jsonc` 文件中进行配置：

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "list",
    "opencode-helicone-session",
    "@my-org/custom-plugin",
    "opencode-wakatime"
  ],
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (本地)",
      "options": {
        "baseURL": "http://localhost:11434/v1",
        "apiKey": "ollama"
      },
      "models": {
        "MFDoom/deepseek-coder-v2-tool-calling:16b": {
          "name": "MFDoom/deepseek-coder-v2-tool-calling:16b"
        },
        "qwen2.5-coder:14b": {
          "name": "qwen2.5-coder:14b"
        },
        "codellama:13b-code": {
          "name": "codellama:13b-code"
        },
        "llama3.1:latest": {
          "name": "llama3.1:latest"
        },
        "qwen3.5:9b": {
              "name": "qwen3.5:9b"
        },
        "deepseek-r1:7b": {
              "name": "deepseek-r1:7b"
        }
      }
    }
  },
  "model": "ollama/qwen2.5-coder:14b"
}
```

**步骤2：在OpenCode中使用多个模型**

1. **代码补全**：在设置里，把「代码补全默认模型」设为`qwen2.5-coder:7b`（代码专用模型，补全更精准）
2. **对话聊天**：在OpenCode对话窗口，顶部可一键切换模型，比如：
   - 写文档、需求分析：切换到`qwen3.5:9b`（中文全能）
   - 调试代码、写算法：切换到`qwen2.5-coder:7b`（代码专用）
   - 逻辑推理、问题拆解：切换到`deepseek-r1:7b`（推理专用）
3. 所有模型调用都是本地离线运行，数据不经过云端，和Ollama终端效果完全一致。

#### 场景2：Oh My OpenAgent 多模型高级配置（Agent分工调用）

适用于你之前关注的OpenCode Agent生态，可实现**不同任务自动调用对应模型**，比如代码生成用Coder模型、推理用DeepSeek模型、文档用通义千问模型。

**步骤1：修改Agent配置文件，添加多个Ollama模型**

1. 打开你的Oh My OpenAgent项目根目录，找到配置文件（通常是`config.json`/`agent_config.json`）
2. 在`model_providers`数组里，添加多个Ollama模型配置，完整示例直接复制：
```json
{
  "model_providers": [
    {
      "name": "Ollama-通用对话",
      "type": "openai",
      "api_base": "http://localhost:11434/v1",
      "api_key": "ollama",
      "model": "qwen2.5:7b",
      "is_default": true
    },
    {
      "name": "Ollama-代码生成",
      "type": "openai",
      "api_base": "http://localhost:11434/v1",
      "api_key": "ollama",
      "model": "qwen2.5-coder:7b"
    },
    {
      "name": "Ollama-逻辑推理",
      "type": "openai",
      "api_base": "http://localhost:11434/v1",
      "api_key": "ollama",
      "model": "deepseek-r1:7b"
    }
  ]
}
```
3. 保存配置文件，重启OpenCode Agent服务，配置自动生效。

**步骤2：在Skill/Agent中指定模型调用**

在你编写的OpenCode Skill、Agent流程中，可直接指定用哪个模型处理对应任务，示例：
```python
# 代码生成任务，指定用代码专用模型
code_result = agent.run(
    prompt="用Python写一个FastAPI用户登录接口",
    model_provider="Ollama-代码生成"
)

# 逻辑推理任务，指定用推理专用模型
reason_result = agent.run(
    prompt="拆解这个项目的开发流程",
    model_provider="Ollama-逻辑推理"
)

# 日常对话，用默认的通用模型
chat_result = agent.run(prompt="写一段项目说明文档")
```

### 5. 你的AMD硬件专属优化&避坑指南

#### 5.1 最优多模型组合推荐（你的配置专属）

| 组合类型 | 模型1 | 模型2 | 适用场景 |
|----------|-------|-------|----------|
| 全能开发组合（首选） | qwen2.5:7b（通用/文档） | qwen2.5-coder:7b（代码/调试） | 日常编程、全栈开发、办公写作 |
| 强推理组合 | qwen2.5:7b（通用） | deepseek-r1:7b（逻辑/数学） | 算法设计、复杂问题拆解、数据分析 |
| 国产平替组合 | glm4:9b（对标Kimi） | qwen2.5-coder:7b（代码） | 中文长文档、办公场景、代码开发 |

#### 5.2 必看避坑指南

1. **绝对不要开多个`ollama serve`**：只需启动1次后台服务，开多个会导致11434端口冲突，OpenCode无法连接
2. **模型名称必须完全匹配**：OpenCode里填写的模型名，必须和`ollama list`里的名称完全一致（包括tag，比如`qwen2.5:7b`不能写成`qwen2.5`）
3. **防火墙拦截问题**：如果OpenCode连接失败，打开Windows防火墙，放行11434端口，或直接关闭临时防火墙测试
4. **显存溢出解决**：如果出现卡顿、模型加载失败，把`OLLAMA_MAX_LOADED_MODELS`改回2，关闭浏览器、视频软件等占用显存的程序
5. **模型自动卸载**：如果模型经常被自动卸载，确认`OLLAMA_KEEP_ALIVE`设为`-1`，且ollama serve终端没有被关闭

#### 5.3 常用排查命令

```bash
# 查看本地已安装的所有模型（确认模型名正确）
ollama list

# 查看Ollama服务运行状态、配置、GPU识别情况
ollama info

# 停止Ollama服务（Windows）
taskkill /f /im ollama.exe
```

---

## 五、AMD 核显专属 Ollama 全局优化配置（Radeon 860M + 32G内存）
直接全套配置，**复制即用**，解决卡顿、显存溢出、CPU占用高、风扇狂转，适配你的：
Ryzen AI 7 H350 + Radeon 860M + 32G 大内存

### 1. 修改 Ollama 全局环境变量（关键）

针对你的**Radeon 860M + 32G内存**，添加以下系统环境变量，解决卡顿、显存溢出、GPU不识别问题：

| 变量名 | 变量值 | 作用 |
|--------|--------|------|
| `OLLAMA_GPU` | `vulkan` | 强制启用AMD Vulkan GPU加速 |
| `OLLAMA_MAX_VRAM` | `3686` | 限制最大显存占用3.6GB，适配860M的4-6GB显存，防爆显存 |
| `OLLAMA_NUM_THREADS` | `12` | 匹配Ryzen AI 7 H350的多核，平衡速度与功耗 |
| `OLLAMA_LOW_VRAM` | `true` | 全局启用低显存模式，自动分片加载模型 |

> 线程数：Ryzen AI 7 H350 多核，设 12 刚好平衡速度与功耗

### 2. 模型全局默认参数（运行更快）
以后所有模型自动生效，不用每次手动加参数

#### 方式：新建/编辑 Ollama 配置文件
1. 路径：
```
C:\Users\你的用户名\.ollama\modelfile
```
2. 写入以下内容：
```ini
## 上下文窗口 4096（日常/编程/文本足够）
PARAMETER num_ctx 4096

## 关闭随机脑洞，回答更稳定精准
PARAMETER temperature 0.3

## 关闭长文本冗余
PARAMETER top_p 0.9

## 缓存优化，加速重复对话
PARAMETER num_cache 2048

## 自动显存分片，AMD核显专用
PARAMETER low_vram true
```

---

### 3. 重启生效（必须操作）
1. 关闭所有命令行、终端
2. 任务管理器 → 结束进程：`ollama.exe`
3. 重新打开 PowerShell，执行：
```powershell
ollama serve
```

---

### 4. 不同模型 推荐运行方案（按你机器精准划分）
#### ✅ 全速 GPU 运行（7B/8B 系列）
- deepseek-r1:7b
- deepseek-coder-v2:7b
- qwen2.5-coder:7b
- llama3.1:8b
- gemma3:7b
- glm4:9b

#### ⚙️ 显存+内存混合运行（13B/14B 系列，32G内存刚好）
- codellama:13b-instruct
- qwen2.5:14b

运行大号模型时，建议**关闭浏览器、视频软件**，避免内存争抢。

---

### 5. 一键检测是否生效
```powershell
## 查看显卡是否识别
ollama info
```
看到 `GPU: Vulkan` 即为优化全部生效。

---

### 6. 附赠：日常最强 3 模型最终组合
直接复制安装即可长期使用
```powershell
## 1. 中文办公/总结/写作（对标Kimi）
ollama pull glm4:9b

## 2. 编程开发专属
ollama pull qwen2.5-coder:7b

## 3. 逻辑推理/通用全能（对标GPT）
ollama pull llama3.1:8b
```

---

## 六、VSCode集成本地大模型

### 1. 方案一：Continue 插件（强烈推荐）

Continue 是 VS Code 中最强大的 AI 编程助手，完美支持本地 Ollama。

#### 1.1 安装插件

- VS Code → 扩展 → 搜索 `Continue` → 安装

#### 1.2 配置 `config.json`

按 `Ctrl+Shift+P` → `Continue: Open Config.json`：

```json
{
  "models": [
    {
      "title": "Qwen Coder 14B",
      "provider": "ollama",
      "model": "qwen2.5-coder:14b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "DeepSeek R1 14B",
      "provider": "ollama",
      "model": "deepseek-r1:14b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "Qwen Chat 14B",
      "provider": "ollama",
      "model": "qwen2.5:14b",
      "apiBase": "http://localhost:11434"
    }
  ],
  "tabAutocompleteModel": {
    "title": "Qwen Coder",
    "provider": "ollama",
    "model": "qwen2.5-coder:14b",
    "apiBase": "http://localhost:11434"
  },
  "customCommands": [
    {
      "name": "explain",
      "prompt": "{{{ input }}}\n\n用中文详细解释这段代码的工作原理：",
      "description": "解释代码"
    },
    {
      "name": "refactor",
      "prompt": "{{{ input }}}\n\n重构这段代码，提高可读性和性能，并说明改进点：",
      "description": "重构代码"
    }
  ],
  "contextProviders": [
    {
      "name": "code",
      "params": {}
    },
    {
      "name": "docs",
      "params": {}
    }
  ]
}
```

#### 1.3 使用方式

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+L` | 打开侧边栏对话 |
| `Ctrl+I` | 内联编辑（选中代码后） |
| `Tab` | 自动补全代码 |
| `Ctrl+Shift+L` | 快速切换模型 |

### 2. 方案二：CodeGPT 插件

更适合轻量级使用：

1. 安装 `CodeGPT` 扩展
2. 设置 → CodeGPT → Provider 选择 `Ollama`
3. Model 填写 `qwen2.5-coder:14b`

### 3. 方案三：自定义 VS Code 任务

创建 `.vscode/tasks.json`：

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Ollama: 启动代码模型",
      "type": "shell",
      "command": "powershell",
      "args": ["-File", "${workspaceFolder}/scripts/switch-model.ps1", "-Mode", "code"],
      "group": "build"
    },
    {
      "label": "Ollama: 启动推理模型",
      "type": "shell",
      "command": "powershell",
      "args": ["-File", "${workspaceFolder}/scripts/switch-model.ps1", "-Mode", "reason"],
      "group": "build"
    },
    {
      "label": "Ollama: 停止所有模型",
      "type": "shell",
      "command": "ollama stop qwen2.5-coder:14b; ollama stop deepseek-r1:14b; ollama stop qwen2.5:14b",
      "group": "build"
    }
  ]
}
```

按 `Ctrl+Shift+P` → `Tasks: Run Task` 选择执行。

### 4. 完整工作流配置

#### 4.1 项目结构建议

```
my-project/
├── .vscode/
│   ├── tasks.json          # VS Code 任务
│   └── settings.json       # 编辑器设置
├── scripts/
│   ├── switch-model.ps1    # 切换脚本
│   ├── code.bat            # 快捷方式
│   ├── reason.bat
│   └── chat.bat
└── Modelfile               # 自定义模型配置
```

#### 4.2 `.vscode/settings.json`

```json
{
  "continue.enableTabAutocomplete": true,
  "continue.telemetryEnabled": false,
  "editor.inlineSuggest.enabled": true,
  "editor.quickSuggestions": {
    "comments": "inline",
    "strings": "inline",
    "other": "inline"
  }
}
```

### 5. 一键初始化脚本

创建 `setup.ps1`：

```powershell
Write-Host "🚀 初始化 Ollama + VS Code 开发环境" -ForegroundColor Cyan

# 1. 下载模型
$models = @("qwen2.5-coder:14b", "deepseek-r1:14b", "qwen2.5:14b")
foreach ($m in $models) {
    Write-Host "`n📥 下载模型: $m" -ForegroundColor Yellow
    ollama pull $m
}

# 2. 创建目录结构
New-Item -ItemType Directory -Force -Path "scripts", ".vscode" | Out-Null

# 3. 创建切换脚本（内容同上，略）
# ...

Write-Host "`n✅ 环境初始化完成！" -ForegroundColor Green
Write-Host "💡 使用方式：" -ForegroundColor Cyan
Write-Host "   .\scripts\switch-model.ps1 -Mode code    # 编程模式"
Write-Host "   .\scripts\switch-model.ps1 -Mode reason  # 推理模式"
Write-Host "   .\scripts\switch-model.ps1 -Mode chat    # 对话模式"
Write-Host "   VS Code 安装 Continue 插件后按 Ctrl+L 开始对话"
```

---