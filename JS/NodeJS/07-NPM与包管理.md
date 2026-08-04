# NPM 与包管理

## npm 基础

### 常用命令

```bash
npm init -y                # 快速初始化 package.json
npm install <pkg>          # 安装到 dependencies
npm install -D <pkg>       # 安装到 devDependencies
npm install -g <pkg>       # 全局安装
npm uninstall <pkg>        # 卸载
npm update <pkg>           # 更新
npm outdated               # 查看过期包
npm ls                     # 查看已安装包（树形）
npm ls --depth=0           # 仅顶层
```

### 安装语义

```bash
npm install          # 安装 package.json 中所有依赖
npm install          # 会生成 node_modules 和 package-lock.json
npm ci               # 根据 lock 文件精确安装（CI 环境使用）
```

---

## package.json

### 核心字段

```json
{
  "name": "my-project",
  "version": "1.0.0",
  "description": "项目描述",
  "main": "index.js",
  "scripts": {
    "start": "node app.js",
    "dev": "node --watch app.js",
    "test": "jest",
    "build": "tsc"
  },
  "dependencies": {
    "express": "^4.18.0"
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "typescript": "^5.0.0"
  },
  "peerDependencies": {
    "react": "^18.0.0"
  },
  "optionalDependencies": {},
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  },
  "type": "commonjs",
  "exports": {
    ".": "./index.js",
    "./utils": "./utils.js"
  },
  "files": ["dist", "lib"],
  "keywords": [],
  "author": "",
  "license": "MIT",
  "private": true
}
```

### scripts 自定义命令

```bash
npm run start       # 执行 scripts.start
npm run dev         # 执行 scripts.dev
npm test            # npm run test 的简写
npm start           # 同上

# 生命周期钩子
# prepublish / postpublish
# preinstall / postinstall
# pretest / posttest
# prestart / poststart
```

---

## 语义化版本 (SemVer)

格式：`主版本.次版本.补丁`

```text
"express": "^4.18.2"
```

| 符号 | 含义 | 示例 |
|------|------|------|
| `^` | 允许次版本和补丁版本升级 | `^4.18.2` → `4.x.x` |
| `~` | 仅允许补丁版本升级 | `~4.18.2` → `4.18.x` |
| 无 | 精确版本 | `4.18.2` → 固定 |
| `*` | 任意版本 | `*` → 最新 |
| `>=1.0.0` | 大于等于 | |
| `1.0.0 - 2.0.0` | 范围 | |

### 版本号含义

```text
1.2.3
^    ^  ^
|    |  └── 补丁 (Patch) - bug 修复
|    └───── 次版本 (Minor) - 向下兼容的新功能
└────────── 主版本 (Major) - 不兼容的修改
```

### npm version 命令

```bash
npm version patch   # 1.0.0 → 1.0.1
npm version minor   # 1.0.0 → 1.1.0
npm version major   # 1.0.0 → 2.0.0
# 自动修改 package.json + 打 git tag
```

---

## package-lock.json

- 锁定精确版本号和依赖树
- 保证不同环境安装结果一致
- **必须提交到版本控制**

```bash
npm install         # 生成/更新 lock 文件
npm ci              # 仅使用 lock 文件安装（更快、更严格）
```

---

## npx

无需全局安装即可执行包中的命令：

```bash
npx create-react-app my-app   # 临时下载并执行
npx http-server               # 启动静态服务器
npx --package typescript tsc  # 指定包执行命令
```

---

## 发布包

```bash
npm login                      # 登录
npm whoami                     # 查看当前用户
npm publish                    # 发布
npm publish --access public    # 发布公共包
npm unpublish <pkg>@<version>  # 取消发布（72 小时内）
npm deprecate <pkg>@<version> "msg"  # 标记弃用
```

### package.json 发布相关字段

```json
{
  "private": true,          // 防止意外发布
  "publishConfig": {
    "registry": "https://registry.npmjs.org"
  }
}
```

---

## 其他包管理工具

| 工具 | 命令 | 特点 |
|------|------|------|
| **npm** | `npm` | 默认 |
| **yarn** | `yarn` | 更快、离线缓存 |
| **pnpm** | `pnpm` | 节省磁盘（硬链接） |

```bash
# yarn
yarn add <pkg>         # 安装
yarn add -D <pkg>      # 开发依赖
yarn remove <pkg>      # 卸载
yarn upgrade <pkg>     # 更新

# pnpm
pnpm add <pkg>
pnpm add -D <pkg>
pnpm remove <pkg>
pnpm update
```

---

## .npmrc 配置

```bash
# 设置 registry（镜像源）
npm config set registry https://registry.npmmirror.com

# 查看配置
npm config list

# 配置文件位置
# ~/.npmrc  （用户级）
# ./.npmrc  （项目级）
```

典型 `.npmrc`：

```ini
registry=https://registry.npmjs.org/
save-exact=true
ignore-scripts=false
```
