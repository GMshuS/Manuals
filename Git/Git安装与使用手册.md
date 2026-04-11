# 深入浅出Git使用手册

## 1. 安装

### Windows

1. 访问 <https://git-scm.com/download/win> 下载安装包
2. 运行安装程序，大部分选项保持默认即可
3. 注意选择默认编辑器（推荐VSCode或Vim）
4. 配置PATH环境：选择"Git from the command line and also from 3rd-party software"
5. 配置行尾转换：选择"Checkout Windows-style, commit Unix-style line endings"
6. 完成安装

### macOS

```bash
# 方法1: 使用Homebrew
brew install git

# 方法2: 下载官方安装包
# 访问 https://git-scm.com/download/mac
```

### Linux

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install git

# CentOS/RHEL/Fedora
sudo yum install git
# 或
sudo dnf install git
```

### 验证安装

```bash
git --version
# 显示类似: git version 2.35.1
```

## 2. 命令列表

### 基础命令

- `git init` - 初始化仓库
- `git clone` - 克隆仓库
- `git add` - 添加文件到暂存区
- `git commit` - 提交更改
- `git status` - 查看状态
- `git log` - 查看提交历史
- `git diff` - 查看差异

### 分支管理

- `git branch` - 分支操作
- `git checkout` - 切换分支/恢复文件
- `git switch` - 切换分支（推荐）
- `git merge` - 合并分支
- `git rebase` - 变基操作

### 远程操作

- `git remote` - 远程仓库管理
- `git fetch` - 获取远程更新
- `git pull` - 拉取并合并
- `git push` - 推送更改

### 撤销与回退

- `git reset` - 重置提交
- `git revert` - 撤销提交
- `git restore` - 恢复文件
- `git stash` - 暂存更改

### 配置与帮助

- `git config` - 配置管理
- `git help` - 获取帮助

## 3. 命令使用实例

### 3.1 创建仓库

#### 本地创建仓库

**作用**：将现有目录初始化为Git仓库

**使用过程**：

```bash
# 1. 在本地初始化仓库并完成初次提交
mkdir my-project
cd my-project
git init
echo "# My Project" > README.md
git add README.md
git commit -m "Initial commit"

# 2. 在GitHub/GitLab上创建新空仓库
# 注意：不要选择"Initialize with README"

# 3. 添加远程仓库地址
git remote add origin https://github.com/username/my-project.git
# 或使用SSH
git remote add origin git@github.com:username/my-project.git

# 4. 重命名默认分支（如果需要）
# 较新版本的Git默认分支是main，旧版本可能是master
git branch -M main  # 将当前分支重命名为main

# 5. 推送并设置上游分支
git push -u origin main
# -u 参数设置上游分支，后续可直接使用 git push
# 输出示例：
# Enumerating objects: 3, done.
# Counting objects: 100% (3/3), done.
# Writing objects: 100% (3/3), 227 bytes | 227.00 KiB/s, done.
# Total 3 (delta 0), reused 0 (delta 0)
# To github.com:username/my-project.git
#  * [new branch]      main -> main
# Branch 'main' set up to track remote branch 'main' from 'origin'.
```

#### 远程创建仓库

**作用**：在GitHub/GitLab等平台创建仓库后关联到本地

**使用过程**：

```bash
# 1. 在GitHub上创建新仓库（不初始化README等文件）

# 2. 本地操作
mkdir new-project
cd new-project
git init
echo "# New Project" > README.md
git add README.md
git commit -m "Initial commit"

# 3. 关联远程仓库
git remote add origin https://github.com/username/new-project.git

# 4. 推送代码
git branch -M main
git push -u origin main
```

### 3.2 克隆仓库

**作用**：获取远程仓库的完整副本到本地

**使用过程**：

```bash
# 基本克隆
git clone https://github.com/user/repo.git
# 这会在当前目录创建repo文件夹

# 克隆到指定目录
git clone https://github.com/user/repo.git my-folder

# 克隆指定分支
git clone -b develop https://github.com/user/repo.git

# 克隆深度为1（只克隆最近一次提交）
git clone --depth 1 https://github.com/user/repo.git
```

### 3.3 分支管理

**作用**：创建、切换、删除分支，实现并行开发

**使用过程**：

```bash
# 1. 查看分支
git branch              # 查看本地分支
git branch -a          # 查看所有分支（本地+远程）
git branch -r          # 查看远程分支

# 2. 创建分支
git branch feature-auth  # 创建分支但不切换
git checkout -b feature-auth  # 创建并切换到新分支
# 或（Git 2.23+推荐）
git switch -c feature-auth

# 3. 切换分支
git checkout feature-auth
# 或
git switch feature-auth

# 4. 删除分支
git branch -d feature-auth  # 删除已合并的分支
git branch -D feature-auth  # 强制删除未合并的分支

# 5. 重命名分支
git branch -m old-name new-name

# 6. 跟踪远程分支
git checkout --track origin/feature-auth
```

### 3.4 日志管理

**作用**：查看提交历史，分析项目演变

**使用过程**：

```bash
# 1. 基本日志
git log

# 2. 简洁单行显示
git log --oneline
# 输出示例:
# 9f430b1 (HEAD -> main) Add user authentication
# 7a2e5c8 Fix typo in README
# 3b8d1e0 Initial commit

# 3. 带分支图的日志
git log --graph --oneline --all

# 4. 显示最近N次提交
git log -5  # 最近5次提交

# 5. 按作者搜索
git log --author="John"

# 6. 按时间范围
git log --since="2026-01-01" --until="2026-01-31"

# 7. 搜索提交信息
git log --grep="fix"

# 8. 显示文件修改统计
git log --stat

# 9. 显示具体修改内容
git log -p

# 10. 显示每个文件的最后修改者
git blame README.md
```

### 3.5 提交代码

**作用**：将更改保存到本地仓库

**使用过程**：

```bash
# 1. 检查状态
git status

# 2. 查看具体更改
git diff
git diff --staged  # 查看已暂存的更改

# 3. 添加文件到暂存区
git add file.txt           # 添加特定文件
git add .                  # 添加所有更改
git add *.js               # 添加所有js文件
git add -u                 # 添加已跟踪文件的修改（不包含新文件）

# 4. 提交更改
git commit -m "Add user login feature"
git commit -m "Fix bug" -m "Details: Fixed null pointer exception"

# 5. 修改最近一次提交
git add forgotten-file.js
git commit --amend
# 这会打开编辑器，可以修改提交信息

# 6. 跳过暂存区直接提交（仅对已跟踪文件有效）
git commit -a -m "Quick commit"

# 7. 提交示例工作流
echo "New content" > file.txt
git status                # 查看未跟踪文件
git add file.txt
git status                # 查看已暂存文件
git commit -m "Update file.txt"
```

### 3.6 合并代码

**作用**：将一个分支的更改整合到当前分支

**使用过程**：

#### 快速合并（无冲突）

```bash
# 1. 切换到目标分支
git checkout main

# 2. 合并特性分支
git merge feature-auth
# 如果feature-auth的更改是main分支的直接后代，会执行快速合并

# 3. 删除已合并的特性分支
git branch -d feature-auth
```

#### 处理合并冲突

```bash
# 1. 开始合并（产生冲突）
git checkout main
git merge feature-auth
# 输出: Auto-merging file.txt
#       CONFLICT (content): Merge conflict in file.txt
#       Automatic merge failed; fix conflicts and then commit the result.

# 2. 查看冲突文件状态
git status
# 显示: Unmerged paths: file.txt

# 3. 查看冲突内容
cat file.txt
# 显示:
# <<<<<<< HEAD
# Current main branch content
# =======
# Feature branch content
# >>>>>>> feature-auth

# 4. 手动解决冲突
# 编辑file.txt，删除冲突标记，保留正确内容
vim file.txt

# 5. 标记冲突已解决
git add file.txt

# 6. 完成合并
git commit
# 编辑器会自动生成合并信息
```

#### 禁用快速合并

```bash
git merge --no-ff feature-auth
# 这会创建新的合并提交，即使可以进行快速合并
```

### 3.7 回滚代码

**作用**：撤销错误的更改或提交

**使用过程**：

#### 撤销工作区更改（未暂存）

```bash
# 查看将要丢弃的更改
git checkout -- file.txt
# 或（Git 2.23+）
git restore file.txt

# 丢弃所有未暂存的更改
git checkout -- .
# 或
git restore .
```

#### 撤销暂存区的更改

```bash
# 从暂存区移除文件，但保留工作区更改
git reset HEAD file.txt
# 或
git restore --staged file.txt

# 从暂存区移除所有文件
git reset HEAD
```

#### 重置提交历史

```bash
# 1. 软重置（只移动HEAD指针，保留更改在暂存区）
git reset --soft HEAD~1
# 撤销最近一次提交，更改回到暂存区

# 2. 混合重置（默认，移动HEAD指针，更改回到工作区）
git reset --mixed HEAD~1
# 或
git reset HEAD~1

# 3. 硬重置（丢弃所有更改）
git reset --hard HEAD~1
# 警告：这会永久丢弃提交和更改

# 4. 重置到特定提交
git reset --hard abc1234
```

#### 创建撤销提交

```bash
# 创建一个新提交来撤销指定提交的更改
git revert abc1234
# 这会打开编辑器让你输入撤销信息

# 撤销最近一次提交
git revert HEAD

# 撤销多个提交
git revert HEAD~3..HEAD
```

#### 找回被重置的提交

```bash
# 查看所有引用日志
git reflog
# 输出示例:
# abc1234 HEAD@{0}: reset: moving to HEAD~1
# def5678 HEAD@{1}: commit: Add feature

# 重置到之前的某个状态
git reset --hard HEAD@{1}
```

### 3.8 Rebase

**作用**：重新应用提交，创建线性的提交历史

**使用过程**：

#### 基本变基

```bash
# 1. 在特性分支上
git checkout feature-auth

# 2. 获取最新main分支更改
git fetch origin

# 3. 变基到最新的main分支
git rebase origin/main
# 如果有冲突，需要解决冲突后执行 git rebase --continue

# 4. 切换回main并合并
git checkout main
git merge feature-auth
```

#### 交互式变基

```bash
# 1. 修改最近3次提交
git rebase -i HEAD~3
# 编辑器会打开，显示类似:
# pick a1b2c3d Commit message 1
# pick b2c3d4e Commit message 2
# pick c3d4e5f Commit message 3

# 2. 修改指令，例如:
# pick a1b2c3d Commit message 1
# squash b2c3d4e Commit message 2
# reword c3d4e5f Commit message 3

# 可用指令:
# pick - 使用提交
# reword - 使用提交但修改提交信息
# edit - 使用提交但暂停修改
# squash - 合并到前一个提交
# fixup - 合并到前一个提交，丢弃提交信息
# drop - 删除提交
```

#### 解决rebase冲突

```bash
# 1. 开始rebase
git rebase main

# 2. 遇到冲突时，Git会暂停
# 手动解决冲突文件

# 3. 添加已解决的文件
git add file.txt

# 4. 继续rebase
git rebase --continue

# 5. 如果要跳过当前提交
git rebase --skip

# 6. 如果要中止rebase
git rebase --abort
```

#### 变基的风险和最佳实践

```bash
# 危险：不要对已推送到远程的分支进行变基
# 除非你确定没有其他人在这个分支上工作

# 安全的变基流程
git checkout my-feature
git fetch origin
git rebase origin/main
# 解决可能的冲突
git push origin my-feature --force-with-lease
```

## 4. Git配置文件与配置项详解

### 配置文件级别

1. **系统级别** (`/etc/gitconfig`)
   - 对所有用户生效
   ```bash
   git config --system
   ```
2. **全局级别** (`~/.gitconfig` 或 `~/.config/git/config`)
   - 对当前用户的所有仓库生效
   ```bash
   git config --global
   ```
3. **本地级别** (`.git/config`)
   - 只对当前仓库生效
   ```bash
   git config --local
   ```

### 常用配置项

```ini
# 用户身份
[user]
    name = Your Name
    email = your.email@example.com

# 编辑器
[core]
    editor = vim
    excludesfile = ~/.gitignore_global
    
# 别名
[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    lg = log --oneline --graph --all
    
# 远程仓库
[remote "origin"]
    url = https://github.com/user/repo.git
    fetch = +refs/heads/*:refs/remotes/origin/*
    
# 分支跟踪
[branch "main"]
    remote = origin
    merge = refs/heads/main
    
# 推送策略
[push]
    default = simple
    
# 拉取策略
[pull]
    rebase = false
    
# 颜色输出
[color]
    ui = auto
    
# 差异工具
[diff]
    tool = vimdiff
    
# 合并工具
[merge]
    tool = vimdiff
```

## 5. 配置实例

### 5.1 设置远程仓库的别名

#### 命令行方式

```bash
# 添加远程仓库
git remote add origin https://github.com/user/repo.git

# 查看远程仓库
git remote -v
# 输出:
# origin  https://github.com/user/repo.git (fetch)
# origin  https://github.com/user/repo.git (push)

# 修改远程仓库URL
git remote set-url origin https://github.com/user/new-repo.git

# 添加多个远程仓库
git remote add upstream https://github.com/original/repo.git
git remote add company git@company.com:project.git

# 重命名远程仓库
git remote rename origin github

# 删除远程仓库
git remote remove upstream
```

#### 配置文件方式

编辑 `.git/config`：

```ini
[remote "origin"]
    url = https://github.com/user/repo.git
    fetch = +refs/heads/*:refs/remotes/origin/*
    
[remote "upstream"]
    url = https://github.com/original/repo.git
    fetch = +refs/heads/*:refs/remotes/upstream/*
```

### 5.2 认证方式配置

#### 5.2.1 Git Credential Helper 工作原理

Git 通过 `credential.helper` 配置项来管理认证信息，支持多种存储方式：

| 模式                         | 存储位置                      | 安全性  | 适用场景      |
| :------------------------- | :------------------------ | :--- | :-------- |
| `store`                    | 明文文件 `~/.git-credentials` | ⚠️ 低 | 个人开发机     |
| `cache`                    | 内存（默认15分钟）                | ⚠️ 中 | 临时使用      |
| `manager` / `manager-core` | Windows凭据管理器              | ✅ 高  | Windows推荐 |
| `osxkeychain`              | macOS钥匙串                  | ✅ 高  | macOS推荐   |
| `libsecret`                | Linux密钥环                  | ✅ 高  | Linux推荐   |

##### 5.2.2 凭据管理常用命令

| 命令                                      | 作用         |
| :-------------------------------------- | :--------- |
| `git config credential.helper`          | 查看当前凭据助手配置 |
| `git config --global credential.helper` | 查看全局凭据助手配置 |
| `git credential reject`                 | 清除缓存的凭据    |
| `rm ~/.git-credentials`                 | 删除存储的凭据文件  |
| `git config --unset credential.helper`  | 禁用凭据助手     |

##### 5.2.3 凭据文件位置与格式

启用 `store` 后，凭据会保存在：

- **Linux/macOS**: `~/.git-credentials`
- **Windows**: `C:\Users\用户名\.git-credentials`

文件格式示例：

```
https://username:ghp_xxxxxxxxxxxx@github.com
https://username:glpat-xxxxxxxxxxxx@gitlab.com
```

##### 5.2.4 清除已保存的凭据

```bash
# 方法1：删除凭据文件
rm ~/.git-credentials

# 方法2：使用 credential reject
echo "protocol=https
host=github.com" | git credential reject

# 方法3：Windows 凭据管理器
# 控制面板 → 用户账户 → 凭据管理器 → Windows 凭据 → 删除 Git 相关条目
```

***

#### 5.3 用户名密码认证配置

##### 5.3.1 方式一：命令行配置（推荐）

###### 5.3.1.1 全局配置（所有仓库生效）

```bash
# 启用凭据存储（明文存储到 ~/.git-credentials）
git config --global credential.helper store

# 或者使用内存缓存（15分钟后失效）
git config --global credential.helper cache

# 设置缓存超时时间（单位：秒，如下为1小时）
git config --global credential.helper 'cache --timeout=3600'
```

###### 5.3.1.2 仓库级配置（仅当前仓库生效）

```bash
cd /path/to/your/repo

# 为当前仓库单独配置
git config credential.helper store

# 指定凭据文件位置
git config credential.helper 'store --file .git/.my-credentials'
```

###### 5.3.1.3 首次认证流程

配置完成后，执行一次需要认证的操作（如 `git pull` 或 `git push`）：

```bash
git push
# 首次会提示输入用户名和密码
# 之后会自动从配置文件读取，无需再次输入
```

##### 5.3.2 方式二：直接编辑配置文件

###### 5.3.2.1 全局配置文件（\~/.gitconfig）

```bash
# 编辑全局配置
vim ~/.gitconfig
# 或
notepad ~/.gitconfig  # Windows
```

添加以下内容：

```ini
[credential]
    helper = store
    # 可选：指定凭据文件路径
    # helper = store --file /path/to/.git-credentials
```

###### 5.3.2.2 仓库级配置文件（.git/config）

```bash
# 进入仓库目录
cd /path/to/your/repo

# 编辑仓库配置
vim .git/config
```

添加以下内容：

```ini
[credential]
    helper = store
```

##### 5.3.3 方式三：手动创建凭据文件

```bash
# 创建凭据文件
touch ~/.git-credentials

# 编辑文件，添加认证信息（格式：https://用户名:密码@域名）
vim ~/.git-credentials
```

内容示例：

```
https://username:password@github.com
https://username:password@gitlab.com
```

> ⚠️ **安全警告**：此方式密码为明文存储，仅建议在个人可信机器上使用！

***

#### 5.4 访问令牌（PAT）认证配置

> 📌 **重要**：GitHub、GitLab 等平台已逐步取消用户名密码认证，推荐使用 **Personal Access Token (PAT)** 代替密码。

### 5.4.1 获取访问令牌

###### 5.4.1.1 GitHub

1. 登录 GitHub → Settings → Developer settings → Personal access tokens
2. 选择 "Tokens (classic)" 或 "Fine-grained tokens"
3. 点击 "Generate new token"
4. 选择权限范围（至少勾选 `repo`）
5. 生成后**立即复制保存**（只显示一次）

###### 5.4.1.2 GitLab

1. 登录 GitLab → Settings → Access Tokens
2. 填写名称、过期时间
3. 选择权限范围（至少勾选 `api`、`read_repository`、`write_repository`）
4. 点击 "Create personal access token"

### 5.4.2 配置访问令牌

###### 5.4.2.1 方式一：使用 Credential Helper（推荐）

```bash
# 启用凭据存储
git config --global credential.helper store

# 执行一次需要认证的操作
git clone https://github.com/username/repo.git

# 提示输入用户名时：输入你的GitHub用户名
# 提示输入密码时：粘贴访问令牌（不是密码！）
```

###### 5.4.2.2 方式二：直接在URL中嵌入令牌（⚠️ 不推荐）

```bash
# 格式：https://用户名:令牌@域名/仓库.git
git clone https://username:ghp_xxxxxxxxxxxx@github.com/username/repo.git
```

> ⚠️ **安全风险**：令牌会明文保存在 `.git/config`、命令历史、日志中，极易泄露！

***

#### 5.5 SSH密钥认证（推荐）

**生成SSH密钥**：

```bash
# 1. 生成密钥对
ssh-keygen -t ed25519 -C "your.email@example.com"
# 或使用RSA
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"

# 2. 按提示操作（建议设置密码短语）
# 密钥会保存在 ~/.ssh/id_ed25519 和 ~/.ssh/id_ed25519.pub

# 3. 启动ssh-agent
eval "$(ssh-agent -s)"

# 4. 将密钥添加到ssh-agent
ssh-add ~/.ssh/id_ed25519
```

**配置SSH**：

```bash
# 创建/编辑SSH配置文件
vim ~/.ssh/config
```

添加以下内容：

```ssh
# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

# GitLab
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

# 公司Git服务器
Host git.company.com
    HostName git.internal.company.com
    User git
    IdentityFile ~/.ssh/id_rsa_company
    Port 2222
```

**测试SSH连接**：

```bash
ssh -T git@github.com
# 应看到: Hi username! You've successfully authenticated...

ssh -T git@gitlab.com
```

**配置远程仓库使用SSH**：

```bash
# 修改现有仓库
git remote set-url origin git@github.com:username/repo.git

# 克隆时使用SSH
git clone git@github.com:username/repo.git
```

### 5.5 多仓库多身份配置

#### 5.5.1 按目录配置不同身份

**使用条件配置**：
编辑 `~/.gitconfig`：

```ini
[user]
    name = Default Name
    email = default@example.com

# 工作项目使用工作邮箱
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work

# 个人项目使用个人邮箱
[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig-personal

# GitHub开源项目
[includeIf "gitdir:~/github/"]
    path = ~/.gitconfig-github
```

创建 `~/.gitconfig-work`：

```ini
[user]
    name = Work Name
    email = work@company.com
    
[core]
    sshCommand = ssh -i ~/.ssh/id_rsa_work
```

创建 `~/.gitconfig-personal`：

```ini
[user]
    name = Personal Name
    email = personal@example.com
```

#### 5.5.2 按仓库URL配置不同身份

**使用git凭证助手**：

```bash
# 安装git-credential-manager
# Windows: git-credential-manager-core
# macOS: brew install git-credential-manager
# Linux: 根据发行版安装

# 配置多个凭证
git config --global credential.https://github.com.username github-username
git config --global credential.https://gitlab.com.username gitlab-username
```

#### 完整的配置文件示例

`~/.gitconfig`：

```ini
[core]
    editor = code --wait
    autocrlf = input
    excludesfile = ~/.gitignore_global
    
[init]
    defaultBranch = main
    
[pull]
    rebase = false
    
[push]
    default = current
    
[commit]
    verbose = true
    
[color]
    ui = auto
    branch = auto
    diff = auto
    status = auto
    
[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    ca = commit -a
    cam = commit -am
    d = diff
    dc = diff --cached
    lg = log --oneline --graph --all
    lga = log --oneline --graph --all --decorate
    last = log -1 HEAD
    unstage = reset HEAD --
    undo = reset --soft HEAD^
    
[merge]
    conflictstyle = diff3
    
[rerere]
    enabled = true
    
[filter "lfs"]
    clean = git-lfs clean -- %f
    smudge = git-lfs smudge -- %f
    process = git-lfs filter-process
    required = true
    
[user]
    name = Global Name
    email = global@example.com

# 工作配置
[includeIf "gitdir/i:~/work/"]
    path = .gitconfig-work
    
[includeIf "gitdir/i:~/CompanyProjects/"]
    path = .gitconfig-work

# 个人配置
[includeIf "gitdir/i:~/personal/"]
    path = .gitconfig-personal
    
[includeIf "gitdir/i:~/github/"]
    path = .gitconfig-personal
```

`~/.gitconfig-work`：

```ini
[user]
    name = Zhang San
    email = zhangsan@company.com
    signingkey = WORK_SSH_KEY_FINGERPRINT
    
[commit]
    gpgsign = true
    
[core]
    sshCommand = ssh -i ~/.ssh/id_ed25519_work
    
[url "ssh://git@git.company.com/"]
    insteadOf = https://git.company.com/
```

`~/.gitconfig-personal`：

```ini
[user]
    name = Zhang San
    email = zhangsan.personal@gmail.com
    
[github]
    user = zhangsan
    
[core]
    sshCommand = ssh -i ~/.ssh/id_ed25519_personal
    
[url "git@github.com:"]
    insteadOf = https://github.com/
```

#### 5.5.3 验证配置credential

```bash
# 查看所有配置
git config --list --show-origin

# 查看特定仓库的配置
cd ~/work/project-a
git config user.email
# 应显示: zhangsan@company.com

cd ~/personal/project-b
git config user.email
# 应显示: zhangsan.personal@gmail.com

# 测试SSH连接
cd ~/work/project-a
git remote -v
# 应使用SSH URL
```

#### 5.5.4 临时覆盖配置

```bash
# 为单次提交使用特定邮箱
git -c user.email="temp@example.com" commit -m "Temporary commit"

# 为当前终端会话设置
export GIT_AUTHOR_EMAIL="temp@example.com"
export GIT_COMMITTER_EMAIL="temp@example.com"
```

***

这份手册涵盖了Git的核心功能和高级配置，适用于从初学者到高级用户。建议根据实际需求逐步学习和实践每个部分，特别是分支管理、合并冲突解决和rebase操作，这些是团队协作中的关键技能。
