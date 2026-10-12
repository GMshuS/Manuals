# stable-diffusion-cpp 

## sd-server.exe 参数整理手册
> 
> 来源：sd-server.exe `--help` 输出，commit d32b4e8
> 分类：服务监听选项、模型上下文选项、硬件/后端选项、生成默认选项；包含**参数名、说明、默认值、特点/备注**。
> 重要提示：`Default Generation Options`（生成默认选项）虽然可以写在sd-server启动命令，但**仅作为API未传参时的fallback默认值**；业务调用优先使用HTTP-JSON内参数。`-i/--init-img` 写在启动行只会设置全局默认初始图，**不是固定输入图，实际业务依然建议在每次API请求传入图片**。

### 一、Svr Options 服务监听选项

| 参数 | 说明 | 默认值 | 特点/备注 |
| --- | --- | --- | --- |
| `-l, --listen-ip <string>` | 服务监听IP | `127.0.0.1` | 设为`0.0.0.0`允许局域网访问 |
| `--serve-html-path <string>` | 根路径提供HTML网页文件路径 | （可选，无） | 用于内置WebUI页面 |
| `--listen-port <int>` | 服务监听端口 | `1234` | 注意端口占用冲突 |
| `--color` | 日志标签按日志级别显示彩色 | 关闭 | 终端环境生效，重定向日志文件建议关闭 |
| `-h, --help` | 打印帮助并退出 | - | 仅查看帮助，不启动服务 |
| `--log-level` | 最小输出日志级别；可选：`debug,verbose,info,warn,error` | `info` | 控制日志输出详细程度 |
| `-v, --verbose` | 等价 `--log-level verbose` | 关闭 | 打印大量调试信息，排错用 |

### 二、Context Options 模型上下文选项（**绝大多数写在sd-server启动命令**）

| 参数 | 说明 | 默认值 | 特点/备注 |
| --- | --- | --- | --- |
| `-m, --model <string>` | 完整大模型文件路径 | 无 | 单文件完整模型；与`--diffusion-model`二选一 |
| `--clip_l <string>` | clip-l文本编码器路径 | 无 | SDXL系列使用 |
| `--clip_g <string>` | clip-g文本编码器路径 | 无 | SDXL系列使用 |
| `--clip_vision <string>` | clip视觉编码器路径 | 无 | IP-Adapter依赖此编码器 |
| `--t5xxl <string>` | t5xxl文本编码器路径 | 无 | Wan2.2、SD3系列必选 |
| `--llm <string>` | LLM大语言文本编码器路径 | 无 | 例：qwen2.5-vl用于混元视频；`--qwen2vl`是已废弃别名 |
| `--tokenizer <string>` | tokenizer.json路径；支持逗号赋值 | 无 | PiD、Lens模型必需 |
| `--llm_vision <string>` | LLM的ViT视觉编码器路径 | 无 | `--qwen2vl_vision`已废弃别名 |
| `--diffusion-model <string>` | 独立DiT/Diffusion主干模型路径 | 无 | 视频模型（Wan/HunyuanVideo）主要使用该参数 |
| `--high-noise-diffusion-model <string>` | Wan2.2-A14B MoE高噪专家权重路径 | 无 | **仅A14B MoE使用，TI2V-5B不要填** |
| `--uncond-diffusion-model <string>` | 无条件diffusion模型，Ideogram4 CFG使用 | 无 | 极少用到 |
| `--embeddings-connectors <string>` | LTXAV embedding连接器路径 | 无 | LTXAV视频模型 |
| `--vae <string>` | 独立VAE解码器路径 | 无 | 视频模型必须指定，不同模型VAE不能混用 |
| `--vae-format <string>` | 强制覆盖VAE latent格式；auto/flux/sd3/flux2/wan | `auto` | 识别异常时手动指定，Wan模型填`wan` |
| `--audio-vae <string>` | LTX音频VAE路径 | 无 | 音频-视频生成 |
| `--audio-encoder <string>` | wav2vec2音频编码器（Wan2.2 S2V音频转视频） | 无 | S2V任务使用 |
| `--taesd <string> / --tae` | TAE tiny自动编码器，快速解码质量低 | 无 | 快速预览，画质损失大 |
| `--control-net <string>` | ControlNet模型路径 | 无 | 控制图生成 |
| `--ip-adapter <string>` | IP-Adapter模型路径 | 无 | 需要搭配`--clip_vision` |
| `--motion-module <string>` | AnimateDiff运动模块路径 | 无 | SD1.5图片转视频用 |
| `--embd-dir <string>` | embedding嵌入词文件夹路径 | 无 | 加载文本embedding |
| `--lora-model-dir <string>` | LoRA模型目录路径 | 无 | 自动扫描目录下LoRA权重 |
| `--hires-upscalers-dir <string>` | 高清修复超分模型目录 | 无 |  |
| `--tensor-type-rules <string>` | 按张量模式设置权重精度 | 无 | 示例：`^vae.=f16,model.=q8_0` |
| `--model-args <string>` | 模型额外参数 key=value逗号分隔 | 无 | 如chroma系列、qwen_image_zero_cond_t等 |
| `--photo-maker <string>` | PhotoMaker模型路径 | 无 |  |
| `--pulid-weights <string>` | PuLID Flux权重路径 | 无 |  |
| `--upscale-model <string>` | ESRGAN超分模型路径 | 无 |  |
| `--backend <string>` | 模块后端分配，格式`模块=设备` | 无 | 示例 `te=cpu,vae=cpu,diffusion=vulkan0`；核心硬件参数 |
| `--params-backend <string>` | 参数存储后端：disk/cpu等 | 无 | 可把权重放磁盘做超大模型推理 |
| `--split-mode <string>` | 多设备权重分发模式 `layer`/`row` | `layer` | row仅CUDA有效；可按模块单独设置 |
| `--rpc-servers <string>` | RPC分布式卸载服务器列表 host:port | 无 | 多机分布式推理 |
| `--max-vram <string>` | 单设备显存预算GiB | `0` | 0=读取实时空闲显存；负数代表预留空闲显存；示例`vulkan0=4` |
| `-t, --threads <int>` | CPU计算线程数 | `-1` | ≤0自动取物理CPU核心数 |
| `--disable-prefetch` | 关闭下一段权重异步预取 | 关闭 | 关闭后性能下降 |
| `--disable-segmented-compute` | 强制单块计算图，关闭自动分片 | 关闭 | 大模型会OOM，一般不要开启 |
| `--eager-load` | 启动时一次性全部加载权重，非懒加载 | 关闭 | 启动慢，首次推理快；内存不足不要开 |
| `--force-sdxl-vae-conv-scale` | 强制SDXL VAE conv scale | 关闭 |  |
| `--offload-to-cpu` | 权重放内存，需要时再上传GPU | 关闭 | **AMD 860M/UMA强烈建议开启，防OOM** |
| `--mmap` | 开启内存映射读取模型文件 | 关闭 | 降低内存占用，磁盘IO上升 |
| `--fa` | 全局开启FlashAttention | 关闭 | 全部模块生效 |
| `--diffusion-fa` | **仅diffusion主干开启FlashAttention** | 关闭 | Wan、Hunyuan视频强烈建议开启 |
| `--diffusion-conv-direct` | diffusion使用直接conv2d算子 | 关闭 |  |
| `--vae-conv-direct` | VAE使用直接2D/3D卷积算子 | 关闭 |  |
| `--linear-scale <float>` | 输入线性缩放覆盖 | `0` | 0使用模型默认，1代表不缩放 |
| `--attn-scale <float>` | FA K/V缩放覆盖 | `0` | 0使用模型默认，需要`--fa/--diffusion-fa` |
| `--auto-fit on\|off` | 自动根据内存分配权重位置 | `on` | 与`--backend`共存；开启自动分片；`--params-backend`会禁用本功能 |
| `--type` | 强制权重类型 f16/q4_0/q5_K_M/q8_0等 | 读取文件本身类型 | 不要随便修改，会破坏精度 |
| `--rng` | 全局随机数生成器 `std_default/cuda/cpu` | `cuda`(sd-webui风格) | comfyui习惯用cpu |
| `--sampler-rng` | 采样器RNG | 继承`--rng` | 可与全局RNG分开设置 |
| `--prediction` | 预测类型覆盖 eps/v/edm_v/sd3_flow/flux_flow/sefi_flow | auto | 一般不手动修改 |
| `--lora-apply-mode` | LoRA应用模式 `auto/immediately/at_runtime` | `auto` | 量化权重自动切at_runtime模式 |
| `--list-devices` | 打印可用后端设备列表并退出 | - | 排查Vulkan/CUDA设备，不启动服务 |

### 三、Default Generation Options 生成默认选项

> 
> ⚠️ **注意：写在sd-server启动命令只是HTTP请求不传该字段时的后备默认值，不是写死任务参数。正式业务建议全部放在API JSON；`-i --init-img`写启动行只会是全局默认初始图，每次请求可以覆盖。**

| 参数 | 说明 | 默认值 | 特点/备注 |
| --- | --- | --- | --- |
| `-p, --prompt <string>` | 正向提示词 | 空 | API请求不传则取该默认；不要在启动写业务prompt |
| `-n, --negative-prompt <string>` | 负向提示词 | 空 | 同上 |
| `-i, --init-img <string>` | 初始参考图路径（图生图/图生视频） | 无 | **不适合写死在server启动；优先API传base64 input_image** |
| `--end-img <string>` | 结束帧图片路径，Flux2V使用 | 无 |  |
| `--mask <string>` | 掩码图片路径 | 无 | 图生图局部重绘 |
| `--control-image <string>` | ControlNet控制图路径 | 无 |  |
| `--ip-adapter-image <string>` | IP-Adapter参考图片路径 | 无 |  |
| `--control-video <string>` | control视频帧目录路径 | 无 | 目录存放按序号命名图片 |
| `-W, --width <int>` | 输出宽度 | `512` | 视频模型必须符合模型支持分辨率 |
| `-H, --height <int>` | 输出高度 | `512` |  |
| `--steps <int>` | 采样总步数 | `20` | Wan视频一般20-28步 |
| `--high-noise-steps <int>` | Wan A14B MoE高噪专家步数 | `-1(auto)` | 仅A14B MoE；TI2V-5B忽略 |
| `--video-frames <int>` | 视频总帧数 | `1` | >1开启视频输出 |
| `--fps <int>` | 视频帧率 | `24` |  |
| `--cfg-scale <float>` | CFG引导强度 | `7.0` | Wan TI2V常用5.0-7.0 |
| `--flow-shift <float>` | Flow模型（Wan/SD3）运动偏移 | `auto` | Wan2.2视频典型3.0，控制运动幅度 |
| `--sampling-method` | 采样器：euler/euler_a/dpm++等 | 模型自适应 | Wan官方示例euler |
| `--vae-tiling` | 开启VAE分块解码，降低显存 | 关闭 | **视频模型强烈建议开启** |
| `--temporal-tiling` | 开启视频VAE时间维度分块 | 关闭 | **大幅降低视频推理显存；860M必开** |
| `-s, --seed` | 随机种子 | `42` | 小于0使用随机种子 |
| `--strength <float>` | 图生图重绘强度 | `0.75` |  |
| `--moe-boundary <float>` | Wan2.2 A14B MoE时间步切换阈值 | `0.875` | 仅MoE模型生效 |
| `--extra-sample-args <string>` | 采样器额外参数 key=value | 无 | 传递shift、eta、各种调度器参数 |
| `--extra-tiling-args <string>` | VAE分块额外参数，时间分片大小等 | 无 | `temporal_tile_frames`等 |

### 四、关键实操规则总结（针对sd-server）

1. ✅ **写在sd-server启动命令**：模型路径、VAE、t5xxl/llm、`--backend`、`--diffusion-fa`、`--offload-to-cpu`、`--vae-tiling`、`--temporal-tiling`、`--auto-fit`、`--listen-ip/port`、`-v`、`--max-vram`。
2. ⚠️ **生成类参数（prompt、-W-H、video-frames、flow-shift、cfg-scale、-i init-img）**：
   - 可以写启动行，但只是**后备默认值**；每次HTTP请求JSON可以完全覆盖。
   - **业务开发不要依赖启动行设置图片、提示词，全部放到API请求体。**
3. Wan2.2 TI2V-5B：**不要出现任何`high-noise-*`系列参数**，该组参数只给A14B-MoE。
4. 860M APU固定推荐必开性能参数：`--diffusion-fa --vae-tiling --temporal-tiling --offload-to-cpu --auto-fit on`。


## 通俗讲解：clip_l / clip_g / clip_vision_g / sd35_clip_g / sd35_clip_l / t5xxl / VAE / LoRA / Embedding / connectors


一句话总纲：**文本编码器负责读懂文字提示词；视觉编码器看懂参考图；VAE（解码器）负责把 AI 潜空间数字画面还原成真实图片 / 视频；LoRA/Embedding 是小插件；connectors 是模型之间的翻译转换器**

| 名称 | 通俗作用 | 和模型关系 | sd.cpp怎么用 |
| --- | --- | --- | --- |
| **clip_l** | CLIP文本编码器（L版本，轻量）   把**文字提示词**转换成AI能看懂的数字向量。 | SDXL、SD3系列用；   ⚠️ `clip_l` ≠ `sd35_clip_l`，二者权重不同，不能互换。 | 启动参数 `--clip_l 路径.gguf`   SDXL：clip_l + clip_g 成对使用 |
| **clip_g** | CLIP文本编码器（G版本，大版本）   同样解析文字，理解能力更强，和clip_l成对配套。 | SDXL原版专用；**不是SD3.5的clip_g**，不要和sd35_clip_g混用。 | 启动参数 `--clip_g 路径.gguf`   SDXL必须同时加载 clip_l + clip_g |
| **sd35_clip_l** | SD3.5专用clip_l文本编码器   专门为SD3.5训练的clip_l，结构和原版SDXL clip_l不一样。 | **仅SD3.5系列模型使用**，不能给SDXL用。 | `--clip_l sd35_clip_l.gguf` |
| **sd35_clip_g** | SD3.5专用clip_g文本编码器   SD3.5专属的clip_g。 | **仅SD3.5系列模型使用**，不能给SDXL用。 | `--clip_g sd35_clip_g.gguf`   SD3.5：clip_l+clip_g + t5xxl三者一起加载 |
| **clip_vision_g** | CLIP视觉编码器（图像版CLIP）   **不读文字，读图片**：把参考图片转为向量。 | 配合IP-Adapter使用；   用于图生图参考风格、参考人物。 | `--clip_vision 路径.gguf`   **必须搭配 --ip-adapter 模型参数**，文生图不需要 |
| **t5xxl（umt5-xxl）** | 超大T5文本编码器   理解长提示词、复杂语义，Wan2.2、SD3、HunyuanVideo视频模型依赖。   CLIP擅长理解风格，T5擅长理解长句子、动作描述。 | Wan2.2（T2V/TI2V）、SD3/SD3.5、HunyuanVideo视频模型**必选**；SDXL不需要。 | `--t5xxl umt5-xxl.gguf`   Wan2.2生成视频，缺少它会提示词失效 |
| **VAE** | 图像/视频解码器   Diffusion主干输出的是一堆抽象潜空间数字，VAE把这堆数字**还原成肉眼可见图片/视频帧**。   没有VAE，AI只会输出一堆噪点，看不到画面。 | **强绑定模型！VAE不能跨模型混用**   Wan用Wan的VAE，FLUX用FLUX，SDXL用SDXL。 | `--vae 路径.safetensors` 或gguf   视频模型必须指定VAE；可搭配`--vae-tiling`省显存 |
| **LoRA（小模型插件）** | 轻量化微调插件，小文件。   不改变主干大模型本身，只增加风格、人物、物体、动作。   好比给PS装滤镜/人物素材。 | 适配主干模型：FLUX的LoRA只能给FLUX，Wan的LoRA只能给Wan。 | `--lora-model-dir D:\xxx\loras`   自动扫描目录下所有lora文件；**在WebUI/API请求里选择启用哪个LoRA**，不是启动时直接激活 |
| **Embedding（Textual Inversion）** | 文本嵌入词，很小的文件。   训练出来的“特殊关键词”，用来固定特定人脸/物体/风格，直接写在提示词里调用。 | 同样绑定基础模型，SD1.5的embedding不能给FLUX用。 | `--embd-dir D:\xxx\embeddings`   加载后，直接在正向提示词写embedding名字即可生效 |
| **connectors（embeddings-connectors）** | 嵌入连接器   相当于**适配器**，用来连接不同类型编码器和主干模型之间的向量格式。   简单理解：转接头，让文本编码器输出向量能被主干模型读懂。 | **LTX系列视频模型专用**，Wan、SD3.5、FLUX不需要。 | `--embeddings-connectors 连接器文件.gguf`   只有跑LTX视频才需要加，其他模型不要加这个参数 |

### 重点区分（容易混淆）

1. **clip_g（SDXL） vs sd35_clip_g**
二者名字都叫 G，但**不能混用**。SDXL 的 clip_g 是老版本 CLIP；sd35_clip_g 是 SD3.5 单独训练的 CLIP，结构不同，强行加载会画面崩坏。
2. **clip_g（文本） vs clip_vision_g（视觉）**
   - clip_g：**读文字**（提示词）
   - clip_vision_g：**读图片**（参考图），完全两类东西
3. CLIP 系列 vs T5XXL
   - CLIP：擅长风格、画面描述，短提示词，体积相对小（SDXL 用）
   - T5XXL：超大文本模型，擅长超长、复杂、精细描述，Wan 视频、SD3、Qwen-Image 依赖它，显存占用高

### 简单例子（帮你串起来）

SDXL 文生图：
`clip_l + clip_g` 读取你的提示词 → 扩散模型生成潜数据 → **VAE 解码成图片**

Wan2.2 文生视频：
`t5xxl`读取提示词 → Wan 扩散模型生成视频潜张量 → **VAE 解码成视频**

Qwen-Image 图编（换图里人物）：
`llm+clip_vision_g`读取参考图 + 文字指令 → connector 转换向量 → 扩散模型生成新潜图 → VAE 解码图片

### 适配 sd.cpp (sd-server) 的使用要点

- Wan2.2 视频：**只使用 t5xxl 做文本编码，不用 clip_g/clip_l**
- Qwen-Image：LLM + clip_vision_g + connectors + VAE 整套一起配合
- FLUX.2 Klein（Flux2-klein-9B）：文本编码器是 Qwen3 LLM，图生图 / 参考图能力是由这个 Qwen3 LLM 本身自带的视觉能力承担，不再单独拆出独立的 `clip_vision_g` 文件，所以启动命令不用写 `--clip_vision_g`。
- SD3 / SD3.5： 原生架构里，**图生图 / 参考图不是靠独立的 `clip_vision_g` 视觉编码器**，它是直接把原图编码进**扩散模型本身的潜空间**，用潜变量输入，不需要单独视觉 CLIP。


## sd-server WebUI 视频生成参数详细说明

以下参数均为**单次请求生效**，不修改服务端全局配置，适用于 stable-diffusion.cpp 所有模型（图片/视频生成），部分参数仅特定模型生效会单独标注。

---

### INPUT 基础输入模块

| 参数名称 | 说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| Prompt（正向提示词） | 描述想要生成的画面内容、运动轨迹、镜头运镜、光影风格；视频模型建议同时写清「主体+动作+镜头+环境」。 | 空 | 视频生成建议结构：主体描述 + 动作描述 + 运镜描述 + 风格光影；越具体可控性越强。 |
| Negative Prompt（负向提示词） | 描述需要排除的瑕疵、错误元素、不良效果，比如畸形、模糊、过曝、静态画面等。 | 空 | 通用负面词：模糊、过曝、低质量、畸形肢体、画面静止；视频可补充「卡顿、跳帧、融合错误」。 |
| Width（宽度） | 生成画面/视频的宽度像素，必须符合模型支持的分辨率倍数。 | 512 | Wan2.2常用横版832×480、竖版480×832；720p规格用1280×720；禁止随意设置非标准分辨率。 |
| Height（高度） | 生成画面/视频的高度像素。 | 512 | 同上，竖版视频480×832，横版832×480。 |
| Video Frames（视频总帧数） | 生成视频的总帧数，数值越大时长越长，显存占用越高。 | 1（纯图片模式） | 短视频常用33帧（约2秒@16fps）、128帧（约8秒@16fps）；显存不足优先减少帧数。 |
| FPS（帧率） | 最终输出视频的播放帧率，仅影响播放速度，不改变生成速度和显存占用。 | 24 | 常规短视频16fps/24fps；慢动作场景可降低到8~12fps。 |
| Seed（随机种子） | 生成结果的随机种子，相同种子+相同参数可复现完全一致的画面。 | 42 | 固定数值可复现效果；设为-1表示每次生成随机种子。 |

---

### SAMPLE 采样设置（主降噪阶段）

控制主扩散过程的核心参数，决定画质、生成速度、运动强度。

| 参数名称 | 说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| Scheduler（调度器） | 噪声时间步的调度算法，决定降噪节奏；default为模型自动匹配最优方案。 | default | 普通场景保持default即可；特殊需求可切换euler_a、dpm++ 2m等。 |
| Flow Shift（运动偏移） | **Flow架构模型专属**（Wan、SD3、Flux），控制视频运动幅度、画面动态强度；数值越大运动越剧烈。 | 3 | Wan视频推荐2.5~3.5；   - 偏低：画面静止、运镜不动；   - 偏高：画面崩坏、物体变形、逻辑错乱。 |
| Method（采样器） | 数值求解的具体算法，直接影响画质和生成速度。 | euler | 视频模型推荐euler，速度快且效果稳定；追求精细画质可尝试dpm++ 2m。 |
| Steps（采样步数） | 主降噪阶段的总步数；步数越高画质越精细，生成速度越慢。 | 20 | Wan视频性价比区间20~~28步；快速预览可降到12~~16步；高质量输出可到30步以上。 |

> 
> 「Show extras」展开包含Eta等高级采样参数，新手保持默认即可，无需修改。

---

### GUIDANCE 引导设置

控制提示词对生成过程的约束强度。

| 参数名称 | 说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| CFG Scale（引导强度） | 控制AI遵循提示词的程度；数值越低越自由发挥，越高越严格贴合提示词，过高会导致画面过饱和、僵硬死板。 | 6 | Wan视频推荐5~7；   - 太低：画面严重偏离提示词；   - 太高：色彩溢出、画面死板、出现伪影。 |
| Distilled Guidance（蒸馏引导强度） | 蒸馏加速模型专属的引导强度，配合CFG共同控制引导效果。 | 3.5 | 默认3.5即可；量化模型可微调，普通场景无需修改。 |

---

### HIGH NOISE PASS 高噪阶段设置

> 
> ⚠️ **仅 Wan2.2-T2V/I2V-A14B（MoE双专家模型）生效**，对应HighNoise高噪专家的独立参数；单稠密模型（如TI2V-5B、SD3、HunyuanVideo）设置后不生效。

#### MoE 总控

| 参数名称 | 说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| MoE Boundary（切换阈值） | 高噪专家→低噪专家的切换时间点，取值0~1；数值越大，高噪专家工作占比越高。 | 0.875 | 官方推荐0.875；   - 调大：前期构图更充分，后期细节渲染时间减少；   - 调小：更早进入细节阶段，容易构图崩坏、动作混乱。 |

#### 高噪阶段采样设置

| 参数名称 | 说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| Scheduler（高噪调度器） | 高噪阶段的噪声调度器，default自动匹配。 | default | 保持default即可。 |
| Flow Shift（高噪运动偏移） | 高噪阶段的运动强度，blank=default表示跟随主采样设置。 | blank = default | 默认跟随主设置；需要单独调整前期运动幅度可手动赋值。 |
| Method（高噪采样器） | 高噪阶段的采样算法。 | default | 保持default。 |
| Steps（高噪步数） | 高噪专家运行的步数；**总推理步数 = 高噪步数 + 主Steps**。 | 20 | 官方常用8~~12步；总步数建议控制在20~~30步区间。 |
| Eta（噪声系数） | 采样过程的噪声注入量，blank=auto自动计算。 | blank = auto | 新手无需修改，影响采样随机性。 |
| Shifted Timestep（时间步偏移） | 降噪起始点偏移量，特殊调试使用。 | 0 | 默认0即可。 |

#### 高噪阶段引导设置

| 参数名称 | 说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| CFG Scale（高噪CFG） | 高噪阶段的提示词引导强度。 | 7 | 默认7即可；高噪阶段CFG可略高于主阶段。 |
| Distilled Guidance（高噪蒸馏引导） | 高噪阶段蒸馏引导强度。 | 3.5 | 默认即可。 |
| Image CFG（图像引导强度） | 图生视频任务中，参考首图的还原强度；blank表示跟随文本CFG。 | blank = follow text cfg | 图生视频可设1.5~2.5，平衡首帧还原度和运动自由度。 |
| SLG Layers | 稀疏引导生效的网络层编号。 | 7,8,9 | 高级调试参数，默认即可。 |
| SLG Layer Start | SLG层生效起始时间点。 | 0.000999... | 默认即可，新手不建议修改。 |
| SLG Layer End | SLG层生效结束时间点。 | 0.200000... | 默认即可。 |
| SLG Scale | SLG整体强度系数，0为关闭。 | 0 | 需要增强局部引导可微调，普通场景保持0。 |

---

### CONDITIONING 条件控制模块

| 参数名称 | 说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| CLIP Skip（跳过CLIP层） | 跳过文本编码器最后N层输出；-1表示不跳过，使用完整编码结果。 | -1 | Wan/T5类视频模型保持-1；SDXL部分LoRA需要设为2。 |
| Strength（条件强度） | 整体条件引导的权重，影响提示词对画面的作用强度。 | 0.75 | 默认0.75；画面太飘可提高，太死板可降低。 |
| VACE Strength | VAE条件强度，控制解码阶段的条件权重。 | 1 | 高级参数，默认1即可，一般不修改。 |

---

### LORA 插件模块

| 参数名称 | 说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| Add LoRA（添加LoRA） | 点击选择已加载的LoRA模型，可单独设置权重；   前提：sd-server启动时已通过`--lora-model-dir`指定LoRA目录。 | 无（No LoRA） | 根据需求添加对应LoRA；权重常用0.6~1.0；   ⚠️ LoRA必须匹配当前主干模型，跨模型无效甚至报错。 |

---

### IMAGE INPUTS 图像输入模块

用于图生视频、首尾帧插值、控制帧等任务。

| 参数名称 | 说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| Start Frame（起始帧） | 图生视频（TI2V/I2V）的参考首图；上传后视频第一帧会还原该图片内容。 | 无 | 图生视频必须上传；分辨率建议和生成分辨率一致。 |
| End Frame（结束帧） | 视频结尾参考帧，用于首尾帧插值、FLF2V风格生成；可选。 | 无 | 需要固定结尾画面时上传；普通图生视频无需设置。 |
| Control Frames（控制帧） | 多帧有序参考图，用于全程控制视频画面结构、运动轨迹。 | 无 | ControlNet、运动控制等场景使用；普通生成无需上传。 |

---

### VAE TILING VAE分块解码

> 
> ✅ **显存优化核心功能**，大分辨率、视频生成强烈建议开启，几乎不损失画质。
> 
> 
> | 参数名称 | 说明与特点 | 默认值 | 建议值 |
> | --- | --- | --- | --- |
> | Enabled（启用开关） | 开启VAE分块解码，将画面拆成小块逐一解码，大幅降低显存峰值。 | 关闭 | 视频生成、720p以上分辨率必须开启；   512×512小图可关闭。 |
> | Tile Width（分块宽度） | 每个分块的宽度像素；0=自动计算最优分块大小。 | 0 | 保持0自动即可，手动设置容易出现拼接痕迹。 |
> | Tile Height（分块高度） | 每个分块的高度像素；0=自动。 | 0 | 保持0自动。 |
> | Target Overlap（重叠率） | 分块之间的重叠比例，用于消除拼接缝；数值越高拼接越自然，速度越慢。 | 0.5 | 默认0.5平衡效果和速度；出现拼接缝可提高到0.6~0.7。 |
> | Relative Width（相对宽度） | 分块相对宽度比例，0=自动。 | 0 | 保持0自动。 |
> | Relative Height（相对高度） | 分块相对高度比例，0=自动。 | 0 | 保持0自动。 |

---

### CACHE 缓存设置

用于加速重复生成、优化采样效率的高级功能。

| 参数名称 | 说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| Mode（缓存模式） | 缓存功能开关；disabled=关闭，开启后缓存文本编码等结果，重复生成同提示词更快。 | disabled | 批量生成相同提示词可开启；单次生成保持disabled。 |
| Cache Option（缓存参数） | 缓存的阈值、生效起止时间点；格式为`threshold=xx,start=xx,end=xx`。 | threshold=0.25,start=0.15,end=0.95 | 默认即可，属于高级调试参数。 |
| SCM Mask | 稀疏注意力掩码设置。 | 空 | 默认空即可，高级功能。 |
| Dynamic SCM Policy（动态SCM策略） | 自动动态调整SCM策略，优化推理性能。 | 勾选 | 保持勾选开启，有助于提升速度。 |

---

### 关键注意事项

1. **模型适配性**：
   - HIGH NOISE PASS 仅对 Wan A14B MoE 模型生效，其余单模型设置无效。
   - Flow Shift 仅 Flow 架构模型（Wan、SD3、Flux）有效，SDXL 等传统扩散模型无此参数。
2. **显存优化优先级**：开启 VAE Tiling → 降低分辨率 → 减少视频帧数 → 服务端开启 temporal-tiling。
3. **效果调试顺序**：先优化 Prompt → 调整 CFG Scale → 微调 Flow Shift → 最后修改 Steps。

## sd.cpp WebUI 图片生成参数详解（通用，适配Qwen-Image/FLUX/SD3.5等全部图像模型）

> 
> 说明：这是`sd-server`内置WebUI界面，参数是**单次生成请求参数**（不是服务启动参数），全部会提交到后端API。

### INPUT（基础输入区）

| 参数名称 | 参数说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| Prompt（正向提示词） | 描述你想要生成/编辑的画面内容。Qwen-Image这类图编辑模型，写修改指令放在这里。 | 空 | 清晰简洁，英文优先；图编辑模型写修改指令 |
| Negative Prompt（反向提示词） | 不想出现的画面缺陷，瑕疵、畸形、低画质。**FLUX/Qwen-Image很多场景可以留空**，不像SD1.5强依赖负面词 | 空 | 画面质量差时添加：`low quality, blurry, deformed` |
| Width 宽度 | 输出图片横向像素，分辨率越大显存占用越高 | 512 | 512~1024；860M显卡优先 ≤768 |
| Height 高度 | 输出图片纵向像素 | 512 | 512~1024；长宽尽量1:1、16:9等标准比例 |
| Batch Count 批次数量 | 一次请求生成几张图片，会成倍消耗显存 | 1 | 1，显存充足才改为2 |
| Seed 随机种子 | 固定种子=固定画面，换种子得到不同结果；填-1代表随机 | 42 | 需要复现画面固定；随便生成填`-1` |

### SAMPLE（采样设置）

| 参数名称 | 参数说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| Scheduler 调度器 | 噪声衰减算法，不同模型适配不同调度器，`default`会自动匹配模型 | default | default（优先自动适配，不建议手动改） |
| Method 采样方法 | 采样器，euler/dpmpp等；`default`自动选模型原生最优采样器 | default | default；FLUX/Qwen-Image推荐保持默认 |
| Steps 采样步数 | 迭代去噪次数。步数越多细节越好，耗时更长；**FLUX、Qwen-Image不需要高步数** | 20 | FLUX：4~~12；SD3.5：18~~28；SDXL：20~30 |
| Flow Shift | Flow模型专用（FLUX系列），控制噪声偏移，影响画面动态/细节 | blank=default | default，大部分场景不用修改 |

### GUIDANCE（引导CFG）

| 参数名称 | 参数说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| CFG Scale 提示词引导强度 | 控制模型遵守提示词的严格程度。数值越高越严格，过高容易画面崩坏 | 7 | FLUX/Qwen-Image：1.0~~3.5；SDXL/SD3.5：5~~8 |
| Distilled Guidance 蒸馏引导 | 蒸馏模型专用参数（FLUX distilled、SD3.5-distilled），蒸馏模型配套引导值 | 3.5 | 跟随模型推荐值；非蒸馏模型留空/默认 |

### CONDITIONING（条件控制）

| 参数名称 | 参数说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| CLIP Skip | CLIP文本编码器跳过层数。FLUX/Qwen不使用CLIP，该参数会被忽略；仅SDXL/SD1.5生效 | -1 | -1（默认，不跳过）；SDXL老模型偶尔用2 |
| Strength 重绘强度 | **图生图/参考图核心**。原图保留程度；数值越大，改动越大。0=完全保留原图，1=完全重绘 | 0.75 | 小幅修改：0.3~~0.5；大幅改写：0.7~~0.85 |
| Control Strength ControlNet强度 | ControlNet参考图的控制力度，越高越贴合姿态/线稿参考图 | 0.9 | 0.6~0.9；太高容易画面僵硬 |

### LORA

| 参数名称 | 参数说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| LoRA | 风格/人物微调小模型。提示词绑定LoRA权重。   ⚠️WebUI提示`No LoRA entries`：是因为**sd-server启动没加--lora-model-dir**，找不到LoRA文件夹 | 无加载 | 0.4~0.8；不要超过1.0，容易崩坏 |

> 
> 解决`No LoRA entries were returned by capabilities`：sd-server启动命令增加 `--lora-model-dir 你的lora文件夹路径`，重启服务，WebUI才能读取LoRA列表。

### IMAGE INPUTS（图像输入区，Qwen-Image重点）

| 参数名称 | 参数说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| Init Image 初始图 | 图生图（img2img）原图，基于这张图重绘 | 无 | 上传原图，配合Strength使用 |
| Mask Image 蒙版图 | 黑白遮罩，白色区域代表**要修改的区域**，黑色保留原图（inpaint局部重绘） | 无 | 局部编辑时上传；全图编辑不用 |
| Control Image ControlNet图 | 线稿/姿态图，用于ControlNet控制构图、人体姿态 | 无 | 使用ControlNet才上传 |
| Reference Images 参考图 | ✅**支持多张上传**！Qwen-Image、FLUX支持多图参考，用来参考风格、构图、参考素材 | 无 | 可一次上传1~多张参考图，Qwen-Image图像编辑核心输入 |

### VAE TILING（VAE分块，显存优化，对应启动参数--vae-tiling）

| 参数名称 | 参数说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| Enabled 启用VAE分块 | 把大图切成小块解码，**大幅降低VAE解码显存占用**，AMD 860M必开 | ✅开启 | ✅勾选开启 |
| Tile Width / Tile Height | 分块尺寸，0=自动自适应 | 0 | 保持0自动，不要手动填写 |
| Target Overlap 重叠 | 块之间重叠像素，防止拼接出现接缝瑕疵 | 0.5 | 0.4~0.5，默认0.5即可 |
| Relative Width / Relative Height | 相对分块系数，0=自动 | 0 | 保持0 |

### CACHE（缓存）

| 参数名称 | 参数说明与特点 | 默认值 | 建议值 |
| --- | --- | --- | --- |
| Mode 缓存模式 | 注意力缓存，加速重复生成，降低显存；disabled=关闭缓存 | disabled | 显存紧张：disabled；多次同图迭代可开启 |
| Cache Option | 缓存阈值参数 | threshold=0.25,start=0.15,end=0.95 | 默认即可，一般不用修改 |
| Dynamic SCM Policy | 动态SCM缓存策略，提升缓存稳定性 | ✅勾选 | 默认勾选 |

### 补充重要通用提示

1. **区分两类参数**
   - 启动命令参数（`sd-server.exe`那一行）：控制模型加载、后端Vulkan、文件夹路径，**启动后不能在WebUI修改**；
   - WebUI页面参数：每次生成提交的推理参数，每次生成可以独立调整。
2. **Qwen-Image 图像编辑重点**：使用`Reference Images`上传参考图，Prompt写修改指令，Strength控制改动幅度。
3. 显存小（860M）推荐固定开启：VAE Tiling。
4. LoRA列表不显示：**必须在sd-server启动命令添加`--lora-model-dir`**，重启服务。
