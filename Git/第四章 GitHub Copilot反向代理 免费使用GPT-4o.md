# 超详细：GitHub Copilot 反向代理 = 免费 GPT-4o / 兼容 OpenAI 接口
这是**目前最实用、开发成本最低**的 Copilot 接入方式：
**把 GitHub Copilot 转换成标准 OpenAI 接口**，你可以用任何支持 OpenAI 的软件/代码直接调用，**不用改逻辑，只换地址和 Key**。

---

## 一、核心原理（一句话看懂）
1. 你有 **GitHub Copilot 订阅**（个人/企业都行）
2. 用工具**本地启动一个代理服务**
3. 这个服务**伪装成 OpenAI API**
4. 你的软件/代码调用这个本地服务 → 转发到 GitHub Copilot → 返回结果
5. **支持：GPT-4o / 流式输出 / 代码补全 / 聊天**

**优点**
- ✅ 完全兼容 OpenAI SDK（Python/JS/Java/Curl）
- ✅ 不用申请 API Key，用你已有的 Copilot 账号
- ✅ 本地运行，安全可控
- ✅ 支持几乎所有 AI 客户端（ChatBox、LobeChat、OpenCat、Dify 等）

---

## 二、准备工作
1. **必须有 GitHub Copilot 订阅**
   - 个人版：$10/月
   - 企业版/学生版：免费
2. 安装 **VS Code**（必须用它拿 Token）
3. 安装 **Node.js 18+**（运行代理服务）

---

## 三、方案一：VS Code 安装代理扩展（最简单方案）
这是**零配置、一键启动**的方案，推荐新手用。

### 步骤 1：安装扩展
**1. 安装扩展**
打开 VS Code → 扩展商店搜索：
```
GitHub Copilot API
```
作者：`suhaibbinyounis`
> 全名：`GitHub Copilot API (OpenAI Compatible Server)`

**2. 确保你已登录 Copilot**
VS Code 右下角 → 点击 Copilot 图标 → 登录 GitHub 账号
**必须看到 Copilot 正常工作**（能提示代码）

---

### 步骤 2：启动代理服务
1. 按快捷键：
   ```
   Ctrl + Shift + P
   ```
2. 输入命令：
   ```
   GitHub Copilot: Start API Server
   ```
3. 看到提示：
   ```
   Server running on http://127.0.0.1:3030
   ```
✅ **服务启动成功！**

---

### 步骤 3：调用方式（标准 OpenAI 接口）

- **Base URL**：`http://127.0.0.1:3030/v1`
- **API Key**：任意字符串（填 `123` 都行）
- **支持模型**：
  - `gpt-4` / `gpt-4o`（Copilot 高级模型）
  - `gpt-3.5-turbo`
  - `copilot-chat`（原生模型）

---

### 步骤 4：调用示例（全平台可用）
**示例 1：Python OpenAI SDK（最常用）**
```python
from openai import OpenAI

# 关键：只改 base_url 和 api_key 就行
client = OpenAI(
    base_url="http://127.0.0.1:3030/v1",
    api_key="any-key-works",  # 随便填
)

# 标准 OpenAI 格式
completion = client.chat.completions.create(
    model="gpt-4o",  # 支持 gpt-4 / gpt-3.5
    messages=[
        {"role": "system", "content": "你是一个编程助手"},
        {"role": "user", "content": "写一个Python快速排序"}
    ],
    stream=True  # 支持流式输出
)

# 打印结果
for chunk in completion:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="", flush=True)
```

**示例 2：Curl 命令**
```bash
curl http://127.0.0.1:3030/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "解释什么是反向代理"}]
  }'
```

**示例 3：接入任意 AI 客户端（LobeChat / ChatBox / Dify）**
以 **LobeChat** 为例：
1. 设置 → 大模型 → OpenAI
2. **API 地址**：`http://127.0.0.1:3030/v1`
3. **API Key**：`123`
4. 模型选择：`gpt-4o`
✅ 直接用！

---

## 四、方案二：纯命令行代理（无 VS Code）
如果你不想用 VS Code 扩展，可以用**命令行工具**：

### 项目：github-copilot-openai-proxy
1. 安装
```bash
npm install -g github-copilot-openai-proxy
```
2. 运行
```bash
copilot-proxy
```
3. 默认地址：`http://localhost:3030/v1`

使用方式和上面**完全一样**。

---

### 五、常见问题（必看）
**1. 报错 401/403**
- 原因：没登录 GitHub Copilot
- 解决：VS Code 登录 GitHub，确保 Copilot 能正常提示

**2. 端口被占用**
修改启动端口：
```
Ctrl + Shift + P → GitHub Copilot: Set Server Port
```

**3. 模型不存在**
可用模型列表：
- `gpt-4o`
- `gpt-4`
- `copilot-chat`
- `gpt-3.5-turbo`

---

### 六、总结（最简版）
1. VS Code 装 `GitHub Copilot API` 扩展
2. 登录 GitHub Copilot
3. 启动服务：`Ctrl+Shift+P → Start API Server`
4. 调用地址：`http://127.0.0.1:3030/v1`
5. 用标准 OpenAI 格式调用 **GPT-4o**
