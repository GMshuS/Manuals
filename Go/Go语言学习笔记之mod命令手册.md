# Go Modules 完整手册

## 目录
- [一、核心概念](#一核心概念)
- [二、go.mod 文件详解](#二gomod-文件详解)
- [三、核心命令](#三核心命令)
- [四、依赖管理](#四依赖管理)
- [五、replace 使用指南](#五replace-使用指南)
- [六、vendor 使用指南](#六vendor-使用指南)
- [七、实战流程](#七实战流程)
- [八、完整项目实例](#八完整项目实例)
- [九、常见问题与最佳实践](#九常见问题与最佳实践)

---

## 一、核心概念

### 1.1 什么是 Module
- **模块（Module）**：一个带 `go.mod` 的目录，是 Go 依赖管理的**最小单元**。
- 模块路径：如 `github.com/gin-gonic/gin`，全局唯一，用于导入和版本控制。
- 语义化版本：`v主.次.修订`（如 `v1.9.1`），主版本不同视为不兼容。

### 1.2 解决 GOPATH 痛点
- ✅ 项目可放在**任意目录**，不再强制 `GOPATH/src`。
- ✅ 依赖**按项目隔离**，不同项目可使用不同版本。
- ✅ 版本锁定 + 可重现构建（`go.sum` 校验）。

### 1.3 GO111MODULE 环境变量
```bash
# 查看当前状态
go env GO111MODULE

# 三种模式
off   # 禁用模块，走 GOPATH
on    # 强制启用模块（推荐）
auto  # 默认：有 go.mod 用模块，否则 GOPATH
```
> Go 1.13+ 默认 `auto`，**建议直接设为 on**。

---

## 二、go.mod 文件详解

### 2.1 基础结构
```go
// 模块路径（唯一标识）
module github.com/yourname/yourproject

// 最低支持的 Go 版本
go 1.21

// 依赖声明（直接依赖）
require (
    github.com/gin-gonic/gin v1.9.1
    gorm.io/gorm v1.25.4
)

// 替换依赖（本地调试/私有源）
replace github.com/gin-gonic/gin => ../gin v1.9.1

// 排除依赖（禁止使用某版本）
exclude github.com/go-playground/validator/v10 v10.15.0
```

### 2.2 四大指令
1. **module**：定义模块路径，**唯一且必须第一行**。
2. **require**：声明依赖及版本，`indirect` 表示间接依赖。
3. **replace**：替换依赖来源（本地目录/私有仓库），**高频用于本地调试**。
4. **exclude**：排除特定版本（规避 bug 版本）。

### 2.3 go.sum 文件
- 记录**所有依赖（含间接）的哈希值**，确保构建一致性。
- 不要手动修改，由 `go mod tidy` 或 `go get` 维护。

---

## 三、核心命令

### 3.1 初始化模块
```bash
# 新建项目
mkdir myproject && cd myproject

# 初始化（模块路径建议用远程仓库名）
go mod init github.com/yourname/myproject

# 生成 go.mod
cat go.mod
```

### 3.2 日常开发常用命令
```bash
# 1. 自动整理依赖（增删+清理+更新 go.mod/go.sum）
# 写完代码 import 后必执行
go mod tidy

# 2. 下载所有依赖到本地缓存（$GOPATH/pkg/mod）
go mod download

# 3. 本地调试：替换远程依赖为本地目录
# 方式1：命令行（临时）
go mod edit -replace=github.com/gin-gonic/gin=../gin

# 方式2：直接改 go.mod（永久）
# replace github.com/gin-gonic/gin => ../gin v1.9.1

# 4. 生成 vendor 目录（离线构建）
go mod vendor

# 5. 查看依赖树
go mod graph

# 6. 查看依赖为何被引入
go mod why github.com/gin-gonic/gin

# 7. 验证依赖完整性（是否被篡改）
go mod verify
```

### 3.3 版本管理
```bash
# 获取指定版本
go get github.com/gin-gonic/gin@v1.9.1

# 获取最新版本
go get github.com/gin-gonic/gin@latest

# 升级所有依赖到最新兼容版本
go get -u ./...

# 降级到某版本
go get github.com/gin-gonic/gin@v1.8.2
```

### 3.4 最常用命令总结（背这 3 个就够）
```bash
go mod init 项目名    # 初始化
go get 依赖名         # 添加依赖
go mod tidy           # 整理、清理、下载所有依赖
```

---

## 四、依赖管理

### 4.1 添加依赖（3种方法）

#### 方法1：写代码 import → 自动添加（最常用）
这是开发中**最推荐**的方式：

1. 直接在代码里写 import
```go
import (
    "github.com/gin-gonic/gin"
)
```

2. 执行命令（自动下载 + 写入 go.mod）
```bash
go mod tidy
```

✅ 效果：
- 自动把依赖写入 `go.mod`
- 自动生成/更新 `go.sum`
- 自动处理版本

#### 方法2：用 go get 直接安装（手动指定）
```bash
# 安装最新版
go get github.com/gin-gonic/gin

# 安装指定版本
go get github.com/gin-gonic/gin@v1.9.1
```

#### 方法3：直接编辑 go.mod（不推荐，但能用）
打开 `go.mod`，手动加一行：
```go
require github.com/gin-gonic/gin v1.9.1
```
然后执行：
```bash
go mod tidy
```

### 4.2 删除依赖

#### 核心方法（99% 场景用这个）
1. 先把代码里的 `import` 删掉
```go
// 把这行删掉
import "github.com/gin-gonic/gin"
```

2. 执行一键清理命令
```bash
go mod tidy
```
✅ 完成！
- 自动从 `go.mod` 中移除无用依赖
- 自动更新 `go.sum`
- 不会删错、不会残留

#### 强制删除（不删代码也能移除）
```bash
go get 依赖路径@none
# 例如：
go get github.com/gin-gonic/gin@none
```
然后再执行：
```bash
go mod tidy
```

#### 错误做法（千万别做）
❌ 直接打开 go.mod 手动删一行，容易导致依赖错乱、编译报错。

### 4.3 升级/降级依赖版本

#### 升级依赖
```bash
# 升级到最新版
go get github.com/gin-gonic/gin@latest

# 升级到指定版本
go get github.com/gin-gonic/gin@v1.9.1

# 升级项目里所有依赖到最新
go get -u ./...
```

#### 降级依赖
```bash
go get github.com/gin-gonic/gin@v1.8.2
```

#### 查看可用版本
```bash
go list -m -versions github.com/gin-gonic/gin
```

#### 操作完必做
```bash
go mod tidy  # 同步 go.mod 和 go.sum
```

### 4.4 固定依赖版本（锁死）

#### 固定到指定版本
```bash
go get github.com/gin-gonic/gin@v1.9.1
```
执行完后，`go.mod` 里就会写死版本号，只要不手动改，它永远不变。

#### 防止意外升级
❌ 危险命令（会升级所有依赖）：
```bash
go get -u ./...
```

✅ 安全做法：只升级你想升级的依赖
```bash
go get github.com/xxx/xxx@指定版本
```

### 4.5 查看当前依赖
```bash
# 查看所有依赖
go list -m all

# 查看特定依赖
go list -m github.com/gin-gonic/gin
```

---

## 五、replace 使用指南

### 5.1 replace 的作用
**把 A 依赖，强制替换成 B 来源**（本地目录、其他仓库、指定版本）。

最常用场景：
1. **本地调试依赖包**（改别人源码、本地开发）
2. 依赖包下载失败，替换成国内镜像
3. 私有仓库依赖无法拉取
4. 依赖包有 bug，临时替换成修复版

### 5.2 两种写法

#### 写法1：直接写在 go.mod 里（推荐）
```go
// 格式
replace 原依赖路径 => 替换来源 版本

// 例子：把 gin 换成本地目录
replace github.com/gin-gonic/gin => ../gin v1.9.1
```

#### 写法2：命令行添加（自动写入 go.mod）
```bash
go mod edit -replace=github.com/gin-gonic/gin=../gin
```

### 5.3 常用实战场景

#### 场景1：本地调试依赖（最常用）
```bash
# 1. 把依赖克隆到本地
git clone https://github.com/gin-gonic/gin.git ../gin

# 2. 在 go.mod 添加 replace
replace github.com/gin-gonic/gin => ../gin

# 3. 刷新依赖
go mod tidy
```

#### 场景2：替换成另一个 GitHub 仓库
```go
replace github.com/old/author/pkg => github.com/your/fork/pkg v1.2.0
```

#### 场景3：解决依赖下载失败
```go
replace golang.org/x/net => github.com/golang/net latest
```

#### 场景4：指定固定版本（强制锁定）
```go
replace github.com/gin-gonic/gin => github.com/gin-gonic/gin v1.8.2
```

### 5.4 replace 规则
1. **replace 优先级最高**，一旦设置，go mod 会忽略原依赖地址。
2. 版本号可以省略：`replace github.com/gin-gonic/gin => ../gin`
3. **只对当前项目生效**，不会影响其他项目。
4. 提交代码时**建议注释掉 replace**，否则别人拉代码会找不到你的本地路径。

### 5.5 删除 replace
```bash
# 方法1：命令行（推荐）
go mod edit -dropreplace=github.com/gin-gonic/gin

# 方法2：手动删除 go.mod 里那一行 replace
# 然后执行：
go mod tidy
```

---

## 六、vendor 使用指南

### 6.1 vendor 是什么
`go mod vendor` 命令会：
1. 在项目根目录**生成一个 `vendor/` 文件夹**
2. 把**当前项目所有依赖的源代码**全部复制进去
3. 以后构建时，**优先使用 vendor 里的代码，不联网下载**

一句话总结：**vendor = 把所有依赖打包进项目里，离线可用、版本锁死。**

### 6.2 5大使用场景

#### 场景1：离线环境 / 无外网服务器构建
```bash
# 本地生成依赖包
go mod vendor

# 上传代码到服务器，直接构建（不联网）
go build -mod=vendor
```

#### 场景2：保证团队所有人依赖版本完全一致

#### 场景3：生产环境稳定构建，防止依赖突然失效

#### 场景4：CI/CD 自动化构建加速

#### 场景5：不想用 Go 模块缓存，希望完全可控

### 6.3 使用方法
```bash
# 1. 生成 vendor
go mod vendor

# 2. 使用 vendor 运行/编译
go run -mod=vendor main.go
go build -mod=vendor -o app
go test -mod=vendor ./...

# 3. 更新 vendor
go get github.com/gin-gonic/gin@v1.9.1
go mod tidy
go mod vendor  # 重新覆盖
```

### 6.4 什么时候不建议使用 vendor
1. **本地开发调试**（没必要，占空间、慢）
2. 项目很大，依赖特别多（vendor 会让项目体积暴增）
3. 团队都有外网、依赖稳定（不需要离线）

### 6.5 关键知识点
1. **vendor 优先级最高**，加 `-mod=vendor` 会完全忽略网络和缓存。
2. **go mod tidy 不会删除 vendor**，要更新必须重新执行 `go mod vendor`。
3. **git 要不要提交 vendor？**
   - 要离线/生产稳定 → **提交**
   - 正常开发 → **不提交**（放 .gitignore）

---

## 七、实战流程

### 7.1 新建项目
```bash
mkdir hello-mod && cd hello-mod
go mod init github.com/yourname/hello-mod
```

### 7.2 写代码并引入依赖
```go
// main.go
package main

import (
    "github.com/gin-gonic/gin"
)

func main() {
    r := gin.Default()
    r.GET("/ping", func(c *gin.Context) {
        c.JSON(200, gin.H{"message": "pong"})
    })
    r.Run()
}
```

### 7.3 整理依赖
```bash
# 自动下载 gin 并更新 go.mod/go.sum
go mod tidy

# 运行
go run main.go
```

### 7.4 本地调试依赖
```bash
# 1. 克隆 gin 到本地
git clone https://github.com/gin-gonic/gin.git ../gin

# 2. 在当前项目 go.mod 添加 replace
replace github.com/gin-gonic/gin => ../gin v1.9.1

# 3. 重新整理依赖
go mod tidy

# 4. 运行（使用本地 gin）
go run main.go
```

---

## 八、完整项目实例

### 实例一：基础工具库（单包 + 本地调试）

#### 目录结构
```
workspace/
├── stringutils/          # 工具库模块
│   ├── go.mod
│   ├── stringutils.go
│   └── stringutils_test.go
└── myapp/                # 应用模块
    ├── go.mod
    └── main.go
```

#### 创建工具库 stringutils
```go
// stringutils/go.mod
module github.com/yourname/stringutils

go 1.21
```

```go
// stringutils/stringutils.go
package stringutils

// Reverse 反转字符串
func Reverse(s string) string {
    r := []rune(s)
    for i, j := 0, len(r)-1; i < len(r)/2; i, j = i+1, j-1 {
        r[i], r[j] = r[j], r[i]
    }
    return string(r)
}
```

#### 创建应用 myapp
```go
// myapp/go.mod
module github.com/yourname/myapp

go 1.21

require github.com/yourname/stringutils v0.0.0

replace github.com/yourname/stringutils => ../stringutils
```

```go
// myapp/main.go
package main

import (
    "fmt"
    "github.com/yourname/stringutils"
)

func main() {
    s := "Go Modules"
    fmt.Printf("Original: %s\n", s)
    fmt.Printf("Reversed: %s\n", stringutils.Reverse(s))
}
```

#### 运行
```bash
cd workspace/myapp
go run main.go
# 输出：
# Original: Go Modules
# Reversed: seludoM oG
```

### 实例二：Web 服务（多包 + 第三方依赖）

#### 目录结构
```
taskmanager/                    # 模块根
├── cmd/
│   └── server/
│       └── main.go             # 程序入口
├── internal/
│   ├── handler/
│   │   └── task.go             # HTTP 处理器
│   ├── model/
│   │   └── task.go             # 数据模型
│   └── service/
│       └── task.go             # 业务逻辑
├── pkg/
│   └── logger/
│       └── logger.go           # 可复用的日志包
├── api/
│   └── openapi.yaml            # API 文档
├── configs/
│   └── config.yaml             # 配置文件
├── go.mod
├── go.sum
└── Makefile
```

#### 初始化模块
```bash
mkdir taskmanager && cd taskmanager
go mod init github.com/yourname/taskmanager
```

#### 添加第三方依赖
```bash
go get github.com/gin-gonic/gin@latest
go get github.com/sirupsen/logrus@latest
go get gopkg.in/yaml.v3@latest
```

#### 核心代码
```go
// internal/model/task.go
package model

import "time"

type Task struct {
    ID          uint      `json:"id"`
    Title       string    `json:"title" binding:"required"`
    Description string    `json:"description"`
    Status      string    `json:"status"`
    CreatedAt   time.Time `json:"created_at"`
}
```

```go
// internal/service/task.go
package service

import (
    "errors"
    "sync"
    "time"
    "github.com/yourname/taskmanager/internal/model"
)

type TaskService struct {
    mu     sync.RWMutex
    tasks  map[uint]model.Task
    nextID uint
}

func NewTaskService() *TaskService {
    return &TaskService{
        tasks:  make(map[uint]model.Task),
        nextID: 1,
    }
}

func (s *TaskService) Create(title, desc string) model.Task {
    s.mu.Lock()
    defer s.mu.Unlock()
    
    task := model.Task{
        ID:          s.nextID,
        Title:       title,
        Description: desc,
        Status:      "pending",
        CreatedAt:   time.Now(),
    }
    s.tasks[s.nextID] = task
    s.nextID++
    return task
}

func (s *TaskService) Get(id uint) (model.Task, error) {
    s.mu.RLock()
    defer s.mu.RUnlock()
    
    task, ok := s.tasks[id]
    if !ok {
        return model.Task{}, errors.New("task not found")
    }
    return task, nil
}

func (s *TaskService) List() []model.Task {
    s.mu.RLock()
    defer s.mu.RUnlock()
    
    result := make([]model.Task, 0, len(s.tasks))
    for _, t := range s.tasks {
        result = append(result, t)
    }
    return result
}
```

```go
// internal/handler/task.go
package handler

import (
    "net/http"
    "strconv"
    "github.com/gin-gonic/gin"
    "github.com/yourname/taskmanager/internal/model"
    "github.com/yourname/taskmanager/internal/service"
)

type TaskHandler struct {
    svc *service.TaskService
}

func NewTaskHandler(svc *service.TaskService) *TaskHandler {
    return &TaskHandler{svc: svc}
}

func (h *TaskHandler) RegisterRoutes(r *gin.Engine) {
    api := r.Group("/api/v1/tasks")
    {
        api.POST("", h.Create)
        api.GET("", h.List)
        api.GET("/:id", h.Get)
    }
}

func (h *TaskHandler) Create(c *gin.Context) {
    var req model.Task
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }
    task := h.svc.Create(req.Title, req.Description)
    c.JSON(http.StatusCreated, task)
}

func (h *TaskHandler) List(c *gin.Context) {
    tasks := h.svc.List()
    c.JSON(http.StatusOK, tasks)
}

func (h *TaskHandler) Get(c *gin.Context) {
    id, err := strconv.ParseUint(c.Param("id"), 10, 32)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
        return
    }
    task, err := h.svc.Get(uint(id))
    if err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
        return
    }
    c.JSON(http.StatusOK, task)
}
```

```go
// pkg/logger/logger.go
package logger

import "github.com/sirupsen/logrus"

var Log = logrus.New()

func init() {
    Log.SetFormatter(&logrus.JSONFormatter{})
    Log.SetLevel(logrus.InfoLevel)
}
```

```go
// cmd/server/main.go
package main

import (
    "github.com/gin-gonic/gin"
    "github.com/yourname/taskmanager/internal/handler"
    "github.com/yourname/taskmanager/internal/service"
    "github.com/yourname/taskmanager/pkg/logger"
)

func main() {
    logger.Log.Info("Starting Task Manager Server...")
    
    r := gin.Default()
    
    taskSvc := service.NewTaskService()
    taskHandler := handler.NewTaskHandler(taskSvc)
    taskHandler.RegisterRoutes(r)
    
    logger.Log.Info("Server listening on :8080")
    if err := r.Run(":8080"); err != nil {
        logger.Log.Fatal(err)
    }
}
```

### 实例三：多模块协作（工作区模式）

#### 目录结构
```
workspace/
├── go.work                     # 工作区文件
├── shared-lib/                 # 共享库模块
│   ├── go.mod
│   └── utils/
│       └── utils.go
├── api-service/                # API 服务模块
│   ├── go.mod
│   └── main.go
└── worker-service/             # 后台服务模块
    ├── go.mod
    └── main.go
```

#### 创建共享库
```bash
mkdir shared-lib && cd shared-lib
go mod init github.com/yourname/shared-lib
```

```go
// shared-lib/utils/utils.go
package utils

import "time"

func FormatTime(t time.Time) string {
    return t.Format("2006-01-02 15:04:05")
}

func Retry(attempts int, fn func() error) error {
    var err error
    for i := 0; i < attempts; i++ {
        if err = fn(); err == nil {
            return nil
        }
        time.Sleep(time.Second * time.Duration(i+1))
    }
    return err
}
```

#### 创建 API 服务
```bash
mkdir api-service && cd api-service
go mod init github.com/yourname/api-service
go get github.com/gin-gonic/gin@latest
```

```go
// api-service/main.go
package main

import (
    "time"
    "github.com/gin-gonic/gin"
    "github.com/yourname/shared-lib/utils"
)

func main() {
    r := gin.Default()
    
    r.GET("/time", func(c *gin.Context) {
        c.JSON(200, gin.H{
            "time": utils.FormatTime(time.Now()),
        })
    })
    
    r.Run(":8080")
}
```

#### 创建工作区
```bash
cd workspace
go work init ./shared-lib ./api-service ./worker-service
```

生成的 `go.work`：
```go
go 1.21

use (
    ./api-service
    ./shared-lib
    ./worker-service
)
```

#### 各服务 go.mod（无需 replace）
```go
// api-service/go.mod
module github.com/yourname/api-service

go 1.21

require (
    github.com/gin-gonic/gin v1.10.0
    github.com/yourname/shared-lib v0.0.0
)
```

#### 运行任意模块
```bash
# 在 workspace 根目录下
go run ./api-service
go run ./worker-service
```

#### 生产构建
```bash
# 发布共享库
cd shared-lib
git tag v1.0.0
git push origin v1.0.0

# 更新服务依赖到真实版本
cd ../api-service
go get github.com/yourname/shared-lib@v1.0.0

# 生产构建（禁用工作区）
go build -workfile=off ./...
```

### 项目结构速查表

| 目录 | 用途 | 外部可导入 |
|------|------|------------|
| `cmd/` | 可执行程序入口 | ❌ |
| `internal/` | 内部实现，业务逻辑 | ❌（Go 编译器强制保护） |
| `pkg/` | 可复用的公共库 | ✅ |
| `api/` | API 定义、协议文件 | ✅ |
| `configs/` | 配置文件模板 | ❌ |
| `deployments/` | 部署脚本、Dockerfile | ❌ |
| `scripts/` | 构建、测试脚本 | ❌ |

### 完整 Makefile 参考
```makefile
GOCMD=go
GOBUILD=$(GOCMD) build
GOTEST=$(GOCMD) test
BINARY_NAME=server

.PHONY: all build test run clean tidy lint

all: build

build:
	$(GOBUILD) -o bin/$(BINARY_NAME) ./cmd/server

test:
	$(GOTEST) -v -race ./...

run:
	$(GOCMD) run ./cmd/server

clean:
	rm -rf bin/
	$(GOCMD) clean -cache

tidy:
	$(GOCMD) mod tidy
	$(GOCMD) mod verify

lint:
	golangci-lint run ./...

# 生成 vendor（离线编译）
vendor:
	$(GOCMD) mod vendor
```

---

## 九、常见问题与最佳实践

### 9.1 依赖下载慢/失败
**设置 GOPROXY**（国内必配）：
```bash
# 临时生效
export GOPROXY=https://goproxy.cn,direct

# 永久生效（Linux/Mac）
echo "export GOPROXY=https://goproxy.cn,direct" >> ~/.zshrc
source ~/.zshrc

# Windows
go env -w GOPROXY=https://goproxy.cn,direct
```

### 9.2 私有仓库依赖
```bash
# 配置 SSH 密钥后，用 go get
go get gitlab.com/yourname/private-lib

# 或在 go.mod 直接引用
require gitlab.com/yourname/private-lib v1.0.0
```

### 9.3 多模块工作区（Go 1.18+）
```bash
# 新建工作区
go work init ./mod1 ./mod2

# 工作区文件 go.work
use ./mod1
use ./mod2

# 统一构建
go build ./...
```

### 9.4 最佳实践
1. **始终提交 go.mod 和 go.sum** 到版本控制。
2. **使用语义化版本**，主版本升级（v2+）需在路径加 `/v2`：
```go
require github.com/yourname/yourlib/v2 v2.0.0
```
3. **避免手动修改 go.mod**，优先用 `go mod tidy` 和 `go get`。
4. **本地调试用 replace**，上线前注释或删除。
5. **不随意执行** `go get -u ./...`（会升级所有依赖）。
6. **生产环境锁死**：`go mod vendor` + `go build -mod=vendor`。

---

## 十、总结

- **go mod 是 Go 依赖管理的标准**，彻底告别 GOPATH。
- 核心是 **go.mod + go.sum**，四大指令管理依赖。
- 日常开发：`init` → `tidy` → `get` → `vendor`。
- 国内必配 **GOPROXY**，本地调试用 **replace**。
- 生产环境用 **vendor** 锁定依赖版本。

### 命令速查表

| 命令 | 说明 |
|------|------|
| `go mod init 项目名` | 初始化模块 |
| `go mod tidy` | 整理依赖（最常用） |
| `go get 包@版本` | 添加/升级/降级依赖 |
| `go get 包@latest` | 升级到最新版 |
| `go get 包@none` | 删除依赖 |
| `go mod download` | 下载所有依赖 |
| `go mod vendor` | 生成 vendor 目录 |
| `go mod verify` | 验证依赖完整性 |
| `go mod graph` | 查看依赖树 |
| `go mod edit -replace=包=路径` | 添加 replace |
| `go mod edit -dropreplace=包` | 删除 replace |
| `go list -m -versions 包` | 查看可用版本 |
| `go list -m all` | 查看所有依赖 |
| `go work init ./mod1 ./mod2` | 创建工作区 |
