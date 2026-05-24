# WSL2 Python 环境配置与使用手册

> WSL2 (Ubuntu) 下 Python 环境配置的完整指南，涵盖安装配置、虚拟环境管理、VS Code 远程开发及常见问题。

---

## 目录

1. [环境准备与安装](#一环境准备与安装)
2. [Python 虚拟环境管理](#二python-虚拟环境管理)
3. [VS Code 远程开发](#三vs-code-远程开发)
4. [常用命令速查](#四常用命令速查)

---

## 一、环境准备与安装

### 1.1 前置检查

WSL2 的 Ubuntu 默认自带 Python3，先验证：

```bash
python3 --version
```

出现版本号（如 3.10.x）说明系统自带 Python 正常。

### 1.2 安装核心工具

安装 **pip（包管理器）** 和 **venv（虚拟环境）**，这是 Python 开发标配：

```bash
sudo apt update -y
sudo apt install python3-pip python3-venv -y
```

验证安装成功：

```bash
pip3 --version
```

### 1.3 配置 pip 国内源

永久配置阿里云镜像，解决下载慢/超时问题：

```bash
mkdir -p ~/.pip
cat > ~/.pip/pip.conf << EOF
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
trusted-host = mirrors.aliyun.com
EOF
```

### 1.4 快捷优化：`python` 命令别名

默认需输入 `python3`，配置软链接后可直接使用 `python`：

```bash
sudo ln -s /usr/bin/python3 /usr/bin/python
```

之后可用：

```bash
python --version
python 脚本.py
```

### 1.5 安装常用 Python 库

激活虚拟环境后一键安装常用工具（推荐在虚拟环境内操作）：

```bash
pip install numpy pandas matplotlib pillow openpyxl requests
```

---

## 二、Python 虚拟环境管理

### 2.1 创建与使用

**创建虚拟环境**

```bash
python3 -m venv venv
```

**激活虚拟环境**

```bash
source venv/bin/activate
```

激活成功后，终端前面会出现 `(venv)` 标识。

**安装包（仅当前环境生效）**

```bash
pip install flask django jupyter requests
```

**退出虚拟环境**

```bash
deactivate
```

**删除虚拟环境**

直接删除文件夹即可：

```bash
rm -rf venv
```

### 2.2 关键规则：虚拟环境存放位置

**核心规则：代码可放在 Windows 盘（`/mnt/`），虚拟环境必须放在 WSL 本地文件系统（`~` 家目录）。**

NTFS 文件系统不支持 Linux 的权限和软链接，将虚拟环境放在 `/mnt/` 下会导致安装 Python 包时权限报错（Operation not permitted）。

推荐工作流程：

```bash
# 虚拟环境放在 WSL 家目录
cd ~
python3 -m venv .venv
source ~/.venv/bin/activate

# 代码文件继续留在 Windows 盘（方便 Windows 编辑和 Git 管理）
cd /mnt/e/Git/GMshuS/项目目录
python3 your_script.py
```

### 2.3 常见错误与解决方案

**错误：虚拟环境放在 `/mnt/` 下导致 Operation not permitted**

- 原因：NTFS 文件系统不兼容 Linux 权限/软链接
- 解决：删除 `/mnt/` 下的 `.venv`，在 `~` 家目录重新创建

```bash
rm -rf /mnt/e/项目路径/.venv
cd ~
python3 -m venv .venv
source ~/.venv/bin/activate
```

**错误：未激活虚拟环境导致 pip 安装失败**

- 原因：新版 Ubuntu/WSL 强制禁止系统 pip 装包
- 解决：执行 `pip install` 前必须先激活虚拟环境
- 激活标志：命令行开头出现 `(.venv)`

```bash
source ~/.venv/bin/activate
pip install 包名
```

---

## 三、VS Code 远程开发

### 3.1 配置 Remote - WSL

1. 在 Windows 端 VS Code 中安装 **Remote - WSL** 插件
2. 在 WSL 终端进入项目文件夹后执行：

```bash
code .
```

3. VS Code 会自动识别 WSL 中的 Python 环境

### 3.2 选择 Python 解释器

1. 打开 VS Code 命令面板（`Ctrl+Shift+P`）
2. 选择 **Python: Select Interpreter**
3. 选中虚拟环境路径 `.venv/bin/python`

即可直接在 WSL 环境中运行、调试 Python 代码。

---

## 四、常用命令速查

### 4.1 Python 与 pip

| 功能 | 命令 |
|------|------|
| 查看 Python 版本 | `python3 --version` |
| 安装包 | `pip install 包名` |
| 卸载包 | `pip uninstall 包名` |
| 查看已安装包 | `pip list` |
| 导出依赖清单 | `pip freeze > requirements.txt` |
| 安装清单依赖 | `pip install -r requirements.txt` |

### 4.2 虚拟环境

| 功能 | 命令 |
|------|------|
| 创建虚拟环境 | `python3 -m venv 环境名` |
| 激活虚拟环境 | `source 环境名/bin/activate` |
| 退出虚拟环境 | `deactivate` |
| 删除虚拟环境 | `rm -rf 环境名` |

---

## 附录

### A. 参考资料

- [WSL 官方文档](https://learn.microsoft.com/zh-cn/windows/wsl/)
- [Python venv 官方文档](https://docs.python.org/zh-cn/3/library/venv.html)
- [pip 官方文档](https://pip.pypa.io/en/stable/)

### B. 核心要点

1. WSL2 自带 Python3，只需安装 `pip` 和 `venv`
2. **必须使用虚拟环境**，这是 Python 开发的最佳实践
3. **虚拟环境放 `~`（WSL 本地），代码放 Windows 盘**
4. 配置国内源，解决下载卡顿问题
5. 配合 VS Code Remote-WSL，开发体验最佳

---

> 文档生成时间：2026-05-22
> 文档版本：v1.0
