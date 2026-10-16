# ComfyUI KSampler 与 sd-cpp（sd-server.exe）参数详解

> 本文整合：KSampler 核心参数、采样器/调度器逐个解析、extra-sample-args 高阶参数、7 大模型推荐参数与优缺点、以及常见故障排错速查表。

---

## 目录
1. [KSampler 核心参数总览](#一ksampler-核心参数总览)
2. [采样器 sampler_name 详解](#二采样器-sampler_name-详解)
3. [调度器 scheduler 详解](#三调度器-scheduler-详解)
4. [采样器 + 调度器组合推荐表](#四采样器--调度器组合推荐表)
5. [extra-sample-args 高阶参数详解](#五extra-sample-args-高阶参数详解)
6. [7 大模型推荐参数组合与优缺点](#六7-大模型推荐参数组合与优缺点)
7. [常见故障排错速查表](#七常见故障排错速查表)
8. [sd-cpp 完整命令示例](#八sd-cpp-完整命令示例)

---

## 一、KSampler 核心参数总览

### 通俗理解

扩散生成好比「擦掉画布上的杂色（噪声）」：

| KSampler 参数 | 通俗比喻 |
|---|---|
| **sampler_name（采样器）** | 擦除的数学算法 |
| **scheduler（调度器）** | 每一步擦掉多少杂色（sigma 噪声序列） |
| **steps** | 一共擦多少轮 |
| **denoise** | 一开始铺多少杂色（图生图强度） |
| **cfg** | 画笔受提示词约束有多强 |
| **seed** | 初始杂色图案编号，同 seed 出同图 |

### 参数总表（含 sd-cpp 映射）

| ComfyUI KSampler 参数 | 通俗原理&作用 | 常用取值范围 | sd-cpp sd-server.exe 对应启动参数 | 备注 |
|---|---|---|---|---|
| **seed** | 随机种子，生成初始噪声；**相同全部参数 + 相同 seed 生成完全一样的图**；-1 = 随机 | 整数；-1=随机；0~超大整数 | `-s, --seed`；`<0` 代表随机 | 文档：`-s, --seed RNG seed (default:42, use random seed for < 0)` |
| **steps** | 去噪迭代轮数；轮数越多擦除噪声越精细，但速度越慢；超过一定步数收益变低 | SD1.5/XL：20-30；Flux：20-35 | `--steps <int>` | sd-cpp 默认 20；不是越大越好，很多采样器 20 步足够 |
| **cfg(cfg_scale)** | CFG 无分类引导强度；控制模型多严格遵守正负提示词；值越高越贴提示词，太高会过曝、畸形、色彩炸裂 | SD：6-8；Flux：3-4；0-20；>12 慎用 | `--cfg-scale <float>` | sd-cpp 默认 7.0；Flux 模型 cfg 普遍很低 |
| **sampler_name** | 采样算法，怎么一步步算潜空间；不同算法收敛速度、细节风格不一样，和 scheduler 配对生效 | euler、euler_a、dpm++2m、dpm++2s_a、dpm++2m_sde、lcm、heun 等 | `--sampling-method <string>` | sd-cpp 支持列表见下节 |
| **scheduler** | 调度器；生成每一步的噪声强度 sigma 序列，决定每一步去掉多少噪声；同 sampler 换 scheduler 结果大变 | normal(discrete)、karras、simple、ays、sgm_uniform、exponential | `--scheduler <string>` | sd-cpp 可选见下节；`normal=discrete` 别名 |
| **denoise(denoising strength)** | 去噪强度；**图生图核心参数**。1.0=完全文生图全部重绘；0=完全保留原图；越大改动越多；只对有输入 latent 图片生效 | 0.0-1.0；图生图常用 0.4-0.7 | `--strength <float>` | sd-cpp 默认 0.75；`--init-img` 传入原图才生效 |

> 补充：ComfyUI `positive/negative` 提示词 → sd-cpp `-p,--prompt` / `-n,--negative-prompt`；`latent_image` 图生图输入 → sd-cpp `-i,--init-img`

### 参数之间相互关系

1. **sampler_name + scheduler 绑定搭档**：sampler 是「计算公式」，scheduler 给这套公式喂「每一步的噪声强度 sigma 列表」。**同一个 sampler，换 scheduler，图片差异巨大**。例：euler + karras 是经典组合；lcm 采样器必须搭配 lcm 调度器。

2. **steps × scheduler**：steps 决定 sigma 序列长度；scheduler 按 steps 生成 N 个 sigma。steps 太少，再好采样器也会糊；steps 超过模型需要，收益微乎其微，浪费时间。

3. **denoise 控制起点，steps 控制迭代过程**：denoise<1（图生图）不是完整走完所有 sigma，只取后半段，保留原图信息；denoise=1 完整走完全部 steps。

4. **cfg 是每一步迭代都生效的约束**：每一轮去噪都用 cfg 拉扯正负提示词。cfg 不替代 steps，哪怕 steps 很高 cfg 过高依然崩坏。Flux 系列天生 cfg 数值要低。

5. **seed 只决定初始噪声，其他参数全部改变图像**：seed 不变，改 steps/cfg/sampler/scheduler/denoise，图像完全不一样。只有全部参数一模一样，同 seed 才出相同图。

---

## 二、采样器 sampler_name 详解

### sd-cpp `--sampling-method` 支持列表

`euler, euler_a, heun, dpm2, dpm++2s_a, dpm++2m, dpm++2mv2, ipndm, ipndm_v, lcm, ddim_trailing, tcd, res_multistep, res_2s, er_sde, euler_cfg_pp, euler_a_cfg_pp, euler_ge, dpm++2m_sde, dpm++2m_sde_bt, lms`

### 逐个解析表（ComfyUI ↔ sd-cpp）

| ComfyUI 采样器 | sd-cpp `--sampling-method` | 通俗原理&特点 | 适合场景 | 备注 |
|---|---|---|---|---|
| euler | euler | 欧拉算法，一阶微分；速度快，细节丰富；早期 SD1.5 标配；带轻微艺术噪点 | SD1.5、SDXL；文生图 | 搭配 karras 效果佳；Flux 官方默认采样器 |
| euler_ancestral(euler_a) | euler_a | 带随机祖先噪声欧拉；每一步加入额外随机噪声；画面更自由，**同 seed 结果不固定** | SD1.5/XL；想要更多随机性 | 输出不稳定，复现困难；老 webui 经典 |
| heun | heun | 二阶改进欧拉；校正一步，图像质量比 euler 好，速度慢一点 | 追求质量，步数充足 | 步数低时效果一般，建议 ≥25 步 |
| dpm2 | dpm2 | DPM-2，二阶；去噪能力强，容易饱和过曝 | 老 SD1.5，不推荐现在用 | 较少选用 |
| dpm++2s_a | dpm++2s_a | DPM++ 2S Ancestral；单步，带随机噪声；风格柔和，seed 不可复现 | SDXL，喜欢柔和画风 | ancestral 家族，输出有随机性 |
| dpm++2m | dpm++2m | DPM++ 2M；多步二阶，**无随机可复现**；质量高，ComfyUI 高频 | SD1.5 / SDXL；追求稳定可复现 | 业界很通用，搭配 karras |
| dpm++2mv2 | dpm++2mv2 | dpm++2m 升级版，改进数值计算 | SDXL，更高精度 | 比原版 2m 细节更好 |
| dpm++2m_sde | dpm++2m_sde | DPM++2M SDE，加入随机 SDE 噪声；细节丰富，有随机性 | 艺术创作，想要更多细节纹理 | seed 相同图像不完全一样 |
| dpm++2m_sde_bt | dpm++2m_sde_bt | SDE-BT 变体，布朗树噪声，sd-cpp 特有 | 视频生成，时序稳定 | 适合 AnimateDiff 视频 |
| lcm | lcm | 潜在一致性模型；**4-8 步就能出图**，专门给 LCM 蒸馏模型 | LCM 模型、极速出图 | 必须搭配 lcm 调度器，普通模型效果差 |
| ddim | ddim_trailing | DDIM 老经典采样器；确定性可复现；细节偏柔和 | 图生图、inpaint 修复 | 速度中等，现在较少优先选 |
| tcd | tcd | TCD 时间一致性蒸馏；快速采样，兼顾一致性 | TCD 蒸馏模型，快速生成 | 配合 tcd 模型 |
| er_sde | er_sde | Euler-Maruyama SDE，随机微分；丰富纹理，有随机性 | 艺术向、视频 | 图像随机性高 |
| euler_ge | euler_ge | 广义欧拉；sd-cpp 特有变体，带 gamma 参数（`--extra-sample-args gamma=xx`） | 适配 NitroFusion 系列模型 | NitroSD 专用 |
| lms | lms | 线性多步；早期采样器，现在性能落后 | 老旧兼容，不推荐新项目 | 质量一般 |

> ⚠️ **区分 Ancestral（_a 后缀）= 带随机噪声**：带 `_a` / sde 的采样器即使 seed 完全一样，输出图片每次会变，不能严格复现；不带的是确定性采样器，同 seed + 参数一致则图片一致。

---

## 三、调度器 scheduler 详解

### 通俗理解

scheduler 输出一串 sigma 噪声数值序列，长度等于 steps；sigma 从大到小，从满噪声降到 0。**sigma 数值越大 = 噪声越强；sigma=0 = 无噪声最终图像**。

### sd-cpp `--scheduler` 支持列表

`discrete`（别名 `normal`）下的多种调度：`karras, exponential, ays, gits, sgm_uniform, simple, smoothstep, kl_optimal, lcm, bong_tangent, ltx2, logit_normal, flux2, flux, beta, llada_image`

### 逐个解析表（ComfyUI ↔ sd-cpp）

| ComfyUI 调度器 | sd-cpp scheduler 名称 | 通俗原理&特点 | 适用场景 |
|---|---|---|---|
| normal | discrete（别名 normal） | 原始离散 sigma；均匀时间步；老 SD 默认；低步数容易糊图 | SD1.5 老工作流，兼容旧脚本 |
| karras | karras | Karras 噪声调度，**对 sigma 做非线性缩放**；低步数下质量大幅提升；最通用万金油 | 绝大多数场景，euler/dpm++2m 首选，SD1.5/XL/Flux 都能用 |
| sgm_uniform | sgm_uniform | Stable Diffusion 官方原始均匀调度 | SDXL 官方原始配置 |
| simple | simple | 简单线性时间步 | 极少用，实验 |
| exponential | exponential | 指数衰减 sigma，前期噪声下降飞快 | 风格化实验 |
| ays | ays | Adaptive step 调度，自适应步长；对低 steps 友好 | 步数很低（<15 步）尝试提升质量 |
| lcm | lcm | LCM 专用调度器，配合 LCM 采样器 | LCM 蒸馏模型快速出图 |
| flux | flux | Flux 模型原生调度 | Flux 系列模型，官方推荐 |
| flux2 | flux2 | Flux2 调度 | Flux2 模型 |
| logit_normal | logit_normal | Logit-Normal，针对高分辨率图像 | 大图生成，高分辨率 |
| beta | beta | Beta 分布调度，可调 alpha/beta（`--extra-sample-args alpha=xx,beta=xx`） | 风格实验 |

> ⚠️ **Flux 模型不要乱用 karras，优先选 flux 调度器**；SD1.5/XL 优先 karras。

---

## 四、采样器 + 调度器组合推荐表

| 使用场景 | sampler_name | scheduler | 推荐 steps | cfg_scale | sd-cpp 对应参数片段 |
|---|---|---|---|---|---|
| SD1.5 通用高质量（可复现） | dpm++2m | karras | 20-28 | 6-7 | `--sampling-method dpm++2m --scheduler karras --steps 24 --cfg-scale 7` |
| SDXL 通用高质量（可复现） | dpm++2mv2 | karras | 22-30 | 6-7.5 | `--sampling-method dpm++2mv2 --scheduler karras --steps 26 --cfg-scale 7` |
| SD1.5 艺术氛围感（随机） | euler_a | karras | 20-25 | 7 | `--sampling-method euler_a --scheduler karras --steps 22 --cfg-scale 7` |
| Flux-dev/schnell 官方 | euler | flux | 20-28 | 3-4 | `--sampling-method euler --scheduler flux --steps 24 --cfg-scale 3.5` |
| LCM 快速出图 | lcm | lcm | 4-8 | 1-2 | `--sampling-method lcm --scheduler lcm --steps 6 --cfg-scale 1.5` |
| 图生图重绘（denoise=0.4-0.7） | dpm++2m | karras | 20-25 | 6-7 | `--strength 0.6 --init-img input.png` |

---

## 五、extra-sample-args 高阶参数详解

### 通俗理解

`--extra-sample-args` 是**采样器高级微调参数**，以 `key=val,key2=val2` 逗号分隔传给采样算法。

> ⚠️ **基础 KSampler 节点看不到这些高级参数**，ComfyUI 要用自定义采样器节点（SamplerCustom / SamplerDPMPP_2M_SDE 等），普通 K 采样器 UI 没有输入框。
> 适用范围：**仅部分采样器支持**；普通确定性采样器（euler/dpm++2m 默认 ODE）很多参数不生效；SDE / ancestral 祖先采样器才会用到 eta、s_churn 等。

### 使用语法

```bash
--extra-sample-args eta=0.7,s_churn=0.1,s_tmin=0.02   # 多个参数逗号隔开，不要空格
```

### 参数总表

| sd-cpp extra-sample-args 参数 | 通俗原理&作用 | 常用取值范围 | ComfyUI 对应节点&参数 | 生效前提与备注 |
|---|---|---|---|---|
| **eta** | 噪声系数，控制采样过程随机强度。eta=0 完全确定同 seed 图不变（ODE）；eta>0 每一步增加额外噪声，画面更自由、纹理更丰富 | 0.0~1.0，常用 0.3-0.8 | SamplerDPMPP_2M_SDE / SamplerSASolver 的 `eta` | ✅DDIM、euler_a、DPM++ SDE、ER_SDE；❌基础 euler、dpm++2m（ODE）；太高易脏、结构崩坏 |
| **s_churn** | Karras 额外噪声扰动强度，主动给每一步叠加一点噪声提升细节艺术感；只针对 Karras 调度器 | 0.0~1.0，推荐 0.0-0.2 | ComfyUI Karras 调度器高级选项 `s_churn` | 搭配 karras；=0 关闭；越大越易出现颗粒噪点 |
| **s_tmin** | s_churn 生效的最小 sigma 阈值；sigma 高于它才启用加噪，低于它（后期低噪声阶段）不再加噪保护画面干净 | 0.0~0.1，默认 0.02 | `s_tmin`（Karras 调度器高级参数） | 防止最后几步乱加噪声导致脏；一般不用改大 |
| **s_tmax** | s_churn 生效的最大 sigma 阈值；只有 sigma 小于它 s_churn 才工作，限制最开始极高噪声阶段不触发 | 0.5~∞，常用 1.0 | `s_tmax`（Karras 调度器高级参数） | 限制前期大噪声阶段，避免破坏构图 |
| **s_noise** | 叠加噪声的缩放倍数，配合 s_churn / SDE 采样器，控制新增噪声本身幅度 | 0.0~1.0，默认 1.0 | SamplerDPMPP_2M_SDE / SamplerSASolver 的 `s_noise` | 仅 s_churn/SDE 采样器生效；降低可减少颗粒感 |
| **gamma** | 广义欧拉 euler_ge 采样器专属，控制噪声衰减曲线，NitroSD/NitroFusion 模型专用 | 1.0~2.0 | ComfyUI 无原生 UI，需自定义采样器配置 euler_ge | **仅 euler_ge 采样器可用**，其他忽略 |
| **alpha / beta** | Beta 调度器专用，控制 beta 分布 sigma 曲线形状改变噪声下降节奏；alpha 影响前期，beta 影响后期 | alpha:1-10；beta:1-10 | BetaScheduler 节点的 alpha、beta | 只有 scheduler=beta 才生效 |
| **r** | DPM++ SDE 系列采样器 SDE 步长比例参数，控制预测校正的平衡 | 0.5~2.0，默认 1.0 | SamplerDPMPP_SDE 的 r 参数 | 微调纹理平滑度；r 变大画面更柔和 |

### 重点原理解析

#### 1. eta（最常用）
> 比喻：画画时每一笔要不要随手带一点随机抖动。
- eta=0：手很稳，每次画一模一样（确定性 ODE，seed 锁定图像）
- eta=0.7：每一笔带一点抖动，画面细节更生动，同 seed 结果会有小幅变化
- eta=1：最大抖动，随机性最强

⚠️ 普通 `euler`、`dpm++2m` 是 ODE 采样忽略 eta；只有 `euler_a`、`dpm++2m_sde`、ddim 才读取 eta。

#### 2. s_churn / s_tmin / s_tmax / s_noise（Karras 调度器四件套）
专门给 Karras 调度器做**可控额外加噪**：
- `s_churn`：开启扰动的总强度（0=关闭）
- `s_tmin`：**噪声太小的后期阶段不再加噪**，保护成品干净
- `s_tmax`：**最开始噪声极大阶段不加噪**，保护主体构图
- `s_noise`：扰动噪声的强弱缩放

> 典型用法：`s_churn=0.1, s_tmin=0.02, s_tmax=1.0, s_noise=1.0` → 细节质感更强，但不会在收尾阶段乱加噪。

#### 3. gamma、alpha/beta、r：小众专用参数
只适配特定采样器/调度器，普通 SD1.5/XL/Flux 日常生成基本不用碰。

### ComfyUI 如何设置这些参数

> ⚠️ **原生 KSampler 节点没有这些输入框！** 只能填 seed/steps/cfg/sampler/scheduler/denoise。

**两种开启方式：**
1. **SamplerCustom + 独立 Sampler 节点 + Scheduler 节点（推荐）**
   - 采样器节点：`SamplerDPMPP_2M_SDE` / `SamplerER_SDE`，填 eta、s_noise、r
   - 调度器节点：`KarrasScheduler`，填 s_churn、s_tmin、s_tmax、s_noise
   - 输出 sampler 对象、scheduler 对象送入 `SamplerCustom`，替代原 KSampler
2. 自定义 Python 采样器（高级用户）

**对应关系示例**
```bash
# sd-cpp
--sampling-method dpm++2m_sde --scheduler karras --extra-sample-args eta=0.6,s_churn=0.1,s_tmin=0.02
```
ComfyUI 工作流：`SamplerDPMPP_2M_SDE(eta=0.6)` → sampler；`KarrasScheduler(s_churn=0.1, s_tmin=0.02)` → scheduler；两者接入 SamplerCustom。

### 联动关系 & 坑点

1. **参数有采样器/调度器绑定，填错直接无效**：给普通 `euler` 采样器设 `eta=0.7` 完全不起效果；给 `normal(discrete)` 调度器设 `s_churn` 也无效，s_churn 只认 karras。
2. `s_churn` 和 `eta` 都会增加随机性，叠加使用图像变化更大，seed 复现失效。
3. eta/s_churn 太高易出现杂色、物体畸形、边缘破碎，尤其高 CFG 时。
4. Flux 模型一般不建议开 s_churn；Flux 原生 flux 调度器不支持 s_churn（s_churn 是 karras 专属）。

---

## 六、7 大模型推荐参数组合与优缺点

> 区分：**Krea2/Z-image/Boogu/Qwen-Image-Edit/FLUX2 = 图像模型；Wan2.2 / LTX2.3 = 视频模型**
> 提示：这类 DiT 类现代模型 **CFG 普遍偏低，不能沿用 SD1.5 的 7~8**；Turbo 蒸馏模型一般 CFG=1（关闭引导，负面提示基本无效）。

| 模型 | 推荐参数组合（ComfyUI KSampler） | sd-cpp 对应参数 | 优点 | 缺点 | 适用场景 |
|---|---|---|---|---|---|
| **Krea2（Turbo/Raw）**<br>文生图，强文字+写实质感 | ✅Turbo：euler + simple，steps 8，cfg 1.0，denoise 0.7，extra `mu=1.15`<br>✅Raw：euler + simple，steps 20-28，cfg 3.0-4.5 | Turbo：`--steps 8 --cfg-scale 1.0 --extra-sample-args mu=1.15`<br>Raw：`--steps 24 --cfg-scale 4.5` | 1. 文字渲染极强，英文/标识清晰；2. 写实质感优秀，胶片氛围感强；3. 参考图身份保持强，可改图保人脸；4. 1K-2K 原生支持 | 1. Turbo 版 cfg=1 负面词几乎无效；2. 亚洲人像略弱于 Z-image；3. 显存消耗偏高，24G 卡跑 2K 压力大 | 产品图、写实摄影、带文字海报、图生图重绘、保留人物形象编辑 |
| **Z-Image**<br>文生图，亚洲人像天花板 | ✅Quality：euler + zimage 原生调度，steps 20，cfg 3.0<br>✅Turbo：euler + zimage-turbo，steps 8，cfg 1.0 | quality：`--steps 20 --cfg-scale 3.0`<br>turbo：`--steps 8 --cfg-scale 1.0` | 1. **亚洲人像最强**，五官皮肤贴合国人；2. 光影柔和肤色自然不易塑料脸；3. Turbo 8 步极快；4. 构图稳定提示词遵循度高 | 1. 英文文字渲染弱于 Krea2/FLUX2；2. 抽象艺术科幻机械细节略差；3. 高分辨率复杂物体易结构崩坏 | 亚洲人像、写真、国风、商业人像、人像图生图 |
| **Boogu（Boogu-Image-0.1）**<br>通用文生图，强语义理解 | dpm++2m + karras，steps 24-28，cfg 3.0-3.5，denoise 0.6 | `--sampling-method dpm++2m --scheduler karras --steps 26 --cfg-scale 3.2` | 1. 语义理解极强，复杂场景逻辑构图强；2. 开源 Apache2.0 商用友好；3. 多物体空间关系、场景叙事好；4. 写实/插画多种风格平衡 | 1. 人像皮肤质感不如 Z-image；2. 文字表现中等；3. 生成速度中等，无专门 Turbo 版本 | 复杂场景、环境全景、叙事画面、概念设计、多物体组合画面 |
| **Qwen-Image-Edit**<br>千问图像编辑模型 | euler + flux，steps 16-20，cfg 2.0-3.0，denoise 0.4-0.7 | `--sampling-method euler --scheduler flux --steps 18 --cfg-scale 2.5 --strength 0.6` | 1. **图像编辑专项模型**，指令式修改强（移除物体、换背景、改局部）；2. 中文提示词理解优秀；3. 支持多参考图保留原图结构；4. 512-2048 自由比例 | 1. 纯文生图上限弱于 FLUX2/Krea2；2. 极端写实质感一般；3. denoise>0.8 大改易崩结构 | 图片局部编辑、物体删除替换、改颜色/背景、保留主体结构图生图、中文指令修图 |
| **FLUX2（Dev/Klein）**<br>通用文生图标杆 | ✅Dev：euler + flux，steps 20-28，cfg 3.0-3.8<br>✅Klein：euler + flux，steps 4，cfg 1.0 | dev：`--steps 24 --cfg-scale 3.5`<br>klein-distill：`--steps 4 --cfg-scale 1.0` | 1. 综合天花板：手部、文字、光影、材质、多参考一致性全部很强；2. 空间透视物理光照真实；3. 支持多参考图锁定物体/产品形态；4. 插画/写实/产品图通吃泛用性最强 | 1. 显存需求高；2. 亚洲人像略逊 Z-image；3. Klein 版 cfg=1 负面词无效；4. 高 CFG>4 易色彩饱和爆炸 | 通用全能、产品摄影、复杂构图、带文字海报、多参考一致性、插画写实、商业设计 |
| **Wan2.2（文生视频）**<br>阿里万相视频模型 | euler + wan，steps 20-28，cfg 3.0-4.0，denoise 0.6 | `--sampling-method euler --scheduler wan --steps 24 --cfg-scale 3.5` | 1. **人物动作、微表情、手部动态开源最强**；2. 电影级光影构图、镜头运镜可控；3. 物理逻辑强，复杂运动不易崩；4. 5B 小版本 4090 可跑，Apache2.0 商用；5. 人物面部稳定性好 | 1. 原生不带音频，需额外音频模型；2. 长视频（>5 秒）人物一致性缓慢下滑；3. 原生分辨率上限 720P；4. 提示词对镜头语言要求高 | 动态人物短片、影视分镜、动作镜头、图生视频、人物表演类短视频 |
| **LTX2.3（Lightricks 视频）**<br>音视频一体 | ✅Full：Res-2-S / euler + ltx2，steps 20-40，cfg 3.0-3.5，stg_scale 0.8<br>✅Distilled：euler + ltx2，steps 4-8，cfg 1.0 | full：`--steps 30 --cfg-scale 3.3`<br>distill：`--steps 8 --cfg-scale 1.0`<br>stg_scale 通过 extra-sample-args 传入 | 1. **音画原生一体**，出视频同时出同步音频，唇形匹配强；2. 生成速度比 Wan2.2 快；3. 支持首/末帧参考，镜头过渡顺滑；4. 原生竖屏适合短视频；5. 支持 STG 时空引导提升帧间一致性 | 1. 复杂肢体动作弱于 Wan2.2，大幅肢体易扭曲；2. 人物跨帧身份一致性一般；3. 长视频易出现静态 PPT 画面；4. 显存开销大 | 短视频、口播类视频、带声音短片、镜头缓慢运镜、首尾帧过渡视频 |

### 补充关键说明

#### 1. 模型调度器必须配对（重中之重）
- FLUX2 → **flux 调度器**，不要强行 karras，易色彩脏、透视崩坏
- LTX2.3 → ltx2 专属调度器；Wan2.2 使用 wan 专用 sigma 调度
- Krea2 Turbo / Z-image Turbo：蒸馏模型原生搭配 simple/zimage 调度，**不适合 dpm++ 系列采样器**

#### 2. Turbo/蒸馏模型共性坑
- steps 极少（4/8 步），**cfg=1.0 等价关闭 CFG 引导**，**负面提示词基本不起作用**，不要写长 neg。
- 不要盲目增加 steps，蒸馏模型训练锁定低步数，加多不提升画质反而变差。

#### 3. 视频模型特殊参数（STG 时空引导，LTX2.3 特有，extra-sample-args）
`stg_scale=0.8,stg_blocks=[29]` 控制帧间画面一致性；
- stg_scale 太高：画面不动变 PPT；
- stg_scale 太低：人物面部疯狂漂移变形。
sd-cpp 写法：`--extra-sample-args stg_scale=0.8`

#### 4. 模型选型快速决策
- 人像写真优先：**Z-image**
- 全能商业图、文字、产品图：**FLUX2**
- 带文字海报、胶片写实质感：**Krea2**
- 图片局部修改、中文指令修图：**Qwen-Image-Edit**
- 复杂场景概念原画：**Boogu**
- 人物动作影视短片：**Wan2.2**
- 需要视频 + 同步音频口播短视频：**LTX2.3**

---

## 七、常见故障排错速查表

### 总览故障对照表

| 故障现象 | 优先排查项 | 图像模型（Krea2/Z-image/Boogu/Qwen-Image-Edit/FLUX2） | 视频模型（Wan2.2 / LTX2.3） | 禁止操作（坑） |
|---|---|---|---|---|
| **画面整体模糊、发虚、细节丢失** | steps、CFG、调度器配对、分辨率 | ✅优先增加 steps（+4~6）；✅检查调度器是否模型原生（FLUX 必须 flux 不能 karras）；✅CFG 不要过低（<2 易模糊）；✅图生图 denoise 不要过小（<0.3 难重绘）；✅Krea2/FLUX2 关闭不必要 s_churn、eta | ✅Wan2.2：steps 24-28，cfg 3.2-3.8；✅LTX2.3：steps 28-35，stg_scale 适度降低（0.6-0.7）太高发僵模糊 | ❌不要单纯无脑拉高 CFG 会直接崩坏；❌Turbo 模型不要增加 steps，多加反而更糊 |
| **人物畸形、五官扭曲、手崩坏、肢体错位** | CFG、steps、denoise、提示词约束 | ✅降低 CFG！过高是畸形头号元凶：FLUX2≤3.8、Z-image≤3.2、Krea2 Raw≤4.5；✅适当提高 steps 24-28；✅图生图 denoise>0.7 易崩，降到 0.5-0.6；✅增加负面词 deformed, disfigured, bad hands；✅Qwen 局部编辑 denoise 不要>0.7 | ✅Wan2.2：CFG 3.0-3.5 不要>4.0；负面词 limb distortion, bad hands；✅LTX2.3：降低 stg_scale 过高肢体僵硬扭曲；图生视频 denoise 0.4-0.6 | ❌CFG>4.5 强行生成人物极易五官炸裂；❌不要用 karras 跑 FLUX2 易透视畸形 |
| **文字乱码、文字扭曲、字母粘连** | 模型选型、CFG、steps、分辨率 | ✅首选 Krea2 / FLUX2（文字最强，Z-image/Qwen 文字弱）；✅steps≥24；CFG 3.0-3.8 太高文字融化；✅提升分辨率，小字必须更高像素；✅不要开高 eta/s_churn 会撕碎文字；✅Boogu 文字一般复杂文字不选用 | ✅视频内文字难度极高，尽量放静态背景；✅Wan2.2：CFG 不超过 3.5，steps≥24；✅LTX2.3 不适合动态文字易逐帧乱码 | ❌Z-image 不要生成带大量英文/标识海报；❌Turbo 版本（8/4 步）文字天生差不适合文字场景 |
| **帧间漂移（视频专属：人脸乱跑、物体形变闪烁）** | STG 参数、denoise、CFG、参考图、extra-sample-args | ——（图像模型无帧间漂移） | ✅Wan2.2：①图生视频 denoise 降到 0.4-0.5（越大漂移越严重）；②CFG 控制 3.0-3.5 过高帧间抖动；③用首帧参考固定主体<br>✅LTX2.3：①调高 stg_scale=0.7-0.9；②steps 提到 30 左右；③denoise 不要>0.6；④开首尾帧约束 | ❌stg_scale>1.0 画面变静态 PPT；❌denoise>0.8 图生视频主体逐帧变形 |

### 分模型细化调参指引

#### 1. Krea2（Turbo / Raw）
| 故障 | 调参方案 | sd-cpp extra-sample-args |
|---|---|---|
| 画面糊 | Raw 版 steps 24-28，CFG 3.5-4.5；Turbo 糊属正常（牺牲细节换速度），改用 Raw 版 | 去掉 `mu=1.15` 尝试降低扰动 |
| 人物畸形 | CFG 降到 3.0-3.8，不要>4.5；图生图 denoise≤0.7 | eta=0，关闭额外随机噪声 |
| 文字乱码 | 必须 Raw 版不要 Turbo；steps≥24；分辨率≥1280；CFG 3.2 | s_churn=0，不加扰动噪声撕碎文字 |

#### 2. Z-image（人像专用）
| 故障 | 调参方案 |
|---|---|
| 画面糊 | Quality 完整版 steps=20，CFG=3.0；不要用 Turbo 做精细写真 |
| 人物畸形 | CFG **不要超过 3.2**，Z-image 对高 CFG 非常敏感；denoise 控制 0.4-0.6 |
| 文字乱码 | **Z-image 天生文字弱**，复杂文字场景直接换 Krea2/FLUX2，调参改善有限 |

#### 3. Boogu
| 故障 | 调参方案 |
|---|---|
| 画面糊 | steps 提升至 26-28，CFG=3.0-3.5，采样 dpm++2m + karras |
| 人物畸形 | CFG 降到≤3.5；Boogu 强项是场景，人像上限不如 Z-image |
| 文字乱码 | 文字能力中等，尽量避免极小字体，提高分辨率 |

#### 4. Qwen-Image-Edit（图像编辑）
| 故障 | 调参方案 |
|---|---|
| 画面糊 | steps=18-20，CFG=2.5-3.0；编辑场景 denoise 不要低于 0.4 |
| 人物畸形 | denoise **不要>0.7**！Qwen 是编辑模型，大幅重绘破坏原图结构，denoise 建议 0.4-0.6 |
| 文字乱码 | 中文尚可英文弱；优先修改已有文字，不要凭空生成大量文字 |

#### 5. FLUX2（Dev/Klein）
| 故障 | 调参方案 |
|---|---|
| 画面糊 | Dev steps=24-28，CFG=3.2-3.8；**调度器必须 flux 禁止 karras**；Klein 蒸馏版天生细节弱改用 Dev |
| 人物畸形 | CFG 上限 3.8，超过极易色彩爆炸肢体崩坏；不要开 s_churn/eta |
| 文字乱码 | FLUX2 文字很强；提升分辨率；steps≥24，CFG 3-3.5，关闭所有额外随机扰动 |

#### 6. Wan2.2（视频）
| 故障 | 调参方案 |
|---|---|
| 画面糊 | steps 24-28，CFG 3.2-3.8，分辨率不要强行拉超原生上限 |
| 人物畸形 | CFG 降到 3.0-3.5；图生视频 denoise≤0.6；负面词增加肢体畸变描述 |
| 帧间漂移人脸闪烁 | denoise 降低 0.4-0.5；使用首帧参考图；CFG 不要过高；缩短视频时长 |

#### 7. LTX2.3（音视频一体）
| 故障 | 调参方案 | sd-cpp extra-sample-args |
|---|---|---|
| 画面糊 | Full 版 steps=28-35，CFG=3.0-3.3；stg_scale 不要>0.9 过高画面僵硬模糊 | `stg_scale=0.7` |
| 人物畸形 | stg_scale 不要>0.9；CFG≤3.3；denoise≤0.6 | `stg_scale=0.7` |
| 帧间漂移 | **提高 stg_scale 0.7-0.9** 增强跨帧一致性；denoise 降低；开首尾帧参考 | `stg_scale=0.8` |

### 快速排查逻辑（固定顺序节省试错）

1. ✅ **调度器是否匹配模型**（最高优先级！很多糊、畸形根源是调度器选错，如 FLUX2 强行 karras）
2. ✅ CFG 是不是太高（人物畸形头号元凶，DiT 新模型不能沿用 SD1.5 的 7~8）
3. ✅ 确认是不是 Turbo/蒸馏模型：Turbo 固定低步数不能增加 steps，CFG=1，负面词基本无效
4. ✅ 图生图/图生视频：denoise 强度，越大改动越大，结构越易崩坏漂移
5. ✅ extra-sample-args：eta、s_churn、stg_scale 这类随机扰动参数，追求稳定/文字/固定人物时全部关掉
6. ✅ 分辨率：小字、精细细节必须提高分辨率，单纯调参救不了过低分辨率的文字糊

### 一句话口诀

> 糊图先查调度器，适度加步控 CFG
> 人物畸形降 CFG，denoise 别高保结构
> 文字乱码换模型，关闭 eta 和扰动
> 视频漂移看 STG，denoise 压低锁首帧

---

## 八、sd-cpp 完整命令示例

### 示例 1：SDXL 通用高质量（dpm++2mv2 + karras，图生图）

```bash
sd-server.exe
--model sdxl_q8_0.gguf
--sampling-method dpm++2mv2
--scheduler karras
--steps 26
--cfg-scale 7
--seed 114514
--rng cpu
-p "masterpiece, girl, city street"
-n "ugly, deformed, blurry"
-i "input.png"
--strength 0.6
```
> 对应 ComfyUI：seed=114514，steps=26，cfg=7，sampler=dpm++2mv2，scheduler=karras，denoise=0.6，图生图输入 input.png。

### 示例 2：Flux 文生图（euler + flux 调度器）

```bash
sd-server.exe
--model flux1-dev-q8_0.gguf
--sampling-method euler
--scheduler flux
--steps 28
--cfg-scale 3.5
--seed 12345
--rng cpu
-p "photorealistic product photo, glass bottle, soft studio lighting"
-n "ugly, deformed, blurry"
```

### 示例 3：带 extra-sample-args 高阶参数（euler_a + karras，开启随机扰动）

```bash
sd-server.exe
--model sd15_q8_0.gguf
--sampling-method euler_a
--scheduler karras
--steps 24
--cfg-scale 7
--seed 12345
--rng cpu
--extra-sample-args eta=0.6,s_churn=0.1,s_tmin=0.02
-p "masterpiece, girl"
-n "ugly, deformed"
```
> 等价 ComfyUI：SamplerCustom + EulerA 采样器(eta=0.6) + KarrasScheduler(s_churn=0.1, s_tmin=0.02)

---

## 附录：核心坑点清单汇总

1. Flux 模型不要用 karras 调度器，优先 `flux` 调度器；cfg 不要 7-8，建议 3-4。
2. `_a`、SDE 系列采样器不要指望 seed 复现图像，自带随机扰动。
3. denoise(`--strength`) 不给 `--init-img` 输入图片时完全不起效果。
4. sd-cpp 调度器名字和 ComfyUI 不完全一样，`normal` 要写 `discrete`。
5. 想要和 ComfyUI 输出对齐，必须设置 `--rng cpu`，否则 seed 相同图片也不一样。
6. LCM 采样器必须搭配 LCM 调度器，普通模型不要用 LCM 采样器。
7. Turbo/蒸馏模型（Krea2 Turbo、Z-image Turbo、FLUX2 Klein、LTX2.3 Distilled）：steps 固定低步数、CFG=1、负面词基本无效，不要盲目加步数。
8. extra-sample-args 的 eta/s_churn 只对特定采样器/调度器生效（SDE/ancestral/karras），填错直接无效。
9. 视频模型帧间漂移：Wan2.2 靠降 denoise + 首帧；LTX2.3 靠提高 stg_scale。
