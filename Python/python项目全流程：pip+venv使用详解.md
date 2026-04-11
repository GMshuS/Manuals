下面给你一份**Python + pip + venv 从入门到全流程实战**的完整指南，包含：
创建环境 → 开发 → 包管理 → 测试 → 打包 → 发布，全部用**可直接复制执行**的实例。
默认环境：**Windows / Linux / macOS 通用**，以 Python 3.8+ 为例。

---

# 一、基础概念
- **venv**：Python 内置虚拟环境工具，隔离项目依赖，避免版本冲突。
- **pip**：Python 官方包管理器，用于安装、升级、卸载第三方库。
- **虚拟环境核心作用**：每个项目一套独立依赖，互不干扰。

---

# 二、创建 & 激活虚拟环境（venv）
## 1. 创建虚拟环境
进入项目文件夹后执行：

```bash
# Windows
python -m venv .venv

# Linux / macOS
python3 -m venv .venv
```

会生成一个 `.venv` 文件夹，包含独立 Python 解释器 + pip。

## 2. 激活虚拟环境
### Windows
```bash
.venv\Scripts\Activate.ps1
```

### Linux / macOS
```bash
source .venv/bin/activate
```

激活成功后，命令行前缀会出现：
```
(.venv) C:\your\project>
```

## 3. 退出虚拟环境
```bash
deactivate
```

---

# 三、pip 包管理（开发阶段）

## 1. 安装加速（解决国内下载慢）
**临时换源（单次生效）**

```bash
# 清华源（推荐）
pip install requests -i https://pypi.tuna.tsinghua.edu.cn/simple
# 阿里源
pip install requests -i https://mirrors.aliyun.com/pypi/simple/
```

**永久换源（一劳永逸）**
在激活的虚拟环境中执行：
```bash
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```

> 配置会保存在虚拟环境内，不影响系统 Python，完美隔离。

## 2. 安装包
**基础安装**
```bash
pip install requests
pip install flask==2.3.3  # 指定版本
pip install django>=4.2   # 最低版本
```

**从 requirements.txt 批量安装**

```bash
# 从 requirements.txt 安装
pip install -r requirements.txt
```

## 3. 查看已安装包
```bash
pip list
pip freeze
```

## 4. 导出依赖清单（最重要）
```bash
pip freeze > requirements.txt
```

生成 `requirements.txt`，内容类似：
```
Flask==2.3.3
requests==2.31.0
```

## 5. 升级 & 卸载包
```bash
pip install --upgrade requests
pip uninstall requests
```

## 6. 清理无用依赖
```bash
pip autoremove  # pip 23.1+ 支持
```

---

# 四、完整开发流程示例（实战项目）
我们做一个简单的 Python 项目：
项目名：`my_demo`
功能：一个简单的 HTTP 接口 + 工具函数 + 单元测试

## 项目结构
```
.venv/
├── bin/                # 可执行文件目录（Windows 特有的命名，对应 Linux 的 bin/）
│   ├── activate        # 激活环境的脚本（Linux 格式，Windows 也兼容）
│   ├── Activate.ps1    # Windows PowerShell 激活脚本（重点！）
│   ├── pip.exe         # pip 可执行文件
│   ├── pip3.10.exe     # 对应 Python 3.10 的 pip
│   ├── pip3.exe        # pip3 软链接
│   ├── python.exe      # Python 解释器
│   ├── python3.10.exe # Python 3.10 解释器
│   ├── python3.exe     # python3 软链接
│   ├── python3w.exe   # 无窗口模式 Python（用于后台运行）
│   └── pythonw.exe    # 旧版无窗口 Python 软链接
├── include/            # C 头文件目录（编译扩展库用）
├── lib/                # 库文件目录
│   └── python3.10/
│       └── site-packages/  # 第三方包安装目录（核心！）
│           ├── _distutils_hack/
│           ├── pip-23.0.1.dist-info/  # pip 自身的元数据
│           ├── pkg_resources/
│           ├── setuptools/
│           ├── setuptools-65.5.0.dist-info/
│           └── distutils-precedence.pth
└── pyvenv.cfg         # 虚拟环境配置文件（记录 Python 路径、版本等）
├── src/
│   └── myapp/
│       ├── __init__.py
│       ├── utils.py     # 工具函数
│       └── api.py       # Flask 接口
├── tests/
│   ├── __init__.py
│   └── test_utils.py    # 测试
├── requirements.txt     # 依赖
└── pyproject.toml      # 打包配置
```

## 1. 初始化环境
```bash
mkdir my_demo
cd my_demo
python -m venv .venv
# 激活环境后
pip install flask pytest
pip freeze > requirements.txt
```

## 2. 写业务代码
`src/myapp/utils.py`
```python
def add(a: int, b: int) -> int:
    return a + b
```

`src/myapp/api.py`
```python
from flask import Flask
from .utils import add

app = Flask(__name__)

@app.get("/")
def index():
    return {"msg": "hello", "add(1,2)": add(1,2)}

if __name__ == "__main__":
    app.run(debug=True)
```

## 3. 虚拟环境下调试

你现在的环境：
- Windows
- 已创建 `.venv` 虚拟环境
- 结构是 `.venv/bin/python.exe`

我分两种最常用场景讲：
1. **命令行直接调试（最简单）**
2. **VSCode 图形化调试（最舒服）**

### 3.1 方法1：命令行调试（最简单、万能）
Python 自带内置调试器 `pdb`，**不用装任何工具**。

**步骤一：先确保虚拟环境已激活**
所有调试**必须在激活的虚拟环境里**，否则会用系统 Python，导致包找不到。

**激活命令（你的结构专用）**

PowerShell / VSCode 终端：
```powershell
.venv\bin\Activate.ps1
```

出现 **(.venv)** 代表成功：
```
(.venv) PS C:\project>
```

**步骤二：在代码里加一行断点**

在你想停下来的地方加：
```python
breakpoint()  # Python 3.7+ 自带
```

例子：
```python
def add(a, b):
    breakpoint()  # 程序会停在这里
    return a + b

result = add(1, 2)
print(result)
```

**步骤三：虚拟环境里运行**
```powershell
python test.py
```

程序会停在断点，进入调试模式。

**扩展：常用调试命令**
- `n` → 下一步（不进入函数）
- `s` → 进入函数
- `l` → 查看当前代码
- `p 变量名` → 打印变量
- `c` → 继续运行
- `q` → 退出调试

> 非常适合**快速排查问题**。

### 3.3 方法2：VSCode 图形化调试（最推荐）
点一下就能断点、看变量、单步执行，**虚拟环境专用配置**。

**步骤一：先确保Python插件已安装**
若未安装，则在VSCode的插件市场搜索`Python Debugger`进行安装。

**步骤二：VSCode 选择虚拟环境的 Python**
右下角点击显示Python版本（如：`3.10.12`）的地方 →选择：`.venv\bin\python.exe`

VSCode 会自动识别你的虚拟环境。

**步骤三：点代码行号左侧 → 出现红点（断点）**

**步骤四：按 F5 开始调试**
搞定！

你会看到：
- 变量实时显示
- 单步跳过
- 单步进入
- 重启/停止
- 控制台交互

**这就是虚拟环境下最舒服的调试方式。**

---

## 4. 运行开发服务
```bash
python src/myapp/api.py
```

访问：http://127.0.0.1:5000


---

# 五、测试流程（pytest + venv）
## 1. 写测试用例
`tests/test_utils.py`
```python
from myapp.utils import add

def test_add():
    assert add(1, 2) == 3
    assert add(-1, 1) == 0
```

## 2. 运行测试
```bash
pytest tests/ -v
```

正常输出：
```
test_utils.py::test_add PASSED
```

---

# 六、打包 & 发布全流程（现代标准）
Python 现代打包工具链：
- `build`：构建 wheel/sdist 包
- `twine`：上传到 PyPI
- `pyproject.toml`：统一配置文件

## 1. 安装打包工具
```bash
pip install build twine
```

## 2. 编写 pyproject.toml

### 2.1 pyproject.toml 结构

```toml
[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

[project]
name = "my_demo_project"
version = "0.1.0"
authors = [{ name="你的名字", email="your@email.com" }]
description = "一个使用 venv + pip 的示例项目"
requires-python = ">=3.8"

# 运行时必须的依赖
dependencies = [
  "requests>=2.30.0",
  "flask>=2.3.0",
]

# 开发时才需要的依赖（测试、格式化、打包）
[project.optional-dependencies]
dev = [
  "pytest>=7.0",
  "black>=23.0",
  "build>=0.10.0",
  "twine>=4.0.0",
]
```

### 2.2 生成 pyproject.toml
**方法1：手动新建（最通用、最推荐）**
1. 在项目根目录新建文件：
   ```
   你的项目/
     └── pyproject.toml
   ```
2. 把上面模板粘贴进去，改改名字、版本、依赖即可。

**方法2：使用 `setuptools` 生成**

```bash
pip install setuptools --upgrade
```

然后执行：

```bash
python -m setup.py init
```
> 会引导你一步步生成。

**方法3：使用 `poetry` 生成（更现代化工具）**

```bash
pip install poetry
poetry init
```
> 会自动生成完整的 `pyproject.toml`，还自带虚拟环境管理。

## 3. 构建包
```bash
python -m build
```

生成：
```
dist/
├── my_demo-0.1.0.tar.gz
└── my_demo-0.1.0-py3-none-any.whl
```

## 4. 测试本地安装（验证包可用）
```bash
pip install dist/my_demo-0.1.0-py3-none-any.whl
```

然后在任意地方 import：
```python
from myapp.utils import add
print(add(2,3))
```

## 5. 上传到 PyPI（公开发布）
先去 https://pypi.org 注册账号。

```bash
twine upload dist/*
```

输入用户名、密码（或 API Token）即可发布。

发布后，别人就可以：
```bash
pip install my_demo
```

---

# 七、requirements.txt团队协作最佳实践
1. **永远不上传 .venv 到 Git**
   创建 `.gitignore`：
   ```
   .venv/
   __pycache__/
   *.pyc
   dist/
   build/
   *.egg-info/
   .pytest_cache/
   ```

2. 新同事拉代码后：
   ```bash
   python -m venv .venv
   # 激活环境
   pip install -r requirements.txt
   pip install -e .[test]  # 开发模式安装 + 测试依赖
   ```

3. 开发模式安装（修改代码立即生效）
   ```bash
   pip install -e .
   ```
---

# 八、打包离线包

针对你这种**内网、无网络、不能联网**的场景，最稳妥、最常用的方案就是：

**在有网机器 → 下载所有依赖包（.whl/.tar.gz）→ 打包整个环境 → 拷贝到离线电脑 → 直接运行**

我给你一套**一步一步、零坑、可直接照做**的完整流程，Windows/Linux 通用。

## 核心思路
1. 有网电脑：用 `venv` + `pip download` 把**项目 + 所有依赖包**全部离线下载好
2. 打包成一个文件夹
3. 拷贝到无网电脑
4. 直接安装、运行

---

## 1. 在【能联网的电脑】上操作

**步骤1：创建并激活虚拟环境（必须）**
```bash
python -m venv .venv
```

Windows 激活：
```bash
.venv\Scripts\activate
```

Linux/macOS：
```bash
source .venv/bin/activate
```

**步骤2：安装你项目需要的所有包**
```bash
pip install flask requests pandas numpy  # 你自己的依赖
```

**步骤3：导出依赖列表**
```bash
pip freeze > requirements.txt
```

**步骤4：离线下载所有依赖包（关键步骤）**
新建一个文件夹存放离线包：
```bash
mkdir packages
```

批量下载所有 `.whl` 离线安装包：
```bash
pip download -r requirements.txt -d packages
```

执行完后，`packages/` 里会有一堆：
- `requests-2.31.0-py3-none-any.whl`
- `Flask-3.0.2-py3-none-any.whl`
等等

这些就是**完全离线安装包**。

## 2. 把整个文件夹复制到离线电脑
最终你要拷走的结构是这样：
```
your_project/
├── .venv/             （可选，推荐拷）
├── packages/          （必须，所有离线依赖）
├── your_code/         你的代码
├── main.py
└── requirements.txt
```

**情况 1：你拷了整个 `.venv`（最简单）**
直接激活环境：
```bash
.venv\Scripts\activate
```

然后直接运行：
```bash
python main.py
```

完事，不需要任何安装。

> 适用：
> - 两台电脑系统一样（Win10 → Win10，同架构）
> - Python 版本完全相同（比如都是 3.10.x）

**情况 2：没拷 venv，只拷了代码 + packages**

在离线机上：

**新建虚拟环境（必须）**
```bash
python -m venv .venv
.venv\Scripts\activate
```

**离线批量安装所有包**
```bash
pip install --no-index --find-links=packages -r requirements.txt
```

> 参数说明：
> - `--no-index`：不去 PyPI 联网
> - `--find-links=packages`：只从本地 packages 文件夹找包

安装完成后直接运行：
```bash
python main.py
```

---

# 九、打包成单个 exe（给不懂 Python 的人用）

如果你希望**对方电脑连 Python 都不用装**，直接双击运行，用：
**PyInstaller**

## 1. 有网机安装
```bash
pip install pyinstaller
```

## 2. 打包成单 exe
```bash
pyinstaller -F -w main.py
```

- `-F`：打包成**单个 exe**
- `-w`：不弹出黑窗口（GUI 用）

生成的文件在：
```
dist/main.exe
```

直接把这个 exe 拷贝到离线电脑，**双击就能运行**。

---

# 十、常见 venv + pip 问题速查
## 1. 换源加速（解决下载慢）
```bash
# 临时
pip install requests -i https://pypi.tuna.tsinghua.edu.cn/simple

# 永久
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```

## 2. 多个 Python 版本冲突
始终用：
```bash
python -m pip install ...
```
避免系统 pip 与虚拟环境 pip 混淆。

## 3. 重建环境
```bash
deactivate
rm -rf .venv  # 或手动删除
python -m venv .venv
# 激活后
pip install -r requirements.txt
```

---

# 十一、全流程命令速览（一页总结）
```bash
# 创建
python -m venv .venv

# 激活
# Windows: .venv\Scripts\activate
# macOS/Linux: source .venv/bin/activate

# 安装
pip install flask pytest
pip freeze > requirements.txt
pip install -r requirements.txt

# 测试
pytest tests/ -v

# 打包
pip install build twine
python -m build
twine upload dist/*
```