# WSL2 完全手册

> 整合 WSL2 安装卸载、常用命令速查及常见问题解决方案的完整指南。

---

## 目录

1. [WSL2 安装与卸载](#一wsl2-安装与卸载)
2. [WSL2 常用命令速查](#二wsl2-常用命令速查)
3. [附录](#附录)

---

## 一、WSL2 安装与卸载

### 1.1 前置条件检查

**系统版本要求**

| 系统 | 最低要求 | 检查方法 |
|------|----------|----------|
| Windows 11 | 所有版本 | Win+R 输入 `winver` 查看 |
| Windows 10 | 2004 版（Build 19041）及以上 | Win+R 输入 `winver` 查看 |

**硬件要求**

- **CPU 虚拟化**：必须在 BIOS/UEFI 中启用
- **检查方法**：任务管理器 → 性能 → CPU → 查看"虚拟化"状态

### 1.2 快速安装法（推荐）

适用于 Windows 10 2004+ 和 Windows 11 系统，一键自动安装。

1. **以管理员身份打开 PowerShell**
2. **执行一键安装命令**：
   ```powershell
   wsl --install
   ```
3. **等待安装完成**：此命令自动启用 WSL 和虚拟机平台功能，下载安装 WSL2 内核，安装默认 Linux 发行版（Ubuntu）
4. **重启电脑**完成安装
5. **设置用户名和密码**

### 1.3 手动安装法

**步骤 1：启用 WSL 和虚拟机平台功能**

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

**步骤 2：重启电脑**

**步骤 3：安装 WSL2 内核更新包**

- **x64 架构**：[WSL2 Linux 内核更新包（x64）](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)
- **ARM64 架构**：[WSL2 Linux 内核更新包（ARM64）](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_arm64.msi)

**步骤 4：设置 WSL2 为默认版本**

```powershell
wsl --set-default-version 2
```

**步骤 5：安装 Linux 发行版**

**方法 1：Microsoft Store 安装（推荐）**

打开 Microsoft Store，搜索 Ubuntu、Debian、Kali Linux 等并安装。

**方法 2：命令行安装特定发行版**

```powershell
wsl --list --online
wsl --install -d Ubuntu-22.04
```

### 1.4 离线安装法（终极方案）

**适用场景**

- 网络错误 0x80072efe
- 系统版本较老，不支持 `--web-download` 参数
- Microsoft Store 无法下载
- 防火墙/安全软件阻止连接

**安装步骤**

**第一步：启用 WSL2 功能**

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

执行完后重启电脑，重启后设置默认 WSL2：

```powershell
wsl --set-default-version 2
```

**第二步：下载 Ubuntu 离线包**

```
https://wslstorestorage.blob.core.wslblob/Ubuntu2204-22040.4.202409210.appx
```

保存到 D 盘根目录。

**第三步：安装离线包**

方法 A：双击安装（最简单）

方法 B：命令行安装

```powershell
cd D:\
Add-AppxPackage .\Ubuntu2204-22040.4.202409210.appx
```

**第四步：初始化 Ubuntu**

1. 打开开始菜单 → 找到 **Ubuntu 22.04 LTS** 并启动
2. 等待几秒自动解压配置
3. 设置 **Linux 用户名**（英文小写）+ **密码**

### 1.5 验证安装结果

```powershell
wsl --list --verbose
```

**成功输出示例**：

```
  NAME      STATE           VERSION
* Ubuntu    Running         2
```

### 1.6 进阶配置

**更新 WSL 到最新版本**

```powershell
wsl --update
```

**更改默认安装位置**

```powershell
wsl --export Ubuntu D:\wsl\Ubuntu.tar
wsl --unregister Ubuntu
wsl --import Ubuntu D:\wsl\Ubuntu D:\wsl\Ubuntu.tar --version 2
ubuntu config --default-user 用户名
```

**安装图形界面**

安装 VcXsrv 或 X410，在 WSL 中安装桌面环境，配置 DISPLAY 环境变量。

### 1.7 卸载 WSL

```powershell
wsl --unregister 发行版名称
dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /all /norestart
```

### 1.8 常见问题与解决方案

**错误 0x80072efe：与微软服务器连接终止**

**方案 1：网络重置**

```powershell
netsh winsock reset
netsh int ip reset
ipconfig /flushdns
ipconfig /release
ipconfig /renew
wsl --shutdown
Get-Service LxssManager | Restart-Service
```

完成后重启电脑。

**方案 2：修改 DNS 服务器**

设置为阿里云 `223.5.5.5` 或腾讯云 `119.29.29.29`，备用 `114.114.114.114`。

**方案 3：Web 下载方式**

```powershell
wsl --install -d Ubuntu --web-download
```

**方案 4：离线安装（终极解决）**

**错误 0x80370102：未启用虚拟化**

进入 BIOS/UEFI 启用 CPU 虚拟化，确保 Hyper-V 相关功能已启用。

**错误：WSL 2 需要更新内核组件**

下载并安装官方内核更新包。

**错误 0x80070003：系统版本过低**

升级 Windows 到 2004 版（Build 19041）及以上。

**其他检查项**

- 确认 WSL 功能已启用
- 检查系统时间与互联网同步
- 临时关闭安全软件

---

## 二、WSL2 常用命令速查

### 2.1 基础启停查看

```powershell
# 查看已安装发行版及版本
wsl --list --verbose
wsl -l -v

# 仅列出发行名
wsl -q

# 查看在线可安装系统
wsl --list --online

# 立即关闭所有WSL实例
wsl --shutdown

# 终止指定发行版
wsl -t Ubuntu

# 设置默认启动发行版
wsl -s Ubuntu

# 直接进入默认WSL
wsl

# 以root身份进入指定系统
wsl -u root -d Ubuntu
```

### 2.2 版本管理切换

```powershell
# 设置新建系统默认使用WSL2
wsl --set-default-version 2

# 更改已有发行版版本
wsl --set-version Ubuntu 2
```

### 2.3 导入导出迁移备份

```powershell
# 导出系统为备份压缩包
wsl --export Ubuntu D:\wsl\ubuntu_backup.tar

# 注销删除现有系统
wsl --unregister Ubuntu

# 导入恢复系统到指定目录
wsl --import Ubuntu D:\wsl\ubuntu D:\wsl\ubuntu_backup.tar --version 2

# 导入后设置默认登录用户
ubuntu config --default-user guosen
```

### 2.4 安装卸载

```powershell
# 在线安装指定系统
wsl --install -d Ubuntu

# 离线包安装
Add-AppxPackage 包路径.appx

# 卸载发行版
wsl --unregister Ubuntu
```

### 2.5 内核与更新

```powershell
# 更新WSL内核
wsl --update

# 回滚内核版本
wsl --update --rollback

# 查看WSL运行状态
wsl --status
```

### 2.6 目录互访

**WSL 访问 Windows**

```bash
cd /mnt/c
cd /mnt/d
cd /mnt/c/Users/guosen
```

**Windows 访问 WSL**

资源管理器地址输入 `\\wsl$\Ubuntu`

**自动挂载配置**

```bash
sudo nano /etc/wsl.conf
```

```ini
[automount]
enabled=true
options="metadata,uid=1000,gid=1000,umask=22"
mountFsTab=false
```

保存后执行 `wsl --shutdown` 重启生效。

### 2.7 网络相关

```powershell
wsl --shutdown
wsl hostname -I
```

WSL 内查看网卡：

```bash
ip addr
```

### 2.8 忘记密码

```powershell
wsl -u root
passwd 用户名
```

### 2.9 日常快捷操作

```bash
# WSL内用VSCode打开当前目录
code .

# 查看系统发行信息
lsb_release -a

# 查看内核版本
uname -r
```

---

## 附录

### A. 参考资料

- [WSL 官方文档](https://learn.microsoft.com/zh-cn/windows/wsl/)

### B. 安装方式对比

| 安装方式 | 适用场景 | 推荐度 |
|----------|----------|--------|
| 快速安装 | 系统版本新、网络良好 | ⭐⭐⭐⭐⭐ |
| 手动安装 | 自定义发行版需求 | ⭐⭐⭐⭐ |
| 离线安装 | 网络问题、旧版系统 | ⭐⭐⭐⭐⭐ |

---

> 文档生成时间：2026-05-22
> 文档版本：v1.0
