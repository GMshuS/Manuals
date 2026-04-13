# 一、 概述

`gitconfig` 是 Git 的配置文件，用于存储 Git 的各种设置和偏好。这些配置可以应用于不同的作用域（全局、系统或本地仓库），并影响 Git 命令的行为。

---

# 二、 配置文件位置与优先级

Git 配置文件存在于三个不同的位置，按优先级从高到低排列：

1. **本地仓库配置**：`.git/config` 文件，仅适用于当前仓库
2. **用户全局配置**：`~/.gitconfig` 或 `~/.config/git/config` 文件，适用于当前用户的所有仓库
3. **系统级配置**：`/etc/gitconfig` 文件，适用于系统上的所有用户

当存在冲突时，高优先级的配置会覆盖低优先级的配置。

---

# 三、 基本配置命令

# 1. 设置配置

```bash
# 设置本地仓库配置
git config user.name "Your Name"
git config user.email "your.email@example.com"

# 设置全局配置
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 设置系统级配置（需要管理员权限）
git config --system core.editor "vim"
```

# 2. 查看配置

```bash
# 查看当前仓库的所有配置
git config --list

# 查看全局配置
git config --global --list

# 查看特定配置项
git config user.name
```

# 3. 删除配置

```bash
# 删除本地仓库配置
git config --unset user.name

# 删除全局配置
git config --global --unset user.name
```

# 四、 主要配置选项

# 1. 基本用户信息

```ini
[user]
    name = Your Name
    email = your.email@example.com
    signingkey = GPG_KEY_ID  # GPG 签名密钥
```

# 2. 核心配置

```ini
[core]
    editor = vim  # 默认编辑器
    excludesfile = ~/.gitignore_global  # 全局忽略文件
    autocrlf = true  # 自动处理换行符（Windows）
    safecrlf = true  # 检查换行符问题
    filemode = true  # 跟踪文件权限变化
    bare = false  # 是否为裸仓库
```

# 3. 远程仓库

```ini
[remote "origin"]
    url = https://github.com/username/repository.git
    fetch = +refs/heads/*:refs/remotes/origin/*
    push = +refs/heads/*:refs/heads/*  # 推送策略
```

# 4. 分支设置

```ini
[branch "main"]
    remote = origin
    merge = refs/heads/main

[branch "develop"]
    remote = origin
    merge = refs/heads/develop
```

# 5. 合并和差异工具

```ini
[merge]
    tool = vimdiff  # 合并工具
    conflictstyle = diff3  # 冲突显示风格

[diff]
    tool = vimdiff  # 差异工具
    algorithm = patience  # 差异算法
```

# 6. 别名

```ini
[alias]
    co = checkout
    br = branch
    ci = commit
    st = status
    lg = log --oneline --graph --decorate
    unstage = reset HEAD --
    last = log -1 HEAD
```

# 7. 凭证管理

```ini
[credential]
    helper = cache  # 缓存凭证
    helper = store  # 存储凭证到文件
    helper = manager  # Windows 凭证管理器
```

## 8. 日志和输出格式

```ini
[log]
    date = iso  # 日期格式

[format]
    pretty = format:"%h %ad %s (%an)"  # 提交信息格式
```

## 9. HTTP 配置

```ini
[http]
    sslVerify = true  # 验证 SSL 证书
    proxy = http://proxy.example.com:8080  # HTTP 代理
    postBuffer = 104857600  # 增大 POST 缓冲区（100MB）
```

## 10. SSH 配置

```ini
[ssh]
    variant = ssh
    useAskPass = false  # 是否使用密码提示
```

# 五、 高级配置选项

## 1. 性能优化

```ini
[core]
    preloadindex = true  # 预加载索引以加速
    fscache = true  # 文件系统缓存

[pack]
    windowMemory = 512m  # 打包窗口内存
    depth = 20  # 打包深度
    deltaCacheSize = 256m  # 增量缓存大小
```

## 2. 安全配置

```ini
[fetch]
    recurseSubmodules = on-demand  # 按需递归子模块

[transfer]
    fsckObjects = true  # 传输时检查对象完整性
```

## 3. 钩子配置

```ini
[core]
    hooksPath = .githooks  # 自定义钩子目录
```

# 4. 完整示例配置

```ini
# ~/.gitconfig 示例

[user]
    name = Your Name
    email = your.email@example.com
    signingkey = ABCDEF1234567890

[core]
    editor = code --wait
    excludesfile = ~/.gitignore_global
    autocrlf = true
    safecrlf = true

[alias]
    co = checkout
    br = branch
    ci = commit
    st = status
    lg = log --oneline --graph --decorate
    lgfull = log --stat
    unstage = reset HEAD --
    last = log -1 HEAD
    difftool = difftool --no-prompt

[remote "origin"]
    url = https://github.com/username/repository.git
    fetch = +refs/heads/*:refs/remotes/origin/*

[branch "main"]
    remote = origin
    merge = refs/heads/main

[credential]
    helper = manager-core

[log]
    date = iso

[format]
    pretty = format:"%h %ad %s (%an)"

[http]
    postBuffer = 104857600

[pack]
    windowMemory = 512m
    depth = 20
    deltaCacheSize = 256m
```

# 六、 配置文件语法

## 1. 基本结构

Git 配置文件使用 INI 格式，包含节（section）和键值对：

- 节用 `[section]` 表示
- 子节用 `[section "subsection"]` 表示
- 键值对使用 `key = value` 格式
- 注释以 `#` 开头

## 2. 特殊字符处理

- 包含空格的值需要用引号括起来
- 反斜杠 `\` 作为转义字符
- 可以使用环境变量，如 `$HOME` 或 `%USERPROFILE%`

# 六、 配置多个 Git 仓库（如 GitHub 和 GitLab）

## 1. 使用SSH密钥访问仓库【推荐】

### 1.2 配置不同平台的 SSH 密钥（多平台区分）

**步骤1：生成两套 SSH 密钥（ed25519 推荐）**

打开终端，在用户目录下的.ssh文件夹下分别为 GitHub、GitLab 生成密钥（邮箱替换为你自己的）：

```bash
# 1. GitHub 密钥（个人）
ssh-keygen -t ed25519 -C "your-email@personal.com" -f %USERPROFILE%/.ssh/id_ed25519_github

# 2. GitLab 密钥（公司/个人）
ssh-keygen -t ed25519 -C "your-email@company.com" -f %USERPROFILE%/.ssh/id_ed25519
```

- 一路回车（可设密码，也可不设）
- 生成后在 `%USERPROFILE%/.ssh/` 下会有 4 个文件：
  - `id_ed25519_github` / `id_ed25519_github.pub`
  - `id_ed25519_gitlab` / `id_ed25519_gitlab.pub`

> 注：在Linux/Mac下，.ssh目录为`~/.ssh/config`

**步骤2：配置 SSH 多 Host（关键）**

创建/编辑 `%USERPROFILE%/.ssh/config`【Linux/Mac为：`~/.ssh/config`】：
```bash
# GitHub 
Host github.com
  HostName github.com
  User git
  # 配置 443 端口绕过防火墙【默认端口22报错时，放开此配置】
  # Port 443
  # 配置绝对路径更安全
  IdentityFile C:\Users\GMshuS\.ssh\id_ed25519_github
  IdentitiesOnly yes

# GitLab
Host gitlab.com
  HostName gitlab.com
  User git
  # 配置 443 端口绕过防火墙【默认端口22报错时，放开此配置】
  # Port 443
  # 配置绝对路径更安全
  IdentityFile C:\Users\GMshuS\.ssh\id_ed25519_gitlab
  IdentitiesOnly yes
```
- **IdentitiesOnly yes**：强制只使用指定密钥，避免密钥串扰
- 权限要正确（Windows 可忽略）：
    ```bash
    chmod 600 ~/.ssh/config
    chmod 700 ~/.ssh
    ```

**步骤3：把公钥加到 GitHub / GitLab**
1. 查看公钥：
   ```bash
   cat ~/.ssh/id_ed25519_github.pub  # 复制
   cat ~/.ssh/id_ed25519_gitlab.pub  # 复制
   ```
2. 网页端添加：
   - **GitHub**: Settings → SSH and GPG keys → New SSH key
   - **GitLab**: User Settings → SSH Keys → Add new key

**步骤4：测试连接**
```bash
ssh -T git@github.com
# 出现：Hi xxx! You've successfully authenticated... 即成功

ssh -T git@gitlab.com
# 出现：Welcome to GitLab, @xxx! 即成功
```

### 1.2  配置不同平台的用户信息（避免提交错用户）

**方法1：使用条件配置（推荐）**
通过在全局 `%USERPROFILE%/.gitconfig`【Linux/Mac为：`~/.gitconfig`】 文件中添加**条件配置**，根据仓库路径自动切换用户信息：

```ini
# 全局默认配置
[user]
    name = 默认用户名
    email = 默认邮箱@example.com

# GitHub 仓库配置（路径包含 github.com）
[includeIf "gitdir:~/Projects/github/"]
    path = ~/.gitconfig-github

# GitLab 仓库配置（路径包含 gitlab.com）
[includeIf "gitdir:~/Projects/gitlab/"]
    path = ~/.gitconfig-gitlab
```

创建对应平台的配置文件：
- `%USERPROFILE%/.gitconfig-github`【Linux/Mac为：`~/.gitconfig-github`】：
  ```ini
  [user]
      name = GitHub 用户名
      email = github邮箱@example.com
  ```
- `%USERPROFILE%/.gitconfig-gitlab`【Linux/Mac为：`~/.gitconfig-gitlab`】：
  ```ini
  [user]
      name = GitLab 用户名
      email = gitlab邮箱@example.com
  ```

**方法2：本地仓库配置用户信息**
在特定仓库中直接设置用户信息：
```bash
# 进入 GitHub 仓库目录
cd /path/to/github/repo
git config user.name "GitHub 用户名"
git config user.email "github邮箱@example.com"

# 进入 GitLab 仓库目录
cd /path/to/gitlab/repo
git config user.name "GitLab 用户名"
git config user.email "gitlab邮箱@example.com"
```

### 1.3 修改远程仓库地址【已经通过非ssh方式clone的仓库】

```bash
# 假设你的参考地址为:git@github.com:你的用户名/仓库名.git
git remote set-url origin git@github.com:你的用户名/仓库名.git
```

## 2. 使用令牌访问仓库

如果你不想用 SSH，想用 **HTTPS + 令牌（Token）** 同时访问 GitHub 和 GitLab，核心思路是：
1. 给两个平台分别生成**只读/读写令牌**
2. 把令牌**直接嵌入仓库 HTTPS 地址**（最稳）
3. 或让 Git 凭据管理器**自动记住不同平台的令牌**（最省心）

下面给你两套最简单、最常用的方案，任选其一即可。

### 2.1 先去两个平台生成令牌
**GitHub 生成 Token**
1. 打开 GitHub → Settings → Developer settings → **Personal access tokens (classic)**
2. 勾选权限：`repo`（仓库权限）
3. 生成后**复制保存**（只显示一次）

**GitLab 生成 Token**
1. 打开 GitLab → User Settings → **Access Tokens**
2. 勾选权限：`read_repository` + `write_repository`
3. 生成后**复制保存**

### 2.2 修改远程仓库地址【已经通过非https方式clone的仓库】

```bash
# 假设你的参考地址为:https://github.com/你的用户名/仓库名.git
git remote set-url origin https://github.com/你的用户名/仓库名.git
```

### 2.3 使用令牌
**方案 1：直接把 Token 写进仓库地址（最简单、最通用）**

克隆/推送时直接用：
```bash
# GitHub 格式
https://你的GitHub用户名:GitHub令牌@github.com/用户名/仓库名.git

# GitLab 格式
https://你的GitLab用户名:GitLab令牌@gitlab.com/用户名/仓库名.git
```

示例
```bash
# 克隆 GitHub
git clone https://zhangsan:ghp_xxxxxxxxx@github.com/zhangsan/my-project.git

# 克隆 GitLab
git clone https://zhangsan:glpat-xxxxxxxxx@gitlab.com/zhangsan/my-project.git
```

> ✅ 优点：不用配置，直接用，互不干扰  
> ✅ 完美同时支持 GitHub + GitLab  
> ✅ 公司电脑、无权限电脑都能用

**方案 2：让 Git 自动记住令牌（推荐，不用每次写长地址）**

Git 自带 **凭据管理器**，会自动保存不同网站的密码/令牌。

直接用普通 HTTPS 地址克隆：
```bash
# GitHub
git clone https://github.com/xxx/repo.git

# GitLab
git clone https://gitlab.com/xxx/repo.git
```

第一次克隆时会让你输入：
- **用户名**：平台用户名
- **密码**：**填令牌（Token），不是登录密码！**

Git 会自动记住，以后克隆、拉取、推送**完全不用再输**，且 GitHub / GitLab 令牌**互不干扰**。

### 2.4 查看/删除已保存的凭据（不想用了可以清）
**Windows**
控制面板 → 凭据管理器 → Windows 凭据  
找到 `github.com` / `gitlab.com` 编辑/删除

**macOS**
钥匙串访问 → 搜索 github / gitlab → 删除

**Linux**
```bash
git config --global --unset credential.helper
```

---

# 总结（最实用版）
1. GitHub、GitLab 各生成一个 **repo 权限令牌**
2. 克隆时直接用：
   - GitHub：`https://user:token@github.com/xxx/repo.git`
   - GitLab：`https://user:token@gitlab.com/xxx/repo.git`
3. 两个平台**完全独立、互不冲突**

我可以直接给你生成**可直接复制替换的 GitHub + GitLab 令牌地址模板**，你只要填用户名和令牌就能用，要吗？

# 七、参考资源

- [Git 官方文档](https://git-scm.com/docs/git-config)
- [Pro Git 书籍](https://git-scm.com/book/en/v2)
- [GitHub 帮助文档](https://help.github.com/en/github/using-git/getting-started-with-git-and-github)

---

本手册提供了 Git 配置文件的详细参考，涵盖了从基本设置到高级配置的各个方面。根据实际需求，可以调整和扩展这些配置选项以适应不同的工作流程。