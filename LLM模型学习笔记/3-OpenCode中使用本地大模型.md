# Ollama 多模型同时运行 + OpenCode 对接完整指南
适配你的**AMD Ryzen AI 7 H350 + Radeon 860M + 32G内存**配置，全程复制可用，核心结论先给你：
> Ollama天生支持多模型同时管理运行，只需修改2个核心环境变量即可解锁；OpenCode可通过**OpenAI兼容API**直接对接Ollama的所有模型，实现多模型一键切换、分工调用，你的配置最优可稳定同时运行2个7B级模型。

---

## 一、核心原理先搞懂（避免踩坑）
### 1. Ollama 多模型运行的底层逻辑
Ollama是**客户端-服务端(C/S)架构**，核心规则：
- 仅需启动**1次`ollama serve`后台服务**，所有模型都由这个服务统一管理，无需开多个服务（开多个会端口冲突）
- 模型的加载、卸载、推理全由后台服务调度，支持同时加载多个模型，可同时响应多个客户端的调用（OpenCode、多个终端对话、API请求）
- 默认限制：Ollama默认仅允许**同时加载1个模型**，闲置5分钟自动卸载，需修改环境变量解锁多模型能力

### 2. 你的硬件适配边界（精准控制不爆显存/内存）
| 同时运行模型组合 | 显存占用 | 内存占用 | 适配性 |
|------------------|----------|----------|--------|
| 2个7B/8B级模型（推荐） | 3.5~5GB（860M显存范围内） | 10~15GB | ✅ 完美流畅，无卡顿 |
| 1个14B + 1个7B模型 | 4~5.5GB | 18~22GB | ⚠️ 可运行，需关闭浏览器等冗余软件 |
| 3个及以上7B模型 | 5GB+ | 20GB+ | ❌ 不推荐，易显存溢出、推理速度骤降 |

---

## 二、第一步：配置Ollama支持多模型同时运行（Windows专属）
### 1. 配置核心环境变量（和你之前的AMD优化完全兼容）
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

### 2. 重启Ollama服务，让配置生效
1. 关闭所有正在运行的Ollama终端、对话窗口
2. 打开「任务管理器」→ 「详细信息」→ 找到`ollama.exe`，右键结束进程
3. 重新打开PowerShell/终端，执行以下命令启动后台服务：
```bash
ollama serve
```
> 终端显示`Listening on [::]:11434`，说明服务启动成功，**不要关闭这个终端**（关闭服务就停了）

### 3. 验证多模型配置是否生效
新开一个PowerShell终端，执行：
```bash
ollama info
```
在输出的「Config」部分，能看到你设置的`max_loaded_models=2`、`keep_alive=-1`，说明配置成功。

---

## 三、第二步：多模型同时运行的2种正确方式
### 方式1：API调用自动加载（OpenCode对接首选）
无需手动提前运行模型，OpenCode通过API调用时，Ollama会自动加载对应模型，已加载的模型会常驻内存，实现秒切秒响应。

示例：同时调用2个模型，验证是否都能正常响应（新开终端执行）
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

### 方式2：同时开多个终端对话窗口
适合手动测试多模型效果，每个终端对应一个模型，互不干扰：
1. 终端1：`ollama run qwen2.5:7b`（通用对话）
2. 终端2：`ollama run qwen2.5-coder:7b`（代码生成）
3. 两个窗口可同时对话，Ollama后台服务会同时调度两个模型，不会冲突。

---

## 四、第三步：在OpenCode中配置&使用多个Ollama模型
针对你之前关注的**OpenCode IDE代码助手**、**Oh My OpenAgent Agent生态**两个核心场景，分别给出可直接复制的配置方案。

### 场景1：OpenCode 代码编辑器/IDE 基础配置（多模型切换）
适用于OpenCode桌面端、VS Code OpenCode插件，核心是对接Ollama的OpenAI兼容API，添加多个模型。

#### 步骤1：基础API配置（全局只配1次）
1. 打开OpenCode → 左下角「设置」→ 「AI模型配置」→ 「添加模型提供商」
2. 选择「OpenAI兼容格式」，填写以下核心配置：
   | 配置项 | 填写内容 |
   |--------|----------|
   | 提供商名称 | Ollama（可自定义） |
   | API Base地址 | `http://localhost:11434/v1` |
   | API Key | `ollama`（随便填非空字符串即可，Ollama无需密钥） |
   | 模型列表 | 手动添加你已安装的模型，一行一个，例如：<br>`qwen2.5:7b`<br>`qwen2.5-coder:7b`<br>`deepseek-r1:7b` |
3. 点击「测试连接」，显示连接成功，保存配置。

#### 步骤2：在OpenCode中使用多个模型
1. **代码补全**：在设置里，把「代码补全默认模型」设为`qwen2.5-coder:7b`（代码专用模型，补全更精准）
2. **对话聊天**：在OpenCode对话窗口，顶部可一键切换模型，比如：
   - 写文档、需求分析：切换到`qwen2.5:7b`（中文全能）
   - 调试代码、写算法：切换到`qwen2.5-coder:7b`（代码专用）
   - 逻辑推理、问题拆解：切换到`deepseek-r1:7b`（推理专用）
3. 所有模型调用都是本地离线运行，数据不经过云端，和Ollama终端效果完全一致。

### 场景2：Oh My OpenAgent 多模型高级配置（Agent分工调用）
适用于你之前关注的OpenCode Agent生态，可实现**不同任务自动调用对应模型**，比如代码生成用Coder模型、推理用DeepSeek模型、文档用通义千问模型。

#### 步骤1：修改Agent配置文件，添加多个Ollama模型
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

#### 步骤2：在Skill/Agent中指定模型调用
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

---

## 五、你的AMD硬件专属优化&避坑指南
### 1. 最优多模型组合推荐（你的配置专属）
| 组合类型 | 模型1 | 模型2 | 适用场景 |
|----------|-------|-------|----------|
| 全能开发组合（首选） | qwen2.5:7b（通用/文档） | qwen2.5-coder:7b（代码/调试） | 日常编程、全栈开发、办公写作 |
| 强推理组合 | qwen2.5:7b（通用） | deepseek-r1:7b（逻辑/数学） | 算法设计、复杂问题拆解、数据分析 |
| 国产平替组合 | glm4:9b（对标Kimi） | qwen2.5-coder:7b（代码） | 中文长文档、办公场景、代码开发 |

### 2. 必看避坑指南
1. **绝对不要开多个`ollama serve`**：只需启动1次后台服务，开多个会导致11434端口冲突，OpenCode无法连接
2. **模型名称必须完全匹配**：OpenCode里填写的模型名，必须和`ollama list`里的名称完全一致（包括tag，比如`qwen2.5:7b`不能写成`qwen2.5`）
3. **防火墙拦截问题**：如果OpenCode连接失败，打开Windows防火墙，放行11434端口，或直接关闭临时防火墙测试
4. **显存溢出解决**：如果出现卡顿、模型加载失败，把`OLLAMA_MAX_LOADED_MODELS`改回2，关闭浏览器、视频软件等占用显存的程序
5. **模型自动卸载**：如果模型经常被自动卸载，确认`OLLAMA_KEEP_ALIVE`设为`-1`，且ollama serve终端没有被关闭

### 3. 常用排查命令
```bash
# 查看本地已安装的所有模型（确认模型名正确）
ollama list

# 查看Ollama服务运行状态、配置、GPU识别情况
ollama info

# 停止Ollama服务（Windows）
taskkill /f /im ollama.exe
```