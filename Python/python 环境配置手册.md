
# VS Code 中配置 Python 语言使用手册

本手册将指导您完成从 Python 语言安装到 VS Code 配置的全过程，包括环境配置、包管理与调试。

---

## 1、Python 语言的安装与配置

### 1.1 下载并安装 Python

#### Windows 系统

1. 访问 Python 官方下载页面：[https://www.python.org/downloads/](https://www.python.org/downloads/)
2. 下载最新版本的安装包（推荐 Python 3.8+）
3. 双击运行安装程序
4. **重要**：勾选 "Add Python to PATH" 选项
5. 点击 "Install Now" 完成安装

#### macOS 系统

**方法一：使用安装包**
1. 访问 [https://www.python.org/downloads/mac-osx/](https://www.python.org/downloads/mac-osx/)
2. 下载 macOS 64-bit universal installer
3. 双击安装包完成安装

**方法二：使用 Homebrew（推荐）**
```bash
brew install python@3.11
```

#### Linux 系统

**Ubuntu/Debian:**
```bash
# 安装 Python 3 和 pip
sudo apt update
sudo apt install python3 python3-pip python3-venv
```

**CentOS/RHEL:**
```bash
sudo yum install python3 python3-pip
```

**Arch Linux:**
```bash
sudo pacman -S python python-pip
```

### 1.2 验证安装

打开终端，执行以下命令：

```bash
# 检查 Python 版本
python --version
# 或
python3 --version
# 应显示类似：Python 3.11.5
```

```bash
# 检查 pip 版本
pip --version
# 或
pip3 --version
```

### 1.3 配置 pip 镜像源（推荐）

由于网络原因，建议配置国内镜像源：

**临时使用（单次生效）:**
```bash
# 清华源（推荐）
pip install requests -i https://pypi.tuna.tsinghua.edu.cn/simple

# 阿里源
pip install requests -i https://mirrors.aliyun.com/pypi/simple/
```

**永久配置:**

**Windows:**
```bash
# 创建配置目录
mkdir %APPDATA%\pip

# 创建 pip.ini 配置文件
notepad %APPDATA%\pip\pip.ini
```

添加以下内容：
```ini
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
```

**macOS/Linux:**
```bash
# 创建配置文件
mkdir -p ~/.pip
nano ~/.pip/pip.conf
```

添加以下内容：
```ini
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
```

---

## 2、虚拟环境配置（venv）

### 2.1 创建虚拟环境

```bash
# 进入项目目录
cd your_project

# Windows
python -m venv .venv

# Linux/macOS
python3 -m venv .venv
```

### 2.2 激活虚拟环境

**Windows (PowerShell):**
```bash
.venv\Scripts\Activate.ps1
```

**Windows (CMD):**
```bash
.venv\Scripts\activate
```

**Linux/macOS:**
```bash
source .venv/bin/activate
```

激活成功后，命令行前缀会出现 `(.venv)` 标识。

### 2.3 退出虚拟环境

```bash
deactivate
```

### 2.4 虚拟环境结构

```
.venv/
├── Scripts/            # Windows 可执行文件目录
│   ├── activate        # 激活脚本（Linux 格式）
│   ├── Activate.ps1    # PowerShell 激活脚本
│   ├── pip.exe         # pip 可执行文件
│   └── python.exe      # Python 解释器
├── include/            # C 头文件目录
├── lib/                # 库文件目录
│   └── python3.x/
│       └── site-packages/  # 第三方包安装目录
└── pyvenv.cfg          # 虚拟环境配置文件
```

---

## 3、VS Code 安装 Python 扩展

### 3.1 安装 Python 扩展

1. 打开 VS Code
2. 点击左侧活动栏的 **扩展** 图标（或按 `Ctrl+Shift+X`）
3. 搜索框输入 `Python`
4. 找到由 **Microsoft** 开发的官方扩展
5. 点击 **安装**

### 3.2 安装 Python 调试器

1. 在扩展商店搜索 `Python Debugger`
2. 找到由 **Microsoft** 开发的调试器扩展
3. 点击 **安装**

### 3.3 扩展安装位置

| 位置类型 | 路径（Windows） | 路径（macOS） | 路径（Linux） | 说明 |
|---------|----------------|---------------|---------------|------|
| **用户插件**（全局） | `%USERPROFILE%\.vscode\extensions` | `~/.vscode/extensions` | `~/.vscode/extensions` | 默认安装位置，所有项目可用 |
| **工作区插件**（项目级） | `.vscode/extensions`（项目目录内） | 同上 | 同上 | 仅当前工作区可用 |

---

## 4、VS Code 配置 Python 开发环境

### 4.1 选择 Python 解释器

1. 按 `Ctrl+Shift+P` 打开命令面板
2. 输入 `Python: Select Interpreter`
3. 选择项目虚拟环境的 Python 解释器
   - Windows: `.venv\Scripts\python.exe`
   - Linux/macOS: `.venv/bin/python`

### 4.2 推荐配置 settings.json

在项目 `.vscode/settings.json` 中添加：

```json
{
    "python.defaultInterpreterPath": "${workspaceFolder}/.venv/Scripts/python.exe",
    "python.terminal.activateEnvironment": true,
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "python.formatting.provider": "black",
    "python.formatting.blackPath": "${workspaceFolder}/.venv/Scripts/black.exe",
    "[python]": {
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
            "source.organizeImports": "explicit"
        },
        "editor.defaultFormatter": "ms-python.black-formatter",
        "editor.tabSize": 4
    },
    "files.exclude": {
        "**/__pycache__": true,
        "**/*.pyc": true
    }
}
```

### 4.3 安装代码格式化工具

在激活的虚拟环境中：

```bash
# 安装 Black 格式化器
pip install black

# 安装 isort 导入排序工具
pip install isort

# 安装 Pylint 代码检查工具
pip install pylint
```

---

## 5、Python 包管理基础

### 5.1 安装包

```bash
# 基础安装
pip install requests

# 指定版本
pip install flask==2.3.3

# 最低版本
pip install django>=4.2

# 从 requirements.txt 批量安装
pip install -r requirements.txt
```

### 5.2 查看已安装包

```bash
pip list
pip freeze
```

### 5.3 导出依赖清单

```bash
pip freeze > requirements.txt
```

生成 `requirements.txt`，内容示例：
```
Flask==2.3.3
requests==2.31.0
```

### 5.4 升级和卸载包

```bash
# 升级包
pip install --upgrade requests

# 卸载包
pip uninstall requests
```

---

## 6、现代包管理工具 uv（可选）

### 6.1 安装 uv

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

**macOS/Linux:**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**pip 安装（备用）:**
```bash
pip install uv
```

### 6.2 uv 基础命令

```bash
# 创建虚拟环境
uv venv

# 激活环境
uv activate

# 安装依赖
uv add requests
uv add --dev pytest

# 同步环境
uv sync

# 运行脚本
uv run python main.py

# 构建包
uv build
```

---

## 7、常见问题排查

### 7.1 环境变量问题

**症状**: `python` 命令在终端可用，但在 VS Code 中提示找不到

**解决**:
1. 完全关闭 VS Code
2. 在配置好环境变量的终端中重新打开 VS Code
3. 或者手动配置 Python 解释器路径

### 7.2 pip 安装失败

**症状**: 安装时超时或失败

**解决**:
1. 确认 pip 镜像源已配置为国内源
2. 使用 `--trusted-host` 参数：
   ```bash
   pip install requests -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn
   ```

### 7.3 虚拟环境激活失败

**症状**: 激活虚拟环境时出现错误

**解决**:
1. Windows PowerShell 执行策略问题：
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
2. 重新创建虚拟环境：
   ```bash
   rm -rf .venv
   python -m venv .venv
   ```

### 7.4 代码补全不工作

**症状**: 没有自动补全提示

**解决**:
1. 确认已安装 Pylance 扩展
2. 检查 Python 解释器是否选择正确
3. 重启 Python 语言服务器：命令面板 → `Python: Restart Language Server`

---

## 8、最佳实践建议

1. **使用虚拟环境**: 每个项目使用独立的虚拟环境，避免依赖冲突
2. **配置镜像源**: 使用国内镜像源加速包下载
3. **代码格式化**: 配置保存时自动格式化，保持代码风格一致
4. **依赖管理**: 使用 `requirements.txt` 管理项目依赖
5. **版本控制**: 将 `.venv/` 和 `__pycache__/` 添加到 `.gitignore`

---

## 参考资源

- [Python 官方文档](https://docs.python.org/3/)
- [VS Code Python 扩展文档](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
- [pip 官方文档](https://pip.pypa.io/)
- [uv 官方文档](https://docs.astral.sh/uv/)
- [PyPI 包仓库](https://pypi.org/)

---

*文档版本：1.0*
*最后更新：2024 年*
