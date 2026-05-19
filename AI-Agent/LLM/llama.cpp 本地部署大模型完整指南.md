# llama.cpp 本地部署大模型完整指南

> 涵盖安装、模型选择、下载、运行、工具使用与性能调优的全流程指南，支持 Windows/macOS/Linux 全平台，包含 GPU 加速、模型运行、参数配置、常见问题完整解决方案。

---

## 目录

1. [安装与配置](#一安装与配置)
2. [模型命名规则](#二模型命名规则)
3. [模型下载](#三模型下载)
4. [运行方式与加速选项](#四运行方式与加速选项)
5. [工具使用详解](#五工具使用详解)
6. [性能调优指南](#六性能调优指南)
7. [常见问题排查](#七常见问题排查)
8. [生态对接与扩展](#八生态对接与扩展)

---

## 一、安装与配置

### 1. 安装方式选择

| 安装方式 | 难度 | 适用场景 |
|---------|------|---------|
| 预编译二进制 | ⭐ 最简单 | 快速体验，无需编译环境，开箱即用 |
| Python 绑定 | ⭐⭐ 简单 | Python 开发者，快速集成到项目中 |
| 从源码编译 | ⭐⭐⭐ 进阶 | 需要 GPU 加速、自定义优化、最新功能 |
| Docker | ⭐⭐ 简单 | 跨平台部署、环境隔离、一键启动服务 |
| 包管理器 | ⭐ 最简单 | macOS(Homebrew)、Linux(Nix) 一键安装 |

### 2. 预编译二进制（新手首选）

无需编译、无需依赖，解压即可运行。

1. 下载：前往 [llama.cpp GitHub Releases](https://github.com/ggerganov/llama.cpp/releases)，下载对应系统的压缩包
2. 解压并进入目录，执行命令：

```bash
# 启动 Web UI 服务（推荐）
./llama-server -m ./your-model.gguf -c 4096 --port 8080

# 交互式命令行对话
./llama-cli -m ./your-model.gguf -p "你好" -n 256
```

3. 访问 `http://localhost:8080` 即可使用内置 Web 界面。

### 3. Python 绑定（llama-cpp-python）

适合 Python 开发场景，支持 CPU/GPU 模式。

#### 3.1 基础安装（CPU 模式）

```bash
pip install llama-cpp-python
```

#### 3.2 GPU 加速安装

**NVIDIA GPU (CUDA)**

```bash
CMAKE_ARGS="-DGGML_CUDA=on" pip install llama-cpp-python --upgrade --force-reinstall
```

**Apple Silicon (Metal，M1/M2/M3/M4)**

```bash
CMAKE_ARGS="-DGGML_METAL=on" pip install llama-cpp-python --upgrade --force-reinstall
```

#### 3.3 Python 代码示例

```python
from llama_cpp import Llama

# 加载模型（-1 表示全部层卸载到 GPU）
llm = Llama(
    model_path="./qwen2.5-7b-instruct-q4_k_m.gguf",
    n_ctx=4096,
    n_gpu_layers=-1
)

# 生成对话
output = llm("你好，请介绍 llama.cpp 的特色", max_tokens=256)
print(output['choices'][0]['text'])
```

#### 3.4 启动 OpenAI 兼容 API 服务

```bash
pip install 'llama-cpp-python[server]'
python3 -m llama_cpp.server --model models/7B/llama-model.gguf --n_gpu_layers 35
```

访问 `http://localhost:8000/docs` 查看可视化 API 文档。

### 4. 从源码编译（进阶/性能最优）

#### 4.1 macOS

```bash
# 1. 安装依赖
xcode-select --install
brew install git cmake

# 2. 克隆仓库
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp

# 3. 编译（Apple Silicon 启用 Metal 加速）
cmake -B build -DGGML_METAL=ON
cmake --build build --config Release

# 4. 验证安装
./build/bin/llama-cli --help
```

✅ 一键安装：`brew install llama.cpp`

#### 4.2 Linux (Ubuntu/Debian)

```bash
# 1. 安装依赖
sudo apt update
sudo apt install -y git build-essential cmake

# 2. 克隆仓库
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp

# 3. 编译
# CPU 模式
cmake -B build
cmake --build build --config Release -j $(nproc)

# NVIDIA GPU 加速模式
cmake -B build -DGGML_CUDA=ON
cmake --build build --config Release -j $(nproc)
```

#### 4.3 Windows

**选项 A：Visual Studio（推荐）**

1. 安装 Visual Studio，勾选 **C++ 桌面开发**
2. 安装 Git + CMake
3. 编译命令：

```powershell
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp

mkdir build
cd build
cmake ..
cmake --build . --config Release
```

**选项 B：WSL（Linux 子系统）**

```powershell
wsl --install  # 安装 WSL
# 后续按照 Linux 编译步骤执行
```

**选项 C：MSYS2（高级用户）**

```bash
pacman -Syu
pacman -S mingw-w64-x86_64-gcc cmake git
# 克隆仓库后执行编译
```

### 5. Docker 部署（跨平台/隔离环境）

```bash
# 拉取镜像
docker pull ghcr.io/ggerganov/llama.cpp:latest

# 启动服务（挂载模型目录）
docker run --rm -it -p 8080:8080 \
  -v /path/to/models:/models \
  ghcr.io/ggerganov/llama.cpp:latest \
  --model /models/llama-model.gguf --port 8080
```

### 6. 安装总结

1. 新手优先选择**预编译二进制**，开箱即用；Python 开发者直接用 `llama-cpp-python`
2. 追求性能选择**源码编译**，开启对应硬件的 GPU 加速（CUDA/Metal/Vulkan）
3. 模型必须使用 **GGUF 格式**，推荐 Q4_K_M 量化版本平衡速度与效果
4. 核心命令：`llama-server` 启动 Web 服务，`llama-cli` 命令行对话

---

## 二、模型命名规则

### 1. 按训练阶段分类

| 关键字 | 含义 | 典型例子 |
|--------|------|----------|
| Base / Pretrained / Raw | 基础预训练模型，未经过微调，主要用于研究或进一步训练 | Llama-3-8B-Base, Qwen2.5-Base |
| Instruct | 指令微调，学习遵循指令 | Llama-3-8B-Instruct, Qwen2.5-Instruct |
| Chat | 对话优化，经过 RLHF 或类似对齐，适合聊天 | GPT-4o, Kimi K2.5, DeepSeek-V3-Chat |
| RLHF / DPO / PPO | 明确标注使用了某种人类反馈对齐技术 | 较少直接出现在名称中 |
| SFT (Supervised Fine-Tuned) | 有监督微调 | 通常不写在名称里，但技术文档会提到 |

### 2. 按应用场景分类

| 关键字 | 含义 | 典型例子 |
|--------|------|----------|
| Code / Coder | 专门优化代码生成、理解和推理 | CodeLlama, DeepSeek-Coder, Qwen2.5-Coder |
| Math | 数学推理能力强化 | DeepSeek-Math, Qwen2.5-Math |
| Vision / VL / VLM | 视觉-语言多模态，能看图 | GPT-4V, Qwen-VL, InternVL |
| Audio / Speech | 语音处理能力 | Qwen-Audio, Whisper |
| MoE (Mixture of Experts) | 混合专家架构，提升效率 | Mixtral-8x7B-MoE, DeepSeek-V2-MoE |
| Embedding | 文本向量化，用于检索、聚类 | BGE-Embedding, GTE-Embedding |
| Reranker | 重排序模型，用于提升检索精度 | BGE-Reranker |

### 3. 按模型规模与效率

| 关键字 | 含义 | 说明 |
|--------|------|------|
| -B (Billion) | 参数量，如 7B = 70 亿 | Llama-3-8B, Qwen2.5-72B |
| -M (Million) | 小模型参数量 | 较少见 |
| Distilled / Small / Tiny / Mini | 知识蒸馏或压缩后的小模型，速度快、资源占用低 | Phi-3-mini, Qwen2.5-0.5B, Llama-3.2-1B |
| Quantized / Q4 / Q8 / AWQ / GPTQ | 量化版本，降低显存占用 | Llama-3-8B-Q4_K_M |

### 4. 按架构或系列

| 关键字 | 含义 | 典型例子 |
|--------|------|----------|
| Turbo | 更快、更轻量的版本 | GPT-3.5-Turbo, GPT-4-Turbo |
| Preview | 预览版，可能不稳定 | GPT-4o-Preview |
| Latest / Current | 指向当前最新版本 | 常见于 API 路由 |
| v1 / v2 / v3 | 代际版本 | Claude 3, GPT-4, Kimi K2.6 |
| Pro / Plus / Max / Ultra | 能力更强的顶配版本 | Gemini 1.5 Pro, Claude 3 Opus |

### 5. 容易混淆的组合

| 名称 | 实际含义 |
|------|----------|
| Llama-3-8B-Instruct | 80亿参数 + 指令微调 |
| DeepSeek-V3-Chat | V3 架构 + 对话对齐（≈ Instruct） |
| Qwen2.5-72B-Instruct | 720亿参数 + 指令微调 |
| CodeLlama-7B-Python | 代码模型 + 专门针对 Python 优化 |

### 6. 快速判断模型定位的口诀

- 有 **Base** → 原材料，需加工
- 有 **Instruct/Chat** → 即开即用，能对话
- 有 **Code/Coder** → 写代码强
- 有 **Vision/VL** → 能看图
- 有 **MoE** → 参数多但推理快
- 带 **Q4/AWQ** → 省显存，本地跑

---

## 三、模型下载

### 1. 模型规范与选择指南

llama.cpp 仅支持 **GGUF 格式** 模型，旧版 GGML 格式已完全不兼容，请勿下载。

#### 1.1 量化等级选择

| 量化等级 | 7B 模型显存占用 | 效果损失 | 推荐场景 |
|----------|----------------|----------|----------|
| `Q2_K` | ~3.2GB | 中等 | 极限低显存、极速响应、简单问答 |
| `Q4_K_M` | ~5.5GB | 极小（黄金标准） | **首选**，日常对话、通用任务、速度与效果完美平衡 |
| `Q5_K_M` | ~6.8GB | 几乎无 | 追求更好的推理效果、复杂逻辑任务 |
| `Q8_0` | ~10GB | 可忽略 | 高精度推理、专业场景 |
| `FP16` | ~13GB | 原生效果 | 不推荐，仅高端独显适用 |

### 2. 使用 ModelScope 下载（国内推荐）

```bash
# Qwen2.5 系列
modelscope download --model=okwinds/Qwen2.5-7B-Instruct-GGUF-V3-LOT --include "*Q4_K_M*" --local_dir ../models/
modelscope download --model=okwinds/Qwen2.5-Coder-7B-Instruct-GGUF-V3-LOT --include "*Q5_K_M*" --local_dir ../models/
modelscope download --model=unsloth/Qwen2.5-Coder-7B-Instruct-128K-GGUF --include "*Q5_K_M*" --local_dir ../models/
modelscope download --model=okwinds/Qwen2.5-Coder-14B-Instruct-GGUF-V3-LOT --include "*Q4_K_M*" --local_dir ../models/
modelscope download --model=okwinds/Qwen2.5-Coder-14B-Instruct-GGUF-V3-LOT --include "*Q5_K_M*" --local_dir ../models/
modelscope download --model=unsloth/Qwen2.5-Coder-14B-Instruct-128K-GGUF --include "*Q5_K_M*" --local_dir ../models/

# DeepSeek 系列
modelscope download --model=unsloth/DeepSeek-R1-Distill-Qwen-14B-GGUF --include "*Q4_K_M*" --local_dir ../models/
modelscope download --model=AI-ModelScope/DeepSeek-Coder-V2-Lite-Instruct-GGUF --include "*Q4_K_M*" --local_dir ../models/
modelscope download --model=AI-ModelScope/DeepSeek-Coder-V2-Lite-Instruct-GGUF --include "*Q5_K_M*" --local_dir ../models/

# Llama 系列
modelscope download --model=NousResearch/Hermes-3-Llama-3.1-8B-GGUF --include "*Q4_K_M*" --local_dir ../models/
modelscope download --model=AI-ModelScope/Llama-3.2-11B-Vision-Instruct-GGUF --include "*Q4_K_M*" --local_dir ../models/

# CodeLlama 系列
modelscope download --model=AI-ModelScope/CodeLlama-13b-hf --include "*Q5_K_M*" --local_dir ../models/
modelscope download --model=Xorbits/CodeLlama-13B-Instruct-GGUF --include "*Q4_K_M*" --local_dir ../models/

# 其他模型
modelscope download --model=unsloth/Qwen3.5-9B-GGUF --include "*Q4_K_M*" --local_dir ../models/
modelscope download --model=Qwen/Qwen3.6-27B --include "*Q4_K_M*" --local_dir ../models/
modelscope download --model=ggml-org/Kimi-VL-A3B-Instruct-GGUF --include "*Q4_K_M*" --local_dir ../models/
modelscope download --model=unsloth/gemma-3-12b-it-GGUF --include "*Q4_K_M*" --local_dir ../models/
modelscope download --model=unsloth/Phi-4-reasoning_plus-GGUF --include "*Q4_K_M*" --local_dir ../models/
```

### 3. 使用 Hugging Face 镜像下载

```bash
# 设置国内镜像
export HF_ENDPOINT="https://hf-mirror.com"

# 下载示例
hf download Qwen/Qwen2.5-7B-Instruct-GGUF qwen2.5-7b-instruct-q4_0-00001-of-00002.gguf qwen2.5-7b-instruct-q4_0-00002-of-00002.gguf --local-dir ./qwen2.5-q4
hf download Qwen/Qwen3-14B-GGUF Qwen3-14B-Q4_K_M.gguf --local-dir ./Qwen3-14B-GGUF-q4
hf download Flagstone8878/Qwen3.5-18B-REAP-A3B-Coding-GGUF Qwen3.5-18B-REAP-A3B-Coding-Q4_K_M.gguf --local-dir ./
hf download mradermacher/qwen3.5-18b-a3b-reap-coding-heretic-v0-i1-GGUF qwen3.5-18b-a3b-reap-coding-heretic-v0.i1-Q4_K_M.gguf --local-dir ./
hf download lmstudio-community/Devstral-Small-2-24B-Instruct-2512-GGUF Devstral-Small-2-24B-Instruct-2512-Q4_K_M.gguf --local-dir ./
hf download Jackrong/Qwen3.5-9B-DeepSeek-V4-Flash-GGUF Qwen3.5-9B-DeepSeek-V4-Flash-Q4_K_M.gguf --local-dir ./
hf download TheBloke/CodeLlama-13B-Instruct-GGUF codellama-13b-instruct.Q4_K_M.gguf --local-dir ./
```

### 4. 靠谱模型来源

- **官方/权威仓库**：Hugging Face 平台的 `Qwen`（通义千问官方）、`TheBloke`、`lmstudio-community`、`meta-llama` 仓库
- **国内加速镜像**：`https://hf-mirror.com`（解决 Hugging Face 无法访问的问题）
- **ModelScope**：国内模型平台，下载速度快

---

## 四、运行方式与加速选项

### 1. 基础 CPU 运行模式

| 选项 | 说明 | 适用场景 |
|------|------|----------|
| **Windows x64 (CPU)** | 纯 CPU 运行，无任何 GPU 加速，仅靠电脑的处理器计算 | 没有独立显卡、显卡不支持任何加速，或只想测试基础功能 |
| **Windows arm64 (CPU)** | 专为 ARM 架构的 Windows 设备（比如 Surface Pro X、部分 ARM 笔记本）编译的纯 CPU 版本 | 使用 ARM 处理器的 Windows 设备，无 GPU 加速 |

**特点**：
- 兼容性最强，所有 Windows 设备都能跑，但速度最慢，大模型推理会很卡
- 可以通过设置 `--threads` 参数指定 CPU 线程数，优化速度（比如设置为 CPU 核心数的 1-2 倍）

### 2. NVIDIA 显卡专属：CUDA 加速

| 选项 | 说明 | 版本差异 |
|------|------|----------|
| **Windows x64 (CUDA 12)** | 基于 CUDA 12.4 工具链编译，带对应的 CUDA 动态链接库（DLL） | 适配较新的 NVIDIA 驱动，支持 RTX 20/30/40 系显卡 |
| **Windows x64 (CUDA 13)** | 基于 CUDA 13.1 工具链编译，带对应的 CUDA 动态链接库（DLL） | 适配最新的 NVIDIA 驱动，对新显卡（如 RTX 40 系）优化更好 |

**核心原理**：CUDA 是 NVIDIA 的并行计算平台，能让 llama.cpp 把模型计算（尤其是矩阵运算）卸载到 GPU 的 CUDA 核心上，大幅提升推理速度，还能利用 VRAM 缓存模型权重，减少内存占用。

**优点**：
- 速度最快，对 NVIDIA 显卡的优化最成熟
- 支持 `--n-gpu-layers` 参数，把模型层加载到 VRAM 中，进一步提速

**注意**：
- 必须安装对应版本的 NVIDIA 显卡驱动（建议更新到最新版，兼容 CUDA 12/13）
- 优先选和你显卡兼容的最高版本，比如 RTX 40 系优先选 CUDA 13，老显卡选 CUDA 12 即可

### 3. 跨平台通用：Vulkan 加速

**选项：Windows x64 (Vulkan)**

**核心原理**：Vulkan 是底层图形 API，llama.cpp 通过它调用 GPU 的通用计算单元，实现模型推理加速，不需要依赖厂商专属的 CUDA/HIP。

**优点**：
- 兼容性极强，几乎所有支持 Vulkan 的显卡都能跑
- 不需要安装 CUDA、HIP 等额外工具链，部署简单

**缺点**：
- 性能比同硬件下的厂商专属加速（CUDA/HIP）稍弱
- 部分老显卡的 Vulkan 驱动优化一般，速度提升有限

### 4. Intel 显卡专属：SYCL 加速

**选项：Windows x64 (SYCL)**

**核心原理**：SYCL 是 Intel 推出的跨平台异构计算框架，能让 llama.cpp 调用 Intel GPU 的 Xe 核心进行计算，利用 Arc 显卡的硬件加速能力。

**优点**：
- 对 Intel Arc 显卡（如 Arc A770、A750）优化较好，能充分发挥硬件性能
- 支持核显 + 独显混合加速（如果是带 Arc 核显的 Intel CPU）

**注意**：
- 必须安装 Intel 显卡的最新驱动，部分老驱动对 SYCL 支持不佳
- 性能表现和 Vulkan 版本差距不大，但在部分场景下（如 FP16 计算）会有优势

### 5. AMD 显卡专属：HIP 加速

**选项：Windows x64 (HIP)**

**核心原理**：HIP 是 AMD 推出的、兼容 CUDA 的计算接口，llama.cpp 的 HIP 版本能直接利用 AMD 显卡的 CDNA/RDNA 架构进行模型推理加速，相当于 AMD 版的 CUDA。

**优点**：
- 对 AMD 显卡（如 RX 6000/7000 系列）优化较好，性能接近 NVIDIA 的 CUDA 版本
- 支持把 CUDA 代码直接转换为 HIP 代码，适配成本低

**注意**：
- 需要安装 AMD 的 ROCm 驱动（Windows 版支持有限，部分新显卡可能需要测试）
- 部分老 AMD 显卡的 HIP 兼容性一般，优先用 Vulkan 兜底

### 6. 硬件选型指南

| 你的硬件 | 优先选择 | 兜底方案 |
|----------|----------|----------|
| NVIDIA 独立显卡（RTX 20/30/40 系） | CUDA 13（或 CUDA 12） | Vulkan |
| AMD 独立显卡（RX 6000/7000 系） | HIP | Vulkan |
| Intel Arc 独立显卡/核显 | SYCL | Vulkan |
| 无独立显卡/老显卡不支持上述加速 | CPU 版本 | - |

### 7. 提升速度的核心参数

1. **`--n-gpu-layers`**：把模型的部分层加载到 GPU 中，比如 `--n-gpu-layers 100`（加载所有层到 GPU，前提是 VRAM 足够），大幅提速（仅 CUDA/HIP/Vulkan/SYCL 支持）
2. **`--threads`**：CPU 版本的核心参数，设置为 CPU 物理核心数（比如 8 核 CPU 设为 8 或 16），提升多线程性能
3. **`--mmap`**：内存映射文件，减少模型加载时间，所有版本都支持
4. **`--ctx-size`**：设置上下文窗口大小，根据你的内存/VRAM 调整（越大越吃内存，但能处理更长文本）

---

## 五、工具使用详解

### 1. 核心可执行文件说明

Windows 预编译包解压后，核心功能文件如下：

| 文件名 | 核心功能 | 高频使用场景 |
|--------|----------|--------------|
| `llama-cli.exe` | 命令行推理/对话核心工具 | 本地交互式对话、单次文本生成、prompt 测试 |
| `llama-server.exe` | 内置 HTTP 服务，**100% 兼容 OpenAI API 格式** | 搭建本地 API 服务、对接第三方应用、Web 界面聊天 |
| `llama-gguf.exe` | GGUF 模型全生命周期处理工具 | 查看模型信息、模型量化、拆分/合并、LoRA 融合 |
| `llama-bench.exe` | 硬件性能基准测试工具 | 测试不同模型的生成速度、显存/内存占用、参数优化 |
| `llama-embedding.exe` | 文本嵌入生成工具 | 本地 RAG 检索、知识库搭建、文本相似度计算 |
| `llama-tokenize.exe` | 分词工具 | 查看 prompt 的 token 数量、分词结果、费用预估 |


### 2. 命令行交互式对话（llama-cli）

#### 2.1 基础交互式对话

```bash
# 完整交互式对话启动命令
./llama-cli \
  -m models/qwen2.5-7b-instruct.Q4_K_M.gguf \
  -ngl 99 \
  --device Vulkan0 \
  -t 8 \
  --ctx-size 4096 \
  --temp 0.7 \
  --flash-attn \
  --chat-template auto \
  --color \
  -i
```

**核心参数说明**：
- `-i`：开启交互式对话模式，输入内容后按回车即可生成回复
- `--chat-template auto`：自动适配模型的对话模板，解决输出乱码、效果差的核心问题
- `--color`：区分用户输入与模型输出，提升可读性

#### 2.2 单次文本生成（非交互式）

适合批量生成文案、脚本、报告等，无需人工交互，执行完成后自动退出：

```bash
./llama-cli \
  -m models/qwen2.5-7b-instruct.Q4_K_M.gguf \
  -ngl 99 \
  --device Vulkan0 \
  -t 8 \
  --ctx-size 4096 \
  -p "写一份 500 字的端午节活动策划方案，面向公司员工" \
  -n 1024 \
  --temp 0.6 \
  -o 活动方案.txt
```

**关键参数**：
- `-p "xxx"`：指定输入的提示词（prompt）
- `-n 1024`：最大生成 token 数，控制输出长度
- `-o 活动方案.txt`：将生成的内容自动保存到指定文件

#### 2.3 高级定制用法

**从文件读取 prompt**：

```bash
./llama-cli -m 模型路径 -f prompt.txt -n 2048
```

**强制结构化输出**（用 `--grammar` 参数通过 BNF 语法约束输出格式，比如强制输出 JSON）：

```bash
# 强制输出 JSON 格式的用户信息
./llama-cli -m 模型路径 -p "生成一个用户信息，包含姓名、年龄、职业" --grammar 'root ::= "{" "name": "\"" [a-zA-Z]+ "\"" ", " "age": [0-9]+ ", " "job": "\"" [a-zA-Z]+ "\"" "}"' -n 128
```

**多轮对话状态保存**：

```bash
# 保存对话状态
./llama-cli -m 模型路径 -i --save-session chat.session
# 恢复对话状态
./llama-cli -m 模型路径 -i --load-session chat.session
```

### 3. OpenAI 兼容 API 服务（llama-server）

这是 llama.cpp 最具扩展性的功能，启动后可对接几乎所有支持 OpenAI API 的应用，比如 ChatGPT-Next-Web、Obsidian、Python 脚本、LangChain 等。

#### 3.1 基础服务启动命令

```bash
./llama-server \
  -m models/qwen2.5-7b-instruct.Q4_K_M.gguf \
  -ngl 99 \
  --device Vulkan0 \
  -t 8 \
  --ctx-size 4096 \
  --flash-attn \
  --chat-template auto \
  -p 8080 \
  --host 0.0.0.0 \
  --cors * \
  --api-key your_custom_key
```

**核心参数说明**：
- `-p 8080`：服务监听端口，可自定义
- `--host 0.0.0.0`：允许局域网内其他设备访问（比如手机、其他电脑）
- `--cors *`：解决跨域问题，对接前端应用必加
- `--api-key your_custom_key`：设置 API 密钥，防止未授权访问，可选

#### 3.2 核心功能使用

**自带 Web 聊天界面**

启动服务后，浏览器访问 `http://localhost:8080` 即可直接使用可视化聊天界面，支持多轮对话、参数调整、文件上传等功能。

**OpenAI API 兼容调用**

完全兼容 OpenAI 的 API 格式，仅需把接口地址中的 `https://api.openai.com/v1` 替换为 `http://localhost:8080/v1` 即可。

- 核心端点：
  - 聊天补全：`POST http://localhost:8080/v1/chat/completions`
  - 文本补全：`POST http://localhost:8080/v1/completions`
  - 模型列表：`GET http://localhost:8080/v1/models`
  - 嵌入生成：`POST http://localhost:8080/v1/embeddings`

**在Python调用API**

```python
from openai import OpenAI

# 初始化客户端，指向本地 llama.cpp 服务
client = OpenAI(
    base_url="http://localhost:8080/v1",
    api_key="your_custom_key"  # 与启动命令中的 api-key 一致
)

# 调用聊天接口
response = client.chat.completions.create(
    model="qwen2.5-7b",
    messages=[{"role": "user", "content": "你好，介绍一下 llama.cpp"}],
    temperature=0.7,
    max_tokens=512
)

print(response.choices[0].message.content)
```

**在OpenCode中配置API**

```json
{
    "$schema": "https://opencode.ai/config.json",
    "llama.cpp": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "llama.cpp-local",
      "options": {
        "baseURL": "http://127.0.0.1:8880/v1",
        "toolParser": [
          {"type":"raw-function-call"},
          {"type":"json"}
        ]
      },
      "models": {
        "DeepSeek-Coder-V2-Lite-Instruct-Q4_K_M.gguf": {
          "name": "DeepSeek-Coder-V2-Lite-Instruct-Q4_K_M",
          "tool_call": true,
          "limit": {
          "context": 32768,
          "output": 8192
          }
        },
        "Qwen3.5-9B-Q4_K_M.gguf": {
          "name": "Qwen3.5-9B-Q4_K_M",
          "tool_call": true,
          "limit": {
          "context": 32768,
          "output": 8192
          }
        },
        "Qwen3-14B-Q4_K_M.gguf": {
          "name": "Qwen3-14B-Q4_K_M",
          "tool_call": true,
          "limit": {
          "context": 32768,
          "output": 8192
          }
        }
      }
    },
    "model": "llama.cpp/Qwen3.5-9B-Q4_K_M.gguf"
}
```

### 4. GGUF 模型处理（llama-gguf）

用于自定义处理模型，解决模型下载后信息不明确、需要量化、合并 LoRA 等需求。

#### 4.1 查看模型详细信息

```bash
./llama-gguf info models/qwen2.5-7b-instruct.Q4_K_M.gguf
```

可查看模型的参数大小、层数、上下文窗口、量化等级、分词器、支持的功能等核心信息，避免下错模型。

#### 4.2 模型量化（自定义生成低比特 GGUF）

如果下载了 FP16/FP32 的高版本模型，可自行量化为适配你硬件的低比特版本：

```bash
# 把 FP16 模型量化为 Q4_K_M 格式
./llama-gguf quantize \
  models/qwen2.5-7b-instruct.FP16.gguf \
  models/qwen2.5-7b-instruct.Q4_K_M.gguf \
  Q4_K_M
```

量化等级可替换为 `Q2_K`、`Q5_K_M`、`Q8_0` 等。

#### 4.3 LoRA 适配器融合

把微调后的 LoRA 模型合并到基础 GGUF 模型中，生成可直接推理的完整模型：

```bash
./llama-gguf merge-lora \
  --base-model 基础模型路径.gguf \
  --lora-path lora 适配器路径.gguf \
  --output 合并后的完整模型.gguf
```

### 5. 性能基准测试（llama-bench）

测试你的硬件在不同参数下的性能，找到最优配置：

```bash
# 基准测试命令
./llama-bench \
  -m models/qwen2.5-7b-instruct.Q4_K_M.gguf \
  -ngl 99 \
  --device Vulkan0 \
  -t 8 \
  -c 4096 \
  -b 512
```

测试完成后会输出 **prompt 处理速度**、**token 生成速度**、**内存/显存占用** 等核心数据，可用于调整线程数、GPU 层数等参数，找到最优配置。

### 6. 核心高频参数全解

#### 6.1 基础核心参数

| 参数 | 简写 | 推荐取值 | 核心作用 |
|------|------|----------|----------|
| `--model` | `-m` | 模型文件路径 | **必填**，指定 GGUF 模型的文件路径 |
| `--threads` | `-t` | 8（你的 CPU 物理核心数） | CPU 推理线程数，建议等于物理核心数，超线程无明显提升 |
| `--ctx-size` | `-c` | 4096 | 上下文窗口大小，决定模型能记住的对话长度，越大占用显存越多 |
| `--n-predict` | `-n` | 512 | 单次最大生成 token 数，-1 为无限生成，直到模型主动结束 |
| `--batch-size` | `-b` | 512 | prompt 批处理大小，越大 prompt 处理速度越快，占用显存越多 |

#### 6.2 GPU 加速专属参数

| 参数 | 简写 | 推荐取值 | 核心作用 |
|------|------|----------|----------|
| `--n-gpu-layers` | `-ngl` | 99 | 加载到 GPU 的模型层数，99=全部层加载到 GPU，最大化加速效果 |
| `--device` | 无 | `Vulkan0` | 指定推理设备，AMD 核显必须填 Vulkan0，避免默认使用 CPU |
| `--flash-attn` | 无 | 必加 | 开启 Flash Attention，速度提升 20-30%，同时降低显存占用 |
| `--vulkan-sync` | 无 | 1 | Vulkan 同步模式优化，AMD 核显推荐 1，降低延迟 |

#### 6.3 生成效果控制参数

| 参数 | 推荐取值 | 核心作用 |
|------|----------|----------|
| `--temperature` | 0.3-1.0 | 温度值，越小输出越稳定、越严谨，越大越有创造性、随机性越强 |
| `--top-p` | 0.9 | 核采样阈值，限制 token 的选择范围，与 temperature 配合调整生成效果 |
| `--repeat-penalty` | 1.1 | 重复惩罚，避免模型输出重复内容，1.0=无惩罚，越大惩罚越强 |
| `--frequency-penalty` | 0.1 | 频率惩罚，降低高频出现的 token 的概率，减少重复 |
| `--presence-penalty` | 0.1 | 存在惩罚，鼓励模型生成新的话题和内容，避免原地打转 |

#### 6.4 服务专属参数

| 参数 | 推荐取值 | 核心作用 |
|------|----------|----------|
| `--port` | `-p` 8080 | 服务监听端口 |
| `--host` | 0.0.0.0 | 服务绑定地址，0.0.0.0 允许局域网访问，127.0.0.1 仅本地访问 |
| `--api-key` | 自定义字符串 | API 访问密钥，开启后请求必须携带密钥 |
| `--cors` | `*` | 跨域资源共享配置，* 为允许所有来源，对接前端应用必加 |
| `--parallel` | 4 | 最大并行请求数，控制服务的并发能力 |

---

## 六、性能调优指南

### 1. 显存真相解读

以 AMD Radeon 860M 核显为例（无独立显存）：

- **专用 GPU 内存 512MB**：仅为系统预留的极小空间，无法用于模型加载，基本可以忽略
- **共享 GPU 内存 15.6GB**：这是你的「实际可用显存」，由系统内存划分而来，Vulkan 加速就是把模型层放到这里
- **总系统内存 32GB**：其中约 16GB 被划分为共享 GPU 内存，剩余 16GB 可用于模型层 CPU 计算+KV 缓存

**核心结论**：模型层 offload（`-ngl` 参数）不能超过 15GB，否则会直接 OOM；大模型必须采用「部分层 offload+ 部分层 CPU 计算」的混合模式。

### 2. 通用必开优化参数

这些参数是所有启动命令的基础，必须加上，能直接提升 20% 以上性能：

```bash
--device Vulkan0        # 强制锁定 GPU，避免默认回退到 CPU
-t 8                    # 固定为 CPU 物理核心数，超线程对 llama.cpp 无增益
--flash-attn            # 必开！降低 KV 缓存显存占用 40%，速度提升 25%+
--no-mmap               # Windows 下关闭内存映射，模型加载更稳，减少卡顿
--chat-template auto    # 自动适配对话模板，避免乱码
--vulkan-sync 1         # AMD 核显专属优化，降低 Vulkan 同步延迟
--parallel 1            # 单请求模式，所有资源集中服务一个任务
--timeout 300           # 超时设为 5 分钟，避免长文本生成被中断
```

### 3. 分模型最优配置

#### 3.1 2B-7B 模型（全量 offload，无压力，体验最佳）

**适用场景**：日常对话、代码编写、快速问答

**显存占用参考**：7B Q4_K_M ≈ 5.5GB + 8192 上下文 KV 缓存≈1.5GB → 总占用≈7GB

**完整启动命令（以 Qwen2.5-7B 为例）**：

```bash
./llama-server \
  -m models/qwen2.5-7b-it-Q4_K_M-LOT.gguf \
  -ngl 99 \
  --device Vulkan0 \
  -c 8192 \
  -t 8 \
  --flash-attn \
  --no-mmap \
  --chat-template auto \
  --vulkan-sync 1 \
  --parallel 1 \
  --timeout 300 \
  --batch-size 1024 \
  --ubatch-size 512
```

**预期性能**：18-25 token/s，流畅无卡顿

#### 3.2 14B 模型（大部分 offload，平衡速度与显存）

**适用场景**：复杂代码分析、逻辑推理、专业问答

**显存占用参考**：14B Q4_K_M ≈ 10GB + 4096 上下文 KV 缓存≈1GB → 总占用≈11GB

**完整启动命令（以 Qwen2.5-Coder-14B 为例）**：

```bash
./llama-server \
  -m models/Qwen2.5-Coder-14B-Instruct-Q4_K_M-LOT.gguf \
  -ngl 35 \
  --device Vulkan0 \
  -c 4096 \
  -t 8 \
  --flash-attn \
  --no-mmap \
  --chat-template auto \
  --vulkan-sync 1 \
  --parallel 1 \
  --timeout 300 \
  --batch-size 512 \
  --ubatch-size 256
```

**预期性能**：8-12 token/s，比纯 CPU 快 3 倍以上，稳定不 OOM

> 如果用 14B Q5_K_M 版本（显存占用≈12GB），需降低 `-ngl` 到 30，`-c` 降到 2048

#### 3.3 20B 模型（部分 offload，低显存稳跑版）

**适用场景**：批量生成、深度分析、非实时任务

**显存占用参考**：20B Q4_K_M ≈ 13-14GB + 2048 上下文 KV 缓存≈0.5GB → 总占用≈14-14.5GB

**完整启动命令**：

```bash
./llama-server \
  -m models/your-20b-model.Q4_K_M.gguf \
  -ngl 25 \
  --device Vulkan0 \
  -c 2048 \
  -t 8 \
  --flash-attn \
  --no-mmap \
  --chat-template auto \
  --vulkan-sync 1 \
  --parallel 1 \
  --timeout 600 \
  --batch-size 256 \
  --ubatch-size 128
```

**预期性能**：4-6 token/s，可跑但速度较慢，适合非实时场景

> 提速技巧：换用 20B Q3_K_M 版本（显存占用≈10GB），可将 `-ngl` 提高到 35，速度提升至 6-8 token/s，效果损失极小

### 4. 系统层面深度优化

1. **释放共享 GPU 内存**：关闭浏览器、视频播放器、游戏、杀毒软件等后台程序，避免和模型争抢共享内存
2. **调整 Windows 虚拟内存**：
   - 路径：此电脑 → 右键属性 → 高级系统设置 → 高级 → 性能设置 → 高级 → 虚拟内存 → 更改
   - 勾选「系统管理的大小」，或手动设置为 **16GB-32GB**，重启生效
3. **BIOS/驱动优化**：
   - 开启 BIOS 中的 `Resizable BAR`（如果支持），提升核显访问系统内存的速度
   - 使用最新稳定版驱动，避免测试版驱动导致 Vulkan 性能下降
4. **电源模式拉满**：
   - Windows 设置 → 系统 → 电源和电池 → 选择「最佳性能」
   - AMD Adrenalin 软件中，将显卡电源设置为「最高性能」，避免 CPU/核显降频

### 5. 避坑指南

1. **不要盲目开高 `-ngl`**：大模型设 `-ngl 99` 会直接超出共享内存上限，必须根据模型大小调整层数
2. **不要开过大的 `-c`**：`ctx-size` 越大，KV 缓存占用的显存越多，大模型建议设为 2048/4096，不要开 8192
3. **必须用正确版本的 llama.cpp**：CPU 版本无法使用 GPU 加速，遇到性能问题大概率是用错了版本
4. **模型路径不要有中文/空格**：否则 llama.cpp 可能无法加载模型，建议放到纯英文路径

---

## 七、常见问题排查

### 1. 模型加载失败/内存不足

**解决方案**：
- 降低模型量化等级（如 Q4_K_M 换成 Q2_K）
- 减小 `--ctx-size`
- 降低 `-ngl` 的数值，减少加载到 GPU 的层数
- 关闭其他占用内存的程序

### 2. GPU 设备找不到/不生效

**解决方案**：
- 更新官方显卡驱动
- 重启电脑
- 把 `--device Vulkan0` 改为 `--device Vulkan1` 尝试
- 确认下载的是对应 GPU 加速版本的安装包，不是 CPU 版本

### 3. 生成速度极慢/跑在 CPU 上

**解决方案**：
- 确认启动命令加了 `-ngl 99 --device Vulkan0`（或对应 GPU 设备）
- 查看启动日志，确认 GPU 设备已被调用
- 更新显卡驱动
- 调整 `-t` 参数为物理核心数

### 4. 输出乱码/胡言乱语/重复

**解决方案**：
- 添加 `--chat-template auto` 参数，适配模型的对话模板
- 添加 `--encoding utf-8` 解决中文乱码
- 调整 `--repeat-penalty 1.1` 降低重复
- 确认下载的是 `Instruct`/`Chat` 对话模型，不是基础预训练模型

### 5. API 服务无法被局域网访问

**解决方案**：
- 启动命令加 `--host 0.0.0.0`
- Windows 防火墙放行对应的端口（如 8080）
- 关闭 VPN/代理软件
- 确认局域网内设备在同一网段

### 6. 驱动版本问题

**解决方案**：
- 加速版本必须安装对应厂商的最新驱动
- CUDA 13 需要较新的 NVIDIA 驱动
- VRAM 不足时，可以降低 `--n-gpu-layers` 的数值，或者使用 4-bit/8-bit 量化模型

---

## 八、生态对接与扩展

### 1. 可视化聊天界面

对接 ChatGPT-Next-Web、Open WebUI、LobeChat 等开源 Web 界面，仅需把 API 地址改为本地 llama.cpp 服务地址。

### 2. 知识库 RAG

结合 LangChain、LlamaIndex、AnythingLLM 等工具，搭建本地私有知识库，实现文档问答、数据检索。

### 3. 办公插件对接

对接 Obsidian、VS Code、Word 等办公软件的 AI 插件，实现本地 AI 辅助写作、代码补全。

### 4. 多模态模型支持

支持 Llava、Qwen2-VL 等多模态模型，可实现图片理解、OCR、图表分析，启动命令添加 `--mmproj` 参数指定多模态投影文件即可。

### 5. 语音交互

结合 Whisper.cpp（同团队开源的语音识别工具），实现本地语音对话，完全离线运行。

---

## 附录

### A. 参考资料

- [llama.cpp 官方 GitHub](https://github.com/ggerganov/llama.cpp)
- [Hugging Face 模型库](https://huggingface.co)
- [ModelScope 模型库](https://modelscope.cn)
- [Hugging Face 国内镜像](https://hf-mirror.com)

### B. 术语表

| 术语 | 说明 |
|------|------|
| GGUF | llama.cpp 使用的模型文件格式，支持量化和元数据 |
| GGML | llama.cpp 旧版模型格式，已淘汰 |
| Quantization（量化） | 降低模型精度以减少显存占用的技术，如 Q4_K_M 表示 4-bit 量化 |
| Offload | 将模型层从 CPU 内存加载到 GPU 显存的过程 |
| KV Cache | 键值缓存，用于加速自回归生成，占用显存 |
| Token | 模型处理文本的基本单位，中文约 1.5-2 个字符 = 1 token |
| Context Size | 上下文窗口大小，决定模型能处理的文本长度 |
| VRAM | 显存，GPU 专用的内存 |
| OOM | Out Of Memory，内存/显存不足错误 |
| Vulkan | 跨平台图形/计算 API，支持多厂商 GPU 加速 |
| CUDA | NVIDIA 专属并行计算平台 |
| HIP | AMD 专属计算接口，兼容 CUDA 代码 |
| SYCL | Intel 专属异构计算框架 |
| RLHF | Reinforcement Learning from Human Feedback，人类反馈强化学习 |
| LoRA | Low-Rank Adaptation，低秩适配器微调技术 |

---

> 文档生成时间：2026-05-19
> 文档版本：v1.0
