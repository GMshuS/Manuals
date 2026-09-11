VS Code 集成方案

方案一：Continue 插件（强烈推荐）

Continue 是 VS Code 中最强大的 AI 编程助手，完美支持本地 Ollama。

1. 安装插件
- VS Code → 扩展 → 搜索 `Continue` → 安装

2. 配置 `config.json`

按 `Ctrl+Shift+P` → `Continue: Open Config.json`：

```json
{
  "models": [
    {
      "title": "Qwen Coder 14B",
      "provider": "ollama",
      "model": "qwen2.5-coder:14b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "DeepSeek R1 14B",
      "provider": "ollama",
      "model": "deepseek-r1:14b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "Qwen Chat 14B",
      "provider": "ollama",
      "model": "qwen2.5:14b",
      "apiBase": "http://localhost:11434"
    }
  ],
  "tabAutocompleteModel": {
    "title": "Qwen Coder",
    "provider": "ollama",
    "model": "qwen2.5-coder:14b",
    "apiBase": "http://localhost:11434"
  },
  "customCommands": [
    {
      "name": "explain",
      "prompt": "{{{ input }}}\n\n用中文详细解释这段代码的工作原理：",
      "description": "解释代码"
    },
    {
      "name": "refactor",
      "prompt": "{{{ input }}}\n\n重构这段代码，提高可读性和性能，并说明改进点：",
      "description": "重构代码"
    }
  ],
  "contextProviders": [
    {
      "name": "code",
      "params": {}
    },
    {
      "name": "docs",
      "params": {}
    }
  ]
}
```

3. 使用方式

快捷键	功能	
`Ctrl+L`	打开侧边栏对话	
`Ctrl+I`	内联编辑（选中代码后）	
`Tab`	自动补全代码	
`Ctrl+Shift+L`	快速切换模型	

---

方案二：CodeGPT 插件

更适合轻量级使用：

1. 安装 `CodeGPT` 扩展
2. 设置 → CodeGPT → Provider 选择 `Ollama`
3. Model 填写 `qwen2.5-coder:14b`

---

方案三：自定义 VS Code 任务

创建 `.vscode/tasks.json`：

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Ollama: 启动代码模型",
      "type": "shell",
      "command": "powershell",
      "args": ["-File", "${workspaceFolder}/scripts/switch-model.ps1", "-Mode", "code"],
      "group": "build"
    },
    {
      "label": "Ollama: 启动推理模型",
      "type": "shell",
      "command": "powershell",
      "args": ["-File", "${workspaceFolder}/scripts/switch-model.ps1", "-Mode", "reason"],
      "group": "build"
    },
    {
      "label": "Ollama: 停止所有模型",
      "type": "shell",
      "command": "ollama stop qwen2.5-coder:14b; ollama stop deepseek-r1:14b; ollama stop qwen2.5:14b",
      "group": "build"
    }
  ]
}
```

按 `Ctrl+Shift+P` → `Tasks: Run Task` 选择执行。

---

完整工作流配置

项目结构建议

```
my-project/
├── .vscode/
│   ├── tasks.json          # VS Code 任务
│   └── settings.json       # 编辑器设置
├── scripts/
│   ├── switch-model.ps1    # 切换脚本
│   ├── code.bat            # 快捷方式
│   ├── reason.bat
│   └── chat.bat
└── Modelfile               # 自定义模型配置
```

`.vscode/settings.json`

```json
{
  "continue.enableTabAutocomplete": true,
  "continue.telemetryEnabled": false,
  "editor.inlineSuggest.enabled": true,
  "editor.quickSuggestions": {
    "comments": "inline",
    "strings": "inline",
    "other": "inline"
  }
}
```

---

一键初始化脚本

创建 `setup.ps1`：

```powershell
Write-Host "🚀 初始化 Ollama + VS Code 开发环境" -ForegroundColor Cyan

# 1. 下载模型
$models = @("qwen2.5-coder:14b", "deepseek-r1:14b", "qwen2.5:14b")
foreach ($m in $models) {
    Write-Host "`n📥 下载模型: $m" -ForegroundColor Yellow
    ollama pull $m
}

# 2. 创建目录结构
New-Item -ItemType Directory -Force -Path "scripts", ".vscode" | Out-Null

# 3. 创建切换脚本（内容同上，略）
# ...

Write-Host "`n✅ 环境初始化完成！" -ForegroundColor Green
Write-Host "💡 使用方式：" -ForegroundColor Cyan
Write-Host "   .\scripts\switch-model.ps1 -Mode code    # 编程模式"
Write-Host "   .\scripts\switch-model.ps1 -Mode reason  # 推理模式"
Write-Host "   .\scripts\switch-model.ps1 -Mode chat    # 对话模式"
Write-Host "   VS Code 安装 Continue 插件后按 Ctrl+L 开始对话"
```

---

需要我帮你生成完整的 `setup.ps1` 可执行文件，或者配置 JetBrains 系列 IDE（PyCharm/IDEA） 的集成方案吗？