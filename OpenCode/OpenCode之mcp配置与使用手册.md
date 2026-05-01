# OpenCode MCP 配置与使用详解

## 目录

1. [MCP 基本概念与架构](#一 mcp-基本概念与架构)
2. [配置文件位置与结构](#二配置文件位置与结构)
3. [本地 MCP 常用服务配置](#三本地 mcp 常用服务配置直接复制可用)
4. [远程 MCP 配置示例](#四远程-mcp 配置示例)
5. [命令行管理 MCP](#五命令行管理-mcpopencode-mcp-系列)
6. [在对话中使用 MCP](#六在对话中使用 mcp 直接用自然语言)
7. [常见问题与排错](#七常见问题与排错)
8. [最佳实践](#八最佳实践)
9. [从零开发本地 MCP 服务](#九从零开发本地 mcp 服务完整教程--可直接运行模板)

---

## 一、MCP 基本概念与架构

### 1.1 什么是 MCP

- **MCP**：Model Context Protocol，模型上下文协议。
- 作用：让 LLM（Claude/Gemini 等）安全、可控地调用外部工具/API。
- OpenCode 角色：作为 MCP **客户端**，管理多个 MCP 服务器，统一暴露给对话模型。

### 1.2 核心架构（三层）

```
OpenCode（Host + MCP Client）
├───stdio──→ 本地 MCP Server（子进程，如 filesystem/github）
└───HTTP──→ 远程 MCP Server（云端/内网服务）
```

- **本地 MCP**：用 stdio 通信，本地进程，适合文件、命令行、数据库等。
- **远程 MCP**：用 HTTP 通信，适合云端服务、第三方 API。

---

## 二、配置文件位置与结构

### 2.1 配置文件路径（优先级从高到低）

1. 项目级：`./.opencode/opencode.json`（推荐，项目独立）
2. 用户级：`~/.opencode.json` 或 `$XDG_CONFIG_HOME/opencode/opencode.json`
3. 全局默认：内置默认配置

### 2.2 基础配置模板（opencode.jsonc）

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    // 每个服务一个唯一 key（如 filesystem、github、browser）
    "filesystem": {
      "type": "local",          // 本地/远程：local | remote
      "command": "npx",          // 本地：启动命令
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/xxx/my-project" // 允许访问的目录
      ],
      "enabled": true,           // 启用/禁用
      "timeout": 30000            // 超时（ms）
    },
    "github": {
      "type": "local",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "{env:GITHUB_TOKEN}" // 从环境变量读取
      },
      "enabled": true
    },
    "browser": {
      "type": "local",
      "command": "npx",
      "args": ["-y", "@executeautomation/playwright-mcp-server"],
      "enabled": true
    }
  }
}
```

**关键字段说明**

| 字段 | 类型 | 必选 | 说明 |
|------|------|------|------|
| `type` | string | ✓ | `local`（本地进程）或 `remote`（HTTP） |
| `command` | string | local ✓ | 本地服务启动命令（如 `npx`/`python`） |
| `args` | array | local ✓ | 命令参数（包名、目录等） |
| `url` | string | remote ✓ | 远程服务地址（如 `https://.../mcp`） |
| `headers` | object | remote ✗ | 自定义请求头（如 `Authorization`） |
| `env` | object | ✗ | 环境变量（密钥、路径等） |
| `enabled` | boolean | ✗ | 是否启用，默认 `true` |

---

## 三、本地 MCP 常用服务配置（直接复制可用）

### 3.1 文件系统（filesystem）

让 AI 读写指定目录文件（最常用）

```jsonc
"filesystem": {
  "type": "local",
  "command": "npx",
  "args": [
    "-y",
    "@modelcontextprotocol/server-filesystem",
    "/path/to/your/project" // Windows 用 "C:/Users/xxx/project"
  ],
  "enabled": true
}
```

### 3.2 GitHub 操作（github）

让 AI 读/写仓库、PR、Issue

```jsonc
"github": {
  "type": "local",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": {
    "GITHUB_TOKEN": "{env:GITHUB_TOKEN}"
  },
  "enabled": true
}
```

- 提前在终端设置环境变量：
  ```bash
  export GITHUB_TOKEN="ghp_xxx..."
  ```

### 3.3 浏览器自动化（browser/playwright）

让 AI 打开网页、点击、填表、截图

```jsonc
"browser": {
  "type": "local",
  "command": "npx",
  "args": ["-y", "@executeautomation/playwright-mcp-server"],
  "enabled": true
}
```

### 3.4 PostgreSQL 数据库（postgres）

让 AI 直接查询/修改数据库

```jsonc
"postgres": {
  "type": "local",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-postgres", "postgres://user:pass@localhost:5432/dbname"],
  "enabled": true
}
```

### 3.5 网页搜索（brave-search）

让 AI 联网搜索

```jsonc
"brave-search": {
  "type": "local",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-brave-search"],
  "env": {
    "BRAVE_API_KEY": "{env:BRAVE_API_KEY}"
  },
  "enabled": true
}
```

---

## 四、远程 MCP 配置示例

### 4.1 基础远程配置（API Key 认证）

```jsonc
"my-remote-mcp": {
  "type": "remote",
  "url": "https://mcp.example.com/mcp",
  "headers": {
    "Authorization": "Bearer sk_xxx..."
  },
  "enabled": true
}
```

### 4.2 OAuth 自动认证（OpenCode 自动跳转授权）

```jsonc
"my-oauth-server": {
  "type": "remote",
  "url": "https://mcp.example.com/mcp",
  "oauth": {
    "clientId": "{env:MCP_CLIENT_ID}",
    "clientSecret": "{env:MCP_CLIENT_SECRET}",
    "scope": "tools:read tools:execute"
  },
  "enabled": true
}
```

---

## 五、命令行管理 MCP（opencode mcp 系列）

### 5.1 查看所有 MCP 服务

```bash
opencode mcp list
# 或简写
opencode mcp ls
```

输出示例：

```
filesystem: enabled (local)
github: enabled (local)
browser: disabled (local)
```

### 5.2 快速添加 MCP（交互式）

```bash
opencode mcp add
```

按提示输入：名称、类型（local/remote）、命令/URL、环境变量等，自动写入配置文件。

### 5.3 启用/禁用服务

```bash
opencode mcp enable filesystem
opencode mcp disable github
```

### 5.4 认证/登出（OAuth/远程服务）

```bash
# 手动认证
opencode mcp auth my-oauth-server

# 清除凭据
opencode mcp logout my-oauth-server
```

---

## 六、在对话中使用 MCP（直接用自然语言）

配置好后，无需额外指令，**直接在聊天中说需求即可**，OpenCode 会自动调用对应 MCP 工具。

### 示例 1：文件操作（filesystem）

```
请读取 ./src/main.js 并修复其中的语法错误，然后保存。
```

- AI 自动调用 `filesystem` 的 `read_file` → 分析 → `write_file`。

### 示例 2：浏览器自动化（browser）

```
打开 https://example.com，点击登录按钮，输入用户名 test/密码 123，然后截图保存到 ./screenshot.png。
```

- AI 自动调用 `browser` 的 `navigate` → `click` → `fill` → `screenshot`。

### 示例 3：GitHub 操作（github）

```
帮我查看仓库 xxx/xxx 的最新 5 个 Issue，并总结未解决的问题。
```

- AI 自动调用 `github` 的 `list_issues`。

---

## 七、常见问题与排错

### 7.1 MCP 服务启动失败

- 检查 `command`/`args` 是否正确（本地需安装 Node.js，npx 可用）。
- 查看日志：`opencode mcp logs <服务名>`。
- 权限问题：确保配置的目录有读写权限。

### 7.2 环境变量不生效

- 用 `{env:VAR_NAME}` 引用，不要硬编码密钥。
- 终端中先 export 变量，再启动 OpenCode。

### 7.3 远程 MCP 连接失败

- 检查 `url` 是否可访问，网络是否通。
- 认证头是否正确（Bearer/API Key）。
- 查看远程服务日志。

### 7.4 模型不调用 MCP

- 确认服务 `enabled: true`，且 `opencode mcp list` 显示正常。
- 提示词需明确（如"读取文件""打开网页"），避免模糊指令。

---

## 八、最佳实践

1. **优先项目级配置**：`.opencode/opencode.json`，团队共享、环境隔离。
2. **最小权限原则**：filesystem 只开放必要目录，避免全盘访问。
3. **密钥用环境变量**：不要硬编码到配置文件，防止泄露。
4. **按需启用服务**：不用的 MCP 设置 `enabled: false`，减少资源占用。

---

## 九、从零开发本地 MCP 服务（完整教程 + 可直接运行模板）

本地 MCP 本质是：**一个遵循 MCP 协议的命令行程序**，OpenCode 通过 **stdio（标准输入/输出）** 与它通信，让 AI 调用你写的自定义工具。

我会用 **Python（最简单、无依赖）** 教你开发，**5 分钟就能写完并接入 OpenCode**。

### 9.1 开发前必备知识

#### 本地 MCP 工作原理

```
OpenCode ←stdio→ 你的 MCP 程序（Python/JS/Go）
```

- 通信：**JSON-RPC 格式**（输入=请求，输出=响应）
- 核心：你只需要**定义工具名 + 工具参数 + 执行逻辑**
- 语言：任意支持 stdio 的语言（Python/Node.js/Go 最常用）

#### 开发环境

- Python 3.8+（无需安装第三方库）
- OpenCode 已安装
- 一个文本编辑器

---

### 9.2 最快上手：写一个【计算器 MCP】

直接给你**可运行的完整代码**，复制即用。

#### 9.2.1 创建 MCP 项目

新建文件夹：

```
my-mcp/
├─ mcp_calculator.py   # 你的 MCP 服务
└─ .opencode/
   └─ opencode.json    # 配置文件
```

#### 9.2.2 编写 MCP 代码（Python）

`mcp_calculator.py`

```python
import sys
import json

def handle_request(request):
    """处理 MCP 请求"""
    method = request.get("method")
    params = request.get("params", {})

    # 1. 初始化：告诉 OpenCode 我有哪些工具
    if method == "initialize":
        return {
            "protocolVersion": "2024-11-03",  # 固定 MCP 版本
            "capabilities": {"tools": {}}     # 支持工具能力
        }

    # 2. 返回工具列表（AI 能调用的功能）
    if method == "tools/list":
        return {
            "tools": [
                {
                    "name": "calculate",      # 工具名（必须唯一）
                    "description": "计算器：加法、减法、乘法、除法",
                    "inputSchema": {          # 参数定义
                        "type": "object",
                        "properties": {
                            "a": {"type": "number", "description": "数字 1"},
                            "b": {"type": "number", "description": "数字 2"},
                            "op": {
                                "type": "string",
                                "description": "运算符：+ - * /",
                                "enum": ["+", "-", "*", "/"]
                            }
                        },
                        "required": ["a", "b", "op"]
                    }
                }
            ]
        }

    # 3. 执行工具（核心逻辑）
    if method == "tools/call":
        tool_name = params.get("name")
        args = params.get("arguments", {})

        if tool_name == "calculate":
            a = args["a"]
            b = args["b"]
            op = args["op"]

            # 你的业务逻辑
            if op == "+":
                res = a + b
            elif op == "-":
                res = a - b
            elif op == "*":
                res = a * b
            elif op == "/":
                if b == 0:
                    return {"error": "除零错误"}
                res = a / b
            else:
                return {"error": "不支持的运算符"}

            # 返回结果给 AI
            return {
                "content": [
                    {
                        "type": "text",
                        "text": f"计算结果：{a} {op} {b} = {res}"
                    }
                ]
            }

    return {"error": f"未知方法：{method}"}

def main():
    """MCP 主循环：读取 stdin → 处理 → 写入 stdout"""
    while True:
        try:
            # 读取一行请求
            line = sys.stdin.readline()
            if not line:
                break

            # 解析 JSON
            req = json.loads(line.strip())
            # 处理
            resp = handle_request(req)
            # 返回响应
            print(json.dumps({
                "jsonrpc": "2.0",
                "id": req.get("id"),
                "result": resp
            }))
            sys.stdout.flush()  # 必须刷新缓冲区

        except EOFError:
            break
        except Exception as e:
            print(json.dumps({
                "jsonrpc": "2.0",
                "id": req.get("id"),
                "error": {"code": -1, "message": str(e)}
            }))
            sys.stdout.flush()

if __name__ == "__main__":
    main()
```

#### 9.2.3 接入 OpenCode 配置

`.opencode/opencode.json`

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "calculator": {
      "type": "local",
      "command": "python3",  # Windows 用 python
      "args": [
        "./mcp_calculator.py" # 你的 MCP 文件路径
      ],
      "enabled": true
    }
  }
}
```

---

### 9.3 测试运行（100% 可用）

#### 9.3.1 检查 MCP 服务

在项目根目录执行：

```bash
opencode mcp list
```

看到：

```
calculator: enabled (local)
```

✅ 说明接入成功！

#### 9.3.2 在 OpenCode 中使用

直接发指令：

```
请用计算器计算 10 + 20
```

```
计算 99 * 88
```

```
500 / 25 等于多少？
```

AI 会**自动调用你写的 MCP 工具**并返回结果！

---

### 9.4 本地 MCP 开发规范（必须掌握）

#### 1. 固定版本

- `protocolVersion`: **2024-11-03**（官方最新）
- `jsonrpc`: **2.0**

#### 2. 必须实现 3 个方法

| 方法 | 作用 |
|------|------|
| `initialize` | 初始化，声明能力 |
| `tools/list` | 返回你提供的工具列表 |
| `tools/call` | 执行工具逻辑 |

#### 3. 工具参数规范

- `name`：英文、唯一
- `description`：**写详细**，AI 靠这个判断是否调用
- `inputSchema`：严格 JSON Schema 格式

#### 4. stdio 规则

- 一次请求 = **一行 JSON**
- 一次响应 = **一行 JSON**
- 必须调用 `sys.stdout.flush()`

---

### 9.5 进阶：写一个【文件批量重命名 MCP】

给你一个**实用模板**，直接扩展你的业务逻辑。

```python
# 核心工具定义
{
    "name": "rename_files",
    "description": "批量重命名目录中的文件",
    "inputSchema": {
        "type": "object",
        "properties": {
            "dir": {"type": "string"},
            "prefix": {"type": "string"}
        },
        "required": ["dir", "prefix"]
    }
}

# 执行逻辑
import os
def rename_files(dir, prefix):
    for i, f in enumerate(os.listdir(dir)):
        old = os.path.join(dir, f)
        new = os.path.join(dir, f"{prefix}_{i+1}{os.path.splitext(f)[1]}")
        os.rename(old, new)
    return f"重命名完成"
```

---

### 9.6 调试 MCP（非常重要）

#### 查看日志

```bash
opencode mcp logs calculator
```

能看到：

- 请求参数
- 报错信息
- JSON 格式错误

#### 手动测试（脱离 OpenCode）

```bash
python mcp_calculator.py
```

输入：

```json
{"jsonrpc":"2.0","id":1,"method":"tools/list"}
```

能输出工具列表 = 代码正常 ✅

---

### 9.7 你可以开发的 MCP 示例

- 文件格式转换（PDF→Word、图片压缩）
- 数据库查询（MySQL/SQLite）
- API 调用（钉钉/企业微信/飞书）
- 系统命令（git、docker、shell）
- 爬虫、数据处理、AI 模型本地调用

---

## 总结

### MCP 配置要点

1. **配置文件位置**：项目级 `.opencode/opencode.json` 优先
2. **本地 vs 远程**：本地用 `command`+`args`，远程用 `url`+`headers`
3. **密钥管理**：用 `{env:VAR_NAME}` 引用环境变量
4. **命令行管理**：`opencode mcp list/add/enable/disable/auth/logout`

### 本地 MCP 开发要点

1. **本地 MCP = 命令行程序 + stdio 通信 + JSON-RPC 协议**
2. **只需实现 3 个方法**：`initialize` / `tools/list` / `tools/call`
3. **用 Python 开发最快**、无依赖、易调试
4. **配置到 `opencode.json` 即可被 AI 直接调用**
