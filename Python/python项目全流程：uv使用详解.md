**uv** 是由 Rust 编写的**超快 Python 包与环境管理工具**，可一站式替代 `pip`/`venv`/`pyenv`/`pip-tools`/`poetry`/`twine` 等，速度极快、全平台一致。以下从 **安装、命令详解、项目全流程实战** 三方面完整讲解。

---

## 一、uv 安装与命令详解
### 1.1 安装（全平台）
#### Windows（PowerShell）
```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

#### macOS / Linux
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

#### pip 安装（备用）
```bash
pip install uv
```

#### 验证安装
```bash
uv --version
# 输出类似：uv 0.11.3 (hexsha)
```

### 1.2 核心命令分类详解
#### 1）Python 版本管理（替代 pyenv）
```bash
# 列出所有可安装版本
uv python list

# 安装指定版本（自动管理、不污染系统）
uv python install 3.12    # 安装 3.12 最新版
uv python install 3.11.8  # 安装精确版本

# 查看已安装
uv python list --installed

# 设置项目本地 Python 版本（生成 .python-version）
uv python pin 3.12
```

#### 2）虚拟环境管理（替代 venv）
```bash
# 创建虚拟环境（默认 .venv）
uv venv

# 创建并指定 Python 版本
uv venv --python 3.11

# 激活（Windows/macOS/Linux 通用）
uv activate
# 或手动：
# Windows: .venv\Scripts\activate
# macOS/Linux: source .venv/bin/activate

# 退出
deactivate

# 删除虚拟环境
rm -rf .venv
```

#### 3）包依赖管理（替代 pip/pip-tools）
```bash
# 安装生产依赖（自动写入 pyproject.toml + 生成 uv.lock）
uv add requests
uv add "pandas>=2.0,<3.0"  # 指定版本范围
uv add requests pandas     # 批量安装

# 安装开发依赖（--dev，仅开发环境使用）
uv add --dev pytest pytest-cov

# 卸载依赖
uv remove requests
uv remove --dev pytest

# 查看依赖树
uv tree

# 同步环境（按 pyproject.toml/uv.lock 安装所有依赖）
uv sync

# 锁定依赖（更新 uv.lock）
uv lock

# 导出为 requirements.txt（兼容旧项目）
uv export --format requirements.txt --output requirements.txt
```

#### 4）运行与脚本（替代 python / python -m）
```bash
# 运行脚本（自动激活虚拟环境）
uv run python main.py
uv run python -c "print('hello')"

# 运行包命令
uv run pytest tests/
uv run uvicorn main:app
```

#### 5）打包与发布（替代 setuptools/wheel/twine）
```bash
# 构建：生成 dist/xxx.whl + .tar.gz
uv build

# 仅构建 wheel（推荐）
uv build --wheel

# 发布到 PyPI（需配置账号）
uv publish
```

#### 6）工具与自我管理
```bash
# 全局安装 CLI 工具（替代 pipx）
uv tool install ruff
uv tool run ruff check .

# 自我更新
uv self update

# 管理缓存
uv cache clean
```

---

## 二、项目全流程实战（开发 → 包管理 → 测试 → 打包发布）
以一个名为 `uv-demo` 的 Python 包项目为例。

### 2.1 初始化项目
```bash
# 1. 创建并进入目录
mkdir uv-demo && cd uv-demo

# 2. uv 初始化（生成标准结构）
uv init --lib
```

生成结构：
```
uv-demo/
├── src/
│   └── uv_demo/       # 包目录（自动命名）
│       ├── __init__.py
│       └── core.py    # 业务代码
├── tests/
│   └── test_core.py   # 测试文件
├── .gitignore
├── .python-version    # 锁定 Python 版本
└── pyproject.toml     # 项目配置（核心）
```

### 2.2 完善 pyproject.toml（项目元数据）
```toml
[project]
name = "uv-demo"
version = "0.1.0"
description = "uv 管理的 Python 项目示例"
long_description = file: "README.md"
authors = [{ name = "Your Name", email = "you@example.com" }]
requires-python = ">=3.10"
dependencies = [
  "requests>=2.31.0",  # 生产依赖
]

[project.scripts]
# 注册 CLI 命令：安装后可直接运行 uv-demo-cli
uv-demo-cli = "uv_demo.core:main"

[tool.uv]
dev-dependencies = [
  "pytest>=7.0",       # 测试依赖
  "ruff>=0.1.0",       # 代码检查
]

[build-system]
requires = ["uv>=0.10"]
build-backend = "uv.build.api"
```

### 2.3 开发：编写代码
`src/uv_demo/core.py`：
```python
import requests

def greet(name: str) -> str:
    return f"Hello, {name}!"

def fetch_web() -> str:
    resp = requests.get("https://httpbin.org/get")
    return resp.json()["origin"]

def main():
    print(greet("uv-user"))
    print("Your IP:", fetch_web())

if __name__ == "__main__":
    main()
```

### 2.4 包管理：安装依赖
```bash
# 安装所有生产+开发依赖
uv sync

# 查看已安装
uv pip list
```

### 2.5 测试：编写 & 运行
`tests/test_core.py`：
```python
from uv_demo.core import greet

def test_greet():
    assert greet("test") == "Hello, test!"
```

运行测试：
```bash
# pytest 一般是开发时用的测试工具，不是生产代码依赖，所以用 --dev 安装
uv add --dev pytest

# 自动激活环境、运行 pytest
uv run pytest tests/ -v
```

### 2.6 运行项目
```bash
# 方式1：直接运行模块
uv run python -m uv_demo.core

# 方式2：运行 CLI 命令（注册后）
uv run uv-demo-cli
```

### 2.7 代码检查（可选）
```bash
# ruff 一般是开发时用的测试工具，不是生产代码依赖，所以用 --dev 安装
uv add --dev ruff

# 检查代码
uv run ruff check src/
```

### 2.8 打包（构建分发）
```bash
# 构建：生成 dist/
uv build

# 输出：
# dist/uv_demo-0.1.0-py3-none-any.whl
# dist/uv-demo-0.1.0.tar.gz
```

### 2.9 本地验证安装
```bash
# 从本地 whl 安装
uv install ./dist/uv_demo-0.1.0-py3-none-any.whl

# 运行 CLI（全局可用）
uv-demo-cli
```

### 2.10 发布到 PyPI（公开）
1. 注册 PyPI 账号：https://pypi.org
2. 配置令牌（`$HOME/.pypirc`）：
   ```ini
   [pypi]
   username = __token__
   password = pypi-xxx-your-token
   ```
3. 发布：
   ```bash
   uv publish
   ```

---

## 三、uv 优势总结
- **极速**：Rust 编写、缓存优化、依赖解析比 pip 快 10–100 倍
- **一站式**：环境/版本/包/构建/发布全搞定，减少工具链
- **确定性**：`uv.lock` 保证环境完全一致
- **兼容性**：兼容 `pyproject.toml`、`requirements.txt`、PyPI 生态
- **跨平台**：Windows/macOS/Linux 行为一致

---

## 四、打包离线包
**在有网机器上打包 → 拷贝到无网机器 → 直接运行，不需要下载任何包**

**步骤 1：导出所有离线依赖（最关键）**
- 1. 先导出所有依赖列表
  ```bash
  uv export --format requirements.txt --output requirements.txt --no-dev
  ```
  会生成 `requirements.txt`，包含**所有精确版本**。

- 2. 创建离线包存放目录
  ```bash
  mkdir vendor
  ```

- 3. 下载所有包的离线安装文件（.whl/.tar.gz）
  ```bash
  uv pip download -r requirements.txt -d vendor
  ```

  ✅ 执行完后：
  `vendor/` 文件夹里就是**全部离线依赖包**，包括 requests、pandas、pytest 等。

**步骤 2：打包你的项目 + 离线依赖**

最终要交付的目录结构如下：
```
your_project_offline/
├── your_code/        # 你的项目代码
├── vendor/           # 所有离线依赖包（刚才下载的）
├── requirements.txt
└── run.py            # 你的入口文件
```

把整个文件夹压缩
```bash
# Windows 右键压缩
# Linux/macOS
zip -r offline.zip your_project_offline/
```

把 `offline.zip` 拷贝到**无网络机器**。

**步骤 3：无网络机器上安装（完全离线）**
- 1. 解压文件
- 2. 创建虚拟环境（不需要联网）
  ```bash
  uv venv .venv
  ```

- 3. **从本地 vendor 目录安装所有依赖（离线安装）**
  ```bash
  uv pip install -r requirements.txt --no-index --find-links=vendor
  ```

> **关键参数解释（必须加）**
> - `--no-index`：**不去 PyPI 下载**
> - `--find-links=vendor`：**只从本地 vendor 文件夹找包**

**步骤 4：运行项目（无网络成功运行）**

```bash
uv run python main.py
```

或者：
```bash
uv run pytest tests/
```

**超级完整版：连 Python 都打包（目标机器连 Python 都没有）**

如果你要在**完全空白机器**运行：

- 1. 下载嵌入式 Python（官网下载 embeddable 包）
- 2. 放到文件夹里
- 3. 用离线 Python + 离线依赖运行

**但 99% 场景不需要这么复杂**，上面的步骤已经满足：
- 有 Python
- 无网络
- 能运行 uv
- 能离线安装包

---

## 五、常见问题（FAQ）
- **Q：uv 与 poetry/pip 区别？**
  A：uv 速度更快、单二进制、无 Python 依赖、命令更简洁；完全兼容 `pyproject.toml`。
- **Q：如何迁移现有项目？**
  A：在项目根目录执行 `uv init` → `uv sync`，自动识别 `requirements.txt`。
- **Q：虚拟环境默认位置？**
  A：项目内 `.venv`，可通过 `UV_PROJECT_ENVIRONMENT` 更改。

---