# Node.js npm 全流程实战详解
`npm`（Node Package Manager）是 **Node.js 默认的包管理工具**，随Node.js自动安装，核心能力是**管理项目依赖、执行脚本、打包发布**，是Node.js开发的核心工具。

本文将以**「自定义字符串处理工具包」**为实战项目，**从零到一**覆盖：**项目初始化 → 包管理 → 开发调试 → 自动化测试 → 打包 → 服务器部署 → 发布npm公共包** 全流程，所有命令和代码均可直接复制使用。

---

## 一、前置环境准备
### 1. 安装 Node.js & npm
直接去 [Node.js官网](https://nodejs.org/) 下载**LTS长期支持版**（推荐），安装后会**自动自带npm**，无需单独安装。

### 2. 验证安装
打开终端（CMD/PowerShell/终端），执行命令验证版本：
```bash
# 查看Node版本
node -v  
# 查看npm版本
npm -v   
```

### 3. 切换国内镜像（解决下载慢）
npm默认源在国外，国内下载极慢，**永久切换淘宝npmmirror镜像**：
```bash
npm config set registry https://registry.npmmirror.com/
```
验证镜像是否切换成功：
```bash
npm config get registry
```

---

## 二、项目初始化（开发第一步）
npm的核心是 `package.json` 文件，它是**项目的配置清单**，记录项目名、依赖包、启动脚本等所有信息。

### 实战：创建字符串工具项目
1. **新建项目文件夹**
```bash
# 创建项目目录
mkdir npm-string-utils
# 进入目录
cd npm-string-utils
```

2. **快速生成 package.json**
```bash
# -y 表示跳过问答，直接生成默认配置（推荐新手）
npm init -y
```

执行后，项目根目录会生成 `package.json`，核心字段解读：
```json
{
  "name": "npm-string-utils",  // 项目名（发布npm包时唯一）
  "version": "1.0.0",          // 项目版本（遵循语义化版本：主版本.次版本.补丁版）
  "main": "index.js",          // 项目入口文件
  "scripts": {                 // 自定义脚本命令（核心！）
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],              // 关键词（发布npm包用）
  "author": "",                // 作者
  "license": "ISC"             // 开源协议
}
```

---

## 三、npm 包管理（核心功能）
包管理是npm最常用的功能：**安装、卸载、更新、管理项目依赖**，分为**生产依赖**和**开发依赖**。

### 1. 依赖分类
| 类型                | 命令参数 | 作用 | 存储位置 |
|---------------------|----------|------|----------|
| 生产依赖（运行必需） | `--save` / 省略 | 项目上线必须用的包（如lodash、express） | `dependencies` |
| 开发依赖（仅开发用） | `--save-dev` / `-D` | 仅开发/打包用的包（如测试、打包工具） | `devDependencies` |
| 全局依赖（系统通用） | `-g` | 全系统可用的命令行工具（如pm2、nodemon） | 系统全局 |

### 2. 实战：安装项目依赖
我们的字符串工具需要：
- 生产依赖：`lodash`（通用工具库）
- 开发依赖：`nodemon`（热更新）、`mocha`（测试）、`pkg`（打包）

```bash
# 1. 安装生产依赖（自动写入 dependencies）
npm install lodash

# 2. 安装开发依赖（-D = --save-dev，自动写入 devDependencies）
npm install -D nodemon mocha pkg

# 3. 全局安装进程管理工具（服务器部署用）
npm install -g pm2
```

安装完成后，`package.json` 会自动更新依赖列表，同时生成 **`package-lock.json`**：
> ✅ 作用：**锁定依赖包的精确版本**，保证团队/服务器安装的依赖完全一致，避免版本冲突。

### 3. 常用包管理命令
```bash
# 卸载包
npm uninstall lodash          # 卸载生产依赖
npm uninstall -D nodemon      # 卸载开发依赖
npm uninstall -g pm2          # 卸载全局包

# 更新包
npm update lodash             # 更新指定包
npm update                    # 更新所有可更新的包

# 查看已安装的包
npm list --depth=0            # 查看项目本地包（层级0）
npm list -g --depth=0         # 查看全局包

# 查看包的信息
npm view lodash versions      # 查看lodash所有版本
```

---

## 四、项目开发与调试
### 1. 编写项目代码
创建源码目录 `src/index.js`，编写字符串工具核心代码：
```javascript
// src/index.js
const _ = require('lodash');

// 1. 字符串转大写
const toUpper = (str) => {
  if (!str) return '';
  return _.toUpper(str);
};

// 2. 去除字符串所有空格
const trimAll = (str) => {
  if (!str) return '';
  return str.replace(/\s/g, '');
};

// 3. 导出方法
module.exports = {
  toUpper,
  trimAll
};

// 本地测试运行
if (require.main === module) {
  console.log(toUpper('hello npm'));
  console.log(trimAll(' 我 爱 编 程 '));
}
```

### 2. 自定义 npm scripts（核心！）
`package.json` 的 `scripts` 字段可以**自定义快捷命令**，替代冗长的终端命令。

修改 `package.json` 的 scripts：
```json
"scripts": {
  "start": "node src/index.js",   // 正式启动项目
  "dev": "nodemon src/index.js",  // 开发热启动（修改代码自动重启）
  "test": "mocha"                 // 测试命令（后面用）
}
```

### 3. 运行项目
```bash
# 正式启动（node原生启动）
npm start

# 开发模式（nodemon热更新，修改代码自动刷新）
npm run dev
```

### 4. Node.js 调试
npm支持Node原生调试，结合Chrome浏览器可视化调试：
```bash
# 开启调试模式
node --inspect src/index.js
```
打开Chrome → 地址栏输入 `chrome://inspect` → 点击 `Configure` → 添加 `localhost:9229`，即可断点调试代码。

---

## 五、项目自动化测试
我们用 `mocha`（测试框架）+ Node原生断言做单元测试。

### 1. 创建测试文件
新建 `test/index.test.js`：
```javascript
const { expect } = require('chai'); // 断言库（后面安装）
const { toUpper, trimAll } = require('../src/index');

// 测试用例
describe('字符串工具测试', () => {
  it('转大写：hello → HELLO', () => {
    expect(toUpper('hello')).to.equal('HELLO');
  });

  it('去空格：" 我 爱 " → "我爱"', () => {
    expect(trimAll(' 我 爱 ')).to.equal('我爱');
  });
});
```

### 2. 安装断言依赖
```bash
npm install -D chai
```

### 3. 执行测试
```bash
npm run test
```
终端会输出测试结果：✅ 成功 / ❌ 失败。

---

## 六、项目打包
npm可以将Node项目**打包为独立可执行文件**（无需安装Node环境即可运行），我们用 `pkg` 工具打包。

### 1. 配置打包脚本
修改 `package.json` 的 scripts：
```json
"scripts": {
  "build": "pkg src/index.js -t node16-win,node16-linux,node16-macos"
}
```
- `-t`：指定打包的平台（Windows/Linux/Mac）
- `node16`：指定Node版本

### 2. 执行打包
```bash
npm run build
```
打包完成后，项目根目录会生成3个可执行文件：
- `index-win.exe`（Windows）
- `index-linux`（Linux）
- `index-macos`（Mac）

直接双击即可运行，**无需安装Node.js**。

---

## 七、项目部署（服务器上线）
以**Linux云服务器**为例，部署Node项目核心：**安装依赖 → 守护进程（后台运行）**。

### 1. 上传项目到服务器
用FTP/SSH将项目代码上传到服务器（如 `/root/npm-string-utils`）。

### 2. 生产环境安装依赖
```bash
# 进入项目目录
cd /root/npm-string-utils
# 只安装 生产依赖（跳过开发依赖，更快更小）
npm install --production
```

### 3. PM2 守护进程（必备）
PM2是Node.js生产环境必备的进程管理工具，支持**后台运行、日志查看、自动重启、负载均衡**。

```bash
# 1. 启动项目（后台运行）
pm2 start src/index.js --name string-utils

# 2. 常用PM2命令
pm2 list                # 查看所有运行的进程
pm2 logs string-utils   # 查看项目日志
pm2 restart string-utils# 重启项目
pm2 stop string-utils   # 停止项目
pm2 delete string-utils # 删除进程
```

启动后，项目会**永久后台运行**，即使关闭终端也不会停止。

---

## 八、发布npm公共包（让全球开发者使用）
我们可以将自己的字符串工具**发布到npm官方仓库**，任何人都可以通过 `npm install` 安装使用。

### 1. 前置准备
1. 注册npm账号：[npm官网注册](https://www.npmjs.com/signup)
2. **切回npm官方源**（必须！镜像源无法发布）：
```bash
npm config set registry https://registry.npmjs.org/
```

### 2. 完善 package.json
发布前必须完善配置，否则无法发布：
```json
{
  "name": "npm-string-utils-demo",  // 唯一包名（不能和现有包重名）
  "version": "1.0.0",               // 版本号（更新时必须修改）
  "main": "src/index.js",           // 包入口文件
  "description": "一个简单的字符串处理工具", // 描述
  "keywords": ["string", "utils"],  // 搜索关键词
  "author": "你的名字",
  "license": "ISC"
}
```

### 3. 发布流程
```bash
# 1. 本地登录npm（输入账号、密码、邮箱）
npm login

# 2. 发布包（首次发布）
npm publish

# 3. 更新包（修改代码后，必须升级version，再执行）
npm version patch  // 补丁版升级：1.0.0 → 1.0.1
npm publish

# 4. 撤销发布（24小时内可撤销，谨慎使用）
npm unpublish npm-string-utils-demo --force
```

### 4. 使用发布的包
发布成功后，全球开发者都可以安装使用：
```bash
npm install npm-string-utils-demo
```

---

## 九、npm 常用命令速查表
| 命令 | 作用 |
|------|------|
| `npm init -y` | 快速初始化项目 |
| `npm install 包名` | 安装生产依赖 |
| `npm install -D 包名` | 安装开发依赖 |
| `npm install -g 包名` | 全局安装 |
| `npm run 脚本名` | 执行自定义脚本 |
| `npm start` | 执行start脚本 |
| `npm update` | 更新依赖 |
| `npm publish` | 发布npm包 |

---

## 十、常见问题解决方案
1. **下载依赖失败**：切换国内镜像
2. **全局包权限不足**：Linux/Mac 加 `sudo`，Windows 用管理员终端
3. **发布包失败**：检查包名重复、切回官方源、邮箱验证
4. **依赖版本冲突**：删除 `node_modules` 和 `package-lock.json`，重新 `npm install`

---

### 总结
1. **npm核心**：`package.json` 是项目灵魂，`scripts` 自定义命令，`package-lock.json` 锁定版本
2. **依赖分类**：生产依赖（运行必需）、开发依赖（仅开发用）、全局依赖（系统工具）
3. **全流程**：初始化 → 装依赖 → 开发调试 → 测试 → 打包 → 部署 → 发布
4. **生产必备**：PM2 守护进程，保证项目稳定运行

按照这个流程，你可以完成**任何Node.js项目**的开发、管理与发布，是前端/Node后端开发的必备技能！