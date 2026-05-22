# WSL2 常用命令速查表
## 一、基础启停查看
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

## 二、版本管理切换
```powershell
# 设置新建系统默认使用WSL2
wsl --set-default-version 2

# 更改已有发行版版本
wsl --set-version Ubuntu 2
```

## 三、导入导出迁移备份
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

## 四、安装卸载
```powershell
# 在线安装指定系统
wsl --install -d Ubuntu

# 离线包安装
Add-AppxPackage 包路径.appx

# 卸载发行版
wsl --unregister Ubuntu
```

## 五、内核与更新
```powershell
# 更新WSL内核
wsl --update

# 回滚内核版本
wsl --update --rollback

# 查看WSL运行状态
wsl --status
```

## 六、WSL内目录互访
### WSL访问Windows
```bash
# C盘
cd /mnt/c
# D盘
cd /mnt/d
# 用户目录示例
cd /mnt/c/Users/guosen
```

### Windows访问WSL
资源管理器地址输入
```
\\wsl$\Ubuntu
```

### 自动挂载配置
```bash
sudo nano /etc/wsl.conf
```
写入内容
```ini
[automount]
enabled=true
options="metadata,uid=1000,gid=1000,umask=22"
mountFsTab=false
```
保存后执行`wsl --shutdown`重启生效

## 七、网络相关
```powershell
# 重置WSL网络
wsl --shutdown

# 查看WSL内网IP
wsl hostname -I
```
WSL内查看网卡
```bash
ip addr
```

## 八、密码重置
```powershell
# 进入root
wsl -u root
# 重置用户名密码
passwd guosen
```

## 九、日常快捷操作
```bash
# WSL内用VSCode打开当前目录
code .

# 查看系统发行信息
lsb_release -a

# 查看内核版本
uname -r
```