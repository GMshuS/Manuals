# AI图片&视频生成工具汇总文档
> 适用硬件：AMD Radeon 860M（RDNA3.5，gfx1151）
> 包含：工具清单、底层原理、GPU计算后端对比、多套部署方案、优缺点、选型建议

## 目录
1. [工具总览表（含ComfyUI、A1111、sd.cpp等）](#1-工具总览表)
2. [底层核心概念通俗讲解](#2-底层核心概念通俗讲解)
3. [GPU计算后端横向对比（CUDA / ROCm / DirectML / Vulkan / ZLUDA）](#3-gpu计算后端横向对比)
4. [三套可落地部署方案对比（针对860M）](#4-三套可落地部署方案对比针对860m)
5. [常见报错与坑点说明](#5-常见报错与坑点说明)
6. [选型最终建议](#6-选型最终建议)

---

## 1. 工具总览表
> 说明：模型权重文件（safetensors/GGUF）是AI本体；下面全部工具都是**UI界面 / 推理引擎**，负责加载模型并执行图像/视频生成计算。

|工具名称|工具本质|底层依赖|核心特点|下载地址|优点|缺点|
|---|---|---|---|---|---|---|
|Stable-Diffusion-WebUI(A1111)|网页可视化UI|默认PyTorch|打包好的全套绘图面板，文生图/图生图/插件开箱即用|[https://github.com/AUTOMATIC1111/stable-diffusion-webui|](https://github.com/AUTOMATIC1111/stable-diffusion-webui|)上手最简单，插件生态极其丰富；参数可视化，适合新手|底层黑盒，自定义推理链路弱；PyTorch显存占用高；860M跑DirectML容易爆显存|
|ComfyUI|节点式流程图UI|默认PyTorch，可替换sd.cpp后端|把扩散模型流程拆成独立节点，自由连线自定义完整推理流水线|[https://github.com/comfyanonymous/ComfyUI|](https://github.com/comfyanonymous/ComfyUI|)自由度最高，可精细控制每一步生成逻辑；支持视频插件AnimateDiff、ControlNet等；工作流可保存复用|原生PyTorch对860M显存压力大；节点模式上手门槛略高|
|stable-diffusion.cpp（sd.cpp）|轻量化推理引擎（无UI）|C++，Vulkan/CPU/GGUF量化|专门轻量化SD扩散推理，支持GGUF量化模型，大幅降低显存需求|[https://github.com/leejet/stable-diffusion.cpp|](https://github.com/leejet/stable-diffusion.cpp|)显存占用极低；适配弱显卡、核显；C++编写，不依赖PyTorch；Vulkan跨平台|无原生图形界面；高级插件（复杂ControlNet、视频模型）兼容性有限；量化会轻微损失细节|
|ComfyUI + sd.cpp后端|ComfyUI节点界面，推理交给sd.cpp|前端ComfyUI，后端sd.cpp(Vulkan)|保留ComfyUI节点工作流，**计算交给sd.cpp的Vulkan引擎+GGUF模型**|依赖ComfyUI+sdcpp插件|界面不变、工作流通用；显存占用大幅下降，860M首选Windows原生方案|支持节点有限；复杂视频/高级ControlNet插件兼容性差；采样器选择变少|

> 补充：视频生成模型（SVD、AnimateDiff）属于**扩散模型的扩展**，不是独立工具，一般作为插件嵌入ComfyUI/A1111。

---

## 2. 底层核心概念通俗讲解
### 2.1 扩散模型（SD图像/视频生成底层原理）
Stable Diffusion属于**扩散模型Diffusion Model**：
1. **训练阶段**：给海量真实图片，逐步添加噪声，把清晰图片变成雪花噪点图。AI学习这套加噪规律。
2. **生成（推理）阶段**：输入一张纯噪声雪花图，AI**反复迭代去除噪声**，几十步后生成图片。
3. **提示词控制**：CLIP文本编码器，将文字prompt转为AI可识别向量，引导去噪方向，保证图片符合描述。
4. **潜空间Latent**：SD不在原图尺寸运算，先压缩图片到更小的潜空间做去噪，最后解码还原图片，是SD节省显存的核心设计。
> 视频模型（SVD/AnimateDiff）：在图像扩散基础上，增加**时间维度**，学习帧之间连续变化，实现动态视频。

### 2.2 PyTorch 原理
PyTorch不是AI模型，是**AI矩阵运算工具箱**。
- 基础单元：Tensor张量（多维数字数组，图片、权重、向量全部以张量存储，可放内存/显存）
- 核心特性：**动态计算图**，运行代码实时构建计算链路，调试方便。
- 自动微分Autograd：**模型训练使用**，推理出图时默认关闭。
- PyTorch只是上层调度层，真正GPU加速依靠底层后端：CUDA / ROCm / DirectML / MPS。

> PyTorch缺点：显存开销大；Windows环境AMD移动端核显（860M）原生ROCm不支持，只能走DirectML，性能差、容易OOM。

### 2.3 术语区分
|缩写|全称|作用|
|---|---|---|
|LLM|大语言模型|输入文字，输出文字（如Qwen、Llama）|
|VLM|视觉语言模型|看图+理解图片内容，**不能画图**（如LLaVA、Qwen-VL）|
|Diffusion Model|扩散模型|图像/视频生成，噪声转图片（SD、SVD）|

### 2.4 MIOpen / rocBLAS / cuDNN / cuBLAS
|库|厂商|作用|对标关系|
|---|---|---|---|
|rocBLAS|AMD|矩阵乘法GEMM|对标NVIDIA cuBLAS|
|MIOpen|AMD|卷积、神经网络算子|对标NVIDIA cuDNN|
|cuBLAS|NVIDIA|矩阵乘法|N卡矩阵运算库|
|cuDNN|NVIDIA|卷积神经网络算子|N卡卷积加速库|
> 你ZLUDA报错`failed to load MIOpen.dll`：Windows版HIP/ROCm默认不带MIOpen，需要TheRock包补充；**ZLUDA不支持860M核显**。

---

## 3. GPU计算后端横向对比
|项目|开发方|底层原理|支持硬件|系统|PyTorch支持情况|SD绘图生态|优点|缺点|
|---|---|---|---|---|---|---|---|---|
|CUDA|NVIDIA|NVIDIA专属并行计算API，高度优化矩阵算子|仅NVIDIA显卡|Windows/Linux|⭐⭐⭐⭐⭐完美原生支持|⭐⭐⭐⭐⭐全部插件、视频模型原生支持|速度最快；算子优化最强，生态天花板|NVIDIA独占；AMD/Intel无法使用|
|ROCm|AMD|AMD自研GPU计算栈，对标CUDA|AMD高端独显；**WSL2+ROCDXG环境支持860M(gfx1151)**|Linux为主；Windows原生支持极差|⭐⭐⭐⭐Linux成熟；Windows原生弱；WSL2 ROCDXG可支持860M|⭐⭐⭐⭐Linux生态好|原生AMD硬件加速，性能接近CUDA|Windows裸机不支持860M；安装复杂；笔记本裸金属Linux坑多；WSL要求Ubuntu24.04|
|DirectML(DML)|微软|基于DX12封装AI计算层，API统一适配多厂商显卡|NVIDIA/AMD/Intel全部显卡/核显（含860M）|仅Windows|⭐⭐中等支持|⭐⭐ComfyUI/A1111可运行，高级算子插件易报错|Windows开箱即用，全硬件兼容，860M原生PyTorch唯一方案|中间层开销大，速度慢；核显共享内存极易爆显存，算子优化弱|
|Vulkan|Khronos行业联盟|跨平台图形+通用计算标准，非AI专用|几乎所有现代GPU/核显（含860M）|Windows/Linux/Android|⭐PyTorch原生Vulkan支持弱；**sd.cpp/llama.cpp深度原生支持**|⭐⭐⭐⭐sd.cpp首选后端|跨厂商跨平台；轻量；C++推理引擎性能优秀，显存占用低|不是为PyTorch设计；复杂扩散插件适配有限|
|ZLUDA|第三方社区项目|劫持CUDA API，将CUDA指令翻译成AMD可执行指令，让AMD显卡直接跑CUDA程序|AMD RX独显（6000/7000系）；**不支持860M核显**|Windows/Linux|⭐⭐目标直接跑原版CUDA PyTorch|⭐⭐⭐可跑CUDA版ComfyUI，稳定性有限|无需修改代码，A卡直接跑CUDA程序|社区非官方项目，bug多；**不支持移动端核显860M**；新版本PyTorch容易失效；依赖MIOpen等HIP组件|

> 关键结论：
> 1. Windows裸机：860M**不能原生使用ROCm**；
> 2. WSL2+ROCDXG（Ubuntu24.04）：ROCm7.1+可原生支持gfx1151（860M）；Ubuntu26.04版本过新，ROCDXG兼容性差；
> 3. ZLUDA仅面向AMD独立显卡，**860M核显不在支持列表**，就算补齐MIOpen依然大量潜在bug。

---

## 4. 三套可落地部署方案对比（针对860M）
|方案|部署方式|性能|显存占用|插件兼容性|上手难度|推荐等级|
|---|---|---|---|---|---|---|
|方案A：Windows原生 ComfyUI + sd.cpp(Vulkan后端+GGUF)|Windows直接运行，不需要虚拟机|中等|最低|一般，复杂ControlNet/视频模型受限|⭐低|⭐⭐⭐⭐⭐【首选】|
|方案B：WSL2 + Ubuntu24.04 + ROCDXG + ROCm PyTorch+ComfyUI|Windows内WSL2虚拟机，AMD PRO驱动，显卡穿透进WSL|较高|中等|⭐全部ComfyUI插件、AnimateDiff视频模型完美支持|⭐很高|⭐⭐⭐⭐【备选，追求完整插件生态】|
|方案C：Windows ZLUDA+HIP+MIOpen|Windows裸机，ZLUDA劫持CUDA|理论较高|中等|理论全部CUDA插件|⭐极高|⭐【不推荐，860M核显非官方支持，翻车概率极大】|

---

## 5. 常见报错与坑点说明
1. **ZLUDA `failed to load MIOpen.dll`**
    Windows HIP SDK默认不带MIOpen卷积库，需要下载TheRock包，选择`therock-dist-windows-gfx1150-xxx.tar.gz`，解压后将bin目录加入系统PATH。
    ⚠️ 即便修复dll报错，860M核显依然不被ZLUDA官方支持，后续大概率崩溃。
2. **WSL2 ROCDXG 404/识别不到GPU**
    容器内Ubuntu版本过高（如Ubuntu26.04），ROCDXG尚未适配；**必须使用Ubuntu24.04**；主机需要安装AMD PRO专业驱动，不是游戏Adrenalin驱动。
3. **原生ComfyUI(PyTorch+DirectML)爆显存OOM**
    AMD 860M核显使用内存共享显存，DirectML中间张量占用大，大模型极易显存溢出，这是优先选sd.cpp方案的原因。

---

## 6. 选型最终建议
1. **优先推荐：ComfyUI + sd.cpp（Vulkan后端 + GGUF量化模型）**
    Windows直接启动，无需虚拟机，显存压力最小，适合860M核显，日常图片生成足够用。缺点：复杂视频、高级ControlNet插件支持有限。
2. **备选：WSL2 Ubuntu24.04 + ROCDXG + ROCm PyTorch**
    需要完整ComfyUI生态、跑AnimateDiff视频、复杂ControlNet时选择。代价：虚拟机环境，配置繁琐，休眠后容易丢失GPU。
3. **不推荐：Windows ZLUDA**
    ZLUDA目标硬件是AMD独立显卡，860M移动端核显不在支持列表，折腾成本极高，投入产出比很低。

---