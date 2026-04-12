# 安装与汉化

## 1 下载与安装
*   **官方下载**：访问 [Visual Studio Code 官网](https://code.visualstudio.com/)，选择适合您操作系统（Windows、macOS 或 Linux）的安装包进行下载。
*   **安装过程**（以 Windows 系统为例）：
    1.  运行下载的安装程序（如 `VSCodeUserSetup-x64-xxx.exe`）。
    2.  同意用户协议，点击“下一步”。
    3.  为VSCode选择安装位置（建议不要安装在系统盘C盘）。
    4.  在选择其他任务界面，**务必勾选“添加到 PATH”选项**，以便通过命令行快速启动VSCode。
    5.  点击“安装”并等待完成。

## 2 界面汉化
VSCode 默认界面为英文，可通过安装语言包扩展实现汉化。
1.  启动 VSCode。
2.  点击左侧活动栏的扩展（Extensions）图标（或使用快捷键 `Ctrl+Shift+X`）打开扩展视图。
3.  在搜索框中输入 `Chinese`。
4.  找到名为 **Chinese (Simplified) (简体中文) Language Pack for Visual Studio Code** 的扩展，点击“Install”按钮进行安装。
5.  安装完成后，右下角会弹出提示框，点击“Change Language and Restart”（更改语言并重启），VSCode 重启后界面即为简体中文。

> **注意**：如果错过提示框，可以按下 `Ctrl+Shift+P` 打开命令面板，输入 `Configure Display Language`，选择“Configure Display Language”，然后在弹出的 `locale.json` 文件中将 `"locale"` 的值修改为 `"zh-cn"`，保存并重启 VSCode。

---

## 2. 主要功能

VSCode 是一款由微软开发的免费、开源、跨平台的现代化代码编辑器，以下是其核心功能：

| 功能类别 | 描述 |
| :--- | :--- |
| **智能代码编辑** | 内置 **IntelliSense** 功能，提供基于变量类型、函数定义和导入模块的智能代码补全、语法高亮、参数提示等。 |
| **集成调试** | 内置强大的调试工具，支持设置断点、单步执行、查看变量和调用堆栈等，可调试多种语言（如 Node.js, Python, C++等）。 |
| **集成终端** | 内置终端（可通过 `` Ctrl+` `` 快速打开/关闭），可直接在编辑器内运行 shell 命令，支持多个终端实例。 |
| **版本控制集成** | 内置 Git 支持，可以直观地进行代码差异对比、暂存（Stage）、提交（Commit）、拉取（Pull）和推送（Push）等操作。 |
| **可扩展性** | 拥有丰富的扩展市场，可通过安装扩展来支持新的编程语言、主题、代码检查、调试器等，几乎可以定制所有功能。 |
| **代码导航** | 支持快速跳转到定义（F12）、查找所有引用（Shift+F12）、文件内符号跳转（Ctrl+Shift+O）等，方便浏览代码。 |
| **自定义与主题** | 允许用户深度自定义编辑器界面，包括颜色主题、文件图标、字体大小、快捷键绑定等，打造个性化开发环境。 |

---

我来为你详细解析 VS Code 中这三个核心配置文件。这是一个非常全面的技术文档需求，我会系统地整理每个文件的结构、配置项和实际应用场景。

---

# VS Code 核心配置文件详解

## 一、settings.json 配置详解

### 1. 文件位置
| 层级 | 路径 (Windows) | 路径 (macOS/Linux) | 作用范围 |
|------|---------------|-------------------|----------|
| 用户设置 | %APPDATA%\Code\User\settings.json | ~/.config/Code/User/settings.json | 全局生效，所有项目 |
| 工作区设置 | .vscode/settings.json (项目根目录) | 同上 | 仅当前项目生效，优先级高于用户设置 |

**优先级**：工作区设置 > 用户设置 > 默认设置

### 2. 作用
- 定义编辑器行为：字体、主题、缩进、换行等外观和行为
- 配置扩展：为安装的扩展提供参数
- 语言特定设置：针对不同编程语言的差异化配置
- 集成终端：自定义终端外观和 shell
- 文件关联：将文件类型与特定语言模式关联

### 3. 配置项详解

#### 编辑器核心配置
| 配置项 | 类型 | 说明 | 示例值 |
|--------|------|------|--------|
| editor.fontSize | number | 字体大小 | 14 |
| editor.fontFamily | string | 字体族 | "Fira Code, Consolas, monospace" |
| editor.fontLigatures | boolean | 启用字体连字 | true |
| editor.tabSize | number | Tab 字符宽度 | 4 |
| editor.insertSpaces | boolean | 是否用空格代替 Tab | true |
| editor.wordWrap | string | 自动换行模式 | "on", "off", "wordWrapColumn" |
| editor.minimap.enabled | boolean | 启用缩略图 | true |
| editor.formatOnSave | boolean | 保存时自动格式化 | true |
| editor.defaultFormatter | string | 默认格式化工具 | "esbenp.prettier-vscode" |

#### 界面与主题
| 配置项 | 类型 | 说明 | 示例值 |
|--------|------|------|--------|
| workbench.colorTheme | string | 颜色主题 | "Dark+", "One Dark Pro" |
| workbench.iconTheme | string | 文件图标主题 | "vscode-icons" |
| workbench.tree.indent | number | 文件树缩进 | 20 |
| window.zoomLevel | number | 界面缩放级别 | 0 |

#### 文件与搜索
| 配置项 | 类型 | 说明 | 示例值 |
|--------|------|------|--------|
| files.autoSave | string | 自动保存模式 | "afterDelay", "onFocusChange" |
| files.exclude | object | 排除的文件/文件夹 | {"**/node_modules": true} |
| files.associations | object | 文件关联 | {"*.vue": "vue"} |
| search.exclude | object | 搜索时排除 | {"**/dist": true} |

#### 终端配置
| 配置项 | 类型 | 说明 | 示例值 |
|--------|------|------|--------|
| terminal.integrated.shell.windows | string | Windows 默认 shell | "C:\\Windows\\System32\\bash.exe" |
| terminal.integrated.fontSize | number | 终端字体大小 | 12 |
| terminal.integrated.cursorStyle | string | 光标样式 | "line", "block", "underline" |

#### Git 配置
| 配置项 | 类型 | 说明 | 示例值 |
|--------|------|------|--------|
| git.enableSmartCommit | boolean | 启用智能提交 | true |
| git.confirmSync | boolean | 同步前确认 | false |
| git.ignoreMissingGitWarning | boolean | 忽略 Git 缺失警告 | true |

#### 扩展特定配置
通常以扩展 ID 为前缀，如：
- eslint.* - ESLint 配置
- prettier.* - Prettier 配置
- python.* - Python 扩展配置

#### 语言特定配置
使用 `[language]` 语法包裹：
```json
"[python]": {
    "editor.tabSize": 4,
    "editor.formatOnSave": true
}
```

### 4. 完整实例
```json
{
    // ========== 编辑器外观 ==========
    "editor.fontSize": 14,
    "editor.fontFamily": "Fira Code, 'Courier New', monospace",
    "editor.fontLigatures": true,
    "editor.lineHeight": 1.6,
    "editor.minimap.enabled": true,
    "editor.minimap.renderCharacters": false,
    "editor.cursorBlinking": "smooth",
    "editor.cursorStyle": "line-thin",
    "editor.renderWhitespace": "boundary",
    "editor.guides.indentation": true,
    
    // ========== 代码格式 ==========
    "editor.tabSize": 2,
    "editor.insertSpaces": true,
    "editor.detectIndentation": false,
    "editor.formatOnSave": true,
    "editor.formatOnPaste": true,
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    
    // ========== 界面主题 ==========
    "workbench.colorTheme": "One Dark Pro",
    "workbench.iconTheme": "vscode-icons",
    "workbench.startupEditor": "welcomePage",
    "workbench.tree.indent": 20,
    
    // ========== 文件处理 ==========
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "files.exclude": {
        "**/.git": true,
        "**/.DS_Store": true,
        "**/node_modules": true,
        "**/dist": true,
        "**/.vscode": false
    },
    "files.associations": {
        "*.wxml": "html",
        "*.wxss": "css",
        ".env.local": "dotenv"
    },
    
    // ========== 搜索配置 ==========
    "search.exclude": {
        "**/node_modules": true,
        "**/bower_components": true,
        "**/*.code-search": true,
        "**/build": true
    },
    
    // ========== 终端配置 ==========
    "terminal.integrated.shell.windows": "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
    "terminal.integrated.shell.osx": "/bin/zsh",
    "terminal.integrated.shell.linux": "/bin/bash",
    "terminal.integrated.fontSize": 13,
    "terminal.integrated.cursorStyle": "line",
    "terminal.integrated.enableMultiLinePasteWarning": false,
    
    // ========== Git 配置 ==========
    "git.enableSmartCommit": true,
    "git.confirmSync": false,
    "git.openRepositoryInParentFolders": "always",
    
    // ========== 扩展配置 ==========
    // Prettier
    "prettier.singleQuote": true,
    "prettier.trailingComma": "es5",
    "prettier.printWidth": 100,
    "prettier.semi": true,
    
    // ESLint
    "eslint.format.enable": true,
    "eslint.codeActionsOnSave.mode": "all",
    
    // Python
    "python.defaultInterpreterPath": "${workspaceFolder}/venv/bin/python",
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    
    // ========== 语言特定设置 ==========
    "[python]": {
        "editor.tabSize": 4,
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "ms-python.black-formatter",
        "editor.rulers": [80, 120]
    },
    "[javascript]": {
        "editor.tabSize": 2,
        "editor.maxTokenizationLineLength": 2500
    },
    "[markdown]": {
        "editor.wordWrap": "on",
        "editor.quickSuggestions": {
            "comments": "off",
            "strings": "off",
            "other": "off"
        }
    },
    
    // ========== 调试与性能 ==========
    "debug.inlineValues": true,
    "debug.console.acceptSuggestionOnEnter": "on",
    
    // ========== 其他实用配置 ==========
    "breadcrumbs.enabled": true,
    "outline.showVariables": false,
    "scm.defaultViewMode": "tree",
    "extensions.autoUpdate": false,
    "update.mode": "none"
}
```

---

## 二、tasks.json 配置详解

### 1. 文件位置
必须位于工作区级别：
```
${workspaceFolder}/.vscode/tasks.json
```
**注意**：tasks.json 不支持用户级别（全局）配置，必须与项目绑定。

### 2. 作用
- 自动化构建流程：编译、打包、转译代码
- 运行自定义脚本：执行测试、部署、清理等任务
- 集成外部工具：调用 CLI 工具（如 webpack、gulp、npm）
- 定义任务依赖：建立任务执行顺序和依赖关系
- 问题匹配：将工具输出解析为 VS Code 问题面板中的错误/警告

### 3. 配置项详解

#### 根级别结构
| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| version | string | 是 | 版本号，固定为 "2.0.0" |
| tasks | array | 是 | 任务定义数组 |
| inputs | array | 否 | 用户输入变量定义 |
| windows, osx, linux | object | 否 | 平台特定配置 |

#### 单个任务配置项
| 属性 | 类型 | 说明 | 示例 |
|------|------|------|------|
| label | string | 任务显示名称（唯一标识） | "Build TypeScript" |
| type | string | 任务类型：shell, process, npm, typescript, eslint 等 | "shell" |
| command | string | 执行的命令 | "npm", "tsc", "${workspaceFolder}/scripts/build.sh" |
| args | array | 命令参数 | ["run", "build"], ["--watch"] |
| options | object | 执行选项（cwd、env、shell） | 见下方详解 |
| group | string/object | 任务分组：build, test, none | "build", {"kind": "build", "isDefault": true} |
| presentation | object | 输出面板行为 | 见下方详解 |
| problemMatcher | string/array | 问题匹配器 | "$tsc", "$eslint-stylish" |
| dependsOn | string/array | 依赖的其他任务 | "Clean", ["Task1", "Task2"] |
| dependsOrder | string | 依赖执行顺序：parallel, sequence | "sequence" |
| runOptions | object | 运行选项 | {"runOn": "folderOpen"} |
| detail | string | 任务描述（悬停显示） | "编译并打包项目" |
| icon | object | 任务图标 | {"color": "terminal.ansiGreen", "id": "symbol-event"} |

#### options 详解
```json
{
    "options": {
        "cwd": "${workspaceFolder}/src",      // 工作目录
        "env": {                              // 环境变量
            "NODE_ENV": "development",
            "API_URL": "http://localhost:3000"
        },
        "shell": {                            // Shell 配置
            "executable": "/bin/bash",
            "args": ["-c"]
        }
    }
}
```

#### presentation 详解
```json
{
    "presentation": {
        "echo": true,                    // 是否显示执行的命令
        "reveal": "always",              // 何时显示面板：always, silent, never
        "focus": false,                  // 是否聚焦面板
        "panel": "shared",               // 面板行为：shared, dedicated, new
        "showReuseMessage": true,        // 显示重用消息
        "clear": false,                  // 执行前清空面板
        "group": "build"                 // 面板分组
    }
}
```

#### 预定义变量
| 变量 | 说明 |
|------|------|
| ${workspaceFolder} | 工作区根目录路径 |
| ${workspaceFolderBasename} | 工作区文件夹名称 |
| ${file} | 当前打开文件的绝对路径 |
| ${fileBasename} | 当前文件名（含扩展名） |
| ${fileBasenameNoExtension} | 当前文件名（不含扩展名） |
| ${fileDirname} | 当前文件所在目录 |
| ${fileExtname} | 当前文件扩展名 |
| ${cwd} | 任务启动时的当前工作目录 |
| ${lineNumber} | 当前光标行号 |
| ${selectedText} | 当前选中的文本 |
| ${env:NAME} | 环境变量值 |

### 4. 完整实例
```json
{
    "version": "2.0.0",
    
    // ========== 用户输入定义 ==========
    "inputs": [
        {
            "id": "environment",
            "type": "pickString",
            "description": "选择部署环境",
            "options": ["development", "staging", "production"],
            "default": "development"
        },
        {
            "id": "version",
            "type": "promptString",
            "description": "输入版本号",
            "default": "1.0.0"
        }
    ],
    
    // ========== 任务定义 ==========
    "tasks": [
        // ----- 基础构建任务 -----
        {
            "label": "Clean Dist",
            "type": "shell",
            "command": "rm",
            "args": ["-rf", "${workspaceFolder}/dist"],
            "windows": {
                "command": "rmdir",
                "args": ["/s", "/q", "${workspaceFolder}\\dist"]
            },
            "presentation": {
                "echo": true,
                "reveal": "silent",
                "panel": "shared"
            }
        },
        
        // ----- TypeScript 编译 -----
        {
            "label": "Compile TypeScript",
            "type": "typescript",
            "tsconfig": "tsconfig.json",
            "option": "watch",
            "problemMatcher": ["$tsc-watch"],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "presentation": {
                "reveal": "always",
                "panel": "dedicated"
            }
        },
        
        // ----- Shell 任务：完整构建流程 -----
        {
            "label": "Full Build",
            "type": "shell",
            "command": "npm",
            "args": ["run", "build"],
            "dependsOn": ["Clean Dist", "Lint Check"],
            "dependsOrder": "sequence",
            "options": {
                "cwd": "${workspaceFolder}",
                "env": {
                    "NODE_ENV": "${input:environment}",
                    "BUILD_VERSION": "${input:version}"
                }
            },
            "group": "build",
            "problemMatcher": {
                "pattern": {
                    "regexp": "^(.*):(\\d+):(\\d+):\\s+(error|warning):\\s+(.*)$",
                    "file": 1,
                    "line": 2,
                    "column": 3,
                    "severity": 4,
                    "message": 5
                },
                "fileLocation": "absolute"
            },
            "detail": "执行完整构建流程（清理 -> 检查 -> 编译）",
            "icon": {
                "color": "terminal.ansiBlue",
                "id": "package"
            }
        },
        
        // ----- 测试任务 -----
        {
            "label": "Run Unit Tests",
            "type": "shell",
            "command": "npm",
            "args": ["test", "--", "--coverage", "--watchAll=false"],
            "group": {
                "kind": "test",
                "isDefault": true
            },
            "presentation": {
                "reveal": "always",
                "panel": "new",
                "clear": true
            },
            "problemMatcher": "$jest",
            "detail": "运行 Jest 单元测试并生成覆盖率报告"
        },
        
        // ----- 自定义脚本任务 -----
        {
            "label": "Deploy to Server",
            "type": "shell",
            "command": "${workspaceFolder}/scripts/deploy.sh",
            "args": ["${input:environment}"],
            "options": {
                "shell": {
                    "executable": "/bin/bash"
                }
            },
            "linux": {
                "command": "./scripts/deploy.sh"
            },
            "windows": {
                "command": "powershell.exe",
                "args": ["-ExecutionPolicy", "Bypass", "-File", "${workspaceFolder}\\scripts\\deploy.ps1"]
            },
            "problemMatcher": [],
            "detail": "部署到远程服务器",
            "runOptions": {
                "runOn": "default"
            }
        },
        
        // ----- 后台运行任务 -----
        {
            "label": "Start Dev Server",
            "type": "npm",
            "script": "dev",
            "isBackground": true,
            "problemMatcher": {
                "pattern": {
                    "regexp": "."
                },
                "background": {
                    "activeOnStart": true,
                    "beginsPattern": ".*Server starting.*",
                    "endsPattern": ".*Server ready.*"
                }
            },
            "presentation": {
                "reveal": "always",
                "panel": "dedicated"
            },
            "runOptions": {
                "runOn": "folderOpen"  // 打开文件夹时自动运行
            }
        },
        
        // ----- 复合任务 -----
        {
            "label": "Setup Project",
            "dependsOn": ["Install Dependencies", "Create Config", "Build Assets"],
            "dependsOrder": "parallel",
            "group": "none",
            "detail": "并行执行项目初始化任务"
        }
    ]
}
```

---

## 三、launch.json 配置详解

### 1. 文件位置
必须位于工作区级别：
```
${workspaceFolder}/.vscode/launch.json
```
与 tasks.json 类似，launch.json 不支持全局配置，必须绑定到具体项目。

### 2. 作用
- 启动调试会话：配置如何启动程序进行调试
- 附加到运行进程：连接已运行的进程进行调试
- 多目标调试：同时调试客户端和服务端
- 集成不同调试器：支持 Node.js、Python、C++、Java、Go 等
- 预启动任务：调试前自动执行构建或准备任务

### 3. 配置项详解

#### 根级别结构
| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| version | string | 是 | 版本号，固定为 "0.2.0" |
| configurations | array | 是 | 调试配置数组 |
| compounds | array | 否 | 复合启动配置（同时启动多个） |

#### 通用配置项（所有调试器）
| 属性 | 类型 | 说明 | 示例 |
|------|------|------|------|
| name | string | 配置显示名称（出现在启动下拉框） | "Launch Chrome" |
| type | string | 调试器类型 | "node", "python", "chrome", "cppdbg" |
| request | string | 请求类型：launch（启动）, attach（附加） | "launch" |
| preLaunchTask | string | 调试前执行的任务（tasks.json 中的 label） | "npm: build" |
| postDebugTask | string | 调试后执行的任务 | "Clean Temp" |
| presentation | object | 展示选项 | 见下方 |
| internalConsoleOptions | string | 内部控制台行为 | "openOnSessionStart", "neverOpen" |

#### presentation 配置
```json
{
    "presentation": {
        "hidden": false,           // 是否在启动配置中隐藏
        "group": "Server",         // 分组名称
        "order": 1                 // 组内排序
    }
}
```

#### Node.js 调试专用
| 属性 | 类型 | 说明 | 示例 |
|------|------|------|------|
| program | string | 入口文件 | "${workspaceFolder}/src/index.js" |
| args | array | 传递给程序的参数 | ["--port", "3000"] |
| cwd | string | 工作目录 | "${workspaceFolder}" |
| env | object | 环境变量 | {"NODE_ENV": "development"} |
| envFile | string | 环境变量文件路径 | "${workspaceFolder}/.env" |
| runtimeExecutable | string | 运行时（默认 node） | "nodemon", "ts-node" |
| runtimeArgs | array | 运行时参数 | ["--transpile-only"] |
| sourceMaps | boolean | 启用 Source Map | true |
| outFiles | array | 编译后文件位置 | ["${workspaceFolder}/dist/**/*.js"] |
| console | string | 控制台类型 | "integratedTerminal", "externalTerminal" |
| restart | boolean | 自动重启（配合 nodemon） | true |
| autoAttachChildProcesses | boolean | 自动附加子进程 | true |
| skipFiles | array | 跳过的文件 | ["<node_internals>/**"] |
| smartStep | boolean | 智能跳过无关代码 | true |

#### Chrome/Edge 调试
| 属性 | 类型 | 说明 | 示例 |
|------|------|------|------|
| url | string | 调试的 URL | "http://localhost:8080" |
| webRoot | string | 本地文件根目录 | "${workspaceFolder}/src" |
| sourceMapPathOverrides | object | Source Map 路径映射 | {"webpack:///src/*": "${webRoot}/*"} |
| userDataDir | boolean/string | 用户数据目录 | false 或路径 |
| runtimeExecutable | string | Chrome 可执行文件路径 | 自定义路径 |
| port | number | 调试端口 | 9222 |

#### Python 调试专用
| 属性 | 类型 | 说明 | 示例 |
|------|------|------|------|
| module | string | 模块名（替代 program） | "flask" |
| python | string | Python 解释器路径 | "${workspaceFolder}/venv/bin/python" |
| pythonArgs | array | Python 解释器参数 | ["-u"] |
| django | boolean | 启用 Django 调试 | true |
| flask | boolean | 启用 Flask 调试 | true |
| jinja | boolean | 启用 Jinja 模板调试 | true |
| justMyCode | boolean | 仅调试用户代码 | true |
| subProcess | boolean | 启用子进程调试 | false |

#### C/C++ 调试（cppdbg）
| 属性 | 类型 | 说明 | 示例 |
|------|------|------|------|
| program | string | 可执行文件路径 | "${workspaceFolder}/build/main" |
| MIMode | string | 调试器类型 | "gdb", "lldb", "lldb-mi" |
| miDebuggerPath | string | 调试器路径 | "/usr/bin/gdb" |
| setupCommands | array | 调试器初始化命令 | 见示例 |
| stopAtEntry | boolean | 入口点暂停 | false |
| externalConsole | boolean | 使用外部终端 | false |

#### 复合配置（compounds）
| 属性 | 类型 | 说明 |
|------|------|------|
| name | string | 复合配置名称 |
| configurations | array | 要同时启动的配置名称列表 |
| preLaunchTask | string | 启动前的任务 |
| stopAll | boolean | 停止其中一个时全部停止 |

### 4. 完整实例
```json
{
    "version": "0.2.0",
    
    // ========== 调试配置 ==========
    "configurations": [
        // ----- Node.js：直接启动 -----
        {
            "name": "Node: Launch Current File",
            "type": "node",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal",
            "internalConsoleOptions": "neverOpen",
            "skipFiles": [
                "<node_internals>/**"
            ]
        },
        
        // ----- Node.js：使用 nodemon（热重载）-----
        {
            "name": "Node: Nodemon",
            "type": "node",
            "request": "launch",
            "runtimeExecutable": "nodemon",
            "runtimeArgs": [
                "--inspect",
                "--transpile-only"
            ],
            "args": [
                "${workspaceFolder}/src/server.ts"
            ],
            "restart": true,
            "console": "integratedTerminal",
            "internalConsoleOptions": "neverOpen",
            "env": {
                "NODE_ENV": "development",
                "DEBUG": "app:*"
            },
            "sourceMaps": true,
            "outFiles": [
                "${workspaceFolder}/dist/**/*.js"
            ],
            "preLaunchTask": "npm: build",
            "presentation": {
                "group": "Node.js",
                "order": 1
            }
        },
        
        // ----- Node.js：附加到进程 -----
        {
            "name": "Node: Attach to Process",
            "type": "node",
            "request": "attach",
            "processId": "${command:PickProcess}",
            "restart": false,
            "stopOnEntry": false,
            "presentation": {
                "group": "Node.js",
                "order": 2
            }
        },
        
        // ----- Chrome：调试前端 -----
        {
            "name": "Chrome: Debug Frontend",
            "type": "chrome",
            "request": "launch",
            "url": "http://localhost:3000",
            "webRoot": "${workspaceFolder}/src",
            "sourceMapPathOverrides": {
                "webpack:///src/*": "${webRoot}/*",
                "webpack:///./*": "${webRoot}/*",
                "webpack:///*": "*"
            },
            "runtimeArgs": [
                "--disable-session-crashed-bubble",
                "--disable-infobars"
            ],
            "userDataDir": false,
            "preLaunchTask": "npm: start",
            "presentation": {
                "group": "Frontend",
                "order": 1
            }
        },
        
        // ----- Chrome：附加到已打开的浏览器 -----
        {
            "name": "Chrome: Attach",
            "type": "chrome",
            "request": "attach",
            "port": 9222,
            "webRoot": "${workspaceFolder}/src",
            "sourceMaps": true,
            "presentation": {
                "group": "Frontend",
                "order": 2
            }
        },
        
        // ----- Python：Flask 应用 -----
        {
            "name": "Python: Flask",
            "type": "python",
            "request": "launch",
            "module": "flask",
            "env": {
                "FLASK_APP": "app.py",
                "FLASK_ENV": "development",
                "FLASK_DEBUG": "1"
            },
            "args": [
                "run",
                "--no-debugger",
                "--no-reload"
            ],
            "jinja": true,
            "justMyCode": true,
            "python": "${workspaceFolder}/venv/bin/python",
            "preLaunchTask": "pip: install requirements",
            "presentation": {
                "group": "Python",
                "order": 1
            }
        },
        
        // ----- Python：当前文件 -----
        {
            "name": "Python: Current File",
            "type": "python",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal",
            "justMyCode": true,
            "env": {
                "PYTHONPATH": "${workspaceFolder}"
            },
            "presentation": {
                "group": "Python",
                "order": 2
            }
        },
        
        // ----- Python：Django -----
        {
            "name": "Python: Django",
            "type": "python",
            "request": "launch",
            "program": "${workspaceFolder}/manage.py",
            "args": [
                "runserver",
                "0.0.0.0:8000"
            ],
            "django": true,
            "justMyCode": true,
            "presentation": {
                "group": "Python",
                "order": 3
            }
        },
        
        // ----- C++：GDB 调试 -----
        {
            "name": "C++: GDB Debug",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/build/${fileBasenameNoExtension}",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "miDebuggerPath": "/usr/bin/gdb",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                },
                {
                    "description": "Set Disassembly Flavor to Intel",
                    "text": "-gdb-set disassembly-flavor intel",
                    "ignoreFailures": true
                }
            ],
            "preLaunchTask": "C/C++: g++ build active file",
            "presentation": {
                "group": "C++",
                "order": 1
            }
        },
        
        // ----- 远程调试：通过 SSH -----
        {
            "name": "Remote: Attach via SSH",
            "type": "node",
            "request": "attach",
            "address": "192.168.1.100",
            "port": 9229,
            "localRoot": "${workspaceFolder}",
            "remoteRoot": "/home/user/project",
            "skipFiles": [
                "<node_internals>/**"
            ],
            "presentation": {
                "group": "Remote",
                "order": 1
            }
        }
    ],
    
    // ========== 复合配置 ==========
    "compounds": [
        {
            "name": "Full Stack: Client + Server",
            "configurations": [
                "Node: Nodemon",
                "Chrome: Debug Frontend"
            ],
            "preLaunchTask": "npm: install",
            "stopAll": true,
            "presentation": {
                "group": "Compound",
                "order": 1
            }
        },
        {
            "name": "Microservices: All Services",
            "configurations": [
                "Node: API Gateway",
                "Node: User Service",
                "Node: Order Service",
                "Python: Notification Service"
            ],
            "stopAll": true,
            "presentation": {
                "group": "Compound",
                "order": 2
            }
        }
    ]
}
```

---

## 四、三个文件的协同关系
```
1. 编辑代码 (settings.json 定义编辑器行为)
           ↓
2. 触发任务 (tasks.json 执行构建/检查)
           ↓
3. 启动调试 (launch.json 配置调试会话)
           ↓
4. 调试器连接 ←→ 运行中的程序
```

### 典型联动示例
场景：TypeScript 全栈项目
1. settings.json：配置保存时自动格式化、TypeScript 语言特定设置
2. tasks.json：
   - tsc: watch 任务持续编译 TS → JS
   - build 任务依赖 clean + lint + compile
3. launch.json：
   - 调试配置 preLaunchTask 指向 build 任务
   - 调试 Node.js 后端 + Chrome 前端（Compound）

```json
// launch.json 中的联动示例
{
    "name": "Debug Full Stack",
    "type": "node",
    "request": "launch",
    "program": "${workspaceFolder}/dist/server.js",
    "preLaunchTask": "Full Build",
    "postDebugTask": "Clean Temp"
}
```

## 五、快速参考：常用命令与技巧
| 操作 | 快捷键/命令 | 说明 |
|------|-------------|------|
| 打开用户设置 | Ctrl+, | 图形化设置界面 |
| 打开 settings.json | 命令面板 → Preferences: Open User Settings (JSON) | 直接编辑 JSON |
| 运行任务 | Ctrl+Shift+P → Tasks: Run Task | 选择并运行任务 |
| 默认构建任务 | Ctrl+Shift+B | 运行 group 为 build 且 isDefault 的任务 |
| 开始调试 | F5 | 启动当前选中的调试配置 |
| 选择调试配置 | Ctrl+Shift+D 然后选择 | 切换不同调试目标 |
| 条件断点 | 右键断点 → 编辑条件 | 如 i > 100 && user !== null |
| 日志断点 | 右键断点 → 编辑日志消息 | 不中断，只输出日志 |

---

## 4. 内置环境变量（预定义变量）

根据搜索结果，我为您整理了 VS Code 的内置环境变量（预定义变量）的完整列表。这些变量可以在 `tasks.json`、`launch.json`、`settings.json` 等配置文件中使用，使用 `${variableName}` 语法引用。

### 4.1 内置预定义变量

#### 工作区相关变量

| 变量名 | 说明 |
|--------|------|
| `${workspaceFolder}` | 当前工作区的根目录路径（最常用） |
| `${workspaceFolderBasename}` | 当前工作区根目录的文件夹名称 |
| `${fileWorkspaceFolder}` | 当前打开文件所属的工作区文件夹路径 |
| `${workspaceFolder:NAME}` | 多根工作区中指定名称的根文件夹路径 |

#### 文件相关变量

| 变量名 | 说明 |
|--------|------|
| `${file}` | 当前打开文件的完整路径（含文件名和扩展名） |
| `${fileDirname}` | 当前打开文件所在的目录路径（不含文件名） |
| `${fileBasename}` | 当前文件的文件名（含扩展名，不含路径） |
| `${fileBasenameNoExtension}` | 当前文件的文件名（不含扩展名和路径） |
| `${fileExtname}` | 当前文件的扩展名（含 `.` 符号） |
| `${relativeFile}` | 当前文件相对于工作区根目录的相对路径 |
| `${relativeFileDirname}` | 当前文件目录相对于工作区根目录的相对路径 |
| `${fileDirnameBasename}` | 当前文件所在目录的文件夹名称 |

#### 编辑位置相关变量

| 变量名 | 说明 |
|--------|------|
| `${lineNumber}` | 当前光标所在的行号 |
| `${column}` | 当前光标所在的列号 |
| `${selectedText}` | 当前选中的文本内容 |

#### 路径分隔符变量

| 变量名 | 说明 |
|--------|------|
| `${pathSeparator}` | 系统路径分隔符（Windows 为 `\`，macOS/Linux 为 `/`） |
| `${/}` | 简写形式的路径分隔符 |

#### 其他变量

| 变量名 | 说明 |
|--------|------|
| `${cwd}` | 当前工作目录（任务启动时的目录） |
| `${defaultBuildTask}` | 默认构建任务的标签名 |
| `${taskLabel}` | 当前正在运行的任务的标签名 |

### 4.2 环境变量引用

使用 `${env:VARIABLE_NAME}` 语法引用操作系统环境变量：

```json
{
  "program": "${workspaceFolder}/app.js",
  "args": ["${env:USERNAME}"]
}
```

### 4.3 配置变量引用

使用 `${config:NAME}` 语法引用 VS Code 设置项的值：

```json
{
  "fontSize": "${config:editor.fontSize}"
}
```

### 4.3 使用示例

#### 在 tasks.json 中使用

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build Project",
            "type": "shell",
            "command": "npm",
            "args": [
                "run",
                "build",
                "--",
                "--projectDir=${workspaceFolder}",
                "--outputDir=${workspaceFolder}/dist"
            ]
        }
    ]
}
```

#### 在 launch.json 中使用

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch Node App",
            "type": "node",
            "request": "launch",
            "program": "${workspaceFolder}/app.js",
            "env": { "NODE_ENV": "development" }
        }
    ]
}
```

#### 在 settings.json 中使用

```json
{
    "terminal.integrated.cwd": "${workspaceFolder}",
    "terminal.integrated.env.windows": {
        "MY_VAR": "${workspaceFolder}/src"
    }
}
```

> **注意事项**
> 1. **Windows 路径转义**：在 JSON 文件中，Windows 路径的反斜杠需要转义，如 `"${workspaceFolder}\\subdir"`
> 2. **跨平台兼容**：建议使用 `${pathSeparator}` 或正斜杠 `/` 来确保配置在不同操作系统间可移植
> 3. **多根工作区**：可以通过 `${workspaceFolder:FolderName}` 访问特定根文件夹
> 4. **变量作用域**：VS Code 变量（如 `${workspaceFolder}`）只能在 VS Code 配置文件中使用，不能直接在 `.env` 文件或操作系统层面使用