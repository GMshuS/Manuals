
# Python 包管理工具使用手册

本手册详细介绍 Python 包管理工具 pip 和 uv 的使用方法，包括安装、配置、依赖管理和最佳实践。

---

## 目录

1. [pip 基础使用](#1pip-基础使用)
2. [pip 高级用法](#2pip-高级用法)
3. [uv 现代包管理](#3uv-现代包管理)
4. [依赖管理最佳实践](#4依赖管理最佳实践)
5. [离线包管理](#5离线包管理)
6. [常见问题排查](#6常见问题排查)

---

## 1、pip 基础使用

### 1.1 pip 简介

`pip` 是 Python 官方推荐的包管理工具，用于安装、升级、卸载和管理 Python 包。

### 1.2 安装包

```bash
# 基础安装
pip install requests

# 指定版本
pip install flask==2.3.3

# 版本范围
pip install django>=4.2,<5.0

# 多个包同时安装
pip install requests flask pandas
```

### 1.3 查看包信息

```bash
# 查看已安装的包
pip list

# 查看已安装包（格式输出）
pip freeze

# 查看包的详细信息
pip show requests

# 查看可升级的包
pip list --outdated

# 搜索包
pip search package_name  # 需要 pip-search 插件
```

### 1.4 升级包

```bash
# 升级单个包
pip install --upgrade requests

# 批量升级所有包（谨慎使用）
pip list --outdated | grep -o '^\S*' | xargs -n1 pip install -U

# 升级 pip 本身
pip install --upgrade pip
```

### 1.5 卸载包

```bash
# 卸载单个包
pip uninstall requests

# 卸载多个包
pip uninstall requests flask

# 卸载并确认
pip uninstall -y requests
```

### 1.6 导出依赖清单

```bash
# 导出所有依赖
pip freeze > requirements.txt

# 排除系统包
pip freeze --local > requirements.txt

# 仅导出顶级依赖
pip install pip-chill
pip-chill > requirements.txt
```

### 1.7 从 requirements.txt 安装

```bash
# 从文件安装
pip install -r requirements.txt

# 强制重新安装
pip install -r requirements.txt --force-reinstall

# 忽略已安装的包
pip install -r requirements.txt --ignore-installed
```

---

## 2、pip 高级用法

### 2.1 镜像源配置

**临时使用（单次生效）:**

```bash
# 清华源（推荐）
pip install requests -i https://pypi.tuna.tsinghua.edu.cn/simple

# 阿里源
pip install requests -i https://mirrors.aliyun.com/pypi/simple/

# 中科大源
pip install requests -i https://pypi.mirrors.ustc.edu.cn/simple/
```

**永久配置:**

**Windows - 创建 `%APPDATA%\pip\pip.ini`:**
```ini
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
```

**macOS/Linux - 创建 `~/.pip/pip.conf`:**
```ini
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
```

### 2.2 虚拟环境中的 pip

```bash
# 创建虚拟环境
python -m venv .venv

# 激活虚拟环境
# Windows PowerShell
.venv\Scripts\Activate.ps1
# Linux/macOS
source .venv/bin/activate

# 虚拟环境内的 pip 操作
pip install requests
pip freeze > requirements.txt
```

### 2.3 多 Python 版本管理

```bash
# 指定 Python 版本安装包
python3.10 -m pip install requests
python3.11 -m pip install requests

# 查看所有 Python 版本的 pip
python -m pip --version
python3 -m pip --version
```

### 2.4 开发模式安装

```bash
# 编辑模式安装（修改代码立即生效）
pip install -e .

# 安装开发依赖
pip install -e .[dev]
```

### 2.5 清理无用依赖

```bash
# pip 23.1+ 支持
pip autoremove

# 或使用 pip-autoremove 工具
pip install pip-autoremove
pip-autoremove package_name -y
```

### 2.6 离线安装

```bash
# 下载离线包
pip download requests -d packages

# 离线安装
pip install --no-index --find-links=packages requests
```

---

## 3、uv 现代包管理

### 3.1 uv 简介

`uv` 是由 Astral 开发的超快 Python 包管理工具，使用 Rust 编写，可替代 pip、venv、pip-tools、poetry 等多个工具。

**核心优势:**
- 速度极快（比 pip 快 10-100 倍）
- 单二进制文件，无需 Python
- 一站式管理环境、依赖、打包
- 完全兼容 pip 生态

### 3.2 安装 uv

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

**验证安装:**
```bash
uv --version
```

### 3.3 Python 版本管理

```bash
# 列出所有可安装版本
uv python list

# 安装指定版本
uv python install 3.12
uv python install 3.11.8

# 查看已安装
uv python list --installed

# 设置项目 Python 版本
uv python pin 3.12
```

### 3.4 虚拟环境管理

```bash
# 创建虚拟环境（默认 .venv）
uv venv

# 创建并指定 Python 版本
uv venv --python 3.11

# 激活环境
uv activate
# 或手动激活
# Windows: .venv\Scripts\activate
# Linux/macOS: source .venv/bin/activate

# 退出环境
deactivate

# 删除环境
rm -rf .venv
```

### 3.5 包依赖管理

```bash
# 安装生产依赖
uv add requests
uv add "pandas>=2.0,<3.0"

# 批量安装
uv add requests pandas numpy

# 安装开发依赖
uv add --dev pytest pytest-cov black

# 卸载依赖
uv remove requests
uv remove --dev pytest

# 查看依赖树
uv tree

# 同步环境
uv sync

# 更新锁文件
uv lock
```

### 3.6 运行命令

```bash
# 运行脚本
uv run python main.py

# 运行包命令
uv run pytest tests/ -v
uv run uvicorn main:app

# 运行全局工具
uv tool run ruff check .
```

### 3.7 打包与发布

```bash
# 构建包
uv build

# 仅构建 wheel
uv build --wheel

# 发布到 PyPI
uv publish
```

### 3.8 导出依赖

```bash
# 导出为 requirements.txt
uv export --format requirements.txt --output requirements.txt

# 仅导出生产依赖
uv export --format requirements.txt --no-dev
```

### 3.9 pyproject.toml 配置

```toml
[project]
name = "your-project"
version = "0.1.0"
description = "Your project description"
requires-python = ">=3.10"
dependencies = [
    "requests>=2.31.0",
    "flask>=2.3.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "black>=23.0",
    "ruff>=0.1.0",
]

[tool.uv]
dev-dependencies = [
    "pytest>=7.0",
]
```

---

## 4、依赖管理最佳实践

### 4.1 requirements.txt 管理

**基础版本 (requirements.txt):**
```txt
# 生产依赖
requests==2.31.0
flask==2.3.3
pandas>=2.0,<3.0

# 开发依赖 (requirements-dev.txt)
pytest>=7.0
black>=23.0
ruff>=0.1.0
```

**分层管理:**
```txt
# requirements.txt - 基础依赖
-r requirements-base.txt
-r requirements-dev.txt
-r requirements-prod.txt

# requirements-base.txt - 核心依赖
requests==2.31.0
flask==2.3.3

# requirements-dev.txt - 开发依赖
-r requirements-base.txt
pytest>=7.0
black>=23.0

# requirements-prod.txt - 生产依赖
-r requirements-base.txt
gunicorn>=21.0
```

### 4.2 依赖版本锁定

**使用 uv.lock (推荐):**
```bash
# uv 自动生成锁文件
uv sync

# 锁定文件确保环境一致
cat uv.lock
```

**使用 pip-tools:**
```bash
# 安装 pip-tools
pip install pip-tools

# 创建 requirements.in
echo "requests" > requirements.in
echo "flask" >> requirements.in

# 生成锁定的 requirements.txt
pip-compile requirements.in

# 安装锁定的依赖
pip-sync requirements.txt
```

### 4.3 团队协作流程

1. **新人加入:**
   ```bash
   git clone <repo>
   cd project
   uv venv
   uv activate
   uv sync
   ```

2. **添加新依赖:**
   ```bash
   uv add new-package
   git add pyproject.toml uv.lock
   git commit -m "添加新依赖"
   ```

3. **更新依赖:**
   ```bash
   uv lock --upgrade
   git add uv.lock
   git commit -m "更新依赖"
   ```

### 4.4 依赖清理

```bash
# 检查未使用的依赖
pip install deptry
deptry .

# 检查依赖冲突
pip check

# 清理缓存
pip cache purge
uv cache clean
```

---

## 5、离线包管理

### 5.1 pip 离线打包

**步骤 1：在有网机器下载依赖**

```bash
# 导出依赖列表
pip freeze > requirements.txt

# 创建离线包目录
mkdir packages

# 下载所有离线包
pip download -r requirements.txt -d packages
```

**步骤 2：打包并传输**

```
project/
├── packages/          # 所有离线依赖包
├── requirements.txt   # 依赖列表
├── src/              # 源代码
└── main.py           # 入口文件
```

**步骤 3：在离线机器安装**

```bash
# 创建虚拟环境
python -m venv .venv
.venv\Scripts\activate

# 离线安装
pip install --no-index --find-links=packages -r requirements.txt
```

### 5.2 uv 离线打包

**步骤 1：导出依赖**

```bash
# 导出依赖列表
uv export --format requirements.txt --output requirements.txt

# 创建离线包目录
mkdir vendor

# 下载离线包
uv pip download -r requirements.txt -d vendor
```

**步骤 2：离线安装**

```bash
# 创建环境
uv venv .venv

# 离线安装
uv pip install -r requirements.txt --no-index --find-links=vendor
```

### 5.3 完整环境打包

```bash
# 1. 创建并激活虚拟环境
python -m venv .venv
.venv\Scripts\activate

# 2. 安装所有依赖
pip install -r requirements.txt

# 3. 打包整个目录
# 压缩 .venv + 代码
# 在目标机器直接激活使用
```

---

## 6、常见问题排查

### 6.1 安装超时/失败

**问题:** pip install 超时或连接失败

**解决:**
```bash
# 使用国内镜像
pip install requests -i https://pypi.tuna.tsinghua.edu.cn/simple

# 增加超时时间
pip install requests --default-timeout=1000

# 使用信任主机
pip install requests --trusted-host pypi.tuna.tsinghua.edu.cn
```

### 6.2 依赖冲突

**问题:** 安装时报依赖冲突错误

**解决:**
```bash
# 查看冲突
pip check

# 强制重新安装
pip install package_name --force-reinstall

# 忽略依赖（不推荐）
pip install package_name --no-deps
```

### 6.3 权限问题

**问题:** 安装时报权限错误

**解决:**
```bash
# 使用 --user 安装到用户目录
pip install --user package_name

# 使用虚拟环境（推荐）
python -m venv .venv
source .venv/bin/activate
pip install package_name
```

### 6.4 找不到包

**问题:** 包已安装但 import 失败

**解决:**
```bash
# 确认当前 Python 环境
which python
python -c "import sys; print(sys.executable)"

# 确认包安装位置
pip show package_name

# 重新安装包
pip uninstall package_name
pip install package_name
```

### 6.5 uv 常见问题

**问题 1: uv 命令找不到**

```bash
# 确认 uv 安装路径
which uv  # Linux/macOS
where uv  # Windows

# 添加到 PATH
export PATH="$HOME/.cargo/bin:$PATH"
```

**问题 2: uv sync 失败**

```bash
# 删除锁文件重新生成
rm uv.lock
uv sync

# 清理缓存
uv cache clean
```

---

## 7、工具对比总结

| 功能 | pip | uv |
|------|-----|-----|
| 安装包 | ✅ | ✅ |
| 虚拟环境 | ❌ (需 venv) | ✅ |
| Python 版本管理 | ❌ (需 pyenv) | ✅ |
| 依赖锁定 | ❌ (需 pip-tools) | ✅ |
| 构建打包 | ❌ (需 setuptools) | ✅ |
| 发布 | ❌ (需 twine) | ✅ |
| 速度 | 慢 | 极快 |
| 兼容性 | 完全兼容 | 完全兼容 |

---

## 参考资源

- [pip 官方文档](https://pip.pypa.io/)
- [uv 官方文档](https://docs.astral.sh/uv/)
- [PyPI 包仓库](https://pypi.org/)
- [pip-tools 文档](https://github.com/jazzband/pip-tools)

---

*文档版本：1.0*
*最后更新：2024 年*
