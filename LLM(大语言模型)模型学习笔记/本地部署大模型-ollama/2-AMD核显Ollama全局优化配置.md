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

需要我再给你一条**一键命令**，直接测试优化前后的推理速度对比吗？