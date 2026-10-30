# LoRA（Low-Rank Adaptation）全体系详解
> 面向 **Krea2 / Z-Image / Boogu / Qwen-Image-Edit / FLUX2 / Wan2.2 / LTX2.3 / MiniMax-H3** 等现代 DiT 图像/视频扩散模型
> 覆盖：LoRA 概述 → 普通 LoRA → 加速 LoRA → 控制参数 → 完整命令行范例 → 坑点总结

---

## 目录
1. [LoRA 概述](#一lora-概述)
2. [普通 LoRA 详解](#二普通-lora-详解)
3. [加速 LoRA 详解](#三加速-lora-详解)
4. [LoRA 控制参数详解](#四lora-控制参数详解)
5. [完整命令行范例](#五完整命令行范例)
6. [坑点总结](#六坑点总结)

---

## 一、LoRA 概述

### 1.1 核心原理
> **一句话**：LoRA 不是独立大模型，是挂载在主扩散模型（Base Model / Checkpoint）上的**轻量外挂参数包**；主模型权重冻结，只训练少量低秩矩阵，推理时动态叠加到 UNet/DiT 注意力层，用来注入特定特征。

扩散模型（SD / SDXL / FLUX / Wan 等）的核心是 UNet 或 DiT（Transformer），其中 **Cross-Attention / Self-Attention 交叉注意力层**负责把文本提示词映射到图像潜空间，是控制画面风格、人物、材质、结构的关键位置。

- **训练时**：冻结主模型全部原始权重 `W`，只训练两组很小的矩阵 `A`、`B`。
- **推理时**：将 `ΔW = B·A` 乘以权重系数，叠加到原权重：

```
W' = W + scale × B·A
```

| 关键参数 | 说明 |
|---|---|
| **rank（秩）** | 控制 LoRA 表达能力，常见 4 / 8 / 16 / 32 / 64 / 128；rank 越大可学习细节越多，文件越大 |
| **文件体积** | 普通角色/风格 LoRA 一般几十 MB～几百 MB，远小于几 GB 的主模型 ckpt/safetensors |
| **可切换性** | 支持快速切换、多 LoRA 叠加；不修改原始主模型文件 |
| **卸载恢复** | 卸载 LoRA 后主模型恢复原样，**无灾难性遗忘** |

### 1.2 作用与分类
LoRA 分两大类，功能完全不同，不可混淆：

**① 普通 LoRA（微调特征：角色 / 风格 / 材质 / 动作 / 控制）**
- ✅ 固定人物人脸、五官特征：真人、动漫角色、IP 形象，保证多图/视频序列里长相稳定
- ✅ 锁定画风：厚涂、水墨、像素风、某画师风格、渲染质感
- ✅ 特定物体/服饰/道具：品牌 logo、特定服装、家具、机甲、场景
- ✅ 构图、光影、色彩、材质：电影感布光、胶片颗粒、金属材质
- ⚠️ **普通 LoRA 本身不能减少采样步数**，只约束画面特征，采样步数依然遵循主模型常规步数

**② 加速 LoRA（蒸馏加速：减少采样步数）**
- 用知识蒸馏训练出来，教模型在更少噪声迭代步内完成去噪
- 把原本需 20~50 步的扩散，压缩到 **1~8 步**出图，大幅加速图片/视频生成
- 常见类型：**LCM-LoRA（SD/SDXL UNet 生态）**、**Lightning-LoRA（LightX2V，DiT 图像/视频专属）**、**LTX Distilled LoRA**
- 注意区分：角色 LoRA 控制**画什么长什么样**（不加速）；加速 LoRA 控制**怎么更快去噪**（减少采样步数）

### 1.3 在图片/视频生成流程中的环节

**整体流程（推理阶段）**
```
1. 加载主模型（Checkpoint）：UNet/DiT + VAE + 文本编码器（CLIP/T5/LLM）
2. 加载 LoRA：在 UNet/DiT 注意力层动态叠加 LoRA 权重（发生在采样循环之前）
3. 输入提示词 → 文本编码器编码文本条件
4. 初始化随机潜噪声 → 进入采样循环（去噪迭代）
5. UNet/DiT 每一步采样，使用叠加了 LoRA 的权重预测噪声
6. 采样完成，潜空间送入 VAE 解码，输出图片/视频帧
```
> **关键点**：LoRA 作用于 UNet/DiT 的注意力权重，不作用于 VAE、CLIP，不是替换主模型；每一次前向推理都会把 LoRA 增量加到原权重。

**训练阶段（制作 LoRA）**
1. 数据集准备（图片 + 标注 caption）
2. 载入对应的主模型，**冻结主模型所有权重**
3. 在 UNet/DiT 注意力层插入 LoRA 矩阵，只更新 A、B 矩阵
4. 训练收敛后，只保存 A、B 矩阵，导出 LoRA 文件（.safetensors）

> **训练 LoRA 必须绑定同版本主模型**：训练时用 SD1.5，就只能在 SD1.5 主模型上推理；DiT 模型（Qwen/Wan/LTX/Krea2）同理，**跨架构不可混用**。

---

## 二、普通 LoRA 详解

### 2.1 认识普通 LoRA（分类、作用、特点）

> 普通 LoRA = **低秩适配微调适配器**，**不是蒸馏加速用**。核心：**不改动底模主干权重，只在 Transformer/DiT 注意力层插入少量低秩矩阵**，学习角色、画风、材质、物体、动作、结构控制等特征；文件体积小，可自由挂载、多 LoRA 叠加，**架构强绑定**。

| 分类 | 核心作用 | 特点 | 推荐强度 | 适用场景 |
|---|---|---|---|---|
| **角色/身份 Identity LoRA** | 记住特定人物、虚拟角色、IP 形象，跨场景保持长相五官特征 | 需多角度多表情训练集；带 trigger 触发词；**最常用** | 0.4~0.7 | 人物写真、虚拟人、IP 角色、人物一致性生成 |
| **风格 Style LoRA** | 固定美术画风、色调、笔触、光影体系（油画/水墨/像素/胶片） | 训练集内容多样，统一视觉风格；易与其他 LoRA 打架 | 0.3~0.6 | 海报、插画、统一视觉系列图/短视频 |
| **材质/物体 Material LoRA** | 学习特定材质（毛皮、皮革、金属、布料）、产品、道具、服装细节 | 适合材质替换、产品渲染（如 Qwen-Image-Edit 材质修改场景） | 0.4~0.6 | 电商产品、材质替换、道具设计 |
| **概念/动作 Concept LoRA** | 学习特定动作、镜头、构图、手势、特殊物体 | 学习固定形态逻辑，不锁定人物长相；视频模型用来学运镜、打斗动作 | 0.3~0.7 | 特定姿态、镜头语言、特殊道具 |
| **IC-LoRA（上下文控制 LoRA，DiT 视频专属）** | 类似 ControlNet，提取参考图/视频的轮廓、深度、姿态、运动轨迹，控制生成结构 | DiT 视频模型专属（LTX/Wan/H3），跨帧保持运动一致性；属于控制类普通 LoRA | 0.6~0.8 | 视频姿态控制、人物动作复刻、镜头运动传递 |

> **区分重点**：
> - 加速 LoRA：**蒸馏得到，目标 = 减少采样步数，不负责画风/角色**
> - 普通 LoRA：**微调训练，目标 = 固化特征、身份、材质、动作，不提速**

**通用特性**
1. **加载位置**（ComfyUI）：`UNet/DiT 底模 → LoRA 加载器 → K 采样器`；可多个普通 LoRA 串联叠加，最多 2~3 个为宜，太多权重冲突画面崩坏。
2. **架构隔离**：DiT 模型之间 LoRA 不互通（Qwen 的普通 LoRA 不能给 Wan，Krea2 不能给 FLUX2）。
3. **Rank 参数**：rank 越高学习能力越强，文件越大；DiT 模型社区 LoRA 常用 rank=32 / 64 / 128。
4. **叠加规则**：**1 个加速 LoRA + 最多 2~3 个普通 LoRA**；加速 LoRA 强度固定 0.9~1.0，普通 LoRA 压低强度。

### 2.2 各模型普通 LoRA 汇总表

> 下载站点说明：
> 1. **HuggingFace**：官方/社区开源原版 LoRA，优先推荐
> 2. **Civitai**：社区大量角色/风格 LoRA 预览下载
> 3. **模型文件后缀统一**：`.safetensors`
> 4. 普通 LoRA 必须加载在对应底模（RAW/Base），也可以挂载同系列 Turbo 蒸馏底模推理

| 基础模型 | 普通 LoRA 名称 | LoRA 类型 | 特点 | 推荐强度 | 下载地址 | 备注 |
|---|---|---|---|---|---|---|
| **Krea2** | krea2_darkbrush | 风格 LoRA | 水墨单色笔触风格 | 0.5~0.8 | Civitai / HuggingFace krea 社区库 | Krea 官方风格 LoRA 系列，同系列还有 dotmatrix、softwatercolor、retroanime 等 |
| **Krea2** | krea2_identity_edit_v1.2 | 角色身份 LoRA | 人物身份保持，换场景换服装保人脸，支持图生图编辑 | 0.4~0.7 | https://huggingface.co/SogniAI/krea2_identity_edit_v1_2 | 可用于 Krea2 RAW / Turbo 底模，人物换场景、虚拟试衣 |
| **Krea2** | krea2-turbo-sda v1.0 | 多样性修复 LoRA | 修复 Turbo 蒸馏后结果同质化严重问题，恢复画面多样性 | 0.4~0.6 | https://huggingface.co/F16/krea2-turbo-sda | 修复类普通 LoRA，非加速 LoRA，仅适配 Krea2 Turbo |
| **Z-Image** | Z-Image PixelArt 像素风 LoRA | 风格 LoRA | 8bit 复古像素游戏质感，无需复杂提示词 | 0.4~0.7 | z-image.me 资源中心 / HuggingFace qujincheng-z-image-lora | Z.I.T 官方画廊风格 LoRA，兼容 Z-Image Base / Turbo |
| **Z-Image** | Z-Image Identity 人物系列 LoRA | 角色身份 LoRA | 大量人物/虚拟角色，带专属 trigger 词，保持面部一致性 | 0.4~0.6 | https://huggingface.co/qujincheng/z-image-lora | 社区批量人物 LoRA 合集，200+ 角色 |
| **Boogu-Image-0.1** | boogu_image_turbo_lora_rank_128_bf16 | 基础风格增强 LoRA | 增强中英文文字渲染、海报质感，强化指令遵循能力 | 0.3~0.6 | https://huggingface.co/Boogu/Boogu-Image-0.1-Turbo-fp8 | Boogu 官方配套 LoRA；适合海报、UI 界面、带文字图像生成 |
| **Qwen-Image-Edit** | Qwen-Image-Multiple-Angles-LoRA | 角色身份 LoRA | 多视角人物保持，图像编辑场景下不丢失人物五官特征 | 0.4~0.6 | https://huggingface.co/fal/Qwen-Image-Edit-2511-Multiple-Angles-LoRA | 与 Lightning 加速 LoRA 一起使用，兼容材质修改工作流 |
| **Qwen-Image-Edit** | Qwen-Image-i2L 系列（Style/Fine） | 风格/材质 LoRA | 图像一键转 LoRA，上传参考图训练风格/材质 | 0.4~0.6 | HuggingFace fal 社区库 | i2L-Style：画风迁移；i2L-Fine：物体材质保留（适配皮革改毛皮场景） |
| **FLUX2** | FLUX2 Character 角色 LoRA | 角色身份 LoRA | FLUX2 专属人物 IP、写实人像，文字渲染保留能力强 | 0.4~0.7 | Civitai FLUX2 专区、HuggingFace BFL 社区 | ⚠️**不能用 FLUX.1 的 LoRA，架构不兼容** |
| **FLUX2** | FLUX2 Product 材质 LoRA | 产品/材质 LoRA | 工业产品、金属、布料、珠宝材质增强，商业渲染 | 0.3~0.6 | Civitai | 适合电商产品图生成 |
| **Wan2.2（14B 视频）** | WanAnimate_relight_lora_fp16 | 光影重绘 LoRA | 视频逐帧光影重映射，统一光影，减少光影闪烁 | 0.4~0.7 | https://huggingface.co/Kijai/WanVideo_comfy/tree/main/LoRAs/Wan22_relight | 视频专用，适合短剧、人物短片，与 LightX2V 加速 LoRA 叠加使用 |
| **Wan2.2** | Wan2.2 CharacterConsistency 角色 LoRA | 人物身份 LoRA | 短视频人物跨帧保脸，减少人脸崩坏漂移 | 0.4~0.6 | HuggingFace Kijai WanVideo_comfy | Wan2.2 图生视频专用，推荐搭配 4 步 Lightning 加速 LoRA |
| **LTX2.3** | ltx-2.3-22b-ic-lora-union-control-ref0.5 | IC-LoRA（多模态控制） | 深度、边缘、姿态联合控制，参考图传递结构，保持空间结构 | 0.6~0.8 | LTX 官方 HuggingFace 仓库 | LTX 标志性控制类普通 LoRA，相当于视频版 ControlNet |
| **LTX2.3** | ltx-2.3-22b-ic-lora-motion-track-control-ref0.5 | IC-LoRA 运动轨迹控制 | 复刻参考视频镜头运动、人物动作，动作时序稳定 | 0.5~0.7 | LTX 官方仓库 | 适合动作片、舞蹈视频，抑制帧间物体抖动 |
| **MiniMax H3** | cinemagrade_style | 电影质感风格 LoRA | 胶片调色、电影光影，解决原生画面发灰发平，短剧氛围感 | 0.3~0.6 | HuggingFace / Civitai H3 专区 | H3 视频专用，可叠加 Crash Zoom 运镜 LoRA |
| **MiniMax H3** | Crash Zoom 镜头运镜 LoRA | 动作/镜头概念 LoRA | 生成快速向前冲击推拉镜头，增强打斗卡点冲击力 | 0.4~0.7 | HuggingFace loraai.me | 适合高能开场、打斗镜头；可和 cinemagrade 风格叠加 |
| **MiniMax H3** | LMS LoRA | 通用细节修复 LoRA | 提升人物面部稳定性，减少肢体畸形，优化细节 | 0.4~0.7 | HuggingFace loraai.me | 通用兜底增强，几乎所有 H3 视频场景都可挂载 |

**叠加使用规范**（工作流节点顺序）
```
UNet/DiT 底模 →【加速 LoRA 加载器】→【普通 LoRA 加载器 1】→【普通 LoRA 加载器 2】→ KSampler
```
1. 加速 LoRA 固定强度 0.9~1.0，**只加载 1 个加速 LoRA**
2. 普通 LoRA 最多叠加 2~3 个，强度全部压低；风格类优先最低
3. IC-LoRA（LTX/H3/Wan）属于控制类，强度上限可到 0.8，不要超过 0.8，容易压制底模运动
4. Qwen-Image-Edit 场景（材质替换）：`Lightning 加速 LoRA(1.0) + 材质 LoRA(0.4~0.6)`，不要拉高材质 LoRA，否则覆盖编辑指令

---

## 三、加速 LoRA 详解

### 3.1 认识加速 LoRA（LCM / Turbo / Lightning / Distilled）

> 前置结论：加速 LoRA **不只是 LCM、Turbo 两类**。

**概念澄清**
| 类型 | 本质 | 说明 |
|---|---|---|
| **加速 LoRA** | 外挂 Adapter，挂载原版 Dev/base 底模 | 底模不动，通过低秩适配实现少步去噪 |
| **Turbo / Klein 模型** | 完整蒸馏 Checkpoint（模型本身） | 整个主模型被蒸馏，是独立 ckpt，不是 LoRA |

> **区分口诀**：Turbo = **整个主模型被蒸馏**（独立 ckpt）；LCM-LoRA / LightX2V / LTX Distilled LoRA = **底模不动，外挂 LoRA 适配器实现少步去噪**。

**四种类型定位**
| 类型 | 归属 | 说明 |
|---|---|---|
| **LCM-LoRA** | 一致性蒸馏外挂 LoRA | SD/SDXL UNet 生态原生 |
| **Turbo（Krea2/Z-Image/FLUX2 Klein）** | 蒸馏完整底模（非 LoRA） | 整个主模型被蒸馏，独立 ckpt |
| **Lightning-LoRA（LightX2V）** | DiT 专属外挂蒸馏 LoRA | Qwen-Image-Edit / Wan2.2 专属，衍生一致性蒸馏 |
| **LTX Distilled LoRA** | 模型专属外挂蒸馏 LoRA | LTX2.3 时间步蒸馏，非严格一致性模型 |

> **Cache-DiT / TeaCache 是另一种加速**：不修改权重，只缓存中间 token 计算；**采样步数不变**，每步更快；不属于蒸馏类加速 LoRA，是完全不同技术路线。

### 3.2 加速 LoRA 三类原理对比

| 项目 | LCM-LoRA | Lightning-LoRA（LightX2V：Qwen/Wan） | LTX Distilled LoRA |
|---|---|---|---|
| **原生适配网络** | SD UNet（SD1.5 / SDXL） | DiT（Qwen 图像编辑、Wan 视频 DiT） | LTX 自研视频 DiT |
| **核心蒸馏原理** | **一致性模型蒸馏（Consistency Model）**，训练让模型直接预测同一个终点潜像，不同时间步映射到同一结果，支持 1~8 步 | **Lightning 蒸馏（衍生自一致性蒸馏）**，专门针对 DiT 架构改造；对齐多步教师模型输出，把长采样链压缩为极少步数 | **时间步蒸馏（Time-step distillation）**，教师模型原生 30 步，学习把多步去噪信息压缩进 LoRA；非严格一致性模型 |
| **是否修改网络结构** | 不修改，仅在 UNet 注意力层插入低秩矩阵 | 不修改 DiT 网络，在 Self-Attn/Cross-Attn 插入 LoRA 低秩矩阵 | 不修改原生 LTX DiT，在 Transformer 层插入 LoRA |
| **采样调度器** | LCM 调度器（必须配套） | Lightning 专属调度器，部分兼容 Euler，优先 Lightning Scheduler | Simple 调度器 / Euler，无专属调度器 |
| **CFG 推荐** | 1.0，尽量 ≤1.5 | 1.0，>1.5 极易画面崩坏、编辑指令失效 | 1.0，最高不超 1.5 |
| **步数范围** | 1~8 步，常用 4/8 | 4/8 步版本（Qwen 4 步；Wan2.2 4 步） | 8 步为主 |
| **适用场景** | SD 系列文生图、图生图 | DiT 图像编辑、DiT 视频生成 | LTX 视频生成 |
| **跨模型兼容性** | 仅 SD UNet，不能给 DiT 用 | Qwen Lightning 只能 Qwen-Image-Edit；Wan Lightning 只能 Wan2.2，互不通用 | 仅 LTX2.3，无法迁移到其他 DiT |
| **叠加角色/风格 LoRA** | ✅ 支持，LCM 0.8~1.0；角色 LoRA 0.4~0.7 | ✅ 支持，Lightning 固定 1.0；材质/角色 LoRA 0.4~0.7 | ✅ 支持，Distilled 0.9~1.0；其他 LoRA 0.4~0.7 |
| **缺点** | SDXL 低步数下细节损失；不支持 DiT 模型 | DiT 低步数，复杂编辑指令会打折，多参考图稳定性下降 | 人物长视频易闪烁，复杂动作细节丢失比 Lightning 明显 |

### 3.3 各模型加速方案汇总表

> 统一前置规则：
> 1. 同一主模型**最多只能挂载 1 个加速蒸馏 LoRA**，禁止多个加速 LoRA 叠加
> 2. 所有蒸馏加速方案，CFG 优先 = 1.0，尽量不要 > 1.5，高 CFG 极易画面崩坏/指令失效
> 3. 加速 LoRA 尽量拉满（0.9~1.0），普通角色/材质/风格 LoRA 低强度叠加，避免权重冲突

| 模型 | 模型架构 | 可用加速方案 | 加速类型 & 原理归属 | 推荐采样参数（ComfyUI） | 加速 LoRA 推荐强度 | 叠加普通 LoRA 策略 | 特殊备注 |
|---|---|---|---|---|---|---|---|
| **Krea2** | 图像 DiT | Krea2 Turbo | **蒸馏完整底模（非 LoRA，Turbo 路线）**，独立 ckpt | Steps=8，CFG=1.0，Sampler=Euler，Scheduler=Turbo | 无（是完整模型，不是 LoRA） | 角色/风格 LoRA：0.4~0.7，最多叠加 2 个，总强度不超 1.0 | Krea2 RAW 底模训练的普通 LoRA 可挂载到 Turbo 底模推理；**没有外挂加速 LoRA** |
| **Z-Image（含 Z-Image-Edit）** | 图像 DiT | Z-Image Turbo | **蒸馏完整底模（非 LoRA，Turbo 路线）**，内置蒸馏权重 | Steps=8，CFG=1.0，Sampler=Euler，Scheduler=Turbo | 无（是完整模型，不是 LoRA） | 角色/材质 LoRA：0.4~0.6；多 LoRA 叠加时风格类优先降强度 | Z-Image-Edit 图像编辑分支共用这套 Turbo 底模逻辑；无独立外挂加速 LoRA |
| **Qwen-Image-Edit** | 图像编辑 DiT | Qwen-Image-Lightning-4steps-V2.0（LightX2V Lightning LoRA） | **外挂蒸馏加速 LoRA，Lightning 家族（衍生一致性蒸馏）**，DiT 专用，不改动底模权重 | Steps=4，CFG=1.0，Sampler=Euler，Scheduler=Lightning | 1.0（建议固定，调低丢失 4 步加速能力） | 材质/物体 LoRA：0.4~0.6；⚠️强度 >0.7 容易覆盖图像编辑指令，参考图材质替换失效 | 支持多参考图编辑，复杂编辑指令在 4 步下效果会打折；可叠加角色/材质 LoRA |
| **FLUX2（BFL FLUX.2）** | 图像 MM-DiT | FLUX2 Klein | **蒸馏精简底模（非 LoRA）**；社区小众 Glance Fast-LoRA（实验性，不推荐生产） | Steps=8，CFG=1.0，Sampler=Euler | 无（Klein 是完整底模） | 角色/风格 LoRA：0.4~0.7；不建议同时叠加 ≥3 个 LoRA | 官方无 LCM-LoRA；Glance Fast-LoRA 仅学术测试，稳定性差，生产环境慎用 |
| **Wan2.2（视频）** | 视频 DiT | LightX2V Lightning LoRA | **外挂蒸馏加速 LoRA，Lightning 家族（衍生一致性蒸馏）**，Wan2.2 DiT 专属 | Steps=4，CFG=1.0~2.0，Sampler=LCM，Scheduler=LCM | 0.9~1.0 | 人物一致性 LoRA：0.5~0.7；动作 LoRA：0.4~0.6；两个普通 LoRA 叠加，强度互相下调 0.1 | 分高噪/低噪版本；**不能使用 SDXL LCM-LoRA**；适合短视频人物固定，抑制人脸漂移 |
| **LTX2.3（视频）** | 视频自研 DiT | LTX2.3 Distilled LoRA（Kijai 社区版） | **外挂蒸馏加速 LoRA，时间步蒸馏（非严格一致性模型）**，LTX DiT 专属 | Steps=8，CFG=1.0，Sampler=Euler，Scheduler=Simple | 0.9~1.0 | IC-LoRA 姿态/深度控制：0.6~0.8；角色 LoRA：0.4~0.6；长视频场景全部 LoRA 强度再降 0.1，减少帧闪烁 | 不属于 LCM/Lightning 系列；原生 30 步，加载 LoRA 压缩至 8 步；可叠加控制类 IC-LoRA |
| **SD1.5 / SDXL** | UNet 图像模型 | LCM-LoRA | **外挂蒸馏加速 LoRA，一致性模型（Consistency Model）**，UNet 架构专用 | Steps=1~8（常用 4/8），CFG=1.0，Sampler=LCM，Scheduler=LCM | 0.8~1.0 | 角色 LoRA：0.4~0.7；风格 LoRA：0.3~0.6；多 LoRA 叠加风格优先降权 | 仅适配 SD 系列 UNet，**无法给任何 DiT 模型使用**；低步数复杂细节会有损失 |

### 3.4 ComfyUI 与 sd.cpp 参数对照与设置（加速方案篇）

> 本节聚焦**加速 LoRA / Turbo 蒸馏方案的采样参数**在 ComfyUI 与 sd-cpp 中的设置；控制参数的完整对照见[第 4 章](#四lora-控制参数详解)。

#### 采样核心参数对照表（Sampler / Scheduler / Guidance）

| 功能 | ComfyUI | sd-cpp(sd-cli.exe) 参数 | 说明 |
|---|---|---|---|
| 采样步数 | KSampler `steps` | `--steps <int>` | 加速 LoRA(Lightning/LCM) 设置 4-8 步 |
| CFG Scale | KSampler `cfg_scale` | `--cfg-scale <float>` | DiT 加速 LoRA 建议 = 1.0 |
| Sampler 采样算法 | KSampler `sampler` | `--sampling-method` | 可选：euler / lcm / dpm++2m 等 |
| Scheduler 噪声调度 | KSampler `scheduler` | `--scheduler` | 重要：LCM-LoRA 用 `lcm`；LTX2 用 `ltx2`；FLUX2 用 `flux2` |
| eta | KSampler `eta` | `--eta <float>` | ddim/euler_a 噪声乘数 |
| Flow 模型 shift（WAN/SD3/FLUX） | ModelSamplingSD3 `shift` | `--flow-shift <float>` | Flow 匹配模型，控制噪声分布偏移，auto=模型默认 |
| SLG Skip-Layer Guidance（DiT） | ModelSamplingSLG | `--slg-scale`、`--skip-layer-start`、`--skip-layer-end`、`--skip-layers` | slg-scale=0 关闭；SD3.5 Medium 典型 2.5 |
| 额外采样高级参数 | KSampler extra_model_args | `--extra-sample-args key=value,key2=value2` | lcm: noise_clip_std；ltx2: stretch/terminal；flux: base_shift/max_shift |

> **sd-cpp 完整参数支持（自 help 核实）**：
> - `--sampling-method`：euler, euler_a, heun, dpm2, dpm++2s_a, dpm++2m, dpm++2mv2, ipndm, ipndm_v, lcm, ddim_trailing, tcd, res_multistep, res_2s, er_sde, euler_cfg_pp, euler_a_cfg_pp, euler_ge, dpm++2m_sde, dpm++2m_sde_bt, lms（默认：Flux/SD3/Wan 为 euler，其余 euler_a）
> - `--scheduler`：discrete, karras, exponential, ays, gits, sgm_uniform, simple, smoothstep, kl_optimal, lcm, bong_tangent, ltx2, logit_normal, flux2, flux, beta, llada_image（默认：模型相关）
> - `--extra-sample-args`：CFG 支持 guidance_schedule；SLG 支持 slg_uncond；lcm 支持 noise_clip_std / noise_scale_start / noise_scale_end；flux 支持 base_shift / max_shift；ltx2 支持 max_shift / base_shift / stretch / terminal

**sd-cpp 示例（Lightning 4 步 Wan2.2）**
```bash
sd-cli.exe -m wan2.2-dev.gguf ^
-p "girl dancing <lora:lightx2v_4step:1.0:te=0>" ^
--steps 4 --cfg-scale 1.0 ^
--sampling-method lcm --scheduler lcm ^
--flow-shift auto
```

#### DiT 推理缓存加速参数（Cache-DiT / EasyCache）

> ComfyUI 一般用自定义插件节点传入 cache 参数；sd-cpp 原生命令行支持。

| 功能 | ComfyUI | sd-cpp 参数 |
|---|---|---|
| 缓存模式选择 | 插件节点 cache-dit/easycache | `--cache-mode easycache\|ucache\|dbcache\|taylorseer\|cache-dit\|spectrum` |
| 缓存阈值/预热等配置 | 插件内键值配置 | `--cache-option threshold=0.25,warmup=2` |
| SCM 掩码（cache-dit） | 插件 | `--scm-mask "1,1,1,0,0"`、`--scm-policy dynamic` |

> 示例（开启 cache-dit）：`--cache-mode dbcache --cache-option threshold=0.2,warmup=3`
> 缓存模式说明（help 核实）：easycache(UNET/DiT), ucache(UNET), dbcache/taylorseer/cache-dit(DiT block-level), spectrum(UNET/DiT Chebyshev+Taylor forecasting)

#### 视频生成参数（Wan2.2 / LTX2.3 / MiniMax H3）

| 功能 | ComfyUI | sd-cpp 参数 |
|---|---|---|
| 视频帧数 | VideoCombine/AnimateDiff `frames` | `--video-frames <int>` |
| FPS | VideoCombine fps | `--fps 24` |
| 输出视频格式 | SaveVideo | `-o output_%03d.webp` 支持 `.webp`/`.avi`/`.webm` |
| VAE 时间分块（降低显存） | VAE Temporal Tiling | `--temporal-tiling`；`--extra-tiling-args temporal_tile_frames=4,temporal_tile_overlap=1` |
| Wan MoE 边界参数 | 模型采样设置 | `--moe-boundary 0.875` |

> 视频 VAE 参数（help 核实）：`--extra-tiling-args` 支持 temporal_tile_frames/temporal_tile_size（默认 4）、temporal_tile_overlap（默认 1）

#### 后端/显存管理参数（关键，DiT 大模型）

| 功能 | ComfyUI（后端/VRAM 管理插件） | sd-cli.exe |
|---|---|---|
| 设备分配（cuda0/vulkan0/cpu 分模块） | backend 插件 | `--backend diffusion=cuda0,vae=cpu,clip=cpu` |
| 分层切分多卡 | 插件多卡分流 | `--split-mode layer\|row`；支持 `diffusion=row` 按矩阵行切分 |
| 单设备显存预算 GiB | vram 管理 | `--max-vram 6` 或 `cuda0=8,vulkan0=4`；0=使用剩余显存；负数=预留显存 |
| 权重卸载到内存 | offload | `--offload-to-cpu`；`--mmap` 内存映射；`--auto-fit on` 自动分配权重位置 |
| FlashAttention/SageAttention | 模型加载参数 | `--fa`；`--diffusion-fa`；`--sage-attn` |
| 权重数据类型 | 模型加载量化 | `--type f16/q4_K/q8_0` |

> sd-cpp 大 DiT 模型推荐组合：
> ```bash
> --backend diffusion=cuda0,vae=cpu,clip=cpu ^
> --max-vram 7 --auto-fit on --sage-attn --type q4_K
> ```

---

## 四、LoRA 控制参数详解

### 4.1 核心控制参数（通俗版）

> 你日常在 ComfyUI 的 **`LoRA 加载器`** 节点调的最核心就是两个强度滑杆：
> - **strength_model**：管**画面主体**（人物、材质、动作、画风）的表现力 —— 最重要
> - **strength_clip**：管**文字理解**（触发词、语义、风格关键词的识别力度）

**① strength_model（模型强度）—— 控制画面内容有多明显**
- 范围 `-100 ~ +100`，常用 **0 ~ 1.0**
- 0：LoRA 完全关闭
- 0.3~0.6：弱生效，柔和，适合**风格/材质**（不容易打架）
- 0.6~0.9：强生效，适合**角色/IC 控制**
- 1.0：训练时的原始效果
- **>1.0：不要用**（DiT 模型极易崩坏、人脸扭曲、视频闪烁）
- ⚠️ **加速 LoRA 必须固定 1.0**，调低会丢失加速效果

**② strength_clip（文本编码器强度）—— 控制触发词/语义识别**
- 范围 `0 ~ 1.0`
- 角色 LoRA：0.4~0.7（让触发词能唤醒人物特征）
- 材质/物体 LoRA：可设 0
- ⚠️ **视频 DiT（Wan/LTX/H3）的 IC-LoRA、加速 LoRA：一律填 0**（它们不训练文本分支）
- ⚠️ Qwen-Image-Edit：这个值不要拉高，会破坏图像编辑指令

**③ Trigger Word 触发词（提示词里的开关）**
- 训练 LoRA 时写入的专属关键词，写在正向 prompt 最前面
- **不写触发词，角色/风格 LoRA 效果大幅衰减甚至不生效**
- 加速 LoRA、IC-LoRA、多数视频 LoRA：**无触发词，不用写**
- 例：Krea2 `krea2_darkbrush` → `monochrome ink wash style`

**④ LoRA 加载顺序（必须链式串联）**
```
底模 UNet → LoRA1 → LoRA2 → LoRA3 → K 采样器
```
- **加速 LoRA 放第一位 → 风格 LoRA → 角色/IC 控制 LoRA**（后面在前面的基础上叠加）
- 普通 LoRA 最多 2~3 个；**并联会互相覆盖，不叠加**（不能所有节点都直接读底模）

**⑤ Block 权重控制（高级）**
- Krea2/FLUX2 等 DiT 支持：让 LoRA 只作用在特定 Transformer 层（底层=构图、中层=材质、高层=人脸）
- 用途：角色 LoRA 锁高层人脸，风格 LoRA 锁底层构图，**避免打架**

### 4.2 文件内置参数（训练时定，推理只读）

| 参数 | 通俗理解 | 常用取值 |
|---|---|---|
| **Rank** | 表达能力强弱。越大细节越多、文件越大；太大易过拟合（死记训练集） | 简单风格 4~16；角色/材质/IC 32~128 |
| **lora_alpha** | 缩放系数 = alpha/rank，归一化权重幅度；alpha=rank 最稳 | alpha=rank 或 2×rank |
| **target_modules** | 插在哪些注意力层：角色→QKV；风格/材质→QKV+FFN；IC→Cross-Attn | 训练时定 |
| **lora_dropout** | 训练时防过拟合，推理无效 | 训练时定 |

### 4.3 分模型参数推荐表

| 模型 | LoRA 类型 | strength_model | strength_clip | 触发词 | 叠加注意事项 |
|---|---|---|---|---|---|
| Krea2 | 角色 Identity | 0.4~0.7 | 0.4~0.6 | ✅需要 | 可挂载 Krea2 RAW / Turbo 底模；最多叠加 2 个普通 LoRA |
| Krea2 | 风格 LoRA | 0.3~0.6 | 0.3~0.5 | ✅需要 | 强度不要超 0.7，避免画面同质化 |
| Z-Image | 角色/风格 | 0.4~0.7 | 0.3~0.6 | ✅需要 | Z-Image Turbo 底模叠加 LoRA 总强度上限低，不要多 LoRA 拉满 |
| Qwen-Image-Edit | 角色/材质 | 0.4~0.6 | 0~0.4 | 可选 | 搭配 Lightning 加速 LoRA(1.0)；材质 LoRA>0.7 会覆盖图像编辑指令 |
| FLUX2 | 角色/材质 | 0.4~0.7 | 0.3~0.6 | ✅需要 | **严禁 strength_model>1.0，极易数值崩坏**；不能加载 FLUX1 的 LoRA |
| Wan2.2 视频 | 角色一致性 | 0.4~0.6 | 0 | 可选 | 搭配 LightX2V Lightning 加速 LoRA(1.0) |
| Wan2.2 视频 | Relight 光影 | 0.4~0.7 | 0 | 无 | 纯 DiT 修改，clip=0 |
| LTX2.3 视频 | IC-LoRA（姿态/深度） | 0.6~0.8 | 0 | 无 | 控制类，强度上限更高；长视频降低 0.1 减少闪烁 |
| MiniMax H3 | 电影风格 | 0.3~0.6 | 0.2~0.5 | 可选 | 风格强度压低，防止视频帧间色彩跳变 |
| MiniMax H3 | Crash Zoom 运镜 | 0.4~0.7 | 0 | 无 | 动作镜头，不要和多个动作 LoRA 叠加 |

### 4.4 多 LoRA 叠加调参方法论

> 固定组合：**1 个加速 LoRA + 最多 2~3 个普通 LoRA**
1. 加速 LoRA 放第一个：`strength_model=1.0，clip=0`，**固定不动**
2. 第二个（风格 LoRA）：0.3~0.5，优先低强度
3. 第三个（角色/材质/IC 控制）：0.4~0.7
> **多个 LoRA 不要全部拉满 1.0**；画面崩坏/脏糊/变形时，**优先降普通 LoRA 强度，别动加速 LoRA**。

### 4.5 常见故障排查

| 现象 | 参数原因 | 解决办法 |
|---|---|---|
| LoRA 完全不生效 | strength_model=0；没写 trigger；架构不匹配（Wan LoRA 加载到 Qwen） | 调高 model 强度；添加触发词；核对 LoRA 属于对应底模 |
| 人物五官扭曲、肢体畸形 | 角色 LoRA strength_model 过高（>0.8）；多 LoRA 权重冲突 | 降到 0.4~0.6，减少叠加 LoRA 数量 |
| Qwen 图像编辑失效，材质替换失败 | 材质 LoRA 强度太高，压制编辑指令 | 材质 LoRA ≤0.6；Lightning 加速 LoRA 保持 1.0 |
| 视频帧闪烁，画面抖动 | IC/角色 LoRA 强度过高；叠加过多 LoRA | 所有普通 LoRA 强度下调 0.1~0.2，减少 LoRA 数量 |
| 画面色彩脏糊、饱和度爆炸 | 多个风格 LoRA 叠加，强度同时偏高 | 风格 LoRA 降到 0.3~0.5，去掉多余风格 LoRA |

### 4.6 ComfyUI 与 sd-cli（stable-diffusion.cpp）参数对照与设置（控制参数篇）

#### LoRA 参数（核心）

**ComfyUI：`Load LoRA(LoraModelLoader)` 节点**

| ComfyUI 输入项 | 含义 | sd-cpp 等价设置 |
|---|---|---|
| `model` | 输入 DiT/UNet 模型 | `-m`/`--diffusion-model` 指定底模 |
| `clip` | 输入 CLIP/T5/LLM 文本编码器 | `--clip_l / --clip_g / --t5xxl / --llm` |
| `lora_name` | LoRA 文件名 | `--lora-model-dir` 指定 LoRA 目录；prompt 内写标签语法：`<lora:filename:strength[:te=x:unet=y]>` |
| `strength_model` | DiT/UNet 主干强度 | prompt 标签中 `unet=xx`；简写 `<lora:xxx:0.6>` 整体权重等价 strength_model=0.6 |
| `strength_clip` | CLIP/T5/LLM 文本编码器强度 | prompt 标签中 `te=xx`；加速 LoRA/IC-LoRA 设为 0 |

**sd-cpp LoRA 加载模式**：`--lora-apply-mode <auto|immediately|at_runtime>`
- `immediately`：启动时把 LoRA 合并到底模，推理快；**不支持量化 GGUF/GGML 模型**
- `at_runtime`：每步动态叠加，兼容量化模型，速度略慢
- `auto`：默认；底模量化则自动切 at_runtime，高精度 f16/f32 用 immediately

**sd-cpp 命令行示例（单 LoRA）**
```bash
sd-cli.exe -m flux2-base.gguf --lora-model-dir ./loras ^
-p "photo of girl <lora:my_character:0.6:te=0.4>" ^
--lora-apply-mode auto
```
> 解析：`strength_model=0.6`，`strength_clip=0.4`

**sd-cpp 命令行示例（多 LoRA 串联，等价 ComfyUI 多个 Load LoRA 链式）**
```bash
-p "photo of girl <lora:lightning_4step:1.0:te=0> <lora:character_lora:0.5:te=0.4> <lora:style_lora:0.4:te=0.3>"
```
> ⚠️ sd-cpp 没有独立命令行参数传多个 lora 文件，**全部靠 prompt 标签语法完成多 LoRA 叠加**，和 ComfyUI 链式加载行为一致，顺序即叠加顺序，加速 LoRA 写最前面；**不支持并联**。

#### 模型、编码器、VAE、ControlNet / IP-Adapter

| 组件 | ComfyUI 节点 | sd-cli.exe 参数 |
|---|---|---|
| 主 DiT/UNet 模型 | CheckpointLoader / DiffusionModelLoader | `-m,--model` / `--diffusion-model` |
| CLIP-L | CLIPLoader | `--clip_l` |
| CLIP-G | CLIPLoader | `--clip_g` |
| T5XXL | T5Loader | `--t5xxl` |
| LLM（Qwen-VL / Mistral for Flux2） | LLM 文本编码器 | `--llm`（qwen2vl 别名已废弃） |
| LLM Vision | LLM 视觉编码器 | `--llm_vision` |
| VAE | VAELoader | `--vae`；`--vae-format auto\|flux\|wan\|flux2` |
| ControlNet | ControlNetLoader + ControlNetApply | `--control-net`；`--control-image`；`--control-strength 0.9` |
| IP-Adapter | IPAdapterModelLoader + IPAdapterApply | `--ip-adapter`；`--clip_vision`；`--ip-adapter-strength 0.8`；`--ip-adapter-image ref.jpg` |
| AnimateDiff Motion Module | AnimateDiffLoader | `--motion-module`；`--video-frames`>1 开启视频模式 |

---

## 五、完整命令行范例

### 范例 1：Qwen-Image-Edit + Lightning 加速 LoRA + 材质 LoRA（图像编辑）
> 对应 ComfyUI 工作流：`UNet 加载器 → LoRA 加载器(仅模型) 挂载 Lightning → 加载 CLIP/Qwen2.5-VL → TextEncode → KSampler(4步)`

```bash
sd-cli.exe ^
--mode img_gen ^
-m qwen_image_edit_2511_bf16.gguf ^
--llm qwen2.5-vl-text-encoder.gguf ^
--llm_vision qwen2.5-vl-vision.gguf ^
--vae qwen_image_vae.gguf ^
--vae-format auto ^
--lora-model-dir ./loras ^
-i ref_input.jpg ^
-p "replace sofa surface to fur <lora:Qwen-Image-Lightning-4steps-V2.0:1.0:te=0> <lora:fur_material:0.5:te=0.2>" ^
--steps 4 --cfg-scale 1.0 ^
--sampling-method euler --scheduler lightning ^
-W 1024 -H 1024 ^
-o out_001.png ^
--lora-apply-mode auto ^
--backend diffusion=cuda0,vae=cpu,llm=cpu ^
--max-vram 10
```

### 范例 2：Wan2.2 视频 + LightX2V 加速 LoRA + 人物一致性 LoRA（视频生成）
```bash
sd-cli.exe ^
--mode vid_gen ^
-m wan2.2-dev.gguf ^
--vae wan2.2_vae.gguf --vae-format wan ^
--lora-model-dir ./loras ^
-p "girl dancing <lora:lightx2v_4step:1.0:te=0> <lora:character_consistency:0.6:te=0>" ^
--steps 4 --cfg-scale 1.0 ^
--sampling-method lcm --scheduler lcm ^
--flow-shift auto ^
--video-frames 97 --fps 24 ^
-o out_%03d.webp ^
--lora-apply-mode auto ^
--backend diffusion=cuda0,vae=cpu ^
--max-vram 8
```

---

## 六、坑点总结

### LoRA 通用坑点
1. ❌ **跨模型混用 LoRA**：Wan 的 LoRA 不能给 Qwen，FLUX2 不能用 FLUX.1 LoRA；DiT 和 SD UNet 完全隔离
2. ❌ **多个风格 LoRA 同时拉满**：极易画面污染、主体变形
3. ❌ **角色 LoRA 强度 >0.7**：容易过度固化，丢失画面多样性
4. ✅ 优先在 Base/RAW 底模训练普通 LoRA；训练好的普通 LoRA 可直接挂载同系列 Turbo 蒸馏底模推理
5. ✅ IC-LoRA 是**普通控制 LoRA**，不属于加速 LoRA
6. ✅ **最多加载 1 个加速 LoRA**，禁止多个加速 LoRA 叠加

### sd-cpp 特有坑点
1. **LoRA 在 sd-cpp 没有独立命令行参数逐个指定文件**，全部靠 prompt 标签 `<lora:xxx:s:te=x:unet=y>`；顺序决定叠加顺序，等价 ComfyUI 链式 Load LoRA；不能并联
2. `--lora-apply-mode`：量化 GGUF/GGML 模型必须使用 `auto` 或 `at_runtime`；用 `immediately` 会出错
3. 加速 LoRA（Lightning/LCM）：`te=0`（strength_clip=0），`unet=1.0`；不要降低加速 LoRA 强度
4. DiT 加速 LoRA 采样：`cfg-scale=1.0`，不要大于 1.5，否则画面崩坏；调度器要匹配（lcm / lightning / ltx2）
5. 架构强绑定：sd-cpp **不会做校验**，加载错直接出垃圾图
6. `--llm` 是 Qwen-Image-Edit、FLUX2 等 DiT 的文本编码器；老参数 `--qwen2vl` 已废弃不要使用

### 资源站汇总
1. HuggingFace：模型官方、社区开源原版 LoRA（优先）
2. Civitai：大量预览图，角色/风格 LoRA 最多，筛选对应模型标签
3. 各模型官方资源站：Z-Image 资源中心、LightX2V、Kijai WanVideo、LTX 官网

---

> 文档基于 `sd-cli.exe.help.txt`（stable-diffusion.cpp commit 1b0ba10）核实全部 CLI 参数；模型/LoRA 下载地址与社区 LoRA 信息来自公开资料整理，具体名称与版本以各模型官方仓库为准。
