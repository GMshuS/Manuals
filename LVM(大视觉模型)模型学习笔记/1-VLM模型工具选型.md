# VLM模型工具选型

## 本地AI绘图工具对比表（含你提到的3款+主流备选）
> 说明：全部开源本地部署，GitHub为源码地址；Windows一般有一键整合包，Linux/macOS可手动git部署。

| 工具名称 | 核心特点 | 下载/源码地址 | 优点 | 缺点 | 适用人群 |
|---|---|---|---|---|---|
| **ComfyUI** | 节点图形式推理引擎；以工作流为核心，原生支持Flux、SDXL、SD3，支持自定义节点、批量、API自动化 | [https://github.com/comfyanonymous/ComfyUI](https://github.com/comfyanonymous/ComfyUI) | 显存利用率高、速度快；工作流可保存分享；API友好，适合自动化/流水线；支持最新模型（Flux、视频模型） | 学习曲线陡峭；新手上手难；需要理解扩散推理链路；界面不是传统表单UI | 开发者、自动化批量出图、专业美术管线、需要稳定复现工作流 |
| **stable-diffusion-webui(A1111)** | 传统标签页表单UI，历史最老牌SD界面，海量扩展生态 | [https://github.com/AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui) | 插件生态极其丰富；上手直观；教程资源最多；支持ControlNet、LoRA、图生图、训练 | 显存占用偏高；大模型（Flux）原生支持弱；项目迭代放缓；部分扩展兼容性随版本崩坏 | 普通创作者、新手、依赖大量插件做微调/图生图 |
| **stable-diffusion.cpp** | C++实现的SD推理库，GGUF量化模型，无图形界面，CLI/API，轻量跨平台，支持CPU/AMD/N卡 | [https://github.com/ggml-org/stable-diffusion.cpp](https://github.com/ggml-org/stable-diffusion.cpp) | 极低显存占用；支持GGUF量化；可CPU跑；跨平台；适合后端嵌入、服务化；无Python依赖 | 无原生GUI；参数配置需要命令行；调试麻烦；不适合纯可视化操作 | C/C++后端、嵌入式、低显存设备、批量服务部署 |
| **SD WebUI Forge** | A1111高性能分支，界面和A1111几乎一致，lllyasviel开发，优化显存与推理速度，原生Flux支持 | [https://github.com/lllyasviel/stable-diffusion-webui-forge](https://github.com/lllyasviel/stable-diffusion-webui-forge) | 保留A1111熟悉界面；显存优化更好，SDXL/Flux更省显存；速度明显快于原版A1111；内置ControlNet | 生态插件兼容略弱于原版A1111；部分老旧扩展无法运行；社区规模小于A1111 | A1111老用户，想跑Flux/SDXL，不想学节点 |
| **Fooocus** | 极简一键式UI，设计理念对标Midjourney，隐藏大量参数，内置提示词增强，默认SDXL | [https://github.com/lllyasviel/Fooocus](https://github.com/lllyasviel/Fooocus) | 零配置开箱即用；自动优化提示词；低显存友好；出图美学底子好；一键安装包丰富 | 可调节参数极少；自定义能力弱；仅原生SDXL；主项目基本停止新功能开发 | 新手、快速出概念图，不想调一堆参数 |
| **InvokeAI** | 画布式UI，类似PS，支持画布自由绘制、局部重绘、外绘，Apache2.0商业友好许可 | [https://github.com/invoke-ai/InvokeAI](https://github.com/invoke-ai/InvokeAI) | 画布编辑极强；图像局部编辑/扩图体验优秀；UI现代干净；许可证适合商用；多模型管理 | 批量生成、扩展生态弱于A1111；资源占用偏高；国内教程偏少 | 美术设计师、插画师，需要边画边迭代编辑图像 |
| **SwarmUI** | 前端表单UI，底层引擎是ComfyUI；表单操作，底层跑Comfy工作流，兼容Comfy节点 | [https://github.com/mcmonkey4eva/SwarmUI](https://github.com/mcmonkey4eva/SwarmUI) | 兼顾表单易用性+Comfy引擎性能；原生支持Flux、Qwen-Image、Wan视频；多GPU支持；跨平台 | 底层依赖ComfyUI；高级功能仍需要理解Comfy工作流；社区规模较小 | 想用Comfy性能，但不想手动拖节点的用户 |
| **SD.Next** | 多后端整合WebUI，可切换diffusers/原版SD后端，对新模型支持积极 | [https://github.com/vladmandic/automatic](https://github.com/vladmandic/automatic) | 多推理后端；对新模型、新采样器跟进快；优化多平台；内置大量优化 | 部分扩展兼容性一般；配置项繁多，新手容易迷惑 | 喜欢尝新模型、多后端切换的爱好者 |
| **Diffusers(??Hugging Face)** | 不是完整UI，是Python推理库；可自行写代码封装UI，HuggingFace官方SD生态 | [https://github.com/huggingface/diffusers](https://github.com/huggingface/diffusers) | 官方维护，模型库最全；高度可编程；适合二次开发；支持最新模型 | 无开箱GUI，需要写代码；上手门槛高；需要Python开发能力 | Python开发者、自定义推理服务、研究人员 |

### 简要选型建议
1. 做自动化、批量、流水线、复现工作流：**ComfyUI**
2. 习惯传统表单UI、大量插件、LoRA训练：**A1111 / Forge（优先Forge）**
3. C++后端、低显存、GGUF量化、无GUI服务：**stable-diffusion.cpp**
4. 纯美术画布编辑、局部重绘扩图、商用友好：**InvokeAI**
5. 新手开箱即用，不想调参数：**Fooocus**
6. 想要Comfy底层性能 + A1111表单界面：**SwarmUI**

## `ARM 860M显卡 + 32G统一内存`适配
> AMD Ryzen AI7 H350 + Radeon 860M，**32G LPDDR 统一内存，显存12GB（共享内存），可用内存19.6G**
> 关键点：**核显、HIP（AMD ROCm Windows支持有限），跑AI绘图是「共享内存」，不是独立显存；优势是总内存大，劣势是GPU带宽弱，大模型会慢**

### 适配工具对比（针对你的860M）
|工具|适配程度|推荐度|简要说明（针对你的配置）|
|---|---|---|---|
|stable-diffusion.cpp|⭐⭐⭐⭐⭐|**首选**|原生支持AMD、GGUF量化模型，C++轻量，**直接跑860M**，显存压力最小，支持SDXL、Flux、Wan视频；CLI/API，也可以搭配简易前端；最适合这台机器|
|ComfyUI|⭐⭐⭐⭐|次选|支持AMD HIP，节点化，可加载GGUF模型；**推荐用stable-diffusion.cpp后端或diffusers+AMD HIP**；Flux/SDXL可以跑，但大分辨率速度一般；适合做工作流调试|
|SwarmUI|⭐⭐⭐⭐|次选|底层ComfyUI，表单界面，不用拖节点；可以调用sd.cpp后端；兼顾易用性，适合不想啃命令行的人|
|Fooocus|⭐⭐⭐|备选|支持AMD，但底层是PyTorch，内存开销更大；SDXL可以跑，分辨率不能开太高，出图简单|
|InvokeAI|⭐⭐⭐|备选|画布编辑强，PyTorch后端，AMD部署配置麻烦，内存占用偏高|
|A1111 / Forge|⭐⭐|不优先推荐|PyTorch对Windows AMD支持差，需要额外折腾HIP/DirectML，速度慢，容易爆内存；扩展多，但对你这台机器性价比低|
|Diffusers(HuggingFace)|⭐⭐⭐|开发者备选|Python库，写代码调用，AMD DirectML/HIP配置繁琐，适合做二次开发|

### 详细选型建议
✅ 优先推荐：stable-diffusion.cpp
**最适配你的860M**
1. 优势：GGUF量化模型，C++原生，**不需要PyTorch、CUDA**，支持AMD GPU，直接调用Radeon 860M；32G大内存可以吃下Flux.1 [schnell/dev]、SDXL，甚至Wan2.2视频模型；速度在AMD核显上远好于PyTorch系WebUI。
2. 缺点：原生无GUI；可以搭配简易前端，或者用ComfyUI/SwarmUI调用sd.cpp作为推理后端。
3. 推荐模型：**GGUF量化版本（q4_k_m / q5_k_m）**，Flux、SDXL、SD3。

✅ 第二选择：ComfyUI（搭配sd.cpp后端）
如果你需要可视化节点工作流、做视频（Wan2.2、HunyuanVideo），用ComfyUI，**不要用默认PyTorch/DML**，改用sd.cpp作为推理后端，大幅降低内存压力。
> 注意：原生PyTorch+DirectML跑860M会很慢，尽量规避。

✅ 第三选择：SwarmUI
想保留表单式UI（类似A1111），同时底层跑sd.cpp，兼顾易用+性能，适合不想学习节点、又想用好860M的场景。

❌ 不推荐优先上原版A1111/Forge
Windows下AMD核显跑PyTorch DirectML，**速度差很多，容易内存抖动**，虽然能跑，但体验远不如sd.cpp。
