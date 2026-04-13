
# Python 开发常见问题排查手册

本手册汇总 Python 开发环境配置、包管理、调试、打包发布过程中的常见问题及解决方案。

---

## 目录

1. [环境配置问题](#1环境配置问题)
2. [虚拟环境问题](#2虚拟环境问题)
3. [包管理问题](#3包管理问题)
4. [VS Code 配置问题](#4vs-code-配置问题)
5. [调试问题](#5调试问题)
6. [打包发布问题](#6打包发布问题)
7. [代码执行问题](#7代码执行问题)
8. [网络与代理问题](#8网络与代理问题)

---

## 1、环境配置问题

### 1.1 Python 命令找不到

**症状:**
```bash
python: command not found
# 或
'python' 不是内部或外部命令
```

**解决方案:**

**Windows:**
1. 确认 Python 已安装：
   ```bash
   where python
   where python3
   ```

2. 添加环境变量：
   - 右键"此电脑" → 属性 → 高级系统设置 → 环境变量
   - 在"系统变量"中找到 `Path`
   - 添加 Python 安装路径（如 `C:\Python311\`）
   - 添加 Scripts 路径（如 `C:\Python311\Scripts\`）

3. 重新打开终端

**macOS/Linux:**
```bash
# 添加到 PATH
echo 'export PATH="/usr/local/bin/python3:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 或使用别名
echo 'alias python=python3' >> ~/.bashrc
echo 'alias pip=pip3' >> ~/.bashrc
source ~/.bashrc
```

### 1.2 多版本 Python 冲突

**症状:**
```bash
python --version  # 显示 2.7.x
python3 --version # 显示 3.x.x
```

**解决方案:**

**方法 1: 使用 pyenv 管理多版本**
```bash
# 安装 pyenv
# macOS
brew install pyenv

# Linux
curl https://pyenv.run | bash

# 配置 shell
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
source ~/.bashrc

# 安装 Python 版本
pyenv install 3.11.5
pyenv install 3.10.12

# 设置全局默认版本
pyenv global 3.11.5

# 设置项目本地版本
pyenv local 3.10.12
```

**方法 2: 使用 uv 管理（推荐）**
```bash
# 安装指定版本
uv python install 3.11

# 项目本地 pinned 版本
uv python pin 3.11
```

**方法 3: 显式使用版本命令**
```bash
# 始终使用完整命令
python3.11 -m pip install requests
python3.11 script.py
```

### 1.3 pip 命令找不到

**症状:**
```bash
pip: command not found
```

**解决方案:**
```bash
# 使用 python -m pip 替代
python -m pip install requests

# 安装 pip（如果未安装）
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py

# 或使用 ensurepip
python -m ensurepip --upgrade
```

---

## 2、虚拟环境问题

### 2.1 无法激活虚拟环境

**症状 (Windows PowerShell):**
```
无法加载文件，因为在此系统上禁止运行脚本
```

**解决方案:**
```powershell
# 更改执行策略
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 或使用替代激活方式
.venv\Scripts\activate.bat
```

**症状 (Linux/macOS):**
```bash
bash: .venv/bin/activate: No such file or directory
```

**解决方案:**
```bash
# 确认虚拟环境存在
ls -la .venv/bin/

# 重新创建虚拟环境
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
```

### 2.2 虚拟环境激活后仍使用系统 Python

**症状:**
```bash
(.venv) $ which python
/usr/bin/python  # 而不是 .venv/bin/python
```

**解决方案:**
```bash
# 检查 PATH 顺序
echo $PATH

# 重新激活环境
deactivate
source .venv/bin/activate

# 确认 Python 路径
which python
python -c "import sys; print(sys.executable)"
```

### 2.3 虚拟环境损坏

**症状:**
- 激活失败
- 包安装不生效
- 导入错误

**解决方案:**
```bash
# 最直接的解决方案：重建环境
deactivate
rm -rf .venv
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

---

## 3、包管理问题

### 3.1 pip 安装超时

**症状:**
```bash
ERROR: Connection timed out while downloading
```

**解决方案:**
```bash
# 使用国内镜像
pip install requests -i https://pypi.tuna.tsinghua.edu.cn/simple

# 增加超时时间
pip install requests --default-timeout=1000

# 使用可信主机
pip install requests -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn

# 永久配置
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```

### 3.2 依赖冲突

**症状:**
```bash
ERROR: Cannot install package-a and package-b because these package versions have conflicting dependencies.
```

**解决方案:**
```bash
# 查看冲突详情
pip check

# 方案 1: 升级所有相关包
pip install --upgrade package-a package-b

# 方案 2: 指定兼容版本
pip install package-a==1.0.0 package-b==2.0.0

# 方案 3: 使用 pip-tools 解决依赖
pip install pip-tools
pip-compile requirements.in
pip-sync requirements.txt

# 方案 4: 使用 uv 自动解决
uv add package-a package-b
```

### 3.3 权限错误

**症状:**
```bash
ERROR: Could not install packages due to an EnvironmentError: [Errno 13] Permission denied
```

**解决方案:**
```bash
# 方案 1: 使用 --user 安装到用户目录（推荐）
pip install --user package_name

# 方案 2: 使用虚拟环境（最佳实践）
python -m venv .venv
source .venv/bin/activate
pip install package_name

# 方案 3: 使用 sudo（不推荐，可能破坏系统 Python）
sudo pip install package_name
```

### 3.4 包已安装但导入失败

**症状:**
```python
ModuleNotFoundError: No module named 'requests'
```

**解决方案:**
```bash
# 1. 确认当前 Python 解释器
which python
python -c "import sys; print(sys.executable)"

# 2. 确认包安装位置
pip show requests

# 3. 确认 Python 路径包含 site-packages
python -c "import sys; print(sys.path)"

# 4. 在正确的环境中安装
/path/to/correct/python -m pip install requests

# 5. VS Code 中切换解释器
# Ctrl+Shift+P → Python: Select Interpreter
```

### 3.5 pip 缓存问题

**症状:**
- 安装的包版本不对
- 损坏的缓存导致安装失败

**解决方案:**
```bash
# 清除 pip 缓存
pip cache purge

# 或手动删除缓存目录
# Windows: %LocalAppData%\pip\Cache
# macOS: ~/Library/Caches/pip
# Linux: ~/.cache/pip

# 安装时不使用缓存
pip install --no-cache-dir requests

# 使用 uv 清理缓存
uv cache clean
```

---

## 4、VS Code 配置问题

### 4.1 Python 扩展不工作

**症状:**
- 没有代码补全
- 没有语法检查
- 没有智能提示

**解决方案:**
```bash
# 1. 确认扩展已安装
# 扩展商店搜索 "Python" 和 "Python Debugger"

# 2. 重新加载窗口
Ctrl+Shift+P → Developer: Reload Window

# 3. 重启语言服务器
Ctrl+Shift+P → Python: Restart Language Server

# 4. 检查输出面板
查看 "Python" 和 "Language Server" 输出

# 5. 重新安装扩展
# 卸载 Python 扩展后重新安装
```

### 4.2 解释器选择错误

**症状:**
- 代码补全不正确
- 导入错误
- 运行使用错误的 Python

**解决方案:**
```bash
# 1. 选择正确的解释器
Ctrl+Shift+P → Python: Select Interpreter
选择虚拟环境的解释器

# 2. 手动配置 settings.json
{
    "python.defaultInterpreterPath": "${workspaceFolder}/.venv/Scripts/python.exe"
}

# 3. 确认虚拟环境已激活
```

### 4.3 格式化不工作

**症状:**
- 保存时没有自动格式化
- 格式化命令失败

**解决方案:**
```bash
# 1. 安装格式化器
pip install black

# 2. 配置 settings.json
{
    "[python]": {
        "editor.defaultFormatter": "ms-python.black-formatter",
        "editor.formatOnSave": true
    },
    "black-formatter.path": ["${workspaceFolder}/.venv/Scripts/black.exe"]
}

# 3. 检查格式化器路径
which black
```

### 4.4 调试器无法启动

**症状:**
- 按 F5 无反应
- 调试器连接失败

**解决方案:**
```bash
# 1. 确认 launch.json 配置正确
{
    "name": "Python: Current File",
    "type": "debugpy",
    "request": "launch",
    "program": "${file}",
    "console": "integratedTerminal"
}

# 2. 安装 debugpy
pip install debugpy

# 3. 检查 Python 路径
# settings.json
{
    "python.defaultInterpreterPath": "${workspaceFolder}/.venv/Scripts/python.exe"
}

# 4. 查看调试控制台输出
```

---

## 5、调试问题

### 5.1 断点不触发

**症状:**
- 程序运行但不暂停
- 断点是空心圆

**解决方案:**
```python
# 1. 确认断点设置在被执行的代码路径
# 空心断点表示代码不会被执行

# 2. 检查 justMyCode 设置
# launch.json
{
    "justMyCode": false  # 允许调试第三方库
}

# 3. 确认使用正确的解释器运行

# 4. 尝试条件断点
# 右键断点 → 编辑条件
```

### 5.2 变量无法查看

**症状:**
- 变量显示 `<unable to read variable>`
- 变量值不更新

**解决方案:**
```bash
# 1. 重启调试会话

# 2. 更新 Python 扩展和 debugpy
pip install --upgrade debugpy

# 3. 检查是否有自定义 __repr__ 问题
class MyClass:
    def __repr__(self):
        try:
            return f"MyClass({self.value})"
        except:
            return "MyClass(?)"  # 避免 repr 抛出异常
```

### 5.3 远程调试连接失败

**症状:**
- 无法连接到远程调试器
- 超时错误

**解决方案:**
```bash
# 1. 远程启动 debugpy
python -m debugpy --listen 0.0.0.0:5678 --wait-for-client main.py

# 2. 确认防火墙允许连接
# 开放 5678 端口

# 3. VS Code 配置
{
    "name": "Python: Remote Attach",
    "type": "debugpy",
    "request": "attach",
    "connect": {
        "host": "remote-server-ip",
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

---

## 6、打包发布问题

### 6.1 构建失败

**症状:**
```bash
ERROR: Setup script exited with error
```

**解决方案:**
```bash
# 1. 更新构建工具
pip install --upgrade build setuptools wheel

# 2. 清理构建缓存
rm -rf build/ dist/ *.egg-info/

# 3. 检查 pyproject.toml 语法
# 使用 toml 验证工具

# 4. 确认包结构正确
tree src/

# 5. 检查 __init__.py 是否存在
touch src/your_package/__init__.py
```

### 6.2 包安装后导入失败

**症状:**
```python
ModuleNotFoundError: No module named 'your_package'
```

**解决方案:**
```bash
# 1. 检查 pyproject.toml 配置
[tool.setuptools.packages.find]
where = ["src"]

# 2. 确认包结构
# src/your_package/__init__.py 必须存在

# 3. 重新构建和安装
rm -rf dist/
python -m build
pip install dist/your_package-*.whl
```

### 6.3 CLI 命令不工作

**症状:**
```bash
your-command: command not found
```

**解决方案:**
```bash
# 1. 检查入口点配置
[project.scripts]
your-command = "your_package.cli:main"

# 2. 确认 main 函数存在
# src/your_package/cli.py
def main():
    pass

# 3. 重新安装
pip uninstall your-package
pip install .

# 4. 检查命令路径
which your-command
```

### 6.4 PyPI 发布失败

**症状:**
```bash
HTTPError: 400 Bad Request
```

**解决方案:**
```bash
# 1. 检查包名是否已存在
# https://pypi.org/search/?q=your-package

# 2. 验证 token
export TWINE_USERNAME="__token__"
export TWINE_PASSWORD="pypi-..."

# 3. 检查包元数据
twine check dist/*

# 4. 使用测试 PyPI 先测试
twine upload --repository testpypi dist/*
```

---

## 7、代码执行问题

### 7.1 编码问题

**症状:**
```python
UnicodeDecodeError: 'utf-8' codec can't decode byte
```

**解决方案:**
```python
# 1. 指定文件编码
with open('file.txt', 'r', encoding='utf-8') as f:
    content = f.read()

# 2. 使用正确的编码
with open('file.txt', 'r', encoding='gbk') as f:  # Windows 中文
    content = f.read()

# 3. 设置默认编码（Python 3.7+）
# 在启动时设置
PYTHONUTF8=1 python script.py

# 4. 在脚本开头声明编码
# -*- coding: utf-8 -*-
```

### 7.2 路径问题

**症状:**
```python
FileNotFoundError: [Errno 2] No such file or directory
```

**解决方案:**
```python
# 1. 使用 pathlib 处理路径
from pathlib import Path

# 获取脚本所在目录
BASE_DIR = Path(__file__).resolve().parent

# 构建路径
data_file = BASE_DIR / "data" / "file.txt"

# 2. 使用绝对路径
import os
abs_path = os.path.abspath("relative/path")

# 3. 检查当前工作目录
import os
print(os.getcwd())
```

### 7.3 导入循环问题

**症状:**
```python
ImportError: cannot import name 'X' from partially initialized module 'Y'
```

**解决方案:**
```python
# 方案 1: 重构代码，避免循环导入
# a.py
from b import func_b  # 移动到函数内部

def func_a():
    pass

# b.py
from a import func_a

def func_b():
    pass

# 方案 2: 使用 TYPE_CHECKING
from typing import TYPE_CHECKING
if TYPE_CHECKING:
    from other_module import SomeClass

# 方案 3: 延迟导入
def some_function():
    from heavy_module import HeavyClass
    return HeavyClass()
```

---

## 8、网络与代理问题

### 8.1 无法访问 PyPI

**症状:**
```bash
ERROR: Could not find a version that satisfies the requirement
```

**解决方案:**
```bash
# 1. 使用国内镜像
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 2. 配置代理
export HTTP_PROXY=http://proxy-server:port
export HTTPS_PROXY=http://proxy-server:port

# 或在 pip.conf 中配置
[global]
proxy = http://proxy-server:port

# 3. 检查防火墙设置
```

### 8.2 SSL 证书验证失败

**症状:**
```bash
SSLCertVerificationError: certificate verify failed
```

**解决方案:**
```bash
# 方案 1: 更新 certifi
pip install --upgrade certifi

# 方案 2: 指定证书路径
export SSL_CERT_FILE=/path/to/cert.pem

# 方案 3: 使用 trusted-host（不推荐用于生产）
pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org requests

# macOS 特定解决方案
/Applications/Python\ 3.x/Install\ Certificates.command
```

### 8.3 uv 网络问题

**症状:**
```bash
uv: connection timed out
```

**解决方案:**
```bash
# 1. 配置镜像
export UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple

# 2. 配置代理
export HTTP_PROXY=http://proxy:port
export HTTPS_PROXY=http://proxy:port

# 3. 清理缓存
uv cache clean

# 4. 重试
uv sync --retry 3
```

---

## 9、性能问题

### 9.1 pip 安装慢

**解决方案:**
```bash
# 1. 使用国内镜像（见 3.1）

# 2. 使用 uv 替代 pip（速度提升 10-100 倍）
uv pip install requests

# 3. 使用缓存
pip install --cache-dir ~/.cache/pip requests

# 4. 并行安装
pip install --use-pep517 package1 package2 package3
```

### 9.2 Python 运行慢

**解决方案:**
```python
# 1. 使用 PyPy
# https://www.pypy.org/

# 2. 使用 Numba JIT
from numba import jit

@jit(nopython=True)
def fast_function(x):
    return x * 2

# 3. 使用 Cython 编译
# 4. 使用 multiprocessing 并行
from multiprocessing import Pool

with Pool() as p:
    results = p.map(func, data)
```

---

## 参考资源

- [Python 官方文档](https://docs.python.org/3/)
- [Stack Overflow Python 标签](https://stackoverflow.com/questions/tagged/python)
- [Real Python](https://realpython.com/)
- [Python 常见问题](https://docs.python.org/3/faq/index.html)

---

*文档版本：1.0*
*最后更新：2024 年*
