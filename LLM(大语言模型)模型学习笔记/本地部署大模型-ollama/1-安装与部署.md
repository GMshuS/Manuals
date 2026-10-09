# Ollama 安装与使用完整指南（2026年5月最新）
适配你的**AMD Ryzen AI 7 H350 + Radeon 860M + 32G内存**配置，兼顾零基础新手与进阶开发者，所有命令复制粘贴即可直接执行。

## 一、核心简介
Ollama 是一款开源、跨平台的大模型一键运行工具，核心优势：
- 一键安装/运行上千款开源大模型，自动配置环境、量化优化
- 原生支持NVIDIA/AMD显卡加速，自动适配硬件
- 内置**OpenAI兼容API服务**，可对接IDE、Chat客户端、二次开发
- 完全离线运行，数据100%留在本地，无token费用

---

## 二、安装前准备
### 1. 系统要求
| 系统 | 最低版本要求 |
|------|--------------|
| Windows | Windows 10 22H2 / Windows 11 及以上 |
| macOS | macOS 14 Sonoma 及以上（M系列芯片）/ macOS 12 及以上（Intel芯片） |
| Linux | 内核5.4及以上（Ubuntu/Debian优先适配） |

### 2. 硬件适配说明（你的配置）
- ✅ **完美适配**：7B/8B/9B参数模型，纯GPU流畅运行
- ⚠️ **可稳定运行**：13B/14B参数模型，显存+32G内存混合加载
- ❌ **不推荐**：30B以上大模型，易出现卡顿、内存溢出
- **关键前置**：AMD显卡必须安装**最新版Adrenalin驱动**（24.11.1+，支持ROCm 6.1+），否则无法启用GPU加速

### 3. 存储要求
- 安装包仅需100MB左右空间
- 模型存储建议预留**50GB以上NVMe SSD空间**（单个7B模型约4GB，14B约8GB）

---

## 三、全平台详细安装步骤
### （一）Windows 系统（你的主力系统，2种方法）
#### 方法一：图形安装包（新手首选，100%成功）
1. 打开Ollama官网下载页：https://ollama.com/download
2. 点击 **Download for Windows**，下载 `OllamaSetup.exe` 安装包
3. 双击安装包，一路点击「Next」完成安装（自动配置系统环境变量，无需手动操作）
4. 安装完成后，Ollama会自动在后台运行，桌面右下角会出现小羊驼图标

> 自定义安装路径：如需安装到非C盘，用CMD执行 `OllamaSetup.exe /DIR="D:\Ollama"` 即可
> 自定义模型存储路径：添加用户环境变量 `OLLAMA_MODELS`，值为模型存放文件夹（如 `D:\Ollama\Models`），重启Ollama生效

#### 方法二：命令行一键安装（适合程序员）
以**管理员身份**打开PowerShell，执行以下命令：
```powershell
# 官方一键安装脚本
iwr -useb https://ollama.com/install.ps1 | iex
```

#### AMD显卡专属补充配置（必做，启用GPU加速）
如果安装后无法识别Radeon 860M，执行以下操作：
1. 下载AMD专属ROCm运行时：https://ollama.com/download/windows/amd
2. 解压压缩包，将所有文件复制到Ollama安装目录（默认 `C:\Users\你的用户名\AppData\Local\Programs\Ollama`）
3. 重启电脑，重新打开终端

---

### （二）macOS 系统
#### 方法一：DMG安装包
1. 官网下载 `Ollama.dmg`：https://ollama.com/download/mac
2. 双击打开，将Ollama图标拖拽到「Applications」文件夹
3. 从应用程序打开Ollama，按提示完成初始化

#### 方法二：Homebrew安装
```bash
brew install ollama
```

---

### （三）Linux 系统
一键安装脚本（Ubuntu/Debian/CentOS通用）：
```bash
curl -fsSL https://ollama.com/install.sh | sh
```
安装完成后，Ollama会自动作为系统服务运行，开机自启

---

## 四、安装验证（必做）
安装完成后，打开终端（PowerShell/CMD/终端），执行以下命令验证：

### 1. 验证安装是否成功
```bash
ollama --version
```
> 正常输出示例：`ollama version is 0.5.2`，出现版本号即安装成功

### 2. 验证GPU是否被识别（关键）
```bash
ollama info
```
- NVIDIA显卡：输出中出现 `GPU: CUDA` 即加速生效
- AMD显卡：输出中出现 `GPU: Vulkan` 即加速生效
- 若只显示CPU，说明GPU驱动未正确配置，回到上文AMD专属配置步骤操作

---

## 五、零基础入门：核心使用命令
### 1. 核心逻辑
Ollama所有操作都围绕「模型」展开，核心只有3步：**拉取模型 → 运行对话 → 管理模型**

### 2. 一键运行模型（新手最快体验）
直接执行以下命令，模型不存在会自动下载，下载完成后直接进入对话界面：
```bash
# 中文全能首选，适配你的AMD配置
ollama run qwen2.5:7b
```
> 运行后，直接输入问题回车即可对话，输入 `/exit` 退出对话，输入 `/help` 查看更多指令

### 3. 常用核心命令全解
| 命令 | 作用 | 示例 |
|------|------|------|
| `ollama pull 模型名` | 下载模型到本地 | `ollama pull deepseek-r1:7b` |
| `ollama run 模型名` | 运行模型，进入对话界面 | `ollama run qwen2.5-coder:7b` |
| `ollama list` | 查看本地已安装的所有模型 | `ollama list` |
| `ollama rm 模型名` | 删除本地模型，释放磁盘空间 | `ollama rm llama3.1:8b` |
| `ollama cp 原模型名 新模型名` | 复制模型，用于自定义修改 | `ollama cp qwen2.5:7b my-qwen` |
| `ollama serve` | 启动本地API服务（默认端口11434） | `ollama serve` |
| `ollama show 模型名` | 查看模型详情、配置、参数 | `ollama show qwen2.5:7b` |

---

## 六、进阶使用（开发者必备）
### 1. 启动OpenAI兼容API服务
Ollama内置与OpenAI完全兼容的API接口，可直接对接VS Code、Cursor、ChatBox等客户端，实现本地AI编程、对话。

#### 步骤：
1. 终端执行以下命令，启动API服务：
```bash
ollama serve
```
> 服务默认地址：`http://localhost:11434`，API路径：`http://localhost:11434/v1`

2. 调用示例（curl）：
```bash
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5:7b",
    "messages": [{"role": "user", "content": "用Python写一个冒泡排序算法"}]
  }'
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

### 2. 自定义模型配置（Modelfile）
通过Modelfile可以自定义模型的参数、提示词、上下文长度等，适配你的AMD硬件优化。

#### 示例：创建适配低显存的自定义模型
1. 新建一个名为 `Modelfile` 的文件，写入以下内容：
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

2. 执行命令创建自定义模型：
```bash
ollama create my-code-helper -f ./Modelfile
```

3. 运行自定义模型：
```bash
ollama run my-code-helper
```

### 3. 多模态图文模型使用
Ollama支持图文理解模型，可直接解析图片、文档、截图。

示例：运行Qwen2.5多模态模型
```bash
# 下载并运行多模态模型
ollama run qwen2.5-vl:7b "描述这张图片的内容" --images C:\Users\你的用户名\Pictures\test.png
```

### 4. 远程访问Ollama服务
如需在局域网内其他设备访问Ollama，添加系统环境变量：
```
变量名：OLLAMA_HOST
变量值：0.0.0.0
```
重启Ollama服务后，即可通过 `http://你的局域网IP:11434` 远程访问。

---

## 七、你的AMD硬件专属优化配置（必做）
针对你的**Radeon 860M + 32G内存**，添加以下系统环境变量，解决卡顿、显存溢出、GPU不识别问题：

| 变量名 | 变量值 | 作用 |
|--------|--------|------|
| `OLLAMA_GPU` | `vulkan` | 强制启用AMD Vulkan GPU加速 |
| `OLLAMA_MAX_VRAM` | `3686` | 限制最大显存占用3.6GB，适配860M的4-6GB显存，防爆显存 |
| `OLLAMA_NUM_THREADS` | `12` | 匹配Ryzen AI 7 H350的多核，平衡速度与功耗 |
| `OLLAMA_LOW_VRAM` | `true` | 全局启用低显存模式，自动分片加载模型 |

> 配置完成后，必须结束任务管理器中的`ollama.exe`进程，重新打开终端启动服务生效。

---

## 八、常见问题与解决方案
### 1. 安装后执行`ollama`提示“不是内部或外部命令”
- 解决方案：重启电脑，让系统环境变量生效；若仍无效，手动将Ollama安装目录添加到系统PATH环境变量。

### 2. AMD显卡不被识别，只用CPU运行
- 解决方案：
  1. 更新AMD Adrenalin驱动到最新版
  2. 安装AMD ROCm运行时到Ollama目录
  3. 添加环境变量 `OLLAMA_GPU=vulkan`
  4. 重启电脑

### 3. 模型下载速度慢/下载失败
- 解决方案：
  1. 配置终端代理，或使用国内镜像源
  2. 手动下载GGUF模型，通过Modelfile导入本地模型
  3. 检查网络，关闭VPN/防火墙干扰

### 4. 运行模型提示“显存不足/Out of Memory”
- 解决方案：
  1. 换用更小参数量的模型，或启用INT4量化版本
  2. 添加环境变量 `OLLAMA_LOW_VRAM=true`
  3. 关闭浏览器、游戏等占用显存的程序
  4. 减小`num_ctx`上下文窗口长度

### 5. API调用无响应/连接失败
- 解决方案：
  1. 确认`ollama serve`已正常运行，端口11434未被占用
  2. 关闭防火墙/杀毒软件的拦截
  3. 检查base_url是否正确，结尾不要加斜杠

---

## 九、新手必装模型推荐（适配你的配置）
| 模型名 | 一键安装命令 | 适用场景 |
|--------|--------------|----------|
| Qwen2.5-7B | `ollama pull qwen2.5:7b` | 中文全能主力，日常对话、文案、办公 |
| Qwen2.5-Coder-7B | `ollama pull qwen2.5-coder:7b` | 编程开发、代码生成、调试排错 |
| DeepSeek-R1-7B | `ollama pull deepseek-r1:7b` | 逻辑推理、数学计算、复杂问题拆解 |

> 完整模型库可访问Ollama官网：https://ollama.com/library，上千款模型全部支持一键安装。