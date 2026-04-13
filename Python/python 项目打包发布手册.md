
# Python 项目打包发布使用手册

本手册详细介绍 Python 项目从开发到打包、发布的完整流程，包括现代打包工具链和最佳实践。

---

## 目录

1. [项目结构准备](#1项目结构准备)
2. [配置文件详解](#2配置文件详解)
3. [构建打包](#3构建打包)
4. [本地测试](#4本地测试)
5. [发布到 PyPI](#5发布到-pypi)
6. [私有仓库部署](#6私有仓库部署)
7. [打包成可执行文件](#7打包成可执行文件)
8. [常见问题排查](#8常见问题排查)

---

## 1、项目结构准备

### 1.1 标准项目结构

```
your_project/
├── src/
│   └── your_package/       # 源代码目录
│       ├── __init__.py
│       ├── core.py
│       ├── utils.py
│       └── cli.py
├── tests/
│   ├── __init__.py
│   ├── test_core.py
│   └── test_utils.py
├── docs/
│   ├── index.md
│   └── api.md
├── .gitignore
├── .python-version
├── pyproject.toml          # 项目配置（核心）
├── README.md
├── LICENSE
└── requirements.txt        # 可选，兼容性考虑
```

### 1.2 初始化项目

**使用 uv 初始化（推荐）:**
```bash
# 创建新项目
uv init your_project --lib

# 进入项目目录
cd your_project
```

**手动创建:**
```bash
# 创建目录结构
mkdir -p src/your_package tests docs

# 创建必要文件
touch src/your_package/__init__.py
touch tests/__init__.py
touch pyproject.toml
touch README.md
touch LICENSE
touch .gitignore
```

### 1.3 .gitignore 配置

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# 虚拟环境
.venv/
venv/
ENV/
env/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# 测试
.pytest_cache/
.coverage
htmlcov/
.tox/

# 构建产物
*.manifest
*.spec

# 环境变量
.env
.env.local
```

---

## 2、配置文件详解

### 2.1 pyproject.toml 完整模板

```toml
# 构建系统配置
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

# 项目元数据
[project]
name = "your-package"
version = "0.1.0"
description = "一个实用的 Python 包"
readme = "README.md"
requires-python = ">=3.8"
license = { text = "MIT" }

# 作者信息
authors = [
    { name = "Your Name", email = "your@email.com" }
]

# 维护者信息
maintainers = [
    { name = "Your Name", email = "your@email.com" }
]

# 项目分类
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Operating System :: OS Independent",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "Topic :: Software Development :: Libraries :: Python Modules",
]

# 运行时依赖
dependencies = [
    "requests>=2.31.0",
    "click>=8.0.0",
]

# 可选依赖
[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "pytest-cov>=4.0",
    "black>=23.0",
    "ruff>=0.1.0",
    "mypy>=1.0",
]
docs = [
    "sphinx>=6.0",
    "sphinx-rtd-theme>=1.0",
]

# 入口点（CLI 命令）
[project.scripts]
your-command = "your_package.cli:main"

# 入口点（GUI 应用）
[project.gui-scripts]
your-gui = "your_package.gui:main"

# 项目 URL
[project.urls]
Homepage = "https://github.com/yourname/your-package"
Documentation = "https://your-package.readthedocs.io"
Repository = "https://github.com/yourname/your-package"
Issues = "https://github.com/yourname/your-package/issues"
Changelog = "https://github.com/yourname/your-package/blob/main/CHANGELOG.md"

# 工具配置
[tool.setuptools.packages.find]
where = ["src"]

[tool.setuptools.package-data]
your_package = ["py.typed", "*.json"]

# Black 格式化配置
[tool.black]
line-length = 88
target-version = ["py38", "py39", "py310", "py311"]
include = '\.pyi?$'

# Ruff 代码检查配置
[tool.ruff]
line-length = 88
target-version = "py38"
select = ["E", "F", "W", "I", "N", "UP", "B", "C4"]

# Pytest 测试配置
[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v --cov=your_package"

# Mypy 类型检查配置
[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
ignore_missing_imports = true
```

### 2.2 setup.py（传统方式，不推荐）

```python
from setuptools import setup, find_packages

setup(
    name="your-package",
    version="0.1.0",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    install_requires=[
        "requests>=2.31.0",
        "click>=8.0.0",
    ],
    extras_require={
        "dev": ["pytest", "black", "ruff"],
    },
    entry_points={
        "console_scripts": [
            "your-command=your_package.cli:main",
        ],
    },
)
```

### 2.3 README.md 模板

```markdown
# Your Package

简要描述你的包的功能和用途。

## 安装

```bash
pip install your-package
```

## 快速开始

```python
from your_package import core

result = core.main_function()
print(result)
```

## 功能特性

- 特性 1
- 特性 2
- 特性 3

## 文档

完整文档请访问：[https://your-package.readthedocs.io](https://your-package.readthedocs.io)

## 开发

```bash
git clone https://github.com/yourname/your-package
cd your-package
pip install -e .[dev]
```

## 许可证

MIT License
```

---

## 3、构建打包

### 3.1 安装构建工具

```bash
# 安装 build 和 twine
pip install build twine

# 或使用 uv
uv add --dev build twine
```

### 3.2 构建命令

```bash
# 构建 wheel 和 source 分发包
python -m build

# 仅构建 wheel
python -m build --wheel

# 仅构建 source 包
python -m build --sdist

# 使用 uv 构建
uv build

# 输出目录
dist/
├── your_package-0.1.0-py3-none-any.whl
└── your-package-0.1.0.tar.gz
```

### 3.3 构建产物说明

| 文件类型 | 扩展名 | 用途 |
|---------|--------|------|
| Wheel | `.whl` | 预编译包，安装快速 |
| Source | `.tar.gz` | 源代码包，跨平台 |

### 3.4 包含数据文件

```toml
# pyproject.toml
[tool.setuptools.package-data]
your_package = [
    "py.typed",           # 类型标记
    "*.json",             # JSON 配置文件
    "data/*.csv",         # 数据文件
    "templates/*.html",   # 模板文件
]

[tool.setuptools.data-files]
"share/your-package" = ["config/*.ini"]
```

### 3.5 版本管理

**手动版本:**
```toml
[project]
version = "0.1.0"
```

**使用 setuptools_scm (Git 自动版本):**
```toml
[build-system]
requires = ["setuptools>=61", "setuptools_scm>=8"]
build-backend = "setuptools.build_meta"

[project]
dynamic = ["version"]

[tool.setuptools_scm]
write_to = "src/your_package/_version.py"
```

**版本号规范 (PEP 440):**
- `0.1.0` - 初始版本
- `0.1.0a1` - Alpha 测试版
- `0.1.0b1` - Beta 测试版
- `0.1.0rc1` - 候选发布版
- `0.1.0.post1` - 发布后修订
- `0.1.0.dev1` - 开发版

---

## 4、本地测试

### 4.1 本地安装测试

```bash
# 从 wheel 安装
pip install dist/your_package-0.1.0-py3-none-any.whl

# 从 source 安装
pip install dist/your-package-0.1.0.tar.gz

# 开发模式安装（修改代码立即生效）
pip install -e .

# 包含开发依赖
pip install -e .[dev]
```

### 4.2 验证安装

```bash
# 查看包信息
pip show your-package

# 验证 CLI 命令
your-command --help

# 测试导入
python -c "import your_package; print(your_package.__version__)"
```

### 4.3 运行测试套件

```bash
# 运行所有测试
pytest tests/ -v

# 带覆盖率测试
pytest tests/ -v --cov=your_package

# 生成 HTML 报告
pytest tests/ -v --cov=your_package --cov-report=html
```

### 4.4 代码质量检查

```bash
# 代码格式化检查
black --check src/ tests/

# 代码风格检查
ruff check src/ tests/

# 类型检查
mypy src/

# 格式化代码
black src/ tests/
ruff check --fix src/ tests/
```

---

## 5、发布到 PyPI

### 5.1 注册 PyPI 账号

1. 访问 [https://pypi.org](https://pypi.org)
2. 注册账号
3. 验证邮箱

### 5.2 创建 API Token

1. 登录 PyPI
2. 进入 Account Settings → API Tokens
3. 创建新 Token，设置权限范围
4. 保存 Token（仅显示一次）

### 5.3 配置认证

**方法一：使用 .pypirc 文件**

创建 `~/.pypirc`:
```ini
[distutils]
index-servers =
    pypi
    testpypi

[pypi]
username = __token__
password = pypi-AgEIcHlwaS5vcmc...（你的 Token）

[testpypi]
repository = https://test.pypi.org/legacy/
username = __token__
password = pypi-AgEIcHlwaS5vcmc...（测试 Token）
```

**方法二：使用环境变量**

```bash
export TWINE_USERNAME="__token__"
export TWINE_PASSWORD="pypi-AgEIcHlwaS5vcmc..."
```

**方法三：命令行输入（推荐用于首次）**

```bash
twine upload dist/*
# 会提示输入用户名和密码
```

### 5.4 测试发布（TestPyPI）

```bash
# 上传到测试 PyPI
twine upload --repository testpypi dist/*

# 从测试 PyPI 安装验证
pip install -i https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple your-package
```

### 5.5 正式发布

```bash
# 上传到 PyPI
twine upload dist/*

# 验证上传
twine check dist/*
```

### 5.6 使用 uv 发布

```bash
# 配置 token
export UV_PUBLISH_TOKEN="pypi-AgEIcHlwaS5vcmc..."

# 发布
uv publish

# 发布到测试 PyPI
uv publish --publish-url https://test.pypi.org/legacy/
```

---

## 6、私有仓库部署

### 6.1 使用 GitLab Package Registry

**配置 .pypirc:**
```ini
[gitlab]
repository = https://gitlab.com/api/v4/projects/YOUR_PROJECT_ID/packages/pypi
username = __token__
password = YOUR_GITLAB_TOKEN
```

**上传:**
```bash
twine upload --repository gitlab dist/*
```

**安装:**
```bash
pip install --extra-index-url https://gitlab.com/api/v4/projects/YOUR_PROJECT_ID/packages/pypi --index-url https://pypi.org/simple your-package
```

### 6.2 使用 Azure Artifacts

**配置 .pypirc:**
```ini
[azure]
repository = https://pkgs.dev.azure.com/YOUR_ORG/YOUR_PROJECT/_packaging/YOUR_FEED/pypi/upload/
username = __token__
password = YOUR_AZURE_TOKEN
```

### 6.3 搭建私有 PyPI

**使用 devpi:**
```bash
# 安装 devpi
pip install devpi-server devpi-web

# 启动服务器
devpi-server --start

# 创建用户和索引
devpi user --create username password=xxx
devpi index --create username/dev

# 上传包
devpi use http://localhost:3141/username/dev
devpi upload dist/*
```

---

## 7、打包成可执行文件

### 7.1 PyInstaller

**安装:**
```bash
pip install pyinstaller
```

**打包命令:**
```bash
# 打包成单个 exe
pyinstaller -F main.py

# 打包成单个 exe（无控制台窗口）
pyinstaller -F -w main.py

# 指定图标
pyinstaller -F -i icon.ico main.py

# 包含数据文件
pyinstaller -F --add-data "config.json;." main.py
```

**生成的文件:**
```
dist/
└── main.exe    # 可直接运行的可执行文件
```

### 7.2 PyInstaller  spec 文件配置

```python
# main.spec
from PyInstaller.utils.hooks import collect_submodules

a = Analysis(
    ['main.py'],
    pathex=[],
    binaries=[],
    datas=[('config', 'config')],
    hiddenimports=collect_submodules('your_package'),
    hookspath=[],
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=None,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=None)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='YourApp',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    runtime_tmpdir=None,
    console=False,  # 无控制台窗口
    icon='icon.ico',
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
```

**使用 spec 文件打包:**
```bash
pyinstaller main.spec
```

### 7.3 cx_Freeze

**安装:**
```bash
pip install cx_Freeze
```

**setup.py 配置:**
```python
from cx_Freeze import setup, Executable

build_exe_options = {
    "packages": ["your_package"],
    "include_files": ["config/"],
    "excludes": ["tkinter", "unittest"],
}

setup(
    name="YourApp",
    version="1.0",
    description="Your Application",
    options={"build_exe": build_exe_options},
    executables=[
        Executable(
            "main.py",
            base="Win32GUI",  # Windows GUI 应用
            icon="icon.ico",
        )
    ],
)
```

**构建:**
```bash
python setup.py build
```

### 7.4 Nuitka（高性能编译）

**安装:**
```bash
pip install nuitka
```

**编译命令:**
```bash
# 编译成可执行文件
python -m nuitka --onefile main.py

# 启用所有优化
python -m nuitka --onefile --enable-plugin=all main.py
```

---

## 8、常见问题排查

### 8.1 构建失败

**问题:** `python -m build` 报错

**解决:**
```bash
# 更新构建工具
pip install --upgrade build setuptools wheel

# 清理构建缓存
rm -rf build/ dist/ *.egg-info

# 重新构建
python -m build
```

### 8.2 包导入失败

**问题:** 安装后 import 失败

**解决:**
```bash
# 检查包结构
tree src/your_package

# 确保有 __init__.py
touch src/your_package/__init__.py

# 检查 pyproject.toml 配置
cat pyproject.toml
```

### 8.3 CLI 命令不工作

**问题:** 安装后命令找不到

**解决:**
1. 检查入口点配置：
   ```toml
   [project.scripts]
   your-command = "your_package.cli:main"
   ```

2. 重新安装：
   ```bash
   pip uninstall your-package
   pip install .
   ```

3. 验证安装位置：
   ```bash
   which your-command  # Linux/macOS
   where your-command  # Windows
   ```

### 8.4 发布失败

**问题:** twine upload 报错

**解决:**
```bash
# 检查认证
cat ~/.pypirc

# 使用 token
export TWINE_USERNAME="__token__"
export TWINE_PASSWORD="pypi-..."

# 检查包名是否已存在
pip search your-package  # 或使用网页搜索

# 验证 token 权限
curl -u __token__:pypi-... https://pypi.org/simple/
```

### 8.5 版本号冲突

**问题:** 版本号不能重复上传

**解决:**
```bash
# 修改版本号
# pyproject.toml
version = "0.1.1"

# 或使用自动版本
# git tag v0.1.1
# git push origin v0.1.1
```

---

## 参考资源

- [Python 打包官方指南](https://packaging.python.org/)
- [pyproject.toml 规范](https://peps.python.org/pep-0621/)
- [PyPI 帮助文档](https://pypi.org/help/)
- [setuptools 文档](https://setuptools.pypa.io/)
- [PyInstaller 文档](https://pyinstaller.org/)

---

*文档版本：1.0*
*最后更新：2024 年*
