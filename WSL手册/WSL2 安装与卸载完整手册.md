# WSL2 安装与卸载完整手册

> 本手册整合了 WSL2 的快速安装、手动安装、离线安装等多种方式，以及安装过程中常见问题的解决方案。

---

## 目录

1. [前置条件检查](#一前置条件检查)
2. [快速安装法（推荐）](#二快速安装法推荐)
3. [手动安装法](#三手动安装法)
4. [离线安装法（终极方案）](#四离线安装法终极方案)
5. [验证安装结果](#五验证安装结果)
6. [常见问题与解决方案](#六常见问题与解决方案)
7. [卸载 WSL](#七卸载 wsl)
8. [进阶配置](#八进阶配置可选)

---

## 一、前置条件检查

### 系统版本要求

| 系统 | 最低要求 | 检查方法 |
|------|----------|----------|
| Windows 11 | 所有版本 | Win+R 输入 `winver` 查看 |
| Windows 10 | 2004 版（Build 19041）及以上 | Win+R 输入 `winver` 查看 |

### 硬件要求

- **CPU 虚拟化**：必须在 BIOS/UEFI 中启用
- **检查方法**：任务管理器 → 性能 → CPU → 查看"虚拟化"状态

---

## 二、快速安装法（推荐）

适用于 Windows 10 2004+ 和 Windows 11 系统，一键自动安装。

### 安装步骤

1. **以管理员身份打开 PowerShell**
   - 开始菜单搜索 PowerShell
   - 右键选择"以管理员身份运行"

2. **执行一键安装命令**：
   ```powershell
   wsl --install
   ```

3. **等待安装完成**
   
   此命令会自动完成：
   - 启用 WSL 和虚拟机平台功能
   - 下载安装 WSL2 内核
   - 安装默认 Linux 发行版（Ubuntu）

4. **重启电脑**完成安装

5. **设置用户名和密码**
   - 重启后，Ubuntu 会自动启动
   - 设置 Linux 系统账户（与 Windows 账户独立）

---

## 三、手动安装法

适合有自定义需求的用户。

### 步骤 1：启用 WSL 和虚拟机平台功能

以**管理员身份 PowerShell**执行：

```powershell
# 启用适用于 Linux 的 Windows 子系统
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# 启用虚拟机平台（WSL2 必需）
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

### 步骤 2：重启电脑

完成功能启用后必须重启。

### 步骤 3：安装 WSL2 内核更新包

下载并安装官方内核更新包：

- **x64 架构**：[WSL2 Linux 内核更新包（x64）](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)
- **ARM64 架构**：[WSL2 Linux 内核更新包（ARM64）](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_arm64.msi)

### 步骤 4：设置 WSL2 为默认版本

```powershell
wsl --set-default-version 2
```

### 步骤 5：安装 Linux 发行版

#### 方法 1：Microsoft Store 安装（推荐）

1. 打开 Microsoft Store
2. 搜索 Ubuntu、Debian、Kali Linux 等
3. 选择发行版安装
4. 启动后设置用户名和密码

#### 方法 2：命令行安装特定发行版

```powershell
# 查看可用发行版
wsl --list --online

# 安装指定发行版（如 Ubuntu-22.04）
wsl --install -d Ubuntu-22.04
```

---

## 四、离线安装法（终极方案）

当遇到网络错误（如 0x80072efe）或系统版本较老不支持新命令时，使用离线安装法。

### 适用场景

- 网络错误 0x80072efe（与微软服务器连接意外终止）
- 系统版本较老，不支持 `--web-download` 参数
- Microsoft Store 无法下载
- 防火墙/安全软件阻止连接

### 安装步骤

#### 第一步：启用 WSL2 功能

以**管理员身份 PowerShell**执行：

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

执行完后**重启电脑**。

重启后设置默认 WSL2：

```powershell
wsl --set-default-version 2
```

#### 第二步：下载 Ubuntu 离线包

复制链接到浏览器下载（微软官方）：

**Ubuntu 22.04 离线安装包**：
```
https://wslstorestorage.blob.core.wslblob/Ubuntu2204-22040.4.202409210.appx
```

保存到 **D 盘根目录**。

#### 第三步：安装离线包

**方法 A：双击安装（最简单）**
- 下载完成后，直接双击 `.appx` 文件
- Windows 会自动完成安装

**方法 B：命令行安装**

```powershell
cd D:\
Add-AppxPackage .\Ubuntu2204-22040.4.202409210.appx
```

#### 第四步：初始化 Ubuntu

1. 打开开始菜单 → 找到 **Ubuntu 22.04 LTS** 并启动
2. 等待几秒自动解压配置
3. 设置 **Linux 用户名**（英文小写）+ **密码**（输入不显示）

```
Enter new UNIX username: guosen
New password:
Retype new password:
```

---

## 五、验证安装结果

### 检查 WSL 版本

以**管理员身份 PowerShell**执行：

```powershell
wsl --list --verbose
```

**成功输出示例**：
```
  NAME      STATE           VERSION
* Ubuntu    Running         2
```

**VERSION 列显示 2** 表示 WSL2 安装成功！

### 启动 Linux 发行版

- 开始菜单搜索已安装的发行版名称（如 Ubuntu）
- 或命令行输入发行版名称（如 `ubuntu`）

---

## 六、常见问题与解决方案

### 错误 0x80072efe：与微软服务器连接终止

**原因**：网络不稳定/代理/VPN 拦截、DNS 解析失败、防火墙阻止

**解决方案**：

#### 方案 1：网络重置（必做）

```powershell
# 关闭 VPN/代理，重置网络设置
netsh winsock reset
netsh int ip reset
ipconfig /flushdns
ipconfig /release
ipconfig /renew

# 重启 WSL 服务
wsl --shutdown
Get-Service LxssManager | Restart-Service
```

完成后**重启电脑**，再尝试安装。

#### 方案 2：修改 DNS 服务器

1. 控制面板 → 网络和共享中心 → 当前网络连接 → 属性
2. 选择 Internet 协议版本 4 (TCP/IPv4) → 属性
3. 勾选"使用下面的 DNS 服务器地址"，输入：
   - 首选 DNS：`223.5.5.5`（阿里云）或 `119.29.29.29`（腾讯云）
   - 备用 DNS：`114.114.114.114`
4. 确定后，执行 `ipconfig /flushdns` 并重启电脑

#### 方案 3：Web 下载方式（适用于新版系统）

```powershell
wsl --install -d Ubuntu --web-download
```

#### 方案 4：离线安装（终极解决）

参考 [离线安装法](#四离线安装法终极方案)

---

### 错误 0x80370102：未启用虚拟化

**原因**：BIOS/UEFI 中未启用 CPU 虚拟化

**解决方案**：
1. 进入 BIOS/UEFI 启用 CPU 虚拟化
2. 确保 Hyper-V 相关功能已启用

---

### 错误：WSL 2 需要更新内核组件

**原因**：未安装内核更新包

**解决方案**：
下载并安装官方内核更新包：
- [x64 版本](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)
- [ARM64 版本](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_arm64.msi)

---

### 错误 0x80070003：系统版本过低

**原因**：Windows 版本低于 2004

**解决方案**：升级 Windows 到 2004 版（Build 19041）及以上

---

### 忘记 Linux 密码

**解决方案**：

```powershell
# 以 root 用户启动
wsl -u root

# 重置密码
passwd 用户名
```

---

### 其他检查项

1. **确认 WSL 功能已启用**：
   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```

2. **检查系统时间**：确保 Windows 时间与互联网时间同步，避免 TLS 证书验证失败

3. **临时关闭安全软件**：部分杀毒软件会拦截 WSL 下载

---

## 七、卸载 WSL

### 卸载发行版

```powershell
wsl --unregister 发行版名称
```

### 禁用 WSL 功能

```powershell
dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /all /norestart
```

---

## 八、进阶配置（可选）

### 更新 WSL 到最新版本

```powershell
wsl --update
```

### 更改默认安装位置（适用于 C 盘空间不足）

```powershell
# 导出分发版到指定目录
wsl --export Ubuntu D:\wsl\Ubuntu.tar

# 注销当前分发版
wsl --unregister Ubuntu

# 重新导入到新位置
wsl --import Ubuntu D:\wsl\Ubuntu D:\wsl\Ubuntu.tar --version 2

# 设置默认用户
ubuntu config --default-user 用户名
```

### 安装图形界面

1. 安装 VcXsrv 或 X410 作为 Windows 上的 X 服务器
2. 在 WSL 中安装桌面环境（如 GNOME、KDE）
3. 配置 DISPLAY 环境变量连接到 X 服务器

---

## 总结

| 安装方式 | 适用场景 | 推荐度 |
|----------|----------|--------|
| 快速安装 | 系统版本新、网络良好 | ⭐⭐⭐⭐⭐ |
| 手动安装 | 自定义发行版需求 | ⭐⭐⭐⭐ |
| 离线安装 | 网络问题、旧版系统 | ⭐⭐⭐⭐⭐（终极方案） |

**遇到问题时的优先级**：
1. 先尝试网络重置 + DNS 修改
2. 再用 `--web-download` 参数绕过 Store 限制
3. 最后考虑离线包安装（100% 成功）

---

> 文档最后更新：2026-05-22
