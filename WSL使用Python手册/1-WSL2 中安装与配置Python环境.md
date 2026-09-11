我给你整理一份 **WSL2 (Ubuntu) 下 Python 环境 极简+完整配置教程**，所有命令直接复制运行，适配你的环境，**零报错、新手友好**！

---

# 一、前置检查
WSL2 的 Ubuntu **默认自带 Python3**，先验证一下：
```bash
python3 --version
```
出现版本号（如 3.10.x）说明系统自带 Python 正常。

---

# 二、安装核心工具（必做）
安装 **pip（包管理器）** + **venv（虚拟环境）**，这是 Python 开发标配：
```bash
# 更新软件源
sudo apt update -y
# 安装 pip 和虚拟环境工具
sudo apt install python3-pip python3-venv -y
```

验证安装成功：
```bash
pip3 --version
```

---

# 三、加速配置：pip 国内源（解决下载慢/超时）
永久配置阿里云镜像，比默认源快 10 倍以上：
```bash
# 创建配置目录
mkdir -p ~/.pip
# 写入国内镜像
cat > ~/.pip/pip.conf << EOF
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
trusted-host = mirrors.aliyun.com
EOF
```

---

# 四、核心技能：虚拟环境使用（开发必备！）
**千万不要在系统环境直接装包**，用虚拟环境隔离项目，避免冲突：

### 1. 创建虚拟环境
```bash
# 在当前文件夹创建名为 venv 的虚拟环境
python3 -m venv venv
```

### 2. 激活虚拟环境
```bash
source venv/bin/activate
```
激活成功后，终端前面会出现 `(venv)` 标识

### 3. 安装包（仅当前环境生效）
```bash
# 示例：安装 flask、django、jupyter、requests
pip install flask django jupyter requests
```

### 4. 退出虚拟环境
```bash
deactivate
```

### 5. 删除虚拟环境
直接删除文件夹即可：
```bash
rm -rf venv
```

---

# 五、安装常用 Python 库
激活虚拟环境后，一键安装常用工具：
```bash
pip install numpy pandas matplotlib pillow openpyxl
```

---

# 六、VS Code 远程 WSL 开发 Python（最强组合）
1. Windows 打开 VS Code，安装插件 **Remote - WSL**
2. WSL 终端进入项目文件夹，执行：
   ```bash
   code .
   ```
3. VS Code 会自动识别 WSL 中的 Python 环境
4. 左下角选择解释器 → 选中 `venv/bin/python`

即可直接运行、调试 Python 代码！

---

# 七、快捷优化：让 `python` 命令直接可用
默认需要输 `python3`，配置软链接后直接用 `python`：
```bash
sudo ln -s /usr/bin/python3 /usr/bin/python
```
之后就可以用：
```bash
python --version
python 脚本.py
```

---

# 八、常用命令速查
| 功能 | 命令 |
|------|------|
| 查看 Python 版本 | python3 --version |
| 安装包 | pip install 包名 |
| 卸载包 | pip uninstall 包名 |
| 查看已安装包 | pip list |
| 导出依赖清单 | pip freeze > requirements.txt |
| 安装清单依赖 | pip install -r requirements.txt |

---

### 总结
1. WSL2 自带 Python3，只需装 `pip` 和 `venv`
2. **必须用虚拟环境**，这是 Python 开发的最佳实践
3. 配置国内源，解决下载卡顿问题
4. 配合 VS Code Remote-WSL，开发体验拉满