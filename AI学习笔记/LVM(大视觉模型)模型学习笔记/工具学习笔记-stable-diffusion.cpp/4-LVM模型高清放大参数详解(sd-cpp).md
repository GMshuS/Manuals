# sd.cpp highres‑fix（高清放大 / 高清修复）完整指南

> **一句话总结**：sd‑cpp 的 `--hires` 对应 A1111 WebUI 的**高清修复（Hires. fix）**，它不是简单的图片后处理超分，而是「先生成小图 → 放大尺寸 → 在潜空间重绘降噪」的**两阶段生成方案**，区别于单纯的 ESRGAN 图片超分。
>
> **本文整合**：原理与流程阶段 → 全部参数详解 → 插值类 / AI 类放大算法详解 → 两者对比 → denoise 搭配经验 → 选型决策树 → 命令行示例 → ComfyUI 对应设置。参数来源为 sd‑cpp 官方帮助文档，结合实践补充说明。

**目录**
1. [高清放大概述](#高清放大概述)
2. [hires 相关参数详解](#hires-相关参数详解)
3. [放大算法详解（一）：插值类](#放大算法详解一插值类)
4. [放大算法详解（二）：AI超分类(内置ESRGAN)](#放大算法详解（二）：AI超分类(内置ESRGAN))
5. [放大算法详解（三）：AI超分类(后置ESRGAN)](#放大算法详解（三）：AI超分类(后置ESRGAN))
6. [插值类 vs AI超分类：区别、优劣、适用场景](#插值类-vs-ai-类区别优劣适用场景)
6. [upscaler × denoise 搭配经验](#upscaler--denoise-搭配经验)
7. [决策树：放大算法选型流程](#决策树放大算法选型流程)
8. [sd‑cli 命令行示例](#sdcli-命令行示例)
9. [ComfyUI 对应参数设置](#comfyui-对应参数设置)
10. [附录：术语速查](#附录术语速查)

---

## 高清放大概述

### 什么是高清放大（highres‑fix）

Highres‑fix 是**两阶段文生图**工作流：

1. **第一阶段（基础生成）**：用原始尺寸 `--width / --height` 生成一张潜空间小图；
2. **放大潜变量**：把第一阶段得到的 latent 做放大（潜空间放大 / AI 模型超分），得到更大分辨率的潜变量；
3. **第二阶段（hires 重绘）**：对放大后的大潜变量执行**局部重绘降噪（denoise）**，修复放大带来的模糊、细节丢失，输出最终大图。

### 核心原理

1. 直接生成超大分辨率图有多重问题：VRAM 爆炸、容易出现重复物体、布局崩坏；
2. highres‑fix 先在较小分辨率完成构图、主体生成；
3. 将 latent（潜变量，VAE 解码前的数据）放大；
4. 使用**降噪强度（hires‑denoising‑strength）**控制保留原图多少信息，重新采样补全大图细节：
   - denoise 越高 → 越重绘，细节多，但更容易改变画面、换构图；
   - denoise 越低 → 尽量保留原图画面，只补少量细节，改动小。

### 作用

1. 在不直接跑超大分辨率采样的前提下输出高分辨率图片，降低显存压力；
2. 为图片增加细节、纹理；
3. 规避大尺寸直接生成带来的多头、多肢体等崩坏问题。

### 处于整体生成流程的哪个阶段

```
提示词编码 → 第一阶段采样（--width × --height）得到小 latent
     ↓
【highres‑fix 阶段（仅开启 --hires 才执行）】
     ↓
latent 放大 → hires 第二阶段重采样降噪 → VAE 解码 → 输出图片
```

> highres‑fix 发生在**第一轮采样结束之后、VAE 解码之前**，是潜空间层面的操作，不是输出图片之后做后期。如果不开启 `--hires`，直接跳过这个环节。

### 与普通图片超分的区别

| 模式 | 流程 | 是否会改变画面内容 |
|---|---|---|
| **highres‑fix（`--hires`）** | 潜空间重绘 + 放大 | 会，属于生成流程的一部分，可改变细节与构图 |
| **普通 ESRGAN / Upscale（`-M upscale`）** | 对已解码的 RGB 图片做后处理超分 | 不会，不重新采样降噪，不改变画面结构 |

---

## hires 相关参数详解

### 参数总表

| 参数 | 作用 | 默认值 | 取值范围 / 合法输入 | 使用场景 |
|---|---|---|---|---|
| `--hires` | highres‑fix **总开关**，只有开启，所有 `--hires-*` 系列参数才生效 | 关闭（不提供即关闭） | flag 开关，命令行带上即开启 | 需要高清修复输出大图；不开启则全部 hires 参数忽略 |
| `--hires-width <int>` | 高清修复输出目标宽度；设置非 0 则忽略 `--hires-scale` | 0 | ≥0 整数；0 = 用 scale 倍率计算尺寸 | 精确指定输出像素宽度，而非按倍率缩放，如固定 1792 宽 |
| `--hires-height <int>` | 高清修复输出目标高度；设置非 0 则忽略 `--hires-scale` | 0 | ≥0 整数；0 = 用 scale 倍率计算尺寸 | 精确指定输出像素高度 |
| `--hires-scale <float>` | 放大倍率；当 hires‑width/height 均为 0 时生效，基于原始 `-W -H` 计算最终大图尺寸 | 2.0 | 浮点数，一般 1.2–3.0；太大显存爆炸 | 绝大多数场景按倍率放大，如 1.5x、2x；512×512 + scale=2 → 1024×1024 |
| `--hires-steps <int>` | hires 第二阶段重绘的采样步数 | 0 | 整数；0 = 继承主 `--steps`；>0 = 独立步数 | 第一轮 20 步、hires 只用 12 步加快速度 |
| `--hires-denoising-strength <float>` | hires 重绘降噪强度，**最核心参数**；控制多大程度重绘画面 | 0.7 | 0.0–1.0；0 = 完全不重绘，1 = 完全重新生成 | 0.3–0.4 轻微补细节；0.6–0.75 通用平衡；0.85+ 大幅重绘画面容易大变 |
| `--hires-upscaler <string>` | 高清修复阶段 latent 放大算法，分**插值类**与**AI 超分模型**两类 | Latent | 插值类：`Lanczos, Nearest, Latent, Latent (nearest), Latent (nearest-exact), Latent (antialiased), Latent (bicubic), Latent (bicubic antialiased)`；AI 类：`--hires-upscalers-dir` 下的模型文件名 | Latent 系列：潜空间插值，速度快，不吃额外模型；ESRGAN 模型名：AI 超分，细节更强，需要加载模型 |
| `--hires-upscalers-dir <string>` | AI 超分模型的存放目录路径 | 无 | 本地文件夹路径 | 使用 ESRGAN 等 AI 超分时必须指定，程序从该目录读取模型 |
| `--hires-upscale-tile-size <int>` | AI 超分模型分块 tile 大小，**仅对模型类 upscaler 生效**，插值类不使用 | 128 | 正整数；常见 128–512 | 大图 AI 超分时分块降低显存；数值越小显存越低、速度越慢 |
| `--hires-sigmas <string>` | 自定义 hires 第二阶段的 sigma 噪声序列；指定后 `--hires-steps`、scheduler 对 hires 阶段失效 | 未设置 | 逗号分隔浮点数，如 `0.85,0.725,0.421875,0.0`；也支持预设 `qwen-image-2.1-turbo` | 高级用户固定 hires 噪声调度；一般生成不要设置 |

> **两个全局参数与 hires 的关系**：
> 1. `--sigmas`：控制**第一轮基础生成**的自定义 sigma，只影响第一阶段，不影响 hires 第二轮；设置后主流程 `--steps / --scheduler` 失效；hires 阶段不受它影响。
> 2. `--scheduler`：默认 hires 第二阶段会复用该 scheduler，除非设置了 `--hires-sigmas`。
> 3. 补充理解：`--sigmas` 自定义第一轮采样噪声序列，指定后 `--scheduler`、`--steps` 失效；`--hires-sigmas` 自定义第二轮 hires 重绘噪声序列，**不指定时 hires 会用「hires-steps + scheduler + hires denoise」独立生成新 sigmas，不会直接复用主采样 sigmas**。

### 参数之间的逻辑关系

1. **总开关优先**：不写 `--hires`，所有 `hires-*` 参数全部直接忽略，不执行高清修复。
2. **尺寸二选一逻辑**
   - `--hires-width >0 OR --hires-height>0`：使用指定像素尺寸，`--hires-scale` 被忽略；
   - `--hires-width=0 && --hires-height=0`：最终大图尺寸 = `原始W × hires-scale`、`原始H × hires-scale`。
3. **hires-steps 逻辑**
   - `--hires-steps 0`：第二阶段步数 = 主生成 `--steps`；
   - `--hires-steps >0`：第二阶段使用独立步数；
   - 设置了 `--hires-sigmas`：hires-steps 不再生效，sigma 列表长度决定采样步数。
4. **upscaler 逻辑分支**
   - 插值类（Latent/Lanczos 等）：不需要 `--hires-upscalers-dir`，`--hires-upscale-tile-size` 无效；
   - AI 类（ESRGAN 模型文件名）：必须配置 `--hires-upscalers-dir`，`--hires-upscale-tile-size` 生效控制分块。
5. **denoising-strength**：不改变图片尺寸，只控制第二阶段重绘强度，是 hires 效果最关键参数。

### 典型组合策略

1. **通用平衡方案（大多数人）**：开启 `--hires`，用 scale 倍率，latent 放大，denoise=0.7，hires-steps=0 继承主步数。
2. **尽量保留原图画面、只轻微加细节**：denoise 调低到 0.3–0.4；不要用太高 denoise，否则构图大变。
3. **想要更强 AI 超分细节**：指定 ESRGAN 模型做 hires-upscaler，配置模型目录，调 tile-size。
4. **追求速度**：hires-steps 设较小值，denoise 不要过高。

---

## 放大算法详解（一）：插值类

> **核心前置概念**：
> 1. **不带 Latent(xxx)**：`Lanczos`、`Nearest` → **RGB 图像空间插值**；先把 latent 解码成图片，放大图片，再编码回 latent，交给 hires 第二阶段重绘。
> 2. **带 Latent(xxx)**：`Latent`、`Latent (nearest)`、`Latent (nearest-exact)`、`Latent (antialiased)`、`Latent (bicubic)`、`Latent (bicubic antialiased)` → **直接在潜空间做插值放大，不经过 VAE 编解码**，速度更快，显存占用更低。
>
> ⚠️ **所有插值算法不会凭空创造真实细节**，只做数学拉伸，真正的细节来自 hires 第二阶段重采样。如果 denoise 开得很低，无论选哪个插值，画面都会模糊发虚。

### 两类空间的本质区别

**RGB 空间（Lanczos / Nearest）**
> latent → VAE 解码变成可见图片 → 图片放大 → VAE 编码压缩回 latent → 送入 hires 第二轮采样。
> ✅ 优点：放大逻辑与 PS 等图片软件一致，色彩更稳；
> ❌ 缺点：多两次 VAE 运算，**显存、耗时更高**；VAE 编解码会引入轻微色彩偏移。

**Latent 潜空间（所有 Latent(xxx)）**
> 直接操作 AI 内部压缩数据，**不做 VAE 解码**，把 4 倍压缩的 latent 矩阵拉伸变大，直接丢给第二轮采样。
> ✅ 优点：速度快，省显存；
> ❌ 缺点：latent 不是真正图片，插值出来的信号不完全符合真实图像分布，**非常依赖 hires-denoising-strength 重绘修复瑕疵**；denoise 低于 0.4 时容易出现色彩脏、扭曲。

> 重点：**插值只是“把画布拉大”，画上去的细节靠第二阶段采样**，不要指望插值算法本身变出头发、皮肤纹理。

### 插值类算法总览对照表

| 算法名称 | 工作空间 | 通俗原理 | 优点 | 缺点 | 适用场景 |
|---|---|---|---|---|---|
| **Lanczos** | RGB 图片空间 | 取周围一大圈像素加权计算，放大后边缘锐利，传统高质量缩放算法 | 边缘锐利；抗锯齿好；不易糊成一团 | 计算稍慢；高对比度边缘易出**振铃伪影（白边/光晕）**；需 VAE 解码+重编码，显存开销更大 | 人像、照片写实；图片层高质量拉伸；不喜欢 latent 空间色彩偏移 |
| **Nearest** | RGB 图片空间 | 最近邻，直接复制就近像素，不做混合，像马赛克放大 | 速度最快；硬边缘完全保留 | 锯齿、马赛克感很重；需 VAE 编解码 | 几乎不用；仅快速调试预览；像素风图片 |
| **Latent** | Latent 潜空间 | sd‑cpp **hires 默认值**，等价于 `Latent (bicubic antialiased)`，开箱即用平衡方案 | 速度快、显存低；不用来回 VAE 编解码；兼顾平滑+抗锯齿 | 潜空间是压缩信号，放大后偶尔轻微色彩偏移，依赖 denoise 修复 | **绝大多数日常出图，默认直接选这个** |
| **Latent (nearest)** | Latent 潜空间 | latent 内部最近邻复制，不做像素混合 | 速度极快，显存最低 | 块状、锯齿伪影明显；必须搭配较高 denoise 修复 | 快速跑测试、调试参数；像素风 AI 绘画 |
| **Latent (nearest-exact)** | Latent 潜空间 | 改进版最近邻；坐标严格取整，输出尺寸严格对齐，无小数错位 | 比普通 nearest 更稳定，尺寸不漂移；硬边界干净 | 同样块状锯齿；需 denoise 修复 | 像素风格、硬卡通边缘；需严格对齐 latent 网格（ComfyUI 同源） |
| **Latent (antialiased)** | Latent 潜空间 | latent 放大时开启抗锯齿过滤，抑制锯齿、混叠噪点，底层为 area 面积重采样 | 有效消除锯齿、细碎噪点；画面干净顺滑 | 轻微柔化细节；denoise 很低时整体偏糊 | 大量细碎纹理（树叶、毛发、建筑）；写实照片 |
| **Latent (bicubic)** | Latent 潜空间 | latent 内双三次插值，采样周围 16 个潜变量加权平滑，无抗锯齿过滤 | 过渡平滑，梯度柔和 | 易出锯齿/混叠噪点；高对比边缘易振铃 | 动漫插画、渐变多的干净画面 |
| **Latent (bicubic antialiased)** | Latent 潜空间 | latent 双三次插值 + 抗锯齿过滤；就是默认 `Latent` 的真身 | 兼顾平滑与抗锯齿；综合表现最好 | denoise 过低时依旧会模糊 | 通用万金油；人像、动漫、场景都合适 |

### 插值类常见坑点

1. **Nearest / Latent(nearest) / Latent(nearest-exact)**：只适合硬边缘风格；写实人像不要选，会出现大量锯齿马赛克，必须 denoise≥0.6 才压得住瑕疵。`nearest-exact` 比普通 nearest 更稳定，优先选它。
2. **Lanczos**：高对比度线条（黑头发、黑轮廓）边缘容易出现一圈白边光晕（振铃效应）；出现光晕就换成 `Latent(bicubic antialiased)`。
3. **Latent(bicubic)**：无抗锯齿，遇到密集纹理（草、树叶、布料）会冒出细碎奇怪噪点，此类场景优先选带 `antialiased` 的版本。
4. **所有 Latent 系列通用坑**：denoise 太低（0.2–0.4）无论选哪个都容易糊、色彩脏；Latent 放大在 denoise 0.55–0.75 区间效果最佳。

### 插值类选型速查

| 场景 | 推荐 upscaler | 配套 denoise 建议 |
|---|---|---|
| 日常通用，人像/动漫/场景，追求速度省显存 | `Latent`（即 Latent (bicubic antialiased)） | 0.6–0.75 |
| 写实照片、大量细碎纹理（森林、毛发） | `Latent (antialiased)` | 0.65–0.75 |
| 插画、大色块渐变、干净画面 | `Latent (bicubic)` | 0.6–0.7 |
| 像素画、硬边缘卡通风格 | `Latent (nearest-exact)` | ≥0.65 |
| 图片空间高质量放大，不怕多耗显存 | `Lanczos` | 0.6–0.7 |
| 调试、快速预览，不计较画质 | `Latent (nearest)` | ≥0.65 |

> ❌ 不推荐：裸 `Nearest`（RGB 空间最近邻，效果差，还要额外 VAE 开销）。

---

## 放大算法详解（三）：AI超分类(内置ESRGAN)

### 前置说明

> **底层原理**：
> 1. sd‑cpp 的 **AI 类 hires-upscaler 全部是 RGB 像素空间超分**，不是 latent 潜空间超分。流程：第一轮 latent → VAE 解码得到 RGB 图片 → AI 超分模型放大图片 → VAE 编码回 latent → 送入 hires 第二阶段重采样。需要两次 VAE 编解码，**显存、耗时高于 Latent 插值系列**。
> 2. 模型文件：支持 `.pth`（PyTorch）、GGUF 量化后的超分模型；放到 `--hires-upscalers-dir` 指定目录，`--hires-upscaler` 填模型文件名即可调用。
> 3. `--hires-upscale-tile-size` 仅对 AI 超分生效，用于分块推理降低显存；插值类不读取。
> 4. AI 超分只是放大并预生成纹理；**最终画面依然受 `hires-denoising-strength` 重绘强度影响**：denoise 越高，AI 纹理被扩散模型改写越多；denoise 越低，AI 超分痕迹保留越强。
> 5. sd‑cpp 不支持 GFPGAN 直接作为 hires-upscaler；GFPGAN 仅适合后期人脸修复，不能嵌入 hires-fix 链路。

### AI超分类模型总览表

> 这类模型标称倍率多为 4x；在 hires 里设 scale=1.5/2 时，内部会先 AI 4x 放大、再插值缩放到目标尺寸。

| 模型名称 | 标称倍率 | 架构 | 核心特点 | 优点 | 缺点 | 最佳使用场景 | 配套 denoise 推荐 |
|---|---|---|---|---|---|---|---|
| RealESRGAN_x4plus | 4x | RRDBNet | Real‑ESRGAN 官方通用写实模型，训练集含 JPEG 压缩、模糊、噪声等真实退化 | 通用性强，去压缩伪影、去模糊强；人脸/风景/静物自然，稳定不易出怪线条 | GAN 幻觉纹理，偶尔凭空捏造毛孔、皮肤纹理；高对比边缘偶尔锐化过头 | 写实人像、摄影风、产品图、老照片修复、通用写实 AI 图 | 0.45–0.65 |
| RealESRGAN_x4plus_anime_6B | 4x | RRDBNet（6block 轻量化） | 官方动漫专用，针对赛璐璐平涂、清晰黑线、大色块插画训练 | 线条干净利落不糊黑线；平涂色块不乱加噪点；二次元、线稿友好 | 放到写实照片上效果很差，把皮肤做平、丢真实纹理 | 二次元动漫、插画、漫画、线稿、平涂风格 | 0.4–0.6 |
| realesr-general-x4v3 | 4x | SRVGGNetCompact（轻量） | Real‑ESRGAN 轻量化通用模型，自带降噪分支，体积小 | 显存低、速度快；降噪可控；不易过度锐化 | 细节上限弱于 x4plus | 批量快速出图、显存紧张、杂图混合、预览调试 | 0.4–0.6 |
| RealESRNet_x4plus | 4x | RRDBNet | 去掉 GAN 对抗分支，只用 MSE 损失训练，偏保守还原 | 画面柔和，极少幻觉伪影，忠实原图结构，不乱加纹理 | 偏软、锐度不足；质感偏弱 | 严格保留原图样貌、不希望 AI 脑补细节、证件类、文字较多画面 | 0.35–0.5 |
| 4x-UltraSharp | 4x | RRDBNet（社区微调） | Civitai 热门写实向 ESRGAN，专门强化锐度与细节 | 锐度极强、纹理丰富，毛发/布料/建筑细节强 | 易放大噪点、JPEG 块；易“脏感”、过锐、白边 | 写实风景、建筑、金属、布料纹理，需强锐利质感 | 0.5–0.65 |
| 4x_NMKD-Siax_200k | 4x | RRDBNet（社区艺术向） | 偏向艺术插画、CG、游戏原画，兼顾线条和质感 | 线条干净 + 写实纹理兼顾；CG/厚涂过渡自然，不扁平化 | 人像皮肤有时塑料感；不适合纯照片 | CG 原画、厚涂插画、游戏角色、半写实二次元 | 0.45–0.6 |
| 4x-Remacri | 4x | RRDBNet（社区胶片向） | 模拟胶片质感，柔和、保留自然颗粒 | 画面温润不生硬锐化；适合胶片、氛围感人像 | 锐度偏低；细节提升幅度不如 UltraSharp | 胶片风人像、氛围感写真、复古摄影 | 0.4–0.6 |
| BSRGAN_x4 | 4x | RRDBNet 盲复原 | Blind SR，支持未知退化（同时处理模糊+噪点+压缩） | 来源杂乱低清图修复能力强，鲁棒性极高 | 速度慢、显存高；易改变原图色彩倾向 | 来源不明低清素材、老旧模糊杂图、严重压缩截图 | 0.5–0.65 |
| SwinIR 4x（PSNR 版） | 4x | Swin Transformer | Transformer 超分，偏向保真、高指标 | 线条、几何结构精准，文字/建筑直线不易扭曲；伪影少 | 非 GAN，观感偏平淡；速度慢、显存开销大 | 建筑图纸、文字、线稿、需精确几何结构的图 | 0.4–0.55 |

> ⚠️ **兼容性说明**：sd‑cpp 的 `--hires-upscaler` 加载依赖内置的 ESRGAN（RRDBNet 架构）加载器，主流通吃上表中的 RRDBNet 系 `.pth`/GGUF 模型；架构不匹配的模型（如 SwinIR 这类 Transformer 架构）通常**无法直接通过 `--hires-upscaler` 加载**，需在 ComfyUI 中用专用 UpscaleModelLoader 加载；BSRGAN 同为 RRDB 架构可尝试。表内模型仅作推荐，不限于此。另外 sd‑cpp 原生**不支持 latent 空间 AI 超分（LUA 类 latent upscaler）**，以上全部是 RGB 空间 ESRGAN 系模型。

### AI超分类选型速记（一句话）

| 需求 | 模型 |
|---|---|
| 低 denoise 保原图、写实通用 | RealESRGAN_x4plus |
| 二次元插画 / 线稿 | RealESRGAN_x4plus_anime_6B |
| 怕 AI 脑补细节、要保守保真 | RealESRNet_x4plus |
| 想要极致锐利纹理 | 4x-UltraSharp |
| 显存小、批量快速跑 | realesr-general-x4v3 |

### 主流模型 × denoise 搭配建议

**RealESRGAN_x4plus（通用写实首选）**
- 原理：高阶退化模拟真实世界模糊/压缩/噪点，GAN 生成感知真实纹理。工作空间：RGB 像素空间。
- 坑：高 denoise 会被扩散模型改写；低 denoise 易出现人脸蜡质、过度锐化。

| denoise 档位 | 画面表现 | 评价 |
|---|---|---|
| 0.4–0.5（低） | AI 纹理大量保留；修复原图模糊，人脸易蜡化、边缘过锐 | ⚠️ 适合尽量保留原图构图，接受轻微锐化；出现蜡脸就提高 denoise |
| 0.6–0.72（推荐黄金区间） | AI 提供基础清晰度，第二轮重绘修正蜡感、伪影；构图稳定细节丰富 | ✅ 绝大多数写实人像、风景 |
| 0.78–0.9（高） | AI 痕迹被大量覆盖，更多由 diffusion 生成细节；画面容易大变 | ⚠️ 追求极致细节、接受画面改动 |

**RealESRGAN_x4plus_anime_6B（二次元专用）**
- 轻量化 6 块 RRDB，专门针对动漫赛璐璐线条训练，**不要拿来跑写实照片**。

| denoise 档位 | 画面表现 | 评价 |
|---|---|---|
| 0.45–0.55 | 线条锐利干净、平涂色块保留好；偶尔线条毛刺 | ⚠️ 适合尽量保留原始插画轮廓 |
| 0.6–0.7（推荐） | 毛刺被 hires 重绘修复，线条干净、色彩稳定 | ✅ 二次元插画、漫画 |
| >0.75 | 动漫线条特征易被扩散抹掉 | ❌ 不建议过高 denoise |

**realesr-general-x4v3（克制版通用）**：改进版 RealESRGAN，降低幻觉、减少乱造细节、自带降噪。适合讨厌原版 x4plus 过度锐化/蜡脸的用户。推荐 denoise 0.58–0.70；人像、混合风格。

**4x-UltraSharp（强边缘、压缩图）**：针对 JPEG 压缩失真优化，强化边缘，适合建筑、UI、截图。⚠️ 坑：原图带噪点会把噪点一起放大。

| denoise 档位 | 画面表现 | 评价 |
|---|---|---|
| 0.5–0.6 | 边缘锋利，建筑线条、文字干净；噪点问题明显 | ⚠️ 适合建筑/UI 截图；原图干净才用低 denoise |
| 0.65–0.72（推荐） | 重绘压制放大噪点；边缘依旧锐利 | ✅ 建筑、数字艺术、截图 |

**RealCUGAN-se（漫画/二次元）**：非 ESRGAN 架构，专门漫画/动画，支持降噪等级，线条干净、平涂不脏。sd‑cpp 需 GGUF 转换版才能加载。推荐 denoise 0.6–0.7；**禁止用于写实人像**。

**RealESRNet_x4plus（保色彩、少幻觉）**：无 GAN 对抗损失，不主动编造纹理，优先忠实原图色彩。适合“不想 AI 脑补细节、只想放大”。推荐 denoise 0.45–0.6；denoise 太高会浪费保原图优势。

**其他模型补充**：4x_NMKD-Siax_200k（CG/厚涂插画）推荐 denoise 0.45–0.6；4x-Remacri（胶片风）推荐 0.4–0.6；BSRGAN_x4（低清杂图修复）推荐 0.5–0.65；SwinIR 4x（图纸/文字精确结构）推荐 0.4–0.55（需确认 sd‑cpp 加载支持）。

### 使用示例

示例 ：只用 Hires 内部 ESRGAN（前文方案）
```bash
sd --hires --hires-scale 2 --hires-denoising-strength 0.50 \
--hires-upscaler RealESRGAN_x4plus.pth \
--hires-upscalers-dir D:/upscaler_models \
--hires-upscale-tile-size 256
```

---

## 放大算法详解（三）：AI超分类(后置ESRGAN)

### 与 hires 内部 ESRGAN 的区别

> **一句话区分**：
> - `--hires-upscaler`：**Hires.fix 高清修复链路内部**的放大步骤，放大后紧接着走 UNet 图生图重绘，受 `hires-denoising-strength` 控制；
> - `--upscale-model`：**独立后置 ESRGAN 放大**，SD 整图生成完成、VAE 输出最终图之后，对成品图单独做一遍/多遍 ESRGAN 超分，**不再进 UNet 重绘**。

两者都加载 ESRGAN 模型、都支持分块 tile，但**在整条流水线里的位置完全不同**，这是最本质的区别。

### 参数明细

| 参数 | 含义 | 归属链路 |
|---|---|---|
| `--upscale-model <string>` | ESRGAN 模型路径（pth/safetensors） | 后置独立放大 |
| `--upscale-repeats <int>` | ESRGAN 连续跑多少次，默认 1；4x 模型 repeats=2 = 4×4=16 倍放大 | 后置独立放大 |
| `--upscale-tile-size <int>` | ESRGAN 推理时单块瓦片尺寸，默认 128；显存不足调小，调大接缝更少、显存更高 | 后置独立放大 |

> 配套：`--hires-upscalers-dir`、`--hires-upscale-tile-size` 是 **Hires.fix 内部 ESRGAN 放大**的参数，只作用于 Hires 流程。

### 两条流水线对比

Hires.fix 内部 ESRGAN（`--hires-upscaler xxx.pth`）：
```
文生图 → 低分辨率latent → VAE解码RGB → ESRGAN放大RGB → VAE编码回latent → UNet重绘（denoise生效） → VAE输出最终图
```
- ESRGAN 只是**预处理放大底板**，后面还有一轮 SD 重绘；
- denoise 控制 SD 重绘强度，是画面变化的主开关；
- 适合低 denoise，先用 ESRGAN 把底子做干净再微调；
- 上限受 denoise 约束，denoise>0.75 时 ESRGAN 的增强基本被覆盖。

后置独立 ESRGAN（`--upscale-model`）：
```
文生图 → 完整走完采样+VAE → 得到成品RGB图片 → ESRGAN直接对成品图放大增强（N次，由repeats控制） → 输出大图
```
- **没有 UNet 重绘、没有 denoise**，ESRGAN 是最后一步，只做超分、降噪、补纹理；
- 原图构图、五官、细节**完全不会被 SD 改动**，只有分辨率提升 + ESRGAN 自带的纹理幻觉；
- repeats 可链式叠加放大：4x 模型 repeats=2 → 原图→4x→再 4x=16 倍；
- 风险：GAN 幻觉（凭空加毛孔、噪点、伪影）是 ESRGAN 自身问题，没有后续 SD 步骤修正。

**关键对比表**

| 对比项 | Hires.fix 内部 ESRGAN（`--hires-upscaler`） | 后置独立 ESRGAN（`--upscale-model`） |
|---|---|---|
| 执行时机 | 第一轮 latent 之后、第二轮 UNet 重绘之前 | SD 全部采样、VAE 输出图片之后，**最后一步** |
| 是否走 UNet 重绘 | ✅ 是，denoise 控制重绘幅度 | ❌ 否，只跑 ESRGAN |
| 有没有 denoise | 有（`hires-denoising-strength`） | 无 |
| 放大逻辑 | 一般放大一次，目标倍率由 `hires-scale` 控制；ESRGAN 4x 后插值缩放到目标尺寸 | 按模型原生倍率反复跑，`upscale-repeats` 控制链式放大 |
| tile 参数 | `--hires-upscale-tile-size` | `--upscale-tile-size` |
| 画面改动风险 | 可控，denoise 高会改五官构图 | 构图姿态完全不变；只引入 ESRGAN 自身幻觉纹理 |
| 典型用途 | 高清修复，低 denoise 保图 + 适度重绘增强 | 成品图无损放大、降噪、超大尺寸输出（8K） |
| 显存压力来源 | VAE 解码 + ESRGAN + VAE 编码 + 第二轮 UNet | 仅 ESRGAN 推理，没有 UNet |

**使用示例（sd.cpp 命令行）**

示例：只用后置 ESRGAN（先生成满意的图，最后单纯放大，不改动内容）
```bash
sd --width 512 --height 768 \
--upscale-model D:/upscaler_models/RealESRGAN_x4plus.pth \
--upscale-repeats 1 \
--upscale-tile-size 256
```

**选型建议（一句话）**
1. 想要**高清修复（允许 SD 二次重绘、可改细节）** → 用 `--hires-upscaler`，走 Hires 链路；
2. 已经满意 SD 结果，**不想 SD 再改动任何构图五官，只单纯放大降噪** → 用 `--upscale-model` 后置放大；
3. 不要混淆两套 tile 参数：`--hires-upscale-tile-size` 只管 Hires 内部 ESRGAN；`--upscale-tile-size` 只管后置 ESRGAN。

**常见坑**
1. `--upscale-repeats` 只作用在后置阶段，与 `hires-scale` 互相独立，不能叠加；
2. `--upscale-repeats=2` 对 4x 模型是 16 倍，非常吃显存、幻觉很重，一般最多 repeats=1；
3. 后置 ESRGAN 没有 denoise，无法“抑制” GAN 脑补的奇怪纹理，这是它与 Hires ESRGAN 最大的区别。

---

## 插值类 vs AI超分类：区别、优劣、适用场景

### 核心区别总表

| 对比维度 | 插值类（优先 Latent(xxx)） | AI 类（ESRGAN 系列） |
|---|---|---|
| 运算空间 | 主流：Latent 潜空间；少数（Lanczos）RGB 空间 | **固定 RGB 图像空间**，必须 VAE 来回编解码 |
| 原理 | 数学插值采样（bicubic/lanczos/nearest 等），只做拉伸，无细节生成能力 | 深度学习模型，依靠训练先验修复模糊、降噪、添加纹理细节 |
| 是否加载额外模型 | ❌ 不需要，内置算法 | ✅ 需要单独 `.pth`/GGUF 超分模型文件 |
| 显存开销 | 很低（Latent 系列最优）；Lanczos 中等 | 高：VAE 编解码 + AI 超分推理 |
| 推理速度 | Latent 系列最快；Lanczos 中等 | 慢，多两段 VAE + AI 推理 |
| 低 denoise（0.35–0.5） | ⚠️ 短板明显：Latent 拉伸出的 latent 信号畸变，易脏色块、偏色；Lanczos 有振铃光晕 | ✅ 强项：RGB 放大底子干净，降噪+修复模糊，低 denoise 首选 |
| 中高 denoise（0.65+） | ✅ 表现稳定；重绘抹平插值瑕疵，性价比极高 | ⭕ 不错，但 AI 纹理会被第二轮采样覆盖，额外开销收益变小 |
| 细节来源 | 细节**全部来自 hires 第二轮重绘**，插值本身不贡献细节 | AI 先输出增强纹理，再交给第二轮微调；低 denoise 下 AI 纹理可保留 |
| 伪影风险 | bicubic 混叠摩尔纹；nearest 块状锯齿；Lanczos 振铃白边 | GAN 通病：过锐、噪点放大、虚假毛孔/发丝、塑料感；保守模型（RealESRNet）伪影少 |
| 配套参数 | 不需要 `--hires-upscalers-dir`；`--hires-upscale-tile-size` 无效 | 需要 `--hires-upscalers-dir`；tile-size 生效 |

### 优劣拆解

**插值类（Latent 系列为主，默认方案）**
- ✅ 优点：速度快、显存低，弱显卡/大批量友好；链路简单零模型依赖；denoise 0.6–0.75 区间效果足够好，性价比之王；插值模式灵活（插画/像素/写实）。
- ❌ 缺点：低 denoise 是硬伤（<0.5 易脏色块、色彩偏移）；无降噪能力，会把第一轮的模糊、噪点一起拉大；不能修复 JPEG 压缩伪影；Lanczos 高对比边缘易振铃光晕且多 VAE 开销。
- **一句话**：适合愿意给足 denoise、用第二轮采样去“修正拉伸瑕疵 + 生成细节”，优先速度与显存的场景。

**AI 类（ESRGAN）**
- ✅ 优点：低 denoise 场景独一无二——尽量保留原图构图/表情/姿态的同时提升清晰度；自带降噪、去模糊、去压缩块效应；可提前生成细腻纹理并在低 denoise 下保留；模型细分丰富（写实/二次元/保守保真/胶片质感）。
- ❌ 缺点：慢、显存开销大，批量成本高；GAN 易幻觉（凭空捏造毛孔/发丝/噪点/塑料感）；denoise>0.8 时收益很低（纹理被第二轮覆盖）；依赖外部模型文件、需配置目录与 tile；链路长，两次 VAE 有轻微色彩偏移。
- **一句话**：适合低 denoise 保原图清晰度、需要降噪修复模糊，愿意牺牲速度显存换干净底子的场景。

### 三类放大算法核心维度总表

| 对比维度 | Latent 潜空间插值（Latent-xxx） | RGB 传统插值（Lanczos/Nearest） | AI‑ESRGAN 类超分模型 |
|---|---|---|---|
| 运行空间 | Latent 潜空间，**不做 VAE 解码/编码** | RGB：latent→VAE 解码→插值放大→VAE 编码 | RGB：latent→VAE 解码→AI 超分→VAE 编码 |
| 显存开销 | 最低、速度最快 | 中等；两次 VAE 运算 | 最高；VAE+AI 模型推理 |
| 依赖外部文件 | 不需要 | 不需要 | **必须外部 pth/GGUF 模型文件** |
| 低 denoise（0.3–0.5） | ❌ 易脏色块、畸变、发灰；**不适合低 denoise** | ⚠️ Lanczos 色彩稳但易振铃白边；Nearest 马赛克严重 | ✅ 表现最好；低 denoise 首选方案 |
| 中等 denoise（0.55–0.75 最常用） | ✅ 综合优秀；重绘修复畸变，细节由 diffusion 原生生成、风格统一 | ✅ Lanczos 边缘锐利，有振铃风险，速度偏慢 | ✅ 纹理起点更强；有幻觉/蜡脸/过锐风险，需 denoise 压制 |
| 高 denoise（>0.8） | ✅ 插值痕迹几乎全被重绘抹除；与 AI 超分肉眼差距很小 | ✅ 效果尚可，振铃问题消失 | ⚠️ AI 纹理几乎全被覆盖，浪费算力，不如直接 Latent |
| 风格一致性 | 高，与主模型画风高度统一 | 中，VAE 往返带来轻微色彩偏移 | 中，AI 自带纹理风格，可能与 diffusion 画风冲突 |
| 保构图能力 | 优秀 | 较好 | 中等，AI 超分可能轻微偏移边缘轮廓 |
| 典型缺陷 | 低 denoise 脏色块；部分模式摩尔锯齿 | Lanczos 振铃白边；Nearest 马赛克 | 过锐、蜡脸、幻觉伪影、放大原图噪点 |
| `--hires-upscale-tile-size` | 无效 | 无效 | **生效，分块推理降显存** |

### 核心经验（denoise 决定两者差距）

> 最重要的分水岭：**denoise 高低决定两者差距大小**
> - denoise 0.35–0.6（低～中低，保原图）：两类差距最大，AI 类优势明显；
> - denoise 0.65–0.75（常用黄金区间）：都能用，取舍看显存与风格；
> - denoise ≥0.8（高重绘）：两者差异大幅缩小，第二轮采样主导画面，放大步骤痕迹基本被抹掉。
>
> 1. 计划 **denoise 较低（0.4–0.55）**：优先选 AI 超分模型；Latent 插值在低 denoise 极易出现 latent 畸变脏块。
> 2. denoise 设 **0.65–0.75**：AI 超分与 Latent 都可以，AI 纹理起点更强但性能开销更大。
> 3. denoise **>0.8**：两者差异很小，直接用 Latent 节省显存时间。

---

## 决策树：放大算法选型流程

> 先回答 3 个问题：①目标（保留原图 vs 大幅重绘）；②计划 denoise 区间；③显存/速度约束。然后按下图逐层判断：

```
开始
├─ 问题1：denoise ≥ 0.8？
│  ├─ ✅是 → 直接选 Latent（Latent bicubic antialiased），denoise 0.8~0.9
│  │     （高重绘会抹掉放大算法差异，AI 超分纯属浪费显存时间）
│  └─ ❌否 → 进入问题2
│
├─ 问题2：是否【优先保留原图结构/五官/姿态，尽量少改动画面】？
│  ├─ ✅是（保图优先，denoise 0.35~0.55）
│  │  ├─ 愿意加载 ESRGAN 模型、接受更慢速度？
│  │  │  ├─ ✅愿意
│  │  │  │  ├─ 写实人像/摄影/产品图/老照片 → RealESRGAN_x4plus.pth ｜ denoise 0.45–0.55
│  │  │  │  ├─ 二次元/插画/线稿/赛璐璐平涂 → RealESRGAN_x4plus_anime_6B.pth ｜ denoise 0.40–0.50
│  │  │  │  ├─ 文字/图纸/证件图，严禁脑补假纹理 → RealESRNet_x4plus.pth ｜ denoise 0.35–0.45
│  │  │  │  └─ 想要极强锐利纹理（建筑/金属/布料） → 4x-UltraSharp ｜ denoise 0.50–0.60
│  │  │  └─ ❌不愿意加载 AI 模型（折中方案）
│  │  │     └─ 选 Lanczos（RGB 插值）；注意高对比度黑轮廓易振铃白边光晕
│  │
│  └─ ❌否（不怕画面改动，靠第二轮采样生成细节）
│     ├─ denoise 0.50~0.75：
│     │  ├─ 显存小、批量出图、追求速度 → Latent 系列插值
│     │  │  ├─ 写实/毛发/树叶/大量细碎纹理 → Latent (antialiased) ｜ 0.65–0.75
│     │  │  ├─ 通用人像/动漫/场景万能 → Latent（默认） ｜ 0.62–0.72
│     │  │  ├─ 干净插画/大色块渐变 → Latent (bicubic) ｜ 0.60–0.68
│     │  │  └─ 像素画/硬边卡通 → Latent (nearest-exact) ｜ 0.65–0.75
│     │  └─ 显存充足，想在中 denoise 下同时拿到 AI 增强底子
│     │     └─ RealESRGAN_x4plus，denoise 0.50~0.60（进阶玩法，收益有限）
│     └─ denoise 0.75~0.8：
│        └─ 回到顶部规则：优先 Latent，收益与高 denoise 一致
```

### 决策结果汇总表（可直接抄参数）

| 分支场景 | 推荐 upscaler | denoise 区间 | 备注 |
|---|---|---|---|
| denoise ≥0.8，任意风格 | Latent | 0.80–0.90 | 不推荐 AI 超分，算力浪费 |
| 保原图、写实人像，可加载模型 | RealESRGAN_x4plus.pth | 0.45–0.55 | AI 降噪、修复模糊 |
| 保原图、二次元插画线稿 | RealESRGAN_x4plus_anime_6B.pth | 0.40–0.50 | 线条干净，不糊黑线 |
| 保原图、文字/图纸，拒绝幻觉 | RealESRNet_x4plus.pth | 0.35–0.45 | 保守 MSE 训练，几乎不脑补 |
| 保原图，但不想装 ESRGAN 模型 | Lanczos | 0.40–0.50 | RGB 插值，色彩稳，小心振铃光晕 |
| 写实风景、毛发，中高 denoise | Latent (antialiased) | 0.65–0.75 | 抑制锯齿摩尔纹 |
| 通用人像动漫场景 | Latent | 0.62–0.72 | sd‑cpp 默认，首选日常方案 |
| 干净大色块插画 | Latent (bicubic) | 0.60–0.68 | 渐变柔和，避开密集纹理 |
| 像素画、硬边缘卡通 | Latent (nearest-exact) | 0.65–0.75 | denoise 不能太低 |
| 强质感建筑金属纹理 | 4x-UltraSharp.pth | 0.50–0.60 | 容易放大噪点 |

### 配套约束清单（避坑检查）

- ✅ 使用 **AI 超分（ESRGAN）** 时必须带上：
  ```
  --hires-upscalers-dir "你的模型文件夹路径"
  --hires-upscale-tile-size 256
  ```
  tile-size：显存不够降到 128；显存富余可拉到 512，速度更快。
- ✅ 使用 **Latent 插值系列** 不需要上面两个参数。
- ❌ 禁止组合：`Latent(xxx) + denoise<0.45`；`Latent(nearest-exact) + denoise<0.6`；`任意 ESRGAN + denoise>0.75`；`Lanczos + 大量黑色轮廓 + 低 denoise`。

### 极简记忆口诀

> 低 denoise 要保图 → AI 超分优先，不想装模型就 Lanczos
> 中 denoise 正常出图 → Latent 插值性价比最高
> denoise 拉到 0.8 以上 → 一律 Latent，别折腾 ESRGAN

---

## sd‑cli 命令行示例

### 基础示例

**示例 1：基础高清修复，2 倍放大，latent 潜空间插值（最常用）**
原始尺寸 768×512，2 倍放大，denoise 0.7，继承主采样步数。
```cmd
sd-cli.exe -M img_gen -m model.gguf -p "a cat" -n "ugly" -W 768 -H 512 --steps 20 --hires --hires-scale 2.0 --hires-denoising-strength 0.7 -o out.png
```

**示例 2：固定输出尺寸 1536×1024，不使用 scale 倍率，hires 独立 15 步**
```cmd
sd-cli.exe -M img_gen -m model.gguf -p "a dog" -W 768 -H 512 --steps 25 --hires --hires-width 1536 --hires-height 1024 --hires-steps 15 --hires-denoising-strength 0.65 -o out2.png
```

**示例 3：使用 ESRGAN AI 模型做 hires 放大，设置模型目录，分块 256**
```cmd
sd-cli.exe -M img_gen -m model.gguf -p "landscape" -W 768 -H 768 --steps 22 --hires --hires-scale 1.5 --hires-denoising-strength 0.72 --hires-upscalers-dir D:\models\esrgan --hires-upscaler RealESRGAN_x4plus.pth --hires-upscale-tile-size 256 -o out3.png
```

**示例 4：自定义 hires 阶段 sigmas（高级用法）**
```cmd
sd-cli.exe -M img_gen -m model.gguf -p "girl" -W 512 -H 512 --steps 20 --hires --hires-scale 2 --hires-denoising-strength 0.7 --hires-sigmas "0.9,0.6,0.3,0.0" -o out4.png
```

### 按场景组合示例（片段）

```cmd
# 通用，中等 denoise，Latent（首选）
--hires --hires-upscaler Latent --hires-denoising-strength 0.68

# 低 denoise 尽量保原图，AI 超分
--hires --hires-upscaler RealESRGAN_x4plus.pth --hires-upscalers-dir ./esrgan --hires-upscale-tile-size 256 --hires-denoising-strength 0.48

# 低 denoise，不想加载 AI 模型，用 Lanczos
--hires --hires-upscaler Lanczos --hires-denoising-strength 0.48

# 高 denoise 大幅重绘，直接 Latent，不使用 AI 超分
--hires --hires-upscaler Latent --hires-denoising-strength 0.82

# 插值类各场景
--hires --hires-upscaler "Latent (antialiased)" --hires-denoising-strength 0.72   # 写实风景毛发
--hires --hires-upscaler "Latent (bicubic)" --hires-denoising-strength 0.62      # 干净插画
--hires --hires-upscaler "Latent (nearest-exact)" --hires-denoising-strength 0.70 # 像素画风
```

### 完整多行命令（AI超分）

> 注意：ESRGAN 原生是 4x 模型；hires-scale=2 时 sd‑cpp 内部会再做一次插值缩放到目标倍率。

```cmd
# 写实人像，RealESRGAN_x4plus，2 倍放大
sd-cli.exe -M img_gen -m model.gguf -p "photo of girl" -W 768 -H 512 --steps 22 ^
--hires ^
--hires-upscalers-dir D:\models\esrgan ^
--hires-upscaler RealESRGAN_x4plus.pth ^
--hires-scale 2.0 ^
--hires-upscale-tile-size 256 ^
--hires-denoising-strength 0.68 ^
-o ai_upscale_output.png

# 二次元插画，RealESRGAN_x4plus_anime_6B
sd-cli.exe -M img_gen -m anime.gguf -p "anime girl" -W 768 -H 768 --steps 20 ^
--hires ^
--hires-upscalers-dir D:\models\esrgan ^
--hires-upscaler RealESRGAN_x4plus_anime_6B.pth ^
--hires-scale 1.5 ^
--hires-upscale-tile-size 256 ^
--hires-denoising-strength 0.65 ^
-o anime_ai_upscale.png
```

---

## ComfyUI 对应参数设置

> ComfyUI 没有叫 highres-fix 的原生节点，A1111 的高清修复等价工作流需要手动组合节点，对应 sd‑cpp hires 逻辑。

### 完整等价工作流结构

```
文本编码 → KSampler（第一轮基础采样，小分辨率）
        ↓
Latent Upscale（对应 --hires-upscaler；潜空间放大）
        ↓
KSampler（第二轮重采样，hires 阶段）
        ↓
VAE Decode → 输出图片
```

### 参数映射表

| sd‑cpp hires 参数 | ComfyUI 对应节点/参数 | 说明 |
|---|---|---|
| `--hires` | 开启整套两阶段采样工作流 | 不搭建第二阶段 KSampler = 关闭 hires |
| `-W / -H` | 第一轮 KSampler 空 latent 尺寸 | 基础小图分辨率 |
| `--hires-scale` | LatentUpscale 节点 `upscale_factor` | 放大倍率；与宽高二选一 |
| `--hires-width / hires-height` | LatentUpscale 设置 `width/height` | 指定输出 latent 像素，优先级高于倍率 |
| `--hires-upscaler` | LatentUpscale → `upscale_mode` | `latent/bicubic/lanczos` 对应插值；AI 超分用 `UpscaleModelLoader`+`ImageUpscaleWithModel`。注意：ComfyUI 中 AI 超分作用于 RGB 图像，回到 latent 需 VAE Encode；sd‑cpp 可直接在 latent 层调用 esrgan，两者实现不同 |
| `--hires-denoising-strength` | **第二轮 KSampler denoise** | 最重要参数，与 sd‑cpp 含义完全一致；denoise=0.7 |
| `--hires-steps` | 第二轮 KSampler `steps` | 0 = 与第一轮 steps 一致；填数字即独立步数 |
| `--scheduler` | 第二轮 KSampler scheduler | hires 阶段默认继承；设置 `--hires-sigmas` 时，ComfyUI 用 `CustomSigmas` 节点传入自定义 sigma 序列 |
| `--hires-sigmas` | CustomSigmas 节点喂给第二轮 KSampler | 传入逗号分隔的 sigma 列表，此时 steps 参数失效 |

### 插值 / AI超分对应映射

| sd‑cpp hires-upscaler | ComfyUI 对应节点/参数 |
|---|---|
| `Latent` / `Latent (bicubic antialiased)` | LatentUpscale，`upscale_method = bicubic-antialiased` |
| `Latent (bicubic)` | LatentUpscale `bicubic` |
| `Latent (antialiased)` | LatentUpscale `area`（面积重采样，抗锯齿） |
| `Latent (nearest)` | LatentUpscale `nearest` |
| `Latent (nearest-exact)` | LatentUpscale `nearest-exact` |
| `Lanczos` | 先 VAE Decode 图片 → ImageUpscale（lanczos）→ VAE Encode 回 latent，再送入第二轮 KSampler |
| `Nearest` | VAE 解码 → 图片 nearest 放大 → VAE 编码回 latent |
| AI-ESRGAN 模型 | UpscaleModelLoader + ImageUpscaleWithModel（模型放 `models/upscale_models`），VAE 解码 → AI 超分 → VAE 编码回 latent，再送入第二轮 KSampler |

### 重要差异提醒

> 1. sd‑cpp highres-fix 支持**直接在 latent 空间使用 ESRGAN 模型做潜变量放大**；ComfyUI 原生的 ESRGAN 作用在 RGB 图片上。复刻 sd‑cpp 行为需：latent → VAE decode → AI 超分图片 → VAE encode 回 latent，再送入第二轮 KSampler。
> 2. A1111 的 hires fix 节点（ComfyUI 自定义节点）`A1111 Hires Fix` 可几乎 1:1 复刻 sd‑cpp/A1111 行为：
>    - Upscaler：对应 `--hires-upscaler`
>    - Denoising strength：对应 `--hires-denoising-strength`
>    - Resize mode / Scale：对应 `hires-scale` / hires-width/height
>    - Second pass steps：对应 `--hires-steps`
> 3. 第三方节点 `A1111 Hires Fix` 可直接选择 ESRGAN 模型，内部自动完成 VAE 解码-AI 超分-VAE 编码，与 sd‑cpp 行为对齐。

### ComfyUI 简易复刻工作流（使用第三方 A1111 Hires Fix 节点）

1. CheckpointLoaderSimple 加载模型；
2. CLIPTextEncode 正反提示词；
3. A1111_Hires_Fix 节点：
   - base_size W/H：第一轮基础尺寸（对应 `-W -H`）
   - hires_scale：放大倍率
   - denoising_strength：0.7
   - upscaler：Latent / Lanczos / 选择 AI 超分模型
   - second_pass_steps：0 = 继承主采样步数
4. 输出 latent 送入 VAE Decode，保存图片。

### AI超分 ComfyUI 完整链路

```
1. 第一轮 KSampler → latent 小图
2. VAE Decode：latent → RGB 图片
3. UpscaleModelLoader 加载 ESRGAN 模型 + ImageUpscaleWithModel：AI 放大图片
4. VAE Encode：放大后的 RGB 图片转回 latent
5. 送入第二轮 KSampler（hires 重绘，denoise 对应 --hires-denoising-strength）
6. VAE Decode 输出图片
```

---

## 附录：术语速查

| 术语 | 含义 |
|---|---|
| latent | 潜变量，VAE 解码前的压缩数据表示，不可直接查看 |
| hires-fix | 高清修复/高清放大，两阶段生成（小图 → 放大 → 潜空间重绘） |
| denoise / denoising strength | 降噪强度，控制第二阶段重绘程度（0=保留原图，1=完全重绘） |
| upscaler | 放大算法：插值类（Lanczos/Latent 系列）或 AI 超分模型（ESRGAN 系） |
| VAE | 变分自编码器，负责 latent ↔ RGB 图片之间的编解码 |
| sigmas | 采样噪声序列，控制每步噪声调度；自定义后对应 scheduler/steps 失效 |
| ESRGAN | 基于 GAN 的 AI 图片超分模型，可增强纹理、修复模糊/压缩 |
| tile-size | AI 超分分块推理大小，用于降低大图超分显存占用 |
