
# VS Code 中 Python 调试工具使用手册

本手册详细介绍 Python 在 VS Code 中的调试配置，包括内置调试器 pdb 和 VS Code 图形化调试。

---

## 1、Python 调试器概述

### 1.1 调试工具类型

| 工具 | 类型 | 适用场景 |
|------|------|----------|
| **pdb** | 命令行调试器 | 快速排查、简单脚本 |
| **VSCode Debugger** | 图形化调试器 | 项目开发、复杂调试 |
| **debugpy** | Python 调试服务器 | 远程调试、Web 应用 |

---

## 2、命令行调试（pdb）

### 2.1 基础用法

Python 3.7+ 自带内置调试器 `pdb`，无需安装任何工具。

**步骤一：在代码中设置断点**

```python
def add(a, b):
    breakpoint()  # Python 3.7+ 自带，程序会停在这里
    return a + b

result = add(1, 2)
print(result)
```

**步骤二：运行程序**

```bash
python test.py
```

程序会在 `breakpoint()` 处暂停，进入调试模式。

### 2.2 常用调试命令

| 命令 | 简写 | 功能 |
|------|------|------|
| `help` | `h` | 显示帮助信息 |
| `next` | `n` | 执行下一行（不进入函数） |
| `step` | `s` | 执行下一行（进入函数） |
| `return` | `r` | 执行到函数返回 |
| `continue` | `c` | 继续执行到下一个断点 |
| `list` | `l` | 显示当前代码 |
| `print` | `p` | 打印变量值 |
| `where` | `w` | 显示调用堆栈 |
| `quit` | `q` | 退出调试器 |

### 2.3 调试示例

```python
# test_pdb.py
def calculate(items):
    total = 0
    for item in items:
        breakpoint()  # 在循环中设置断点
        total += item
    return total

data = [1, 2, 3, 4, 5]
result = calculate(data)
print(f"Total: {result}")
```

运行调试：
```bash
python test_pdb.py
```

调试会话示例：
```
> test_pdb.py(5)calculate()
-> total += item
(Pdb) p item
1
(Pdb) p total
0
(Pdb) n
> test_pdb.py(4)calculate()
-> for item in items:
(Pdb) p total
1
(Pdb) c
Total: 15
```

---

## 3、VS Code 图形化调试

### 3.1 前置准备

**安装扩展:**
1. Python（Microsoft）
2. Python Debugger（Microsoft）

**选择解释器:**
1. 按 `Ctrl+Shift+P` 打开命令面板
2. 输入 `Python: Select Interpreter`
3. 选择虚拟环境的 Python 解释器

### 3.2 配置 launch.json

点击左侧活动栏的 **运行和调试** 图标（或按 `Ctrl+Shift+D`），点击 **创建 launch.json 文件**，选择 Python 环境。

### 3.3 完整配置模板

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: 当前文件",
            "type": "debugpy",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal",
            "cwd": "${workspaceFolder}"
        },
        {
            "name": "Python: 调试模块",
            "type": "debugpy",
            "request": "launch",
            "module": "your_module",
            "console": "integratedTerminal",
            "cwd": "${workspaceFolder}"
        },
        {
            "name": "Python: 远程调试",
            "type": "debugpy",
            "request": "attach",
            "connect": {
                "host": "localhost",
                "port": 5678
            },
            "pathMappings": [
                {
                    "localRoot": "${workspaceFolder}",
                    "remoteRoot": "/app"
                }
            ]
        },
        {
            "name": "Python: Django",
            "type": "debugpy",
            "request": "launch",
            "program": "${workspaceFolder}/manage.py",
            "console": "integratedTerminal",
            "args": ["runserver"],
            "django": true
        },
        {
            "name": "Python: Flask",
            "type": "debugpy",
            "request": "launch",
            "module": "flask",
            "env": {
                "FLASK_APP": "app.py",
                "FLASK_ENV": "development",
                "FLASK_DEBUG": "1"
            },
            "args": ["run", "--no-debugger", "--no-reload"],
            "jinja": true
        },
        {
            "name": "Python: pytest",
            "type": "debugpy",
            "request": "launch",
            "module": "pytest",
            "args": ["tests/", "-v"],
            "justMyCode": false
        }
    ]
}
```

### 3.4 配置详解

#### 配置 1：调试当前文件

```json
{
    "name": "Python: 当前文件",
    "type": "debugpy",
    "request": "launch",
    "program": "${file}",
    "console": "integratedTerminal",
    "cwd": "${workspaceFolder}"
}
```

- `program: ${file}`: 当前打开的文件
- 适用：单文件脚本、快速测试

#### 配置 2：调试指定模块

```json
{
    "name": "Python: 调试模块",
    "type": "debugpy",
    "request": "launch",
    "module": "your_module",
    "console": "integratedTerminal"
}
```

- `module`: 要运行的 Python 模块
- 适用：包结构项目

#### 配置 3：远程调试

```json
{
    "name": "Python: 远程调试",
    "type": "debugpy",
    "request": "attach",
    "connect": {
        "host": "localhost",
        "port": 5678
    },
    "pathMappings": [
        {
            "localRoot": "${workspaceFolder}",
            "remoteRoot": "/app"
        }
    ]
}
```

- 远程服务器启动 debugpy：
  ```bash
  python -m debugpy --listen 0.0.0.0:5678 --wait-for-client main.py
  ```

#### 配置 4：Django 调试

```json
{
    "name": "Python: Django",
    "type": "debugpy",
    "request": "launch",
    "program": "${workspaceFolder}/manage.py",
    "args": ["runserver"],
    "django": true
}
```

- `django: true`: 启用 Django 模板调试
- `args`: Django 管理命令参数

#### 配置 5：Flask 调试

```json
{
    "name": "Python: Flask",
    "type": "debugpy",
    "request": "launch",
    "module": "flask",
    "env": {
        "FLASK_APP": "app.py",
        "FLASK_DEBUG": "1"
    },
    "jinja": true
}
```

- `jinja: true`: 启用 Jinja2 模板调试

#### 配置 6：pytest 调试

```json
{
    "name": "Python: pytest",
    "type": "debugpy",
    "request": "launch",
    "module": "pytest",
    "args": ["tests/", "-v"],
    "justMyCode": false
}
```

- `justMyCode: false`: 允许调试第三方库

### 3.5 调试快捷键

| 快捷键 | 功能 |
|--------|------|
| `F5` | 开始/继续调试 |
| `Ctrl+F5` | 不调试运行 |
| `F9` | 切换断点 |
| `Shift+F9` | 添加条件断点 |
| `F10` | 单步跳过（Step Over） |
| `F11` | 单步进入（Step Into） |
| `Shift+F11` | 单步跳出（Step Out） |
| `Shift+F5` | 停止调试 |
| `Ctrl+Shift+F5` | 重新启动调试 |

### 3.6 调试面板功能

- **变量**: 查看当前作用域的变量值
- **监视**: 添加表达式监视（如 `len(data)`）
- **调用堆栈**: 查看函数调用链
- **断点**: 管理所有断点
- **已暂停线程**: 查看线程状态

---

## 4、虚拟环境下的调试

### 4.1 虚拟环境调试配置

```json
{
    "name": "Python: 虚拟环境调试",
    "type": "debugpy",
    "request": "launch",
    "program": "${workspaceFolder}/main.py",
    "console": "integratedTerminal",
    "cwd": "${workspaceFolder}",
    "env": {
        "VIRTUAL_ENV": "${workspaceFolder}/.venv"
    }
}
```

### 4.2 激活虚拟环境调试

确保在调试前已激活虚拟环境：

**Windows PowerShell:**
```bash
.venv\Scripts\Activate.ps1
```

**Linux/macOS:**
```bash
source .venv/bin/activate
```

---

## 5、Web 应用调试

### 5.1 FastAPI 调试配置

```json
{
    "name": "Python: FastAPI",
    "type": "debugpy",
    "request": "launch",
    "module": "uvicorn",
    "args": [
        "main:app",
        "--reload",
        "--port",
        "8000"
    ],
    "jinja": true,
    "env": {
        "DEBUG": "1"
    }
}
```

### 5.2 调试运行步骤

1. 在代码中设置断点
2. 选择 "Python: FastAPI" 配置
3. 按 `F5` 启动调试
4. 访问 `http://127.0.0.1:8000` 触发断点

---

## 6、高级调试技巧

### 6.1 条件断点

右键点击断点 → 编辑断点 → 输入条件表达式：

```python
# 当 i == 5 时暂停
i == 5
```

### 6.2 日志断点

右键点击断点 → 编辑断点 → 输入日志消息：

```
当前值：{i}, 总数：{total}
```

### 6.3 异常断点

在断点面板中：
1. 点击 `+` 添加异常断点
2. 选择异常类型（如 `ValueError`）
3. 程序在抛出该异常时自动暂停

### 6.4 多进程调试

```json
{
    "name": "Python: 多进程调试",
    "type": "debugpy",
    "request": "launch",
    "program": "${workspaceFolder}/main.py",
    "subProcess": true
}
```

- `subProcess: true`: 自动调试子进程

---

## 7、常见问题排查

### 7.1 调试器无法启动

**症状**: 按 F5 后无反应

**解决**:
1. 确认 Python 扩展已安装
2. 检查解释器选择是否正确
3. 在输出面板查看 "Debug Console" 日志

### 7.2 断点不触发

**症状**: 程序运行但不暂停

**解决**:
1. 确认断点是实心红点（已激活）
2. 检查代码是否被执行
3. 尝试 `justMyCode: false`

### 7.3 变量无法查看

**症状**: 变量显示为 `<unable to read variable>`

**解决**:
1. 重启调试会话
2. 更新 Python 扩展
3. 检查是否有 `__repr__` 方法问题

---

## 8、最佳实践建议

1. **使用条件断点**: 避免在循环中频繁暂停
2. **配置日志断点**: 非侵入式记录变量值
3. **远程调试**: 服务器问题本地调试
4. **异常断点**: 快速定位异常来源
5. **多配置管理**: 不同场景使用不同配置

---

## 参考资源

- [VS Code Python 调试文档](https://code.visualstudio.com/docs/python/debugging)
- [debugpy 官方文档](https://github.com/microsoft/debugpy)
- [Python pdb 文档](https://docs.python.org/3/library/pdb.html)

---

*文档版本：1.0*
*最后更新：2024 年*
